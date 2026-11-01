import { getPayload } from 'payload'
import React from 'react'

import config from '@/payload.config'
import RegistrationForm, { type RegisterStrings } from './form'

type Props = {
  searchParams: Promise<{ groupe?: string; lang?: string }>
}

type Lang = 'fr' | 'en'

const STRINGS: Record<
  Lang,
  RegisterStrings & {
    title: string
    intro: string
    groupLabel: string
    invalid: string
    notFound: (slug: string) => string
    appBrand: string
  }
> = {
  fr: {
    appBrand: 'PRESENCIA',
    title: 'Fiche d’inscription',
    intro: 'Remplis ce formulaire : ton nom apparaîtra directement sur la liste de présence de ton enseignant.',
    groupLabel: 'Tu t’inscris au groupe',
    invalid: 'Lien d’inscription invalide ou aucun groupe disponible.',
    notFound: (slug) => `Groupe introuvable : « ${slug} ». Demande le lien à jour à ton responsable ou pasteur.`,
    firstName: 'Prénom',
    lastName: 'Nom',
    phone: 'Téléphone (WhatsApp)',
    phonePlaceholder: '+225 07 00 00 00 00',
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
    done: '✅ Inscription réussie ! Ton responsable a bien reçu tes informations.',
    registerAnother: 'Inscrire une autre personne',
  },
  en: {
    appBrand: 'PRESENCIA',
    title: 'Registration Form',
    intro: 'Fill in this form: your name will directly appear on your teacher’s attendance list.',
    groupLabel: 'You are registering for',
    invalid: 'Invalid registration link or no groups currently available.',
    notFound: (slug) => `Group not found: "${slug}". Please ask your leader or pastor for the correct link.`,
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
    done: '✅ Registration successful! Your leader has received your information.',
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
  const lang: Lang = params.lang === 'en' ? 'en' : 'fr'
  const t = STRINGS[lang]
  const { title: _title, intro: _intro, groupLabel: _groupLabel, invalid: _invalid, notFound: _notFound, ...formStrings } = t
  const slug = (params.groupe ?? '').trim()

  const payloadConfig = await config
  const payload = await getPayload({ config: payloadConfig })

  const otherLang = lang === 'fr' ? 'en' : 'fr'
  const langHref = slug
    ? `/inscription?groupe=${encodeURIComponent(slug)}&lang=${otherLang}`
    : `/inscription?lang=${otherLang}`

  // Cas 1 : lien direct vers un groupe → formulaire pré-rempli pour ce groupe
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
        <main className="presencia-page">
          <div className="presencia-container">
            <div className="presencia-card">
              <div className="presencia-top-bar">
                <div className="presencia-badge">
                  <PresenciaLogo />
                  <span>{t.appBrand}</span>
                </div>
                <a href={langHref} className="lang-switch">
                  🌐 {otherLang === 'fr' ? 'Français' : 'English'}
                </a>
              </div>
              <h1 className="presencia-title">{t.title}</h1>
              <div className="error-banner" style={{ marginTop: 16, marginBottom: 20 }}>
                {t.notFound(slug)}
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
            <div className="presencia-top-bar">
              <div className="presencia-badge">
                <PresenciaLogo />
                <span>{t.appBrand}</span>
              </div>
              <a href={langHref} className="lang-switch">
                🌐 {otherLang.toUpperCase()}
              </a>
            </div>

            <h1 className="presencia-title">{t.title}</h1>

            <div className="group-callout">
              <div className="group-callout-icon">👥</div>
              <div>
                <div className="group-callout-label">{t.groupLabel}</div>
                <div className="group-callout-name">{group.name}</div>
              </div>
            </div>

            <p className="presencia-intro">{t.intro}</p>

            <RegistrationForm
              groups={[{ name: group.name ?? slug, slug }]}
              presetSlug={slug}
              t={formStrings}
            />
          </div>
        </div>
      </main>
    )
  }

  // Cas 2 : sans paramètre → liste des groupes disponibles
  const res = await payload.find({
    collection: 'groups',
    limit: 100,
    sort: 'name',
    depth: 0,
    overrideAccess: true,
  })
  const groups = res.docs
    .map((g) => {
      const doc = g as unknown as { name?: string; slug?: string }
      return { name: doc.name ?? '', slug: doc.slug ?? '' }
    })
    .filter((g) => g.name !== '' && g.slug !== '')

  if (groups.length === 0) {
    return (
      <main className="presencia-page">
        <div className="presencia-container">
          <div className="presencia-card">
            <div className="presencia-top-bar">
              <div className="presencia-badge">
                <PresenciaLogo />
                <span>{t.appBrand}</span>
              </div>
              <a href={langHref} className="lang-switch">
                🌐 {otherLang === 'fr' ? 'Français' : 'English'}
              </a>
            </div>
            <h1 className="presencia-title">{t.title}</h1>
            <div className="error-banner" style={{ marginTop: 16 }}>
              {t.invalid}
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
          <div className="presencia-top-bar">
            <div className="presencia-badge">
              <PresenciaLogo />
              <span>{t.appBrand}</span>
            </div>
            <a href={langHref} className="lang-switch">
              🌐 {otherLang.toUpperCase()}
            </a>
          </div>

          <h1 className="presencia-title">{t.title}</h1>
          <p className="presencia-intro">{t.intro}</p>

          <RegistrationForm groups={groups} t={formStrings} />
        </div>
      </div>
    </main>
  )
}
