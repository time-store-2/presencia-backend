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
}

type Group = { name: string; slug: string }

type Props = {
  groups: Group[]
  /** Si défini : formulaire déjà lié à ce groupe (case pré-cochée et verrouillée). */
  presetSlug?: string
  t: RegisterStrings
}

export default function RegistrationForm({ groups, presetSlug, t }: Props) {
  const [status, setStatus] = useState<'idle' | 'sending' | 'done' | 'error'>('idle')
  const [error, setError] = useState('')

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setStatus('sending')
    setError('')
    const form = new FormData(e.currentTarget)
    const flat = Object.fromEntries(form.entries())
    const slugs = presetSlug ? [presetSlug] : form.getAll('groups').map(String)
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
      groupSlugs: slugs,
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
        throw new Error(body?.errors?.[0]?.message || 'Error.')
      }
      setStatus('done')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Error.')
      setStatus('error')
    }
  }

  if (status === 'done') {
    return <p>{t.done}</p>
  }

  return (
    <form onSubmit={onSubmit} style={styles.form}>
      <label style={styles.label}>
        {t.firstName}
        <input name="firstName" required maxLength={60} autoComplete="given-name" style={styles.input} />
      </label>
      <label style={styles.label}>
        {t.lastName}
        <input name="lastName" required maxLength={60} autoComplete="family-name" style={styles.input} />
      </label>
      <label style={styles.label}>
        {t.phone}
        <input name="phone" required maxLength={25} inputMode="tel" autoComplete="tel" placeholder={t.phonePlaceholder} style={styles.input} />
      </label>
      <label style={styles.label}>
        {t.email}
        <input name="email" type="email" maxLength={120} autoComplete="email" style={styles.input} />
      </label>
      <label style={styles.label}>
        {t.gender}
        <select name="gender" style={styles.input} defaultValue="">
          <option value="">{t.genderUnspecified}</option>
          <option value="male">{t.genderMale}</option>
          <option value="female">{t.genderFemale}</option>
        </select>
      </label>
      <label style={styles.label}>
        {t.birthDate}
        <input name="birthDate" type="date" style={styles.input} />
      </label>
      <label style={styles.label}>
        {t.address}
        <input name="address" maxLength={200} style={styles.input} />
      </label>
      {presetSlug ? (
        <p>{t.groups} <strong>{groups[0]?.name}</strong></p>
      ) : (
        <fieldset style={styles.fieldset}>
          <legend>{t.groups}</legend>
          {groups.map((g) => (
            <label key={g.slug} style={styles.check}>
              <input type="checkbox" name="groups" value={g.slug} />
              {g.name}
            </label>
          ))}
        </fieldset>
      )}
      <fieldset style={styles.fieldset}>
        <legend>{t.parent1}</legend>
        <label style={styles.label}>
          {t.parentFirstName}
          <input name="parent1.firstName" maxLength={60} style={styles.input} />
        </label>
        <label style={styles.label}>
          {t.parentLastName}
          <input name="parent1.lastName" maxLength={60} style={styles.input} />
        </label>
        <label style={styles.label}>
          {t.parentPhone}
          <input name="parent1.phone" maxLength={25} inputMode="tel" style={styles.input} />
        </label>
        <label style={styles.label}>
          {t.parentRelation}
          <select name="parent1.relation" style={styles.input} defaultValue="">
            <option value="">{t.relationUnspecified}</option>
            <option value="father">{t.relationFather}</option>
            <option value="mother">{t.relationMother}</option>
            <option value="guardian">{t.relationGuardian}</option>
            <option value="other">{t.relationOther}</option>
          </select>
        </label>
      </fieldset>
      <fieldset style={styles.fieldset}>
        <legend>{t.parent2}</legend>
        <label style={styles.label}>
          {t.parentFirstName}
          <input name="parent2.firstName" maxLength={60} style={styles.input} />
        </label>
        <label style={styles.label}>
          {t.parentLastName}
          <input name="parent2.lastName" maxLength={60} style={styles.input} />
        </label>
        <label style={styles.label}>
          {t.parentPhone}
          <input name="parent2.phone" maxLength={25} inputMode="tel" style={styles.input} />
        </label>
        <label style={styles.label}>
          {t.parentRelation}
          <select name="parent2.relation" style={styles.input} defaultValue="">
            <option value="">{t.relationUnspecified}</option>
            <option value="father">{t.relationFather}</option>
            <option value="mother">{t.relationMother}</option>
            <option value="guardian">{t.relationGuardian}</option>
            <option value="other">{t.relationOther}</option>
          </select>
        </label>
      </fieldset>
      {/* Honeypot anti-robot : invisible pour les humains. */}
      <input
        name="website"
        tabIndex={-1}
        autoComplete="off"
        style={{ position: 'absolute', left: '-9999px', opacity: 0, height: 0 }}
        aria-hidden="true"
      />
      {status === 'error' && <p style={styles.error}>{error}</p>}
      <button type="submit" disabled={status === 'sending'} style={styles.button}>
        {status === 'sending' ? t.sending : t.submit}
      </button>
    </form>
  )
}

const styles: Record<string, React.CSSProperties> = {
  form: { display: 'flex', flexDirection: 'column', gap: 12, marginTop: 16 },
  fieldset: { display: 'flex', flexDirection: 'column', gap: 8, border: '1px solid #ccc', borderRadius: 8, padding: 12 },
  check: { display: 'flex', gap: 8, alignItems: 'center', fontSize: 15 },
  label: { display: 'flex', flexDirection: 'column', gap: 4, fontSize: 14 },
  input: { padding: '10px 12px', fontSize: 16, borderRadius: 8, border: '1px solid #ccc' },
  button: {
    padding: '12px',
    fontSize: 16,
    fontWeight: 700,
    borderRadius: 8,
    border: 'none',
    background: '#16a34a',
    color: '#fff',
    cursor: 'pointer',
  },
  error: { color: '#dc2626' },
}
