import React from 'react'
import { BrandMark } from './BrandMark'

/** Logo de l'écran de connexion de l'admin Payload. */
export default function Logo() {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
      <BrandMark size={56} />
      <div>
        <div style={{ fontSize: 28, fontWeight: 800, color: '#A13A15', lineHeight: 1.1 }}>
          Presencia
        </div>
        <div style={{ fontSize: 14, fontWeight: 600, opacity: 0.7 }}>Administration</div>
      </div>
    </div>
  )
}
