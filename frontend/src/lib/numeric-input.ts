const PERSIAN_DIGITS = "۰۱۲۳۴۵۶۷۸۹"
const ARABIC_INDIC_DIGITS = "٠١٢٣٤٥٦٧٨٩"

export function toAsciiDigits(value: string): string {
  return value
    .replace(/[۰-۹]/g, (d) => String(PERSIAN_DIGITS.indexOf(d)))
    .replace(/[٠-٩]/g, (d) => String(ARABIC_INDIC_DIGITS.indexOf(d)))
}

/** Normalizes a free-typed numeric string -- Persian/Arabic-Indic digits,
 * the Arabic decimal separator ٫, or a plain comma -- into something
 * Number()/parseFloat() can parse. Native <input type="number"> only ever
 * accepts plain ASCII digits and a "." decimal point, so on a Persian
 * keyboard layout (or a locale that types "," for decimals) it silently
 * rejects or clears otherwise-valid input; a plain text input plus this
 * normalization accepts what the user actually typed instead. */
export function normalizeNumericString(value: string): string {
  return toAsciiDigits(value)
    .replace(/[٫,،]/g, ".")
    .trim()
}
