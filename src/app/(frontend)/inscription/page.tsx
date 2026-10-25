import { getPayload } from 'payload'
import React from 'react'

import config from '@/payload.config'
import RegistrationForm, { type RegisterStrings } from './form'

type Props = {
  searchParams: Promise<{ groupe?: string; lang?: string }>
}

type Lang = 'fr' | 'en'

const STRINGS: Record<Lang, RegisterStrings & { title: string; intro: string; groupLabel: string; invalid: string; notFound: (slug: string) => string }> = {
  fr: {
    title: 'Inscription',
    intro: 'Remplis ce formulaire : ton nom apparaîtra chez ton enseignant.',
    groupLabel: 'Tu t’inscris au groupe :',
    invalid: 'Lien d’inscription invalide.',
    notFound: (slug) => `Groupe introuvable : « ${slug} ». Demande le bon lien à ton enseignant.`,
    firstName: 'Prénom *',
    lastName: 'Nom *',
    phone: 'Téléphone (WhatsApp, avec indicatif) *',
    phonePlaceholder: '+225...',
    email: 'Email',
    gender: 'Sexe',
    genderUnspecified: '—',
    genderMale: 'Homme',
    genderFemale: 'Femme',
    birthDate: 'Date de naissance',
    address: 'Adresse',
    groups: 'Groupe(s) *',
    parent1: 'Parent / tuteur 1 (si mineur)',
    parent2: 'Parent / tuteur 2 (optionnel)',
    parentFirstName: 'Prénom',
    parentLastName: 'Nom',
    parentPhone: 'Téléphone',
    parentRelation: 'Lien',
    relationUnspecified: '—',
    relationFather: 'Père',
    relationMother: 'Mère',
    relationGuardian: 'Tuteur',
    relationOther: 'Autre',
    submit: "S'inscrire",
    sending: 'Envoi…',
    done: '✅ Inscription réussie ! Ton enseignant a bien reçu tes informations.',
  },
  en: {
    title: 'Registration',
    intro: 'Fill in this form: your name will appear on your teacher’s list.',
    groupLabel: 'You are registering for:',
    invalid: 'Invalid registration link.',
    notFound: (slug) => `Group not found: "${slug}". Ask your teacher for the correct link.`,
    firstName: 'First name *',
    lastName: 'Last name *',
    phone: 'Phone (WhatsApp, with country code) *',
    phonePlaceholder: '+225...',
    email: 'Email',
    gender: 'Gender',
    genderUnspecified: '—',
    genderMale: 'Male',
    genderFemale: 'Female',
    birthDate: 'Birth date',
    address: 'Address',
    groups: 'Group(s) *',
    parent1: 'Parent / guardian 1 (if minor)',
    parent2: 'Parent / guardian 2 (optional)',
    parentFirstName: 'First name',
    parentLastName: 'Last name',
    parentPhone: 'Phone',
    parentRelation: 'Relation',
    relationUnspecified: '—',
    relationFather: 'Father',
    relationMother: 'Mother',
    relationGuardian: 'Guardian',
    relationOther: 'Other',
    submit: 'Register',
    sending: 'Sending…',
    done: '✅ Registration successful! Your teacher has received your information.',
  },
}

export default async function InscriptionPage({ searchParams }: Props) {
  const params = await searchParams
  const lang: Lang = params.lang === 'en' ? 'en' : 'fr'
  const t = STRINGS[lang]
  // Le formulaire est un Client Component : seules des chaînes peuvent lui
  // être passées (notFound est une fonction → erreur 500 en production).
  const { title: _title, intro: _intro, groupLabel: _groupLabel, invalid: _invalid, notFound: _notFound, ...formStrings } = t
  const slug = (params.groupe ?? '').trim()

  const payloadConfig = await config
  const payload = await getPayload({ config: payloadConfig })

  const otherLang = lang === 'fr' ? 'en' : 'fr'
  const langHref = slug
    ? `/inscription?groupe=${encodeURIComponent(slug)}&lang=${otherLang}`
    : `/inscription?lang=${otherLang}`

  // Cas 1 : lien direct vers un groupe → formulaire déjà lié.
  if (slug) {
    const res = await payload.find({
      collection: 'groups',
      where: { slug: { equals: slug } },
      limit: 1,
      depth: 0,
      overrideAccess: true,
    })
    const group = res.docs[0] as unknown as { name?: string; slug?: string } | undefined
    if (!group) {
      return (
        <main style={styles.main}>
          <h1>{t.title}</h1>
          <p>{t.notFound(slug)}</p>
          <p><a href={langHref}>{otherLang === 'fr' ? 'Français' : 'English'}</a></p>
        </main>
      )
    }
    return (
      <main style={styles.main}>
        <h1>{t.title}</h1>
        <p>{t.groupLabel} <strong>{group.name}</strong></p>
        <p>{t.intro}</p>
        <RegistrationForm
          groups={[{ name: group.name ?? slug, slug }]}
          presetSlug={slug}
          t={formStrings}
        />
        <p><a href={langHref}>{otherLang === 'fr' ? 'Français' : 'English'}</a></p>
      </main>
    )
  }

  // Cas 2 : sans paramètre → l'élève coche ses groupes.
  const res = await payload.find({
    collection: 'groups',
    limit: 100,
    sort: 'name',
    depth: 0,
    overrideAccess: true,
  })
  const groups = res.docs.map((g) => {
    const doc = g as unknown as { name?: string; slug?: string }
    return { name: doc.name ?? '', slug: doc.slug ?? '' }
  }).filter((g) => g.name !== '' && g.slug !== '')

  if (groups.length === 0) {
    return (
      <main style={styles.main}>
        <h1>{t.title}</h1>
        <p>{t.invalid}</p>
        <p><a href={langHref}>{otherLang === 'fr' ? 'Français' : 'English'}</a></p>
      </main>
    )
  }

  return (
    <main style={styles.main}>
      <h1>{t.title}</h1>
      <p>{t.intro}</p>
      <RegistrationForm groups={groups} t={formStrings} />
      <p><a href={langHref}>{otherLang === 'fr' ? 'Français' : 'English'}</a></p>
    </main>
  )
}

const styles: Record<string, React.CSSProperties> = {
  main: {
    maxWidth: 520,
    margin: '0 auto',
    padding: '32px 16px',
    fontFamily: 'system-ui, sans-serif',
  },
}
