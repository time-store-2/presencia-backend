import { getPayload } from 'payload'
import React from 'react'
import type { Metadata } from 'next'

import config from '@/payload.config'
import RegistrationForm, { type RegisterStrings } from './form'
import { findGroupByToken } from '@/endpoints/public'

type Props = {
  searchParams: Promise<{ groupe?: string }>
}

type Lang = 'fr' | 'en'

export async function generateMetadata({ searchParams }: Props): Promise<Metadata> {
  const params = await searchParams
  const token = (params.groupe ?? '').trim()
  let groupName = ''
  if (token) {
    try {
      const payload = await getPayload({ config: await config })
      groupName = (await findGroupByToken({ payload }, token))?.name ?? ''
    } catch (_) {}
  }

  const title = groupName
    ? `Inscription · ${groupName} — Presencia`
    : 'Inscription — Presencia'
  const description = groupName
    ? `Rejoignez le groupe ${groupName} sur Presencia.`
    : 'Portail d’inscription et suivi de présences pour votre communauté.'

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      type: 'website',
      images: [
        {
          url: '/og-image.png',
          width: 1200,
          height: 630,
          alt: 'Presencia',
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title,
      description,
    },
  }
}

const STRINGS: Record<
  Lang,
  RegisterStrings & {
    title: string
    intro: string
    groupLabel: string
    invalid: string
    notFound: string
    appBrand: string
  }
> = {
  fr: {
    appBrand: 'PRESENCIA',
    title: 'Fiche d’inscription',
    intro: 'Remplis ce formulaire : ton nom apparaîtra directement sur la liste de présence de ton responsable.',
    groupLabel: 'Tu t’inscris au groupe',
    invalid: 'Lien d’inscription incomplet. Demande le lien de ton groupe à ton responsable ou à ton pasteur.',
    notFound: 'Ce lien d’inscription n’est plus valide. Demande le nouveau lien à ton responsable ou à ton pasteur.',
    firstName: 'Prénom',
    lastName: 'Nom',
    phone: 'Téléphone (WhatsApp)',
    phonePlaceholder: '+228 90 00 00 00',
    email: 'Adresse email',
    gender: 'Sexe',
    genderUnspecified: 'Sélectionner...',
    genderMale: 'Homme',
    genderFemale: 'Femme',
    birthDate: 'Date de naissance',
    address: 'Adresse de résidence',
    groups: 'Groupe(s) concerné(s)',
    parent1: 'Parent / Tuteur 1 (si mineur)',
    parent2: 'Parent / Tuteur 2 (optionnel)',
    parentFirstName: 'Prénom du parent',
    parentLastName: 'Nom du parent',
    parentPhone: 'Téléphone du parent',
    parentRelation: 'Lien de parenté',
    relationUnspecified: 'Sélectionner...',
    relationFather: 'Père',
    relationMother: 'Mère',
    relationGuardian: 'Tuteur légal',
    relationOther: 'Autre',
    submit: 'Valider mon inscription',
    sending: 'Enregistrement en cours…',
    done: 'Ton responsable a bien reçu tes informations.',
    registerAnother: 'Inscrire une autre personne',
    successTitle: 'Inscription validée !',
    alreadyRegistered: 'Déjà inscrit : tu es maintenant aussi dans ce groupe.',
  },
  en: {
    appBrand: 'PRESENCIA',
    title: 'Registration Form',
    intro: 'Fill in this form: your name will directly appear on your leader’s attendance list.',
    groupLabel: 'You are registering for',
    invalid: 'Invalid registration link or no groups currently available.',
    notFound: 'This registration link is no longer valid. Please ask your leader or pastor for the new link.',
    firstName: 'First name',
    lastName: 'Last name',
    phone: 'Phone (WhatsApp)',
    phonePlaceholder: '+1 (555) 000-0000',
    email: 'Email address',
    gender: 'Gender',
    genderUnspecified: 'Select...',
    genderMale: 'Male',
    genderFemale: 'Female',
    birthDate: 'Birth date',
    address: 'Home address',
    groups: 'Concerned Group(s)',
    parent1: 'Parent / Guardian 1 (if minor)',
    parent2: 'Parent / Guardian 2 (optional)',
    parentFirstName: 'Parent first name',
    parentLastName: 'Parent last name',
    parentPhone: 'Parent phone',
    parentRelation: 'Relationship',
    relationUnspecified: 'Select...',
    relationFather: 'Father',
    relationMother: 'Mother',
    relationGuardian: 'Legal guardian',
    relationOther: 'Other',
    submit: 'Submit Registration',
    sending: 'Submitting…',
    done: 'Registration successful! Your leader has received your information.',
    registerAnother: 'Register another person',
  },
}

function PresenciaLogo() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M12 2L3 7V17L12 22L21 17V7L12 2Z"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <path
        d="M12 6V18M7 9L17 15M17 9L7 15"
        stroke="currentColor"
        strokeWidth="1.75"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

export default async function InscriptionPage({ searchParams }: Props) {
  const params = await searchParams
  // Français uniquement : les messages du serveur ne sont pas traduits, donc
  // pas de bouton « EN » tant que la traduction n'est pas complète.
  const t = STRINGS.fr
  const { title: _title, intro: _intro, groupLabel: _groupLabel, invalid: _invalid, notFound: _notFound, ...formStrings } = t
  const token = (params.groupe ?? '').trim()

  const payload = await getPayload({ config: await config })
  const group = token ? await findGroupByToken({ payload }, token) : undefined

  const header = (
    <div className="presencia-top-bar">
      <div className="presencia-badge">
        <PresenciaLogo />
        <span>{t.appBrand}</span>
      </div>
    </div>
  )

  // Lien absent, ancien (slug devinable), régénéré ou désactivé.
  if (!group) {
    return (
      <main className="presencia-page">
        <div className="presencia-container">
          <div className="presencia-card">
            {header}
            <h1 className="presencia-title">{t.title}</h1>
            <div className="error-banner" style={{ marginTop: 16, marginBottom: 20 }}>
              {token ? t.notFound : t.invalid}
            </div>
          </div>
        </div>
      </main>
    )
  }

  return (
    <main className="presencia-page">
      <div className="presencia-container">
        <div className="presencia-card">
          {header}
          <h1 className="presencia-title">{t.title}</h1>

          <div className="group-callout">
            <div className="group-callout-icon">👥</div>
            <div>
              <div className="group-callout-label">{t.groupLabel}</div>
              <div className="group-callout-name">{group.name}</div>
            </div>
          </div>

          <p className="presencia-intro">{t.intro}</p>

          <RegistrationForm groupToken={token} t={formStrings} />
        </div>
      </div>
    </main>
  )
}
