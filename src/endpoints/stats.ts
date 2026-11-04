import type { Endpoint, PayloadRequest, Where } from 'payload'
import { getVisibleGroupIds } from '../access/roles'

type Id = string | number

// Documents retournés par payload.find (depth: 0) — types locaux minimaux.
type SessionDoc = { id: Id; date: string | Date; group?: unknown; notes?: string }
type RecordDoc = { id: Id; status: string; member?: unknown; session?: unknown }
type MemberDoc = { id: Id; firstName?: string; lastName?: string; groups?: unknown[] }

const toId = (value: unknown): Id | undefined => {
  if (value === undefined || value === null) return undefined
  if (typeof value === 'object') return (value as { id: Id }).id
  return value as Id
}

const emptyCounts = () => ({ present: 0, absent: 0, late: 0, excused: 0 })

/**
 * Portée de l'utilisateur connecté :
 * - admin → tout (groupIds undefined)
 * - pasteur → uniquement ses groupes (créés ou assignés)
 */
type Scope = { groupIds?: Id[]; role?: string }

async function getScope(req: PayloadRequest): Promise<Scope | null> {
  const user = req.user as { role?: string } | null | undefined
  if (!user) return null
  if (user.role === 'admin') return { role: 'admin' }
  return { groupIds: (await getVisibleGroupIds(req)) as Id[], role: user.role as string }
}

function groupAllowed(scope: Scope, groupId: Id): boolean {
  if (scope.groupIds === undefined) return true
  return scope.groupIds.some((id) => String(id) === String(groupId))
}

async function getScopedSessions(
  req: PayloadRequest,
  scope: Scope,
  extraWhere: object = {},
): Promise<SessionDoc[]> {
  const where: Where = { ...extraWhere } as Where
  // Un pasteur ne voit que les séances de ses groupes.
  if (scope.groupIds !== undefined) {
    where.group = { in: scope.groupIds }
  }
  const res = await req.payload.find({
    collection: 'attendance-sessions',
    where,
    sort: '-date',
    limit: 1000,
    depth: 0,
  })
  return res.docs as unknown as SessionDoc[]
}

async function getRecordsForSessions(req: PayloadRequest, sessionIds: Id[]): Promise<RecordDoc[]> {
  if (sessionIds.length === 0) return []
  const res = await req.payload.find({
    collection: 'attendance-records',
    where: { session: { in: sessionIds } },
    limit: 5000,
    depth: 0,
  })
  return res.docs as unknown as RecordDoc[]
}

async function getScopedMembers(req: PayloadRequest, scope: Scope): Promise<MemberDoc[]> {
  const where: Where = {}
  if (scope.groupIds !== undefined) {
    where.groups = { in: scope.groupIds }
  }
  const res = await req.payload.find({
    collection: 'members',
    where,
    limit: 2000,
    depth: 0,
  })
  return res.docs as unknown as MemberDoc[]
}

/**
 * GET /api/org-stats
 * Statistiques globales (ou du périmètre du pasteur).
 * Formes : todayCounts, globalCounts, totalSessions,
 * topPresent, topAbsent, inactivityAlerts.
 */
export const orgStats: Endpoint = {
  path: '/org-stats',
  method: 'get',
  handler: async (req) => {
    const scope = await getScope(req)
    if (!scope) {
      return Response.json({ errors: [{ message: 'Non authentifié.' }] }, { status: 401 })
    }

    const sessions = await getScopedSessions(req, scope)
    const sessionIds = sessions.map((s) => s.id as Id)
    const records = await getRecordsForSessions(req, sessionIds)
    const members = await getScopedMembers(req, scope)
    const memberById = new Map<Id, MemberDoc>(members.map((m) => [m.id as Id, m]))

    const globalCounts = emptyCounts()
    for (const r of records) {
      if (r.status in globalCounts) globalCounts[r.status as keyof typeof globalCounts] += 1
    }

    const today = new Date().toISOString().slice(0, 10)
    const sessionDateById = new Map<Id, string>(sessions.map((s) => [s.id as Id, String(s.date).slice(0, 10)]))
    const todayCounts = emptyCounts()
    for (const r of records) {
      if (sessionDateById.get(toId(r.session) as Id) === today && r.status in todayCounts) {
        todayCounts[r.status as keyof typeof todayCounts] += 1
      }
    }

    const presentByMember = new Map<Id, number>()
    const absentByMember = new Map<Id, number>()
    for (const r of records) {
      const mid = toId(r.member) as Id
      if (r.status === 'present') presentByMember.set(mid, (presentByMember.get(mid) ?? 0) + 1)
      if (r.status === 'absent') absentByMember.set(mid, (absentByMember.get(mid) ?? 0) + 1)
    }
    const top = (map: Map<Id, number>) =>
      [...map.entries()]
        .sort((a, b) => b[1] - a[1])
        .slice(0, 5)
        .map(([id, count]) => ({
          id,
          first_name: memberById.get(id)?.firstName ?? '',
          last_name: memberById.get(id)?.lastName ?? '',
          count,
        }))
    const topPresent = top(presentByMember)
    const topAbsent = top(absentByMember)

    // Alertes : membres absents à 2+ des 3 dernières séances.
    const lastThree = new Set(sessionIds.slice(0, 3))
    const missingByMember = new Map<Id, number>()
    for (const r of records) {
      if (r.status === 'absent' && lastThree.has(toId(r.session) as Id)) {
        const mid = toId(r.member) as Id
        missingByMember.set(mid, (missingByMember.get(mid) ?? 0) + 1)
      }
    }
    const inactivityAlerts = [...missingByMember.entries()]
      .filter(([, n]) => n >= 2)
      .sort((a, b) => b[1] - a[1])
      .map(([id, missing_count]) => ({
        id,
        first_name: memberById.get(id)?.firstName ?? '',
        last_name: memberById.get(id)?.lastName ?? '',
        missing_count,
      }))

    return Response.json({
      totalSessions: sessions.length,
      globalCounts,
      todayCounts,
      topPresent,
      topAbsent,
      inactivityAlerts,
    })
  },
}

/**
 * GET /api/member-stats?memberId=
 * Compteurs + historique d'un membre.
 */
export const memberStats: Endpoint = {
  path: '/member-stats',
  method: 'get',
  handler: async (req) => {
    const scope = await getScope(req)
    if (!scope) {
      return Response.json({ errors: [{ message: 'Non authentifié.' }] }, { status: 401 })
    }
    const url = new URL(req.url ?? '', 'http://localhost')
    const memberId = url.searchParams.get('memberId')
    if (!memberId) {
      return Response.json({ errors: [{ message: 'memberId requis.' }] }, { status: 400 })
    }

    // Un pasteur ne peut consulter que les membres de ses groupes.
    if (scope.groupIds !== undefined) {
      try {
        const member = await req.payload.findByID({
          collection: 'members',
          id: isNaN(Number(memberId)) ? memberId : Number(memberId),
          depth: 0,
        })
        const memberGroups = ((member as MemberDoc | null)?.groups as unknown[] | undefined) ?? []
        const allowed = memberGroups.some((g) =>
          scope.groupIds!.some((id) => String(id) === String(toId(g))),
        )
        if (!allowed) {
          return Response.json({ errors: [{ message: 'Accès refusé.' }] }, { status: 403 })
        }
      } catch {
        return Response.json({ errors: [{ message: 'Membre introuvable.' }] }, { status: 404 })
      }
    }

    const sessions = await getScopedSessions(req, scope)
    const sessionById = new Map(sessions.map((s) => [String(s.id), s]))
    const res = await req.payload.find({
      collection: 'attendance-records',
      where: { member: { equals: isNaN(Number(memberId)) ? memberId : Number(memberId) } },
      limit: 2000,
      depth: 0,
      sort: '-createdAt',
    })

    const stats = emptyCounts()
    const history: Array<Record<string, unknown>> = []
    for (const r of res.docs as unknown as RecordDoc[]) {
      if (r.status in stats) stats[r.status as keyof typeof stats] += 1
      const session = sessionById.get(String(toId(r.session)))
      history.push({
        session_id: toId(r.session),
        status: r.status,
        session_title: (session?.notes as string) || '',
        session_date: session?.date ?? null,
      })
    }
    return Response.json({ stats, history })
  },
}

/**
 * GET /api/period-stats?groupId=&start=AAAA-MM-JJ&end=AAAA-MM-JJ
 * Compteurs par membre pour un groupe sur une période (écran rapport).
 */
export const periodStats: Endpoint = {
  path: '/period-stats',
  method: 'get',
  handler: async (req) => {
    const scope = await getScope(req)
    if (!scope) {
      return Response.json({ errors: [{ message: 'Non authentifié.' }] }, { status: 401 })
    }
    const url = new URL(req.url ?? '', 'http://localhost')
    const groupIdParam = url.searchParams.get('groupId')
    const start = url.searchParams.get('start')
    const end = url.searchParams.get('end')
    if (!groupIdParam || !start || !end) {
      return Response.json(
        { errors: [{ message: 'groupId, start et end requis.' }] },
        { status: 400 },
      )
    }
    const groupId: Id = isNaN(Number(groupIdParam)) ? groupIdParam : Number(groupIdParam)
    if (!groupAllowed(scope, groupId)) {
      return Response.json({ errors: [{ message: 'Accès refusé.' }] }, { status: 403 })
    }

    // Fin inclusive : on ajoute 1 jour.
    const endExclusive = new Date(`${end}T00:00:00Z`)
    endExclusive.setUTCDate(endExclusive.getUTCDate() + 1)
    const sessions = await getScopedSessions(req, scope, {
      group: { equals: groupId },
      and: [
        { date: { greater_than_equal: start } },
        { date: { less_than: endExclusive.toISOString().slice(0, 10) } },
      ],
    })
    const records = await getRecordsForSessions(
      req,
      sessions.map((s) => s.id as Id),
    )
    type Counts = { present: number; absent: number; late: number; excused: number }
    const byMember: Record<string, Counts> = {}
    for (const r of records) {
      const key = String(toId(r.member))
      byMember[key] ??= emptyCounts()
      const status = r.status as keyof Counts
      if (status === 'present' || status === 'absent' || status === 'late' || status === 'excused') {
        byMember[key][status] += 1
      }
    }
    return Response.json(byMember)
  },
}
