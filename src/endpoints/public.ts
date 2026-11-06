import { createHash } from 'node:crypto'
import type { Endpoint, PayloadRequest } from 'payload'
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

/** Nom normalisé pour comparaison : minuscules, sans accents ni espaces en trop. */
const normName = (s: string): string =>
  s
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim()

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

/** Groupe actif correspondant à un jeton d'invitation, ou undefined. */
export async function findGroupByToken(
  req: Pick<PayloadRequest, 'payload'>,
  token: string,
): Promise<{ id: number; name: string } | undefined> {
  const t = token.trim()
  if (!/^[a-z0-9]{12}$/.test(t)) return undefined
  const res = await req.payload.find({
    collection: 'groups',
    where: { and: [{ inviteToken: { equals: t } }, { inviteEnabled: { not_equals: false } }] },
    limit: 1,
    depth: 0,
    overrideAccess: true,
  })
  const g = res.docs[0] as unknown as { id: number; name?: string } | undefined
  return g ? { id: g.id, name: g.name ?? '' } : undefined
}

/**
 * GET /api/public-groups?token=<jeton>
 * Public : renvoie uniquement le nom du groupe lié à un lien d'inscription
 * actif. Plus de liste publique des groupes.
 */
export const publicGroups: Endpoint = {
  path: '/public-groups',
  method: 'get',
  handler: async (req) => {
    const token = String(req.searchParams?.get('token') ?? '')
    const group = await findGroupByToken(req, token)
    if (!group) {
      return Response.json({ errors: [{ message: 'Lien d’inscription invalide.' }] }, { status: 404 })
    }
    return Response.json({ group: { name: group.name } })
  },
}

/** Limite : 5 inscriptions par adresse IP et par quart d'heure. */
const RATE_LIMIT = { max: 5, windowMs: 15 * 60 * 1000 }

function clientIpHash(req: PayloadRequest): string {
  const fwd = req.headers.get('x-forwarded-for') ?? ''
  const ip = fwd.split(',')[0]?.trim() || req.headers.get('x-real-ip') || 'inconnu'
  return createHash('sha256')
    .update(`${process.env.PAYLOAD_SECRET ?? ''}:${ip}`)
    .digest('hex')
}

/** true si l'IP a dépassé la limite ; sinon enregistre la tentative. */
async function rateLimited(req: PayloadRequest): Promise<boolean> {
  const ipHash = clientIpHash(req)
  const since = new Date(Date.now() - RATE_LIMIT.windowMs).toISOString()
  const recent = await req.payload.count({
    collection: 'registration-attempts',
    where: { and: [{ ipHash: { equals: ipHash } }, { createdAt: { greater_than: since } }] },
    overrideAccess: true,
  })
  if (recent.totalDocs >= RATE_LIMIT.max) return true
  await req.payload.create({
    collection: 'registration-attempts',
    data: { ipHash },
    overrideAccess: true,
  })
  // Ménage : tentatives de plus d'un jour.
  const old = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
  await req.payload.delete({
    collection: 'registration-attempts',
    where: { createdAt: { less_than: old } },
    overrideAccess: true,
  })
  return false
}

type RegisterBody = {
  firstName?: unknown
  lastName?: unknown
  phone?: unknown
  groupToken?: unknown
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

    if (await rateLimited(req)) {
      return Response.json(
        { errors: [{ message: 'Trop d’inscriptions depuis cette connexion. Réessaie dans un quart d’heure.' }] },
        { status: 429 },
      )
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

      const group = await findGroupByToken(req, String(body.groupToken ?? ''))
      if (!group) throw new Error('Lien d’inscription invalide ou désactivé. Demande le nouveau lien à ton responsable.')
      const groupIds = [group.id]

      const email = str(body.email, MAX.email, 'email')
      if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        throw new Error('Email invalide.')
      }
      const birthDate = reqStr(body.birthDate, 10, 'date de naissance')
      if (isNaN(Date.parse(birthDate))) throw new Error('Date de naissance invalide.')
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
        birthDate,
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

    // Anti-doublon : même téléphone ET même nom → la même personne se
    // réinscrit : on complète ses groupes et on la réactive. Un numéro
    // partagé (ado inscrit avec le téléphone d'un parent) crée bien un
    // nouveau membre.
    const existing = await req.payload.find({
      collection: 'members',
      where: { phone: { equals: data.phone } },
      limit: 20,
      depth: 0,
      overrideAccess: true,
    })
    type ExistingMember = {
      id: number
      firstName?: string
      lastName?: string
      groups?: Array<number | { id: number }>
    }
    const fn = normName(data.firstName)
    const ln = normName(data.lastName)
    const samePerson = (existing.docs as unknown as ExistingMember[]).find((doc) => {
      const f = normName(doc.firstName ?? '')
      const l = normName(doc.lastName ?? '')
      // Accepte aussi prénom/nom intervertis.
      return (f === fn && l === ln) || (f === ln && l === fn)
    })
    if (samePerson) {
      const current: number[] = (samePerson.groups ?? []).map((g) =>
        typeof g === 'object' && g !== null ? g.id : g,
      )
      for (const id of data.groupIds) {
        if (!current.includes(id)) current.push(id)
      }
      const updated = await req.payload.update({
        collection: 'members',
        id: samePerson.id,
        data: { groups: current, status: 'active' },
        overrideAccess: true,
      })
      return Response.json({ ok: true, created: false, alreadyRegistered: true, memberId: updated.id })
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
