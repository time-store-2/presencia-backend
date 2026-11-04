'use client'

import React, { useState } from 'react'

export type RegisterStrings = {
  firstName: string
  lastName: string
  phone: string
  phonePlaceholder: string
  email: string
  gender: string
  genderUnspecified: string
  genderMale: string
  genderFemale: string
  birthDate: string
  address: string
  groups: string
  parent1: string
  parent2: string
  parentFirstName: string
  parentLastName: string
  parentPhone: string
  parentRelation: string
  relationUnspecified: string
  relationFather: string
  relationMother: string
  relationGuardian: string
  relationOther: string
  submit: string
  sending: string
  done: string
  registerAnother?: string
  successTitle?: string
  alreadyRegistered?: string
  consent?: string
}

type Props = {
  /** Jeton du lien d'inscription du groupe (paramètre ?groupe=). */
  groupToken: string
  t: RegisterStrings
}

export default function RegistrationForm({ groupToken, t }: Props) {
  const [status, setStatus] = useState<'idle' | 'sending' | 'done' | 'error'>('idle')
  const [already, setAlready] = useState(false)
  const [error, setError] = useState('')

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setStatus('sending')
    setError('')
    const form = new FormData(e.currentTarget)
    const flat = Object.fromEntries(form.entries())

    const pick = (prefix: string) => {
      const obj: Record<string, string> = {}
      for (const [k, v] of Object.entries(flat)) {
        if (k.startsWith(prefix + '.') && typeof v === 'string' && v.trim() !== '') {
          obj[k.slice(prefix.length + 1)] = v
        }
      }
      return Object.keys(obj).length > 0 ? obj : undefined
    }

    const pickStr = (key: string) => {
      const v = flat[key]
      return typeof v === 'string' && v.trim() !== '' ? v : undefined
    }

    const data: Record<string, unknown> = {
      firstName: pickStr('firstName'),
      lastName: pickStr('lastName'),
      phone: pickStr('phone'),
      groupToken,
      website: pickStr('website'), // honeypot anti-robot
    }

    const email = pickStr('email')
    const birthDate = pickStr('birthDate')
    const gender = pickStr('gender')
    const address = pickStr('address')

    if (email) data.email = email
    if (birthDate) data.birthDate = birthDate
    if (gender) data.gender = gender
    if (address) data.address = address

    const parent1 = pick('parent1')
    const parent2 = pick('parent2')
    if (parent1) data.parent1 = parent1
    if (parent2) data.parent2 = parent2

    try {
      const res = await fetch('/api/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })
      if (!res.ok) {
        const body = await res.json().catch(() => null)
        throw new Error(body?.errors?.[0]?.message || 'Une erreur est survenue lors de l’inscription.')
      }
      const ok = await res.json().catch(() => null)
      setAlready(Boolean(ok?.alreadyRegistered))
      setStatus('done')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Une erreur inattendue est survenue.')
      setStatus('error')
    }
  }

  if (status === 'done') {
    return (
      <div className="success-card">
        <div className="success-icon-badge">✓</div>
        <h2 className="success-title">{t.successTitle ?? 'Inscription validée !'}</h2>
        <p className="success-message">{already ? (t.alreadyRegistered ?? t.done) : t.done}</p>
        <button
          type="button"
          className="btn-secondary"
          onClick={() => {
            setStatus('idle')
            setError('')
          }}
        >
          {t.registerAnother ?? 'Inscrire une autre personne'}
        </button>
      </div>
    )
  }

  return (
    <form onSubmit={onSubmit} className="reg-form">
      {/* Informations personnelles */}
      <div className="form-grid-2">
        <div className="form-field">
          <label className="form-label">
            {t.firstName} <span className="form-label-required">*</span>
          </label>
          <input
            className="form-input"
            name="firstName"
            required
            maxLength={60}
            autoComplete="given-name"
            placeholder="Ex : Samuel"
          />
        </div>
        <div className="form-field">
          <label className="form-label">
            {t.lastName} <span className="form-label-required">*</span>
          </label>
          <input
            className="form-input"
            name="lastName"
            required
            maxLength={60}
            autoComplete="family-name"
            placeholder="Ex : Kouassi"
          />
        </div>
      </div>

      <div className="form-grid-2">
        <div className="form-field">
          <label className="form-label">
            {t.phone} <span className="form-label-required">*</span>
          </label>
          <input
            className="form-input"
            name="phone"
            required
            maxLength={25}
            inputMode="tel"
            autoComplete="tel"
            placeholder={t.phonePlaceholder}
          />
        </div>
        <div className="form-field">
          <label className="form-label">{t.email}</label>
          <input
            className="form-input"
            name="email"
            type="email"
            maxLength={120}
            autoComplete="email"
            placeholder="email@exemple.com"
          />
        </div>
      </div>

      <div className="form-grid-2">
        <div className="form-field">
          <label className="form-label">{t.gender}</label>
          <select className="form-select" name="gender" defaultValue="">
            <option value="">{t.genderUnspecified}</option>
            <option value="male">{t.genderMale}</option>
            <option value="female">{t.genderFemale}</option>
          </select>
        </div>
        <div className="form-field">
          <label className="form-label">
            {t.birthDate} <span className="form-label-required">*</span>
          </label>
          <input className="form-input" name="birthDate" type="date" required />
        </div>
      </div>

      <div className="form-field">
        <label className="form-label">{t.address}</label>
        <input
          className="form-input"
          name="address"
          maxLength={200}
          placeholder="Quartier, commune ou adresse"
        />
      </div>

      {/* Section Parent 1 */}
      <div className="form-section-card">
        <div className="form-section-header">
          <span>👨‍👩‍👦</span>
          <span>{t.parent1}</span>
        </div>

        <div className="form-grid-2">
          <div className="form-field">
            <label className="form-label">{t.parentFirstName}</label>
            <input className="form-input" name="parent1.firstName" maxLength={60} />
          </div>
          <div className="form-field">
            <label className="form-label">{t.parentLastName}</label>
            <input className="form-input" name="parent1.lastName" maxLength={60} />
          </div>
        </div>

        <div className="form-grid-2">
          <div className="form-field">
            <label className="form-label">{t.parentPhone}</label>
            <input
              className="form-input"
              name="parent1.phone"
              maxLength={25}
              inputMode="tel"
              placeholder="+228 90 00 00 00"
            />
          </div>
          <div className="form-field">
            <label className="form-label">{t.parentRelation}</label>
            <select className="form-select" name="parent1.relation" defaultValue="">
              <option value="">{t.relationUnspecified}</option>
              <option value="father">{t.relationFather}</option>
              <option value="mother">{t.relationMother}</option>
              <option value="guardian">{t.relationGuardian}</option>
              <option value="other">{t.relationOther}</option>
            </select>
          </div>
        </div>
      </div>

      {/* Section Parent 2 */}
      <div className="form-section-card">
        <div className="form-section-header">
          <span>👨‍👩‍👦</span>
          <span>{t.parent2}</span>
          <span className="form-section-badge">Optionnel</span>
        </div>

        <div className="form-grid-2">
          <div className="form-field">
            <label className="form-label">{t.parentFirstName}</label>
            <input className="form-input" name="parent2.firstName" maxLength={60} />
          </div>
          <div className="form-field">
            <label className="form-label">{t.parentLastName}</label>
            <input className="form-input" name="parent2.lastName" maxLength={60} />
          </div>
        </div>

        <div className="form-grid-2">
          <div className="form-field">
            <label className="form-label">{t.parentPhone}</label>
            <input
              className="form-input"
              name="parent2.phone"
              maxLength={25}
              inputMode="tel"
              placeholder="+228 90 00 00 00"
            />
          </div>
          <div className="form-field">
            <label className="form-label">{t.parentRelation}</label>
            <select className="form-select" name="parent2.relation" defaultValue="">
              <option value="">{t.relationUnspecified}</option>
              <option value="father">{t.relationFather}</option>
              <option value="mother">{t.relationMother}</option>
              <option value="guardian">{t.relationGuardian}</option>
              <option value="other">{t.relationOther}</option>
            </select>
          </div>
        </div>
      </div>

      {/* Honeypot anti-robot */}
      <input
        name="website"
        tabIndex={-1}
        autoComplete="off"
        style={{ position: 'absolute', left: '-9999px', opacity: 0, height: 0, width: 0 }}
        aria-hidden="true"
      />

      {status === 'error' && (
        <div className="error-banner">
          ⚠️ {error}
        </div>
      )}

      <button type="submit" disabled={status === 'sending'} className="btn-submit">
        {status === 'sending' ? (
          <>
            <svg
              width="20"
              height="20"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.5"
              className="spinner-icon"
            >
              <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" />
            </svg>
            <span>{t.sending}</span>
          </>
        ) : (
          <span>{t.submit}</span>
        )}
      </button>

      <p className="consent-notice">
        {t.consent ??
          'En envoyant ce formulaire, tu acceptes que ces informations servent uniquement au suivi des présences de ta communauté. Pour un mineur, c’est le parent ou le tuteur qui donne son accord.'}
      </p>
    </form>
  )
}
