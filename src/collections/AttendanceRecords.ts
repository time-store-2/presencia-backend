import type { CollectionConfig } from 'payload'
import { canCreateRecord, filterRecords } from '../access/roles'

export const AttendanceRecords: CollectionConfig = {
  slug: 'attendance-records',
  labels: { singular: 'Présence', plural: 'Présences' },
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
    // Admin : toutes les présences. Pasteur : celles des séances de ses groupes.
    read: filterRecords,
    create: canCreateRecord,
    update: filterRecords,
    delete: filterRecords,
  },
  versions: false,
}
