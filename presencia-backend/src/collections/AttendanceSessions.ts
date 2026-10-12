import type { CollectionConfig } from 'payload'
import { filterSessions, isOrgAdmin } from '../access/roles'

export const AttendanceSessions: CollectionConfig = {
  slug: 'attendance-sessions',
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
      name: 'organization',
      type: 'relationship',
      relationTo: 'organizations',
      required: true,
      label: 'Organisation',
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
    // Seul un utilisateur connecté (org_admin ou group_leader) peut créer
    create: ({ req }) => Boolean(req?.user),
    update: isOrgAdmin,
    delete: isOrgAdmin,
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
