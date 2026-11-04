/** Indicatif par défaut (Togo) pour les numéros saisis sans indicatif. */
export const DEFAULT_COUNTRY_CODE = '228'

/**
 * Normalise un numéro au format E.164 (« + » puis chiffres), avec les mêmes
 * règles que l'app :
 * - espaces, points, tirets et parenthèses ignorés ;
 * - « 00 » initial → « + » (0022899548903 → +22899548903) ;
 * - 8 chiffres sans indicatif → +228 (99548903 → +22899548903) ;
 * - 228XXXXXXXX / 225XXXXXXXXXX sans « + » → « + » ajouté ;
 * - autre numéro sans indicatif → +228 devant.
 * Sert à stocker, comparer (anti-doublon) et construire tel: / wa.me.
 */
export function normalizePhone(phone: unknown): string {
  if (phone === undefined || phone === null) return ''
  let s = String(phone).trim().replace(/[\s.\-()]/g, '')
  if (s === '') return ''
  if (s.startsWith('00')) s = `+${s.slice(2)}`
  const hasPlus = s.startsWith('+')
  const digits = s.replace(/\D/g, '')
  if (digits === '') return ''
  if (hasPlus) return `+${digits}`
  if (digits.length === 8) return `+${DEFAULT_COUNTRY_CODE}${digits}`
  if (digits.startsWith('228') && digits.length === 11) return `+${digits}`
  if (digits.startsWith('225') && digits.length === 13) return `+${digits}`
  return `+${DEFAULT_COUNTRY_CODE}${digits}`
}

/** Un téléphone normalisé valide : « + » puis 8 à 15 chiffres (E.164). */
export function isValidPhone(phone: string): boolean {
  return /^\+[0-9]{8,15}$/.test(phone)
}
