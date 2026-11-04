import React from 'react'

/** Calendrier + coche, aux couleurs de Presencia (terracotta / crème). */
export function BrandMark({ size = 32 }: { size?: number }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" aria-hidden="true">
      <rect width="64" height="64" rx="14" fill="#A13A15" />
      <rect x="15" y="17" width="34" height="32" rx="6" fill="#FFF8F6" />
      <rect x="15" y="17" width="34" height="9" rx="4" fill="#FBE3DC" />
      <rect x="22" y="12" width="4" height="9" rx="2" fill="#FFF8F6" />
      <rect x="38" y="12" width="4" height="9" rx="2" fill="#FFF8F6" />
      <path
        d="M24 36 l6 6 l11 -12"
        fill="none"
        stroke="#A13A15"
        strokeWidth="4.5"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}
