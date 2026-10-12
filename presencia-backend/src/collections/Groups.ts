import type { CollectionConfig } from 'payload'
import { filterGroups, isOrgAdmin } from '../access/roles'

export const Groups: CollectionConfig = {
  slug: 'groups',
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
    {
      name: 'organization',
      type: 'relationship',
      relationTo: 'organizations',
      required: true,
      label: 'Organisation',
    },
    {
      name: 'leader',
      type: 'relationship',
      relationTo: 'users',
      label: 'Responsable',
    },
  ],
  access: {
    read: filterGroups,
    create: isOrgAdmin,
    update: isOrgAdmin,
    delete: isOrgAdmin,
  },
  hooks: {
    // Supprimer un groupe supprime ses séances (et leurs présences
    // via le hook des séances) et détache membres + responsables.
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
        // Responsables : détacher ceux assignés à ce groupe.
        const linkedUsers = await req.payload.find({
          collection: 'users',
          where: { group: { equals: id } },
          limit: 2000,
          depth: 0,
          overrideAccess: true,
        })
        for (const doc of linkedUsers.docs) {
          await req.payload.update({
            collection: 'users',
            id: doc.id,
            data: { group: null },
            overrideAccess: true,
          })
        }
      },
    ],
  },
  versions: false,
}
