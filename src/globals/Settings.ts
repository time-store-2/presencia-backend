import type { GlobalConfig } from 'payload'
import { isAdmin } from '../access/roles'

/**
 * Réglages globaux (un seul document, modifiable par l'admin
 * dans le dashboard : Contenu → Réglages).
 */
export const Settings: GlobalConfig = {
  slug: 'settings',
  label: 'Réglages',
  access: {
    read: ({ req }) => Boolean(req?.user),
    update: isAdmin,
  },
  fields: [
    {
      name: 'absenceMessage',
      type: 'textarea',
      label: "Modèle de message d'absence WhatsApp",
      defaultValue:
        'Bonjour {prenom}, tu as manqué la séance de {groupe} du {date}. Tu nous as manqué, à bientôt !',
      admin: {
        description: 'Variables : {prenom}, {nom}, {groupe}, {date}',
      },
    },
  ],
}
