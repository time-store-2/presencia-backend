import type { CollectionConfig } from 'payload'
import { filterMembers, isAdmin } from '../access/roles'

export const Members: CollectionConfig = {
  slug: 'members',
  admin: {
    useAsTitle: 'lastName',
  },
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
      required: true,
      label: 'Téléphone',
    },
    {
      name: 'email',
      type: 'email',
      label: 'Email',
    },
    {
      name: 'gender',
      type: 'select',
      label: 'Sexe',
      options: [
        { label: 'Homme', value: 'male' },
        { label: 'Femme', value: 'female' },
      ],
    },
    {
      name: 'birthDate',
      type: 'date',
      label: 'Date de naissance',
    },
    {
      name: 'address',
      type: 'text',
      label: 'Adresse',
    },
    // Contacts parents/tuteurs (jusqu'à 2, ex : mineurs à l'église ou à l'école)
    {
      name: 'parent1',
      type: 'group',
      label: 'Parent / tuteur 1',
      fields: [
        { name: 'firstName', type: 'text', label: 'Prénom' },
        { name: 'lastName', type: 'text', label: 'Nom' },
        { name: 'phone', type: 'text', label: 'Téléphone' },
        {
          name: 'relation',
          type: 'select',
          label: 'Lien',
          options: [
            { label: 'Père', value: 'father' },
            { label: 'Mère', value: 'mother' },
            { label: 'Tuteur', value: 'guardian' },
            { label: 'Autre', value: 'other' },
          ],
        },
      ],
    },
    {
      name: 'parent2',
      type: 'group',
      label: 'Parent / tuteur 2',
      fields: [
        { name: 'firstName', type: 'text', label: 'Prénom' },
        { name: 'lastName', type: 'text', label: 'Nom' },
        { name: 'phone', type: 'text', label: 'Téléphone' },
        {
          name: 'relation',
          type: 'select',
          label: 'Lien',
          options: [
            { label: 'Père', value: 'father' },
            { label: 'Mère', value: 'mother' },
            { label: 'Tuteur', value: 'guardian' },
            { label: 'Autre', value: 'other' },
          ],
        },
      ],
    },
    {
      name: 'registrationNumber',
      type: 'text',
      label: 'Matricule (école / entreprise)',
    },
    {
      name: 'position',
      type: 'text',
      label: 'Poste (entreprise)',
    },
    {
      name: 'groups',
      type: 'relationship',
      relationTo: 'groups',
      hasMany: true,
      required: false,
      label: 'Groupes',
    },
    {
      name: 'registrationDate',
      type: 'date',
      label: "Date d'inscription",
      admin: {
        date: {
          pickerAppearance: 'dayOnly',
        },
      },
    },
    {
      name: 'status',
      type: 'select',
      defaultValue: 'active',
      label: 'Statut',
      options: [
        { label: 'Actif', value: 'active' },
        { label: 'Inactif', value: 'inactive' },
      ],
    },
  ],
  access: {
    // Lecture : admin → tous, assistant → membres de ses groupes.
    // Création publique : nécessaire pour le formulaire d'inscription
    // (sera remplacée par l'endpoint /api/register à l'étape suivante).
    read: filterMembers,
    create: () => true,
    update: isAdmin,
    delete: isAdmin,
  },
  hooks: {
    // Supprimer un membre supprime aussi ses présences (sinon FK NOT NULL).
    beforeDelete: [
      async ({ req, id }) => {
        const records = await req.payload.find({
          collection: 'attendance-records',
          where: { member: { equals: id } },
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
