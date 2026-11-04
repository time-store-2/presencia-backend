import { postgresAdapter } from '@payloadcms/db-postgres'
import { lexicalEditor } from '@payloadcms/richtext-lexical'
import path from 'path'
import { buildConfig } from 'payload'
import { fr } from '@payloadcms/translations/languages/fr'
import { fileURLToPath } from 'url'

import { Users } from './collections/Users'
import { Groups } from './collections/Groups'
import { Members } from './collections/Members'
import { AttendanceSessions } from './collections/AttendanceSessions'
import { AttendanceRecords } from './collections/AttendanceRecords'
import { RegistrationAttempts } from './collections/RegistrationAttempts'
import { Settings } from './globals/Settings'
import { memberStats, orgStats, periodStats } from './endpoints/stats'
import { publicGroups, register } from './endpoints/public'

const filename = fileURLToPath(import.meta.url)
const dirname = path.dirname(filename)

const allowedOrigins = [
  ...new Set(
    [
      process.env.NEXT_PUBLIC_SERVER_URL,
      'https://presencia-backend-wine.vercel.app',
      'http://localhost:3002',
    ]
      .filter((u): u is string => Boolean(u))
      .map((u) => u.replace(/\/+$/, '')),
  ),
]

export default buildConfig({
  admin: {
    user: Users.slug,
    importMap: {
      baseDir: path.resolve(dirname),
    },
    // Image de marque : logo, icône, favicon et titre « Presencia Admin ».
    meta: {
      titleSuffix: ' — Presencia Admin',
      icons: [{ rel: 'icon', type: 'image/png', url: '/favicon.png' }],
    },
    components: {
      graphics: {
        Logo: '/components/admin/Logo',
        Icon: '/components/admin/Icon',
      },
    },
  },
  collections: [Users, Groups, Members, AttendanceSessions, AttendanceRecords, RegistrationAttempts],
  globals: [Settings],
  // Interface admin en français uniquement.
  i18n: {
    supportedLanguages: { fr },
    fallbackLanguage: 'fr',
  },
  editor: lexicalEditor(),
  secret: process.env.PAYLOAD_SECRET || '',
  // Navigateur : seul le site lui-même peut appeler l'API avec des cookies
  // (l'app mobile, elle, n'est pas concernée par CORS).
  cors: allowedOrigins,
  csrf: allowedOrigins,
  typescript: {
    outputFile: path.resolve(dirname, 'payload-types.ts'),
  },
  db: postgresAdapter({
    pool: {
      connectionString: process.env.DATABASE_URL || '',
    },
    // Schéma géré uniquement par les migrations (dossier src/migrations).
    // En local : `pnpm payload migrate`. Sur Vercel : le script `build`
    // exécute `payload migrate` avant `next build`.
    push: false,
  }),
  endpoints: [orgStats, memberStats, periodStats, publicGroups, register],
  localization: {
    locales: ['en'],
    fallback: true,
    defaultLocale: 'en',
  },
  plugins: [],
})
