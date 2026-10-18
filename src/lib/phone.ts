/**
 * Normalise un numéro de téléphone au format E.164 : conserve le « + »
 * initial, chiffres uniquement ensuite (ex "+225 07..." → "+22507...").
 * Conserver le « + » permet à l'app de retrouver l'indicatif à l'édition.
 * Utilisé pour stocker, comparer (anti-doublon) et construire les liens wa.me
 * (qui strip eux-mêmes les non-chiffres).
 */
export function normalizePhone(phone: unknown): string {
  if (phone === undefined || phone === null) return ''
  const s = String(phone).trim()
  const plus = s.startsWith('+') ? '+' : ''
  return plus + s.replace(/\D/g, '')
}

/** Un téléphone normalisé valide : « + » optionnel, 8 à 15 chiffres (E.164). */
export function isValidPhone(phone: string): boolean {
  return /^\+?[0-9]{8,15}$/.test(phone)
}
