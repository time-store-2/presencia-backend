import type { Endpoint } from 'payload'
import { renderTemplate, sendWhatsApp } from '../lib/whatsapp'

type Body = {
  sessionId: number | string
}

/**
 * POST /api/notify-absence { sessionId }
 * Réservé aux utilisateurs connectés (le filtrage par rôle se fait
 * via les collections : un assistant ne peut notifier que ses séances).
 * Envoie le message d'absence (Réglages → absenceMessage)
 * à chaque membre marqué absent de la séance.
 */
export const notifyAbsence: Endpoint = {
  path: '/notify-absence',
  method: 'post',
  handler: async (req) => {
    if (!req.user) {
      return Response.json({ errors: [{ message: 'Non authentifié.' }] }, { status: 401 })
    }

    let body: Body | undefined
    try {
      body = (await req.json?.()) as Body | undefined
    } catch {
      return Response.json({ errors: [{ message: 'Corps JSON invalide.' }] }, { status: 400 })
    }
    if (!body?.sessionId) {
      return Response.json({ errors: [{ message: 'sessionId requis.' }] }, { status: 400 })
    }

    const session = await req.payload.findByID({
      collection: 'attendance-sessions',
      id: body.sessionId,
      depth: 2,
    })
    if (!session) {
      return Response.json({ errors: [{ message: 'Séance introuvable.' }] }, { status: 404 })
    }

    const records = await req.payload.find({
      collection: 'attendance-records',
      where: {
        and: [{ session: { equals: body.sessionId } }, { status: { equals: 'absent' } }],
      },
      limit: 500,
      depth: 1,
    })

    const settings = (await req.payload
      .findGlobal({ slug: 'settings', overrideAccess: true })
      .catch(() => null)) as unknown as { absenceMessage?: string | null } | null
    const template =
      settings?.absenceMessage ||
      'Bonjour {prenom}, tu as manqué la séance de {groupe} du {date}.'
    const group = session.group as unknown as { name?: string }
    const date = new Date(session.date as string).toLocaleDateString('fr-FR')

    const results: Array<{ member: unknown; sent: boolean; mode: string }> = []
    for (const record of records.docs) {
      const member = record.member as unknown as {
        firstName?: string
        lastName?: string
        phone?: string | null
      }
      if (!member?.phone) continue
      const message = renderTemplate(template, {
        prenom: member.firstName ?? '',
        nom: member.lastName ?? '',
        groupe: group?.name ?? '',
        date,
      })
      const outcome = await sendWhatsApp(member.phone, message)
      results.push({ member: record.member, ...outcome })
    }

    return Response.json({ notified: results.length, results })
  },
}
