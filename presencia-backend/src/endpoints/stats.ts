import type { Endpoint } from 'payload'

type Id = string | number

const toId = (value: unknown): Id | undefined => {
  if (value === undefined || value === null) return undefined
  if (typeof value === 'object') return (value as { id: Id }).id
  return value as Id
}

const emptyCounts = () => ({ present: 0, absent: 0, late: 0, excused: 0 })

type Scope = { organizationId: Id; groupId?: Id; role?: string }

async function getScope(req: any): Promise<Scope | null> {
  if (!req.user) return null
  const organizationId = toId(req.user.organization)
  if (organizationId === undefined) return null
  return {
    organizationId,
    groupId: toId(req.user.group),
    role: req.user.role as string,
  }
}

async function getScopedSessions(req: any, scope: Scope, extraWhere: object = {}) {
  const where: Record<string, unknown> = {
    organization: { equals: scope.organizationId },
    ...extraWhere,
  }
  // Un responsable ne voit que les séances de son groupe.
  if (scope.role === 'group_leader' && scope.groupId !== undefined) {
    where.group = { equals: scope.groupId }
  }
  const res = await req.payload.find({
    collection: 'attendance-sessions',
    where,
    sort: '-date',
    limit: 1000,
    depth: 0,
  })
  return res.docs as any[]
}

async function getRecordsForSessions(req: any, sessionIds: Id[]) {
  if (sessionIds.length === 0) return []
  const res = await req.payload.find({
    collection: 'attendance-records',
    where: { session: { in: sessionIds } },
    limit: 5000,
    depth: 0,
  })
  return res.docs as any[]
}

async function getScopedMembers(req: any, scope: Scope) {
  const where: Record<string, unknown> = {
    organization: { equals: scope.organizationId },
  }
  if (scope.role === 'group_leader' && scope.groupId !== undefined) {
    where.groups = { in: [scope.groupId] }
  }
  const res = await req.payload.find({
    collection: 'members',
    where,
    limit: 2000,
    depth: 0,
  })
  return res.docs as any[]
}

/**
 * GET /api/org-stats
 * Statistiques globales de l'organisation (ou du groupe pour un responsable).
 * Formes identiques à l'ancien SQLite : todayCounts, globalCounts,
 * totalSessions, topPresent, topAbsent, inactivityAlerts.
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
    const memberById = new Map<Id, any>(members.map((m) => [m.id as Id, m]))

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
    for (const r of res.docs as any[]) {
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
    if (scope.role === 'group_leader' && scope.groupId !== undefined && scope.groupId !== groupId) {
      return Response.json({ errors: [{ message: 'Accès refusé.' }] }, { status: 403 })
    }

    // Fin inclusive : on ajoute 1 jour (même sémantique que l'ancien SQLite).
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
