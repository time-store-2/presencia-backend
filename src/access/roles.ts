import type { Access, FieldAccess } from 'payload'

export type Role = 'admin' | 'assistant'

export const getRole = (req: any): Role | undefined => req?.user?.role as Role | undefined

/** Extrait l'id d'un champ relation (peuplé ou non). */
export const toId = (value: unknown): string | number | undefined => {
  if (value === undefined || value === null) return undefined
  if (typeof value === 'object') return (value as { id: string | number }).id
  return value as string | number
}

/** Ids des groupes assignés à l'utilisateur (rôle assistant). */
export const getAssignedGroupIds = (req: any): Array<string | number> => {
  const groups = req?.user?.assignedGroups
  if (!Array.isArray(groups)) return []
  const ids: Array<string | number> = []
  for (const g of groups) {
    const id = toId(g)
    if (id !== undefined) ids.push(id)
  }
  return ids
}

/** Admin : accès total. */
export const isAdmin: Access = ({ req }) => getRole(req) === 'admin'

/** Groupes : admin → tous, assistant → ses groupes assignés uniquement. */
export const filterGroups: Access = ({ req }) => {
  if (getRole(req) === 'admin') return true
  const ids = getAssignedGroupIds(req)
  if (ids.length === 0) return false
  return { id: { in: ids } }
}

/** Séances : admin → toutes, assistant → séances de ses groupes. */
export const filterSessions: Access = ({ req }) => {
  if (getRole(req) === 'admin') return true
  const ids = getAssignedGroupIds(req)
  if (ids.length === 0) return false
  return { group: { in: ids } }
}

/** Membres : admin → tous, assistant → membres de ses groupes. */
export const filterMembers: Access = ({ req }) => {
  if (getRole(req) === 'admin') return true
  const ids = getAssignedGroupIds(req)
  if (ids.length === 0) return false
  return { groups: { in: ids } }
}

/** Champ rôle : seul l'admin peut le modifier. */
export const canEditRole: FieldAccess = ({ req }) => getRole(req) === 'admin'
