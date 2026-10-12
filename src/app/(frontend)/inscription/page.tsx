import { getPayload } from 'payload'
import React from 'react'

import config from '@/payload.config'
import RegistrationForm from './form'

type Props = {
  searchParams: Promise<{ org?: string }>
}

export default async function InscriptionPage({ searchParams }: Props) {
  const { org: orgCode } = await searchParams
  const payloadConfig = await config
  const payload = await getPayload({ config: payloadConfig })

  if (!orgCode) {
    return (
      <main style={styles.main}>
        <h1>Inscription</h1>
        <p>Lien d&apos;inscription invalide : code d&apos;organisation manquant.</p>
      </main>
    )
  }

  const orgs = await payload.find({
    collection: 'organizations',
    where: { code: { equals: orgCode } },
    limit: 1,
    overrideAccess: true,
  })

  const organization = orgs.docs[0]
  if (!organization) {
    return (
      <main style={styles.main}>
        <h1>Inscription</h1>
        <p>Organisation introuvable pour le code « {orgCode} ».</p>
      </main>
    )
  }

  const groups = await payload.find({
    collection: 'groups',
    where: { organization: { equals: organization.id } },
    limit: 100,
    overrideAccess: true,
  })

  return (
    <main style={styles.main}>
      <h1>Inscription — {organization.name}</h1>
      <p>Remplis ce formulaire : ton nom apparaîtra chez le responsable de ton groupe.</p>
      <RegistrationForm
        organizationId={organization.id as number | string}
        organizationType={organization.type as string}
        groups={groups.docs.map((g) => ({ id: g.id as number | string, name: g.name as string }))}
      />
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
