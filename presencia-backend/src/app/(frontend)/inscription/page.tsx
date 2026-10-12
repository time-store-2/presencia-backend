import React from 'react'

/**
 * Placeholder temporaire : la page d'inscription par lien
 * (paramètre ?groupe=<slug>) sera reconstruite à l'étape suivante.
 */
export default async function InscriptionPage() {
  return (
    <main style={styles.main}>
      <h1>Inscription</h1>
      <p>Le formulaire d&apos;inscription sera bientôt disponible ici.</p>
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
