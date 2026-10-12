import type { Endpoint } from 'payload'
import { isValidPhone, normalizePhone } from '../lib/phone'

const MAX = {
  firstName: 60,
  lastName: 60,
  phone: 25,
  email: 120,
  address: 200,
  parentName: 60,
  parentPhone: 25,
} as const

type ParentInput = {
  firstName?: string
  lastName?: string
  phone?: string
  relation?: 'father' | 'mother' | 'guardian' | 'other'
}

const RELATIONS = ['father', 'mother', 'guardian', 'other'] as const

/** Chaîne rognée limitée en longueur, ou erreur si trop longue. */
function str(value: unknown, max: number, field: string): string | undefined {
  if (value === undefined || value === null) return undefined
  const s = String(value).trim()
  if (s === '') return undefined
  if (s.length > max) throw new Error(`Champ trop long : ${field}.`)
  return s
}

function reqStr(value: unknown, max: number, field: string): string {
  const s = str(value, max, field)
  if (!s) throw new Error(`Champ requis : ${field}.`)
  return s
}

function parentInput(value: unknown): ParentInput | undefined {
  if (value === undefined || value === null || typeof value !== 'object') return undefined
  const p = value as Record<string, unknown>
  const firstName = str(p.firstName, MAX.parentName, 'parent.firstName')
  const lastName = str(p.lastName, MAX.parentName, 'parent.lastName')
  const phoneRaw = str(p.phone, MAX.parentPhone, 'parent.phone')
  const phone = phoneRaw ? normalizePhone(phoneRaw) : undefined
  if (phone && !isValidPhone(phone)) throw new Error('Téléphone parent invalide.')
  const relation = str(p.relation, 20, 'parent.relation')
  if (relation && !(RELATIONS as readonly string[]).includes(relation)) {
    throw new Error('Lien de parenté invalide.')
  }
  if (!firstName && !lastName && !phone) return undefined
  return {
    ...(firstName ? { firstName } : {}),
    ...(lastName ? { lastName } : {}),
    ...(phone ? { phone } : {}),
    ...(relation ? { relation: relation as ParentInput['relation'] } : {}),
  }
}

/**
 * GET /api/public-groups
 * Public : renvoie uniquement { name, slug } des groupes
 * (pour le formulaire d'inscription).
 */
export const publicGroups: Endpoint = {
  path: '/public-groups',
  method: 'get',
  handler: async (req) => {
    const res = await req.payload.find({
      collection: 'groups',
      limit: 100,
      sort: 'name',
      depth: 0,
      overrideAccess: true,
    })
    return Response.json({
      groups: res.docs.map((g) => ({
        name: (g as unknown as { name: string }).name,
        slug: (g as unknown as { slug?: string }).slug,
      })),
    })
  },
}

type RegisterBody = {
  firstName?: unknown
  lastName?: unknown
  phone?: unknown
  groupSlugs?: unknown
  email?: unknown
  birthDate?: unknown
  gender?: unknown
  address?: unknown
  parent1?: unknown
  parent2?: unknown
  /** Honeypot anti-robot : doit rester vide. */
  website?: unknown
}

/**
 * POST /api/register
 * Public : inscription d'un membre via le formulaire.
 * Si le téléphone existe déjà, ajoute simplement les groupes
 * (sans doublon). Rejette les robots (honeypot).
 */
export const register: Endpoint = {
  path: '/register',
  method: 'post',
  handler: async (req) => {
    let body: RegisterBody | undefined
    try {
      body = (await req.json?.()) as RegisterBody | undefined
    } catch {
      return Response.json({ errors: [{ message: 'Corps JSON invalide.' }] }, { status: 400 })
    }
    if (!body) {
      return Response.json({ errors: [{ message: 'Corps JSON invalide.' }] }, { status: 400 })
    }

    // Honeypot : un robot remplit ce champ invisible → rejet silencieux.
    if (body.website !== undefined && body.website !== null && String(body.website) !== '') {
      return Response.json({ errors: [{ message: "Inscription refusée." }] }, { status: 400 })
    }

    let data: {
      firstName: string
      lastName: string
      phone: string
      groupIds: number[]
      email?: string
      birthDate?: string
      gender?: 'male' | 'female'
      address?: string
      parent1?: ParentInput
      parent2?: ParentInput
    }
    try {
      const firstName = reqStr(body.firstName, MAX.firstName, 'prénom')
      const lastName = reqStr(body.lastName, MAX.lastName, 'nom')
      const phone = normalizePhone(reqStr(body.phone, MAX.phone, 'téléphone'))
      if (!isValidPhone(phone)) throw new Error('Téléphone invalide.')

      const rawSlugs = Array.isArray(body.groupSlugs) ? body.groupSlugs : []
      if (rawSlugs.length === 0) throw new Error('Choisis au moins un groupe.')
      if (rawSlugs.length > 10) throw new Error('Trop de groupes.')
      const slugs = rawSlugs.map((s) => {
        const slug = str(s, 60, 'groupe')
        if (!slug) throw new Error('Groupe invalide.')
        return slug
      })

      // Résout les slugs → ids (erreur si un slug est inconnu).
      const groupsRes = await req.payload.find({
        collection: 'groups',
        where: { slug: { in: slugs } },
        limit: slugs.length,
        depth: 0,
        overrideAccess: true,
      })
      const found = new Map(
        groupsRes.docs.map((g) => [
          (g as unknown as { slug?: string }).slug,
          g.id as number,
        ]),
      )
      const groupIds: number[] = []
      for (const slug of slugs) {
        const id = found.get(slug)
        if (id === undefined) throw new Error(`Groupe inconnu : ${slug}.`)
        if (!groupIds.includes(id)) groupIds.push(id)
      }

      const email = str(body.email, MAX.email, 'email')
      if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        throw new Error('Email invalide.')
      }
      const birthDate = str(body.birthDate, 10, 'date de naissance')
      if (birthDate && isNaN(Date.parse(birthDate))) throw new Error('Date de naissance invalide.')
      const gender = str(body.gender, 10, 'sexe')
      if (gender && gender !== 'male' && gender !== 'female') {
        throw new Error('Sexe invalide.')
      }
      const address = str(body.address, MAX.address, 'adresse')
      const parent1 = parentInput(body.parent1)
      const parent2 = parentInput(body.parent2)

      data = {
        firstName,
        lastName,
        phone,
        groupIds,
        ...(email ? { email } : {}),
        ...(birthDate ? { birthDate } : {}),
        ...(gender ? { gender: gender as 'male' | 'female' } : {}),
        ...(address ? { address } : {}),
        ...(parent1 ? { parent1 } : {}),
        ...(parent2 ? { parent2 } : {}),
      }
    } catch (err) {
      return Response.json(
        { errors: [{ message: err instanceof Error ? err.message : 'Données invalides.' }] },
        { status: 400 },
      )
    }

    // Anti-doublon : même téléphone → on complète les groupes existants.
    const existing = await req.payload.find({
      collection: 'members',
      where: { phone: { equals: data.phone } },
      limit: 1,
      depth: 0,
      overrideAccess: true,
    })
    if (existing.docs.length > 0) {
      const doc = existing.docs[0] as unknown as {
        id: number
        groups?: Array<number | { id: number }>
      }
      const current: number[] = (doc.groups ?? []).map((g) =>
        typeof g === 'object' && g !== null ? g.id : g,
      )
      for (const id of data.groupIds) {
        if (!current.includes(id)) current.push(id)
      }
      const updated = await req.payload.update({
        collection: 'members',
        id: doc.id,
        data: { groups: current },
        overrideAccess: true,
      })
      return Response.json({ ok: true, created: false, memberId: updated.id })
    }

    const created = await req.payload.create({
      collection: 'members',
      data: {
        firstName: data.firstName,
        lastName: data.lastName,
        phone: data.phone,
        groups: data.groupIds,
        ...(data.email ? { email: data.email } : {}),
        ...(data.birthDate ? { birthDate: data.birthDate } : {}),
        ...(data.gender ? { gender: data.gender } : {}),
        ...(data.address ? { address: data.address } : {}),
        ...(data.parent1 ? { parent1: data.parent1 } : {}),
        ...(data.parent2 ? { parent2: data.parent2 } : {}),
      },
      overrideAccess: true,
    })
    return Response.json({ ok: true, created: true, memberId: created.id })
  },
}
