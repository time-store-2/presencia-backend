import type { CollectionConfig } from 'payload'

export const AttendanceRecords: CollectionConfig = {
  slug: 'attendance-records',
  fields: [
    {
      name: 'session',
      type: 'relationship',
      relationTo: 'attendance-sessions',
      required: true,
      label: 'Séance',
    },
    {
      name: 'member',
      type: 'relationship',
      relationTo: 'members',
      required: true,
      label: 'Membre',
    },
    {
      name: 'status',
      type: 'select',
      required: true,
      defaultValue: 'present',
      label: 'Statut',
      options: [
        { label: 'Présent', value: 'present' },
        { label: 'Absent', value: 'absent' },
        { label: 'Retard', value: 'late' },
        { label: 'Excusé', value: 'excused' },
      ],
    },
    {
      name: 'note',
      type: 'text',
      label: 'Note',
    },
  ],
  access: {
    // Lecture réservée aux utilisateurs connectés
    // (le filtrage par groupe se fait côté API via la séance).
    read: ({ req }) => Boolean(req?.user),
    // Seul un utilisateur connecté peut enregistrer des présences
    create: ({ req }) => Boolean(req?.user),
    update: ({ req }) => Boolean(req?.user),
    delete: ({ req }) => (req?.user as any)?.role === 'admin',
  },
  versions: false,
}
