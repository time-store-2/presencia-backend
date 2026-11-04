import React from 'react'
import type { Metadata, Viewport } from 'next'
import { Plus_Jakarta_Sans } from 'next/font/google'
import './styles.css'

const plusJakartaSans = Plus_Jakarta_Sans({
  subsets: ['latin'],
  weight: ['400', '500', '600', '700', '800'],
  display: 'swap',
  variable: '--font-sans',
})

export const metadata: Metadata = {
  title: 'Inscription — Presencia',
  description: 'Portail d’inscription et suivi de présences pour votre communauté.',
  openGraph: {
    title: 'Inscription — Presencia',
    description: 'Rejoignez votre groupe et suivez vos activités sur Presencia.',
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
    title: 'Inscription — Presencia',
    description: 'Portail d’inscription et suivi de présences pour votre communauté.',
  },
}

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  themeColor: '#A13A15',
}

export default async function RootLayout(props: { children: React.ReactNode }) {
  const { children } = props

  return (
    <html lang="fr" className={plusJakartaSans.variable}>
      <body className={plusJakartaSans.className}>{children}</body>
    </html>
  )
}
