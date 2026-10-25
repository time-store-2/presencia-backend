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
import { Settings } from './globals/Settings'
import { memberStats, orgStats, periodStats } from './endpoints/stats'
import { publicGroups, register } from './endpoints/public'

const filename = fileURLToPath(import.meta.url)
const dirname = path.dirname(filename)

export default buildConfig({
  admin: {
    user: Users.slug,
    importMap: {
      baseDir: path.resolve(dirname),
    },
  },
  collections: [Users, Groups, Members, AttendanceSessions, AttendanceRecords],
  globals: [Settings],
  // Interface admin en français uniquement.
  i18n: {
    supportedLanguages: { fr },
    fallbackLanguage: 'fr',
  },
  editor: lexicalEditor(),
  secret: process.env.PAYLOAD_SECRET || '',
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
