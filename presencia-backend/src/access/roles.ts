import type { Access, FieldAccess } from 'payload'

export type Role = 'super_admin' | 'org_admin' | 'group_leader'

export const getRole = (req: any): Role | undefined => req?.user?.role as Role | undefined

/** Extrait l'id d'un champ relation (peuplé ou non). SQLite = number, Mongo = string. */
export const toId = (value: unknown): string | number | undefined => {
  if (value === undefined || value === null) return undefined
  if (typeof value === 'object') return (value as { id: string | number }).id
  return value as string | number
}

export const getOrgId = (req: any): string | number | undefined =>
  toId(req?.user?.organization)

export const getGroupId = (req: any): string | number | undefined =>
  toId(req?.user?.group)

/** Super admin : accès total. Org admin : tout de son organisation. */
export const isSuperAdmin: Access = ({ req }) => getRole(req) === 'super_admin'

/**
 * Bootstrap : autorise la création du tout premier utilisateur
 * (ou de la toute première organisation) sans être connecté.
 * Dès qu'un enregistrement existe, seuls les admins peuvent créer.
 */
const allowIfEmpty =
  (collection: 'users' | 'organizations'): Access =>
  async ({ req }) => {
    const role = getRole(req)
    if (role === 'super_admin' || role === 'org_admin') return true
    const { totalDocs } = await req.payload.count({ collection })
    return totalDocs === 0
  }

export const canCreateUser = allowIfEmpty('users')
export const canCreateOrganization = allowIfEmpty('organizations')

export const isOrgAdmin: Access = ({ req }) => {
  const role = getRole(req)
  return role === 'super_admin' || role === 'org_admin'
}

/**
 * Lecture filtrée par organisation :
 * - super_admin → tout
 * - org_admin / group_leader → uniquement leur organisation
 */
export const filterByOrganization: Access = ({ req }) => {
  const role = getRole(req)
  if (role === 'super_admin') return true
  const orgId = getOrgId(req)
  if (!orgId) return false
  return { organization: { equals: orgId } }
}

/** Organisations : chacun ne voit que la sienne (filtrage sur l'id). */
export const filterOwnOrganization: Access = ({ req }) => {
  const role = getRole(req)
  if (role === 'super_admin') return true
  const orgId = getOrgId(req)
  if (!orgId) return false
  return { id: { equals: orgId } }
}

/** Groupes : org_admin → toute l'org, responsable → son groupe uniquement. */
export const filterGroups: Access = ({ req }): ReturnType<Access> => {
  const role = getRole(req)
  if (role === 'super_admin') return true
  if (role === 'org_admin') {
    const orgId = getOrgId(req)
    if (!orgId) return false
    return { organization: { equals: orgId } }
  }
  const groupId = getGroupId(req)
  if (groupId === undefined) return false
  return { id: { equals: groupId } }
}

/** Séances : org_admin → toute l'org, responsable → séances de son groupe. */
export const filterSessions: Access = ({ req }): ReturnType<Access> => {
  const role = getRole(req)
  if (role === 'super_admin') return true
  if (role === 'org_admin') {
    const orgId = getOrgId(req)
    if (!orgId) return false
    return { organization: { equals: orgId } }
  }
  const groupId = getGroupId(req)
  if (groupId === undefined) return false
  return { group: { equals: groupId } }
}

/** Membres : org_admin → toute l'org, responsable → membres de son groupe. */
export const filterMembers: Access = ({ req }): ReturnType<Access> => {
  const role = getRole(req)
  if (role === 'super_admin') return true
  if (role === 'org_admin') {
    const orgId = getOrgId(req)
    if (!orgId) return false
    return { organization: { equals: orgId } }
  }
  const groupId = getGroupId(req)
  if (groupId === undefined) return false
  return { groups: { in: [groupId] } }
}

/** Champ rôle : seul super_admin / org_admin peut le modifier. */
export const canEditRole: FieldAccess = ({ req }) => {
  const role = getRole(req)
  return role === 'super_admin' || role === 'org_admin'
}
