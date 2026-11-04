import type { Access, FieldAccess, PayloadRequest, Where } from 'payload'

/**
 * Deux rôles :
 * - admin   : voit et modifie tout ;
 * - pasteur : ne voit que ses groupes (ceux qu'il a créés + ceux qui lui
 *   sont assignés), leurs membres, leurs séances et leurs présences.
 */
export type Role = 'admin' | 'pasteur'

export const getRole = (req: PayloadRequest): Role | undefined =>
  (req?.user as { role?: Role } | null | undefined)?.role as Role | undefined

const userId = (req: PayloadRequest): number | string | undefined =>
  (req?.user as { id?: number | string } | null | undefined)?.id

/** Extrait l'id d'un champ relation (peuplé ou non). */
export const toId = (value: unknown): string | number | undefined => {
  if (value === undefined || value === null) return undefined
  if (typeof value === 'object') return (value as { id: string | number }).id
  return value as string | number
}

/** Ids des groupes assignés à l'utilisateur par l'admin. */
export const getAssignedGroupIds = (req: PayloadRequest): Array<string | number> => {
  const groups = (req?.user as { assignedGroups?: unknown } | null | undefined)?.assignedGroups
  if (!Array.isArray(groups)) return []
  const ids: Array<string | number> = []
  for (const g of groups) {
    const id = toId(g)
    if (id !== undefined) ids.push(id)
  }
  return ids
}

/**
 * Groupes visibles par un pasteur : assignés + créés par lui.
 * Calculé une fois par requête (req.context).
 */
export const getVisibleGroupIds = async (req: PayloadRequest): Promise<Array<string | number>> => {
  const cacheKey = 'presenciaVisibleGroupIds'
  const cached = req.context?.[cacheKey] as Array<string | number> | undefined
  if (cached) return cached
  const ids = new Set<string | number>(getAssignedGroupIds(req))
  const uid = userId(req)
  if (uid !== undefined) {
    const owned = await req.payload.find({
      collection: 'groups',
      where: { owner: { equals: uid } },
      limit: 1000,
      depth: 0,
      overrideAccess: true,
      req,
    })
    for (const g of owned.docs) ids.add(g.id)
  }
  const list = [...ids]
  if (req.context) req.context[cacheKey] = list
  return list
}

export const isLoggedIn: Access = ({ req }) => Boolean(req?.user)

/** Admin : accès total. */
export const isAdmin: Access = ({ req }) => getRole(req) === 'admin'

/** Groupes : admin → tous, pasteur → ses groupes. */
export const filterGroups: Access = async ({ req }) => {
  if (!req?.user) return false
  if (getRole(req) === 'admin') return true
  const ids = await getVisibleGroupIds(req)
  const uid = userId(req)
  const or: Where[] = []
  if (ids.length > 0) or.push({ id: { in: ids } })
  if (uid !== undefined) or.push({ owner: { equals: uid } })
  return or.length > 0 ? { or } : false
}

/** Séances : admin → toutes, pasteur → séances de ses groupes. */
export const filterSessions: Access = async ({ req }) => {
  if (!req?.user) return false
  if (getRole(req) === 'admin') return true
  const ids = await getVisibleGroupIds(req)
  if (ids.length === 0) return false
  return { group: { in: ids } }
}

/** Membres : admin → tous, pasteur → membres de ses groupes ou ajoutés par lui. */
export const filterMembers: Access = async ({ req }) => {
  if (!req?.user) return false
  if (getRole(req) === 'admin') return true
  const ids = await getVisibleGroupIds(req)
  const uid = userId(req)
  const or: Where[] = []
  if (ids.length > 0) or.push({ groups: { in: ids } })
  if (uid !== undefined) or.push({ createdBy: { equals: uid } })
  return or.length > 0 ? { or } : false
}

/** Présences : admin → toutes, pasteur → présences des séances de ses groupes. */
export const filterRecords: Access = async ({ req }) => {
  if (!req?.user) return false
  if (getRole(req) === 'admin') return true
  const ids = await getVisibleGroupIds(req)
  if (ids.length === 0) return false
  return { 'session.group': { in: ids } }
}

/** Champ rôle : seul l'admin peut le modifier. */
export const canEditRole: FieldAccess = ({ req }) => getRole(req) === 'admin'

const inVisible = (ids: Array<string | number>, id: unknown): boolean => {
  const v = toId(id)
  return v !== undefined && ids.some((x) => String(x) === String(v))
}

/** Création de séance : pasteur → seulement dans un de ses groupes. */
export const canCreateSession: Access = async ({ req, data }) => {
  if (!req?.user) return false
  if (getRole(req) === 'admin') return true
  const ids = await getVisibleGroupIds(req)
  return inVisible(ids, (data as { group?: unknown } | undefined)?.group)
}

/** Création de présence : pasteur → seulement pour une séance de ses groupes. */
export const canCreateRecord: Access = async ({ req, data }) => {
  if (!req?.user) return false
  if (getRole(req) === 'admin') return true
  const sessionId = toId((data as { session?: unknown } | undefined)?.session)
  if (sessionId === undefined) return false
  const session = await req.payload
    .findByID({ collection: 'attendance-sessions', id: sessionId, depth: 0, overrideAccess: true })
    .catch(() => null)
  if (!session) return false
  const ids = await getVisibleGroupIds(req)
  return inVisible(ids, (session as { group?: unknown }).group)
}

/** Création de membre : pasteur → groupes choisis parmi les siens uniquement. */
export const canCreateMember: Access = async ({ req, data }) => {
  if (!req?.user) return false
  if (getRole(req) === 'admin') return true
  const groups = (data as { groups?: unknown[] } | undefined)?.groups ?? []
  if (!Array.isArray(groups) || groups.length === 0) return true
  const ids = await getVisibleGroupIds(req)
  return groups.every((g) => inVisible(ids, g))
}
