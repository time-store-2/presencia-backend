/**
 * Envoi WhatsApp via un fournisseur externe branché par webhook.
 *
 * Configuration (.env) :
 *   WHATSAPP_WEBHOOK_URL=https://mon-evolution-api.com/message/sendText/instance
 *   WHATSAPP_API_KEY=ma-cle-api
 *
 * Sans webhook configuré, les messages sont journalisés (mode dev)
 * au lieu d'être envoyés. Compatible Evolution API / Baileys / ultramsg
 * tant que le webhook accepte { to, message } en JSON.
 */
export async function sendWhatsApp(to: string, message: string): Promise<{ sent: boolean; mode: string }> {
  const webhook = process.env.WHATSAPP_WEBHOOK_URL

  if (!webhook) {
    console.log(`[whatsapp:dev] to=${to} message=${message}`)
    return { sent: false, mode: 'logged' }
  }

  const res = await fetch(webhook, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(process.env.WHATSAPP_API_KEY ? { apikey: process.env.WHATSAPP_API_KEY } : {}),
    },
    body: JSON.stringify({ to, message }),
  })

  if (!res.ok) {
    throw new Error(`Webhook WhatsApp : ${res.status} ${await res.text()}`)
  }
  return { sent: true, mode: 'webhook' }
}

/** Remplace les variables {prenom} {nom} {groupe} {responsable} {date}. */
export function renderTemplate(
  template: string,
  vars: { prenom: string; nom: string; groupe: string; responsable: string; date: string },
): string {
  return template
    .replaceAll('{prenom}', vars.prenom)
    .replaceAll('{nom}', vars.nom)
    .replaceAll('{groupe}', vars.groupe)
    .replaceAll('{responsable}', vars.responsable)
    .replaceAll('{date}', vars.date)
}
