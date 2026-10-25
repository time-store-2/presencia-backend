import type { CollectionConfig } from 'payload'
import { filterGroups, isAdmin } from '../access/roles'

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
        description:
          'Généré automatiquement depuis le nom. Utilisé dans le lien : /inscription?groupe=<slug>',
      },
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
      defaultValue: '#2196F3',
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
    read: filterGroups,
    create: isAdmin,
    update: isAdmin,
    delete: isAdmin,
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
        // Assistants : retirer le groupe supprimé de leurs groupes assignés.
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
