import type { CollectionConfig } from 'payload'
import { canCreateSession, filterSessions } from '../access/roles'

export const AttendanceSessions: CollectionConfig = {
  slug: 'attendance-sessions',
  labels: { singular: 'Séance', plural: 'Séances' },
  admin: {
    useAsTitle: 'date',
  },
  fields: [
    {
      name: 'date',
      type: 'date',
      required: true,
      label: 'Date de la séance',
    },
    {
      name: 'group',
      type: 'relationship',
      relationTo: 'groups',
      required: true,
      label: 'Groupe',
    },
    {
      name: 'leader',
      type: 'relationship',
      relationTo: 'users',
      required: true,
      label: 'Responsable (appel effectué par)',
    },
    {
      name: 'notes',
      type: 'textarea',
      label: 'Notes',
    },
    {
      name: 'isClosed',
      type: 'checkbox',
      defaultValue: false,
      label: 'Séance clôturée',
    },
  ],
  access: {
    read: filterSessions,
    // Tout utilisateur connecté (admin ou pasteur) peut créer une séance
    // pour faire l'appel de ses groupes, et modifier/supprimer les siennes.
    create: canCreateSession,
    update: filterSessions,
    delete: filterSessions,
  },
  hooks: {
    // Supprimer une séance supprime aussi ses présences (sinon FK NOT NULL).
    beforeDelete: [
      async ({ req, id }) => {
        const records = await req.payload.find({
          collection: 'attendance-records',
          where: { session: { equals: id } },
          limit: 5000,
          depth: 0,
          overrideAccess: true,
        })
        for (const record of records.docs) {
          await req.payload.delete({
            collection: 'attendance-records',
            id: record.id,
            overrideAccess: true,
          })
        }
      },
    ],
  },
  versions: false,
}
