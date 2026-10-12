/**
 * Normalise un numéro de téléphone : chiffres uniquement (avec indicatif
 * si l'utilisateur l'a saisi, ex "+225 07..." → "22507...").
 * Utilisé pour stocker, comparer (anti-doublon) et construire les liens wa.me.
 */
export function normalizePhone(phone: unknown): string {
  if (phone === undefined || phone === null) return ''
  return String(phone).replace(/\D/g, '')
}

/** Un téléphone normalisé valide : entre 8 et 15 chiffres (format E.164). */
export function isValidPhone(normalized: string): boolean {
  return /^[0-9]{8,15}$/.test(normalized)
}
