import type { CollectionConfig } from 'payload'
import { randomBytes } from 'node:crypto'
import { filterGroups, isLoggedIn } from '../access/roles'

/** "6ème A" → "6eme-a". Généré depuis le nom si le slug est vide. */
export function slugify(name: string): string {
  const slug = name
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 60)
  return slug || 'groupe'
}

const TOKEN_ALPHABET = 'abcdefghijkmnpqrstuvwxyz23456789'

/** Jeton d'invitation aléatoire de 12 caractères (non devinable). */
export function newInviteToken(): string {
  const bytes = randomBytes(12)
  let out = ''
  for (const b of bytes) out += TOKEN_ALPHABET[b % TOKEN_ALPHABET.length]
  return out
}

export const Groups: CollectionConfig = {
  slug: 'groups',
  labels: { singular: 'Groupe', plural: 'Groupes' },
  admin: {
    useAsTitle: 'name',
  },
  fields: [
    {
      name: 'name',
      type: 'text',
      required: true,
      label: 'Nom du groupe',
    },
    {
      name: 'slug',
      type: 'text',
      unique: true,
      label: 'Slug (lien inscription)',
      admin: {
        description: 'Généré automatiquement depuis le nom (identifiant interne).',
      },
    },
    {
      name: 'inviteToken',
      type: 'text',
      unique: true,
      index: true,
      label: 'Jeton du lien d’inscription',
      admin: {
        description:
          'Lien : /inscription?groupe=<jeton>. Videz ce champ et enregistrez pour générer un nouveau lien (l’ancien ne marchera plus).',
      },
    },
    {
      name: 'inviteEnabled',
      type: 'checkbox',
      defaultValue: true,
      label: 'Lien d’inscription actif',
    },
    {
      name: 'owner',
      type: 'relationship',
      relationTo: 'users',
      label: 'Créé par',
      admin: { readOnly: true, position: 'sidebar' },
    },
    {
      name: 'description',
      type: 'textarea',
      label: 'Description',
    },
    {
      name: 'color',
      type: 'text',
      label: 'Couleur (hex)',
      defaultValue: '#A13A15',
    },
    {
      name: 'meetingDay',
      type: 'text',
      label: 'Jour de réunion',
    },
    {
      name: 'meetingTime',
      type: 'text',
      label: 'Heure de réunion',
    },
  ],
  access: {
    // Admin : tout. Pasteur : crée ses groupes et ne voit/modifie que les siens.
    read: filterGroups,
    create: isLoggedIn,
    update: filterGroups,
    delete: filterGroups,
  },
  hooks: {
    // Génère le slug depuis le nom s'il est vide (modifiable ensuite),
    // en garantissant l'unicité (suffixe -2, -3...).
    beforeValidate: [
      async ({ req, data, originalDoc }) => {
        if (!data) return data
        const name = (data.name as string | undefined) ?? (originalDoc?.name as string | undefined)
        let slug = ((data.slug as string | undefined) ?? '').trim()
        if (!slug && name) slug = slugify(name)
        if (!slug) return data
        let candidate = slug
        let n = 2
        for (;;) {
          const existing = await req.payload.find({
            collection: 'groups',
            where: { slug: { equals: candidate } },
            limit: 2,
            depth: 0,
            overrideAccess: true,
          })
          const clash = existing.docs.some((d) => d.id !== originalDoc?.id)
          if (!clash) break
          candidate = `${slug}-${n}`
          n += 1
        }
        return { ...data, slug: candidate }
      },
    ],
    // Jeton d'invitation : généré s'il est vide (création ou régénération).
    // Propriétaire : l'utilisateur qui crée le groupe.
    beforeChange: [
      ({ req, data, operation }) => {
        if (!data) return data
        const next = { ...data }
        const token = typeof next.inviteToken === 'string' ? next.inviteToken.trim() : ''
        if (operation === 'create' || 'inviteToken' in data) {
          if (!token) next.inviteToken = newInviteToken()
        }
        if (operation === 'create' && !next.owner && req.user) {
          next.owner = req.user.id
        }
        return next
      },
    ],
    // Supprimer un groupe supprime ses séances (et leurs présences
    // via le hook des séances) et détache membres + assistants.
    beforeDelete: [
      async ({ req, id }) => {
        const sessions = await req.payload.find({
          collection: 'attendance-sessions',
          where: { group: { equals: id } },
          limit: 1000,
          depth: 0,
          overrideAccess: true,
        })
        for (const session of sessions.docs) {
          await req.payload.delete({
            collection: 'attendance-sessions',
            id: session.id,
            overrideAccess: true,
          })
        }
        // Membres : retirer le groupe supprimé de leur liste.
        const linkedMembers = await req.payload.find({
          collection: 'members',
          where: { groups: { in: [id] } },
          limit: 2000,
          depth: 0,
          overrideAccess: true,
        })
        for (const doc of linkedMembers.docs) {
          const member = doc as unknown as { groups?: Array<number | { id: number }> }
          const remaining: number[] = []
          for (const g of member.groups ?? []) {
            const gid = typeof g === 'object' && g !== null ? g.id : g
            if (gid !== id) remaining.push(gid)
          }
          await req.payload.update({
            collection: 'members',
            id: doc.id,
            data: { groups: remaining },
            overrideAccess: true,
          })
        }
        // Pasteurs : retirer le groupe supprimé de leurs groupes assignés.
        const linkedUsers = await req.payload.find({
          collection: 'users',
          where: { assignedGroups: { in: [id] } },
          limit: 2000,
          depth: 0,
          overrideAccess: true,
        })
        for (const doc of linkedUsers.docs) {
          const user = doc as unknown as { assignedGroups?: Array<number | { id: number }> }
          const remaining: number[] = []
          for (const g of user.assignedGroups ?? []) {
            const gid = typeof g === 'object' && g !== null ? g.id : g
            if (gid !== id) remaining.push(gid)
          }
          await req.payload.update({
            collection: 'users',
            id: doc.id,
            data: { assignedGroups: remaining },
            overrideAccess: true,
          })
        }
      },
    ],
  },
  versions: false,
}
