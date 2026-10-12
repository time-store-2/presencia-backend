'use client'

import React, { useState } from 'react'

type Group = { id: number | string; name: string }

type Props = {
  organizationId: number | string
  organizationType: string
  groups: Group[]
}

export default function RegistrationForm({ organizationId, organizationType, groups }: Props) {
  const [status, setStatus] = useState<'idle' | 'sending' | 'done' | 'error'>('idle')
  const [error, setError] = useState('')

  async function onSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault()
    setStatus('sending')
    setError('')
    const form = new FormData(e.currentTarget)
    const flat = Object.fromEntries(form.entries())
    const groups = form.getAll('groups').map(String)
    const pick = (prefix: string) => {
      const obj: Record<string, string> = {}
      for (const [k, v] of Object.entries(flat)) {
        if (k.startsWith(prefix + '.') && typeof v === 'string' && v.trim() !== '') {
          obj[k.slice(prefix.length + 1)] = v
        }
      }
      return Object.keys(obj).length > 0 ? obj : undefined
    }
    const data: Record<string, unknown> = { organization: organizationId }
    for (const [k, v] of Object.entries(flat)) {
      if (!k.includes('.') && k !== 'groups' && v !== '') data[k] = v
    }
    data.groups = groups.map((g) => (isNaN(Number(g)) ? g : Number(g)))
    const parent1 = pick('parent1')
    const parent2 = pick('parent2')
    if (parent1) data.parent1 = parent1
    if (parent2) data.parent2 = parent2
    try {
      const res = await fetch('/api/members', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      })
      if (!res.ok) {
        const body = await res.json().catch(() => null)
        throw new Error(body?.errors?.[0]?.message || "Échec de l'inscription.")
      }
      setStatus('done')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue.')
      setStatus('error')
    }
  }

  if (status === 'done') {
    return <p>✅ Inscription réussie ! Le responsable de ton groupe a bien reçu tes informations.</p>
  }

  const showParent = organizationType === 'eglise'
  const showSchool = organizationType === 'ecole'
  const showCompany = organizationType === 'entreprise'

  return (
    <form onSubmit={onSubmit} style={styles.form}>
      <label style={styles.label}>
        Prénom *
        <input name="firstName" required style={styles.input} />
      </label>
      <label style={styles.label}>
        Nom *
        <input name="lastName" required style={styles.input} />
      </label>
      <label style={styles.label}>
        Téléphone (WhatsApp) *
        <input name="phone" required placeholder="+225..." style={styles.input} />
      </label>
      <label style={styles.label}>
        Email
        <input name="email" type="email" style={styles.input} />
      </label>
      <label style={styles.label}>
        Sexe
        <select name="gender" style={styles.input} defaultValue="">
          <option value="">—</option>
          <option value="male">Homme</option>
          <option value="female">Femme</option>
        </select>
      </label>
      <label style={styles.label}>
        Date de naissance
        <input name="birthDate" type="date" style={styles.input} />
      </label>
      <label style={styles.label}>
        Adresse
        <input name="address" style={styles.input} />
      </label>
      <fieldset style={styles.fieldset}>
        <legend>Groupe(s) *</legend>
        {groups.map((g) => (
          <label key={String(g.id)} style={styles.check}>
            <input type="checkbox" name="groups" value={String(g.id)} />
            {g.name}
          </label>
        ))}
      </fieldset>
      {showParent && (
        <>
          <fieldset style={styles.fieldset}>
            <legend>Parent / tuteur 1 (si mineur)</legend>
            <label style={styles.label}>
              Prénom
              <input name="parent1.firstName" style={styles.input} />
            </label>
            <label style={styles.label}>
              Nom
              <input name="parent1.lastName" style={styles.input} />
            </label>
            <label style={styles.label}>
              Téléphone
              <input name="parent1.phone" style={styles.input} />
            </label>
            <label style={styles.label}>
              Lien
              <select name="parent1.relation" style={styles.input} defaultValue="">
                <option value="">—</option>
                <option value="father">Père</option>
                <option value="mother">Mère</option>
                <option value="guardian">Tuteur</option>
                <option value="other">Autre</option>
              </select>
            </label>
          </fieldset>
          <fieldset style={styles.fieldset}>
            <legend>Parent / tuteur 2 (optionnel)</legend>
            <label style={styles.label}>
              Prénom
              <input name="parent2.firstName" style={styles.input} />
            </label>
            <label style={styles.label}>
              Nom
              <input name="parent2.lastName" style={styles.input} />
            </label>
            <label style={styles.label}>
              Téléphone
              <input name="parent2.phone" style={styles.input} />
            </label>
            <label style={styles.label}>
              Lien
              <select name="parent2.relation" style={styles.input} defaultValue="">
                <option value="">—</option>
                <option value="father">Père</option>
                <option value="mother">Mère</option>
                <option value="guardian">Tuteur</option>
                <option value="other">Autre</option>
              </select>
            </label>
          </fieldset>
        </>
      )}
      {showSchool && (
        <label style={styles.label}>
          Matricule
          <input name="registrationNumber" style={styles.input} />
        </label>
      )}
      {showCompany && (
        <>
          <label style={styles.label}>
            Matricule
            <input name="registrationNumber" style={styles.input} />
          </label>
          <label style={styles.label}>
            Poste
            <input name="position" style={styles.input} />
          </label>
        </>
      )}
      {status === 'error' && <p style={styles.error}>{error}</p>}
      <button type="submit" disabled={status === 'sending'} style={styles.button}>
        {status === 'sending' ? 'Envoi…' : "S'inscrire"}
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
