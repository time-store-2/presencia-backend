import type { CollectionConfig } from 'payload'
import { isAdmin } from '../access/roles'

/**
 * Tentatives d'inscription publique (anti-abus) : une ligne par envoi,
 * avec l'empreinte (hash) de l'adresse IP — jamais l'IP en clair.
 * Purgées automatiquement après 24 h.
 */
export const RegistrationAttempts: CollectionConfig = {
  slug: 'registration-attempts',
  labels: { singular: 'Tentative d’inscription', plural: 'Tentatives d’inscription' },
  admin: { hidden: true },
  fields: [{ name: 'ipHash', type: 'text', required: true, index: true }],
  access: {
    read: isAdmin,
    create: () => false,
    update: () => false,
    delete: isAdmin,
  },
  versions: false,
}
