import type { CollectionConfig } from 'payload'
import { canCreateUser, canEditRole, filterByOrganization, isOrgAdmin } from '../access/roles'

export const Users: CollectionConfig = {
  slug: 'users',
  admin: {
    useAsTitle: 'email',
  },
  auth: true,
  fields: [
    {
      name: 'firstName',
      type: 'text',
      required: true,
      label: 'Prénom',
    },
    {
      name: 'lastName',
      type: 'text',
      required: true,
      label: 'Nom',
    },
    {
      name: 'phone',
      type: 'text',
      label: 'Téléphone',
    },
    {
      name: 'role',
      type: 'select',
      required: true,
      defaultValue: 'group_leader',
      label: 'Rôle',
      access: {
        update: canEditRole,
      },
      options: [
        { label: 'Super Admin (SaaS)', value: 'super_admin' },
        { label: "Admin d'organisation", value: 'org_admin' },
        { label: 'Responsable de groupe', value: 'group_leader' },
      ],
    },
    {
      name: 'organization',
      type: 'relationship',
      relationTo: 'organizations',
      required: true,
      label: 'Organisation',
    },
    {
      name: 'group',
      type: 'relationship',
      relationTo: 'groups',
      label: 'Groupe assigné (responsables)',
      admin: {
        description: 'Obligatoire si le rôle est Responsable de groupe.',
        condition: (data) => data?.role === 'group_leader',
      },
    },
  ],
  access: {
    read: filterByOrganization,
    create: canCreateUser,
    update: isOrgAdmin,
    delete: isOrgAdmin,
  },
  versions: false,
}
