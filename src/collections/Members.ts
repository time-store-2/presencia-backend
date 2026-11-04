import type { CollectionConfig } from 'payload'
import { canCreateMember, filterMembers } from '../access/roles'
import { normalizePhone } from '../lib/phone'

export const Members: CollectionConfig = {
  slug: 'members',
  labels: { singular: 'Membre', plural: 'Membres' },
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
    // Miniature (data URI JPEG ~256 px) envoyée par l'app. Solution provisoire
    // avant un vrai stockage de fichiers (Vercel Blob).
    {
      name: 'photo',
      type: 'textarea',
      label: 'Photo',
      admin: { hidden: true },
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
      name: 'createdBy',
      type: 'relationship',
      relationTo: 'users',
      label: 'Ajouté par',
      admin: { readOnly: true, position: 'sidebar' },
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
    // Lecture/modification : admin → tous, pasteur → membres de ses groupes
    // (ou ajoutés par lui).
    // Création : utilisateurs connectés + inscriptions via l'endpoint
    // public /api/register (droits serveur). Jamais anonyme en direct.
    read: filterMembers,
    create: canCreateMember,
    update: filterMembers,
    delete: filterMembers,
  },
  hooks: {
    // Stocke les téléphones au format E.164 (+228…), membre et parents.
    beforeValidate: [
      ({ data }) => {
        if (!data) return data
        const next = { ...data }
        if (next.phone) next.phone = normalizePhone(next.phone)
        for (const key of ['parent1', 'parent2'] as const) {
          const parent = next[key] as { phone?: string } | undefined
          if (parent?.phone) next[key] = { ...parent, phone: normalizePhone(parent.phone) }
        }
        return next
      },
    ],
    // Mémorise qui a ajouté le membre (visibilité du pasteur).
    beforeChange: [
      ({ req, data, operation }) => {
        if (operation === 'create' && data && !data.createdBy && req.user) {
          return { ...data, createdBy: req.user.id }
        }
        return data
      },
    ],
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
