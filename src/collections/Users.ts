import type { CollectionConfig } from 'payload'
import { canEditRole, isAdmin } from '../access/roles'

export const Users: CollectionConfig = {
  slug: 'users',
  admin: {
    useAsTitle: 'displayName',
  },
  // email + password sont fournis par l'authentification Payload.
  // Le tout premier compte se crée via l'écran natif /admin
  // (Payload propose "créer le premier utilisateur" si aucun n'existe).
  // Session longue (1 an), prolongée par l'app à chaque ouverture :
  // on reste connecté tant qu'on ne se déconnecte pas soi-même.
  auth: {
    tokenExpiration: 60 * 60 * 24 * 365,
  },
  fields: [
    {
      name: 'displayName',
      type: 'text',
      required: true,
      label: 'Nom affiché',
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
      defaultValue: 'admin',
      label: 'Rôle',
      access: {
        update: canEditRole,
      },
      options: [
        { label: 'Admin (tout voir, tout modifier)', value: 'admin' },
        { label: 'Assistant (ses groupes uniquement)', value: 'assistant' },
      ],
    },
    {
      name: 'assignedGroups',
      type: 'relationship',
      relationTo: 'groups',
      hasMany: true,
      label: 'Groupes assignés (assistants)',
      admin: {
        description: 'Utilisé uniquement si le rôle est Assistant.',
        condition: (data) => data?.role === 'assistant',
      },
    },
  ],
  access: {
    read: isAdmin,
    create: isAdmin,
    update: isAdmin,
    delete: isAdmin,
  },
  versions: false,
}
