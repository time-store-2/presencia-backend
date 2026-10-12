import type { CollectionConfig } from 'payload'
import { canCreateOrganization, filterOwnOrganization, isOrgAdmin } from '../access/roles'

export const Organizations: CollectionConfig = {
  slug: 'organizations',
  admin: {
    useAsTitle: 'name',
  },
  fields: [
    {
      name: 'name',
      type: 'text',
      required: true,
      label: "Nom de l'organisation",
    },
    {
      name: 'type',
      type: 'select',
      required: true,
      defaultValue: 'eglise',
      label: "Type d'organisation",
      options: [
        { label: 'Église', value: 'eglise' },
        { label: 'École', value: 'ecole' },
        { label: 'Entreprise', value: 'entreprise' },
        { label: 'Association', value: 'association' },
        { label: 'Autre', value: 'autre' },
      ],
    },
    {
      name: 'code',
      type: 'text',
      required: true,
      unique: true,
      label: 'Code unique (lien inscription)',
      admin: {
        description: 'Ex : ORG-ABIDJAN-001. Utilisé dans le lien : /inscription?org=ORG-ABIDJAN-001',
      },
    },
    {
      name: 'address',
      type: 'text',
      label: 'Adresse',
    },
    {
      name: 'phone',
      type: 'text',
      label: 'Téléphone',
    },
    {
      name: 'email',
      type: 'email',
      label: 'Email de contact',
    },
    {
      name: 'absenceMessage',
      type: 'textarea',
      label: "Modèle de message d'absence WhatsApp",
      defaultValue:
        "Bonjour {prenom}, comment vas-tu ? Pourquoi n'étais-tu pas à la séance de {groupe} d'aujourd'hui ? Tu nous as manqué ! - {responsable}",
      admin: {
        description: 'Variables : {prenom}, {nom}, {groupe}, {responsable}, {date}',
      },
    },
  ],
  access: {
    // Lecture : chaque org voit la sienne ; création : bootstrap puis admins
    read: filterOwnOrganization,
    create: canCreateOrganization,
    update: isOrgAdmin,
    delete: isOrgAdmin,
  },
  versions: false,
}
