import { sqliteAdapter } from '@payloadcms/db-sqlite'
import { lexicalEditor } from '@payloadcms/richtext-lexical'
import path from 'path'
import { buildConfig } from 'payload'
import { fileURLToPath } from 'url'

import { Users } from './collections/Users'
import { Groups } from './collections/Groups'
import { Members } from './collections/Members'
import { AttendanceSessions } from './collections/AttendanceSessions'
import { AttendanceRecords } from './collections/AttendanceRecords'
import { Settings } from './globals/Settings'
import { notifyAbsence } from './endpoints/notifyAbsence'
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
  editor: lexicalEditor(),
  secret: process.env.PAYLOAD_SECRET || '',
  typescript: {
    outputFile: path.resolve(dirname, 'payload-types.ts'),
  },
  db: sqliteAdapter({
    client: {
      url: process.env.DATABASE_URL || 'file:./presencia.db',
    },
  }),
  endpoints: [notifyAbsence, orgStats, memberStats, periodStats, publicGroups, register],
  localization: {
    locales: ['en'],
    fallback: true,
    defaultLocale: 'en',
  },
  plugins: [],
})
