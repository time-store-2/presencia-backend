import 'dotenv/config'
import { getPayload } from 'payload'
import config from './payload.config.js'

/**
 * Crée la première organisation + le premier super admin.
 * Usage : pnpm seed
 * Variables d'environnement (optionnelles) :
 *   SEED_ORG_NAME, SEED_ORG_TYPE, SEED_ORG_CODE,
 *   SEED_EMAIL, SEED_PASSWORD
 * Ne fait rien si des utilisateurs existent déjà.
 */
const run = async () => {
  const payload = await getPayload({ config })

  const { totalDocs: userCount } = await payload.count({ collection: 'users' })
  if (userCount > 0) {
    console.log('Des utilisateurs existent déjà : seed ignoré.')
    process.exit(0)
  }

  const orgName = process.env.SEED_ORG_NAME || 'Mon Organisation'
  const orgType = process.env.SEED_ORG_TYPE || 'eglise'
  const orgCode = process.env.SEED_ORG_CODE || 'ORG-001'
  const email = process.env.SEED_EMAIL || 'admin@presencia.local'
  const password = process.env.SEED_PASSWORD || 'ChangeMe123!'

  const organization = await payload.create({
    collection: 'organizations',
    data: {
      name: orgName,
      type: orgType as 'eglise' | 'ecole' | 'entreprise' | 'association' | 'autre',
      code: orgCode,
    },
    overrideAccess: true,
  })

  await payload.create({
    collection: 'users',
    data: {
      email,
      password,
      firstName: 'Admin',
      lastName: 'Principal',
      role: 'super_admin',
      organization: organization.id,
    },
    overrideAccess: true,
  })

  console.log('')
  console.log('Premier compte créé avec succès :')
  console.log(`  Organisation : ${orgName} (code ${orgCode})`)
  console.log(`  Email        : ${email}`)
  console.log(`  Mot de passe : ${password}`)
  console.log('')
  console.log('Connecte-toi sur le dashboard : http://localhost:3002/admin')
  console.log('Pense à changer le mot de passe après la première connexion.')
  process.exit(0)
}

run().catch((err) => {
  console.error('Échec du seed :', err)
  process.exit(1)
})
