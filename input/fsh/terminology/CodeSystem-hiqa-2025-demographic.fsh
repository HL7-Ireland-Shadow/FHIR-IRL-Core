// Value sets that the HIQA Draft National Standard for a Demographic Dataset (2025) actually specifies.
// The 2025 draft states that "coded values have not yet been specified" for everything else (titles, suffixes,
// address type, communication type, roles, relationship, ethnicity, nationality, ...), so those elements are unbound.

CodeSystem: HIQA2025SexCS
Id: hiqa-2025-sex
Title: "HIQA 2025 Sex at Birth"
Description: "Sex at birth values (HIQA 2025 draft, 4.3.1)."
* ^status = #draft
* ^caseSensitive = true
* #M "Male"
* #F "Female"
* #U "Unknown"

CodeSystem: HIQA2025NameUsageCS
Id: hiqa-2025-name-usage
Title: "HIQA 2025 Name Usage Classification"
Description: "Name usage classification (HIQA 2025 draft, 1.5 guidance)."
* ^status = #draft
* ^caseSensitive = true
* #R "Reporting name" "Name to be used for reporting with a specific identifier; only one per identifier at a time."
* #N "Newborn name" "Reserved for unnamed newborn babies; acts as the preferred name until an actual name is available."
* #B "Professional or business name" "Name used for business or professional purposes."
* #M "Maiden name" "Name used prior to marriage."
* #O "Other name" "Any other name the person is or has been known by, including misspellings and retained variations."

CodeSystem: HIQA2025YesNoUnknownCS
Id: hiqa-2025-yes-no-unknown
Title: "HIQA 2025 Yes/No/Unknown"
Description: "Yes/No/Unknown (HIQA 2025 draft, 5.3.1 contact person indicator)."
* ^status = #draft
* ^caseSensitive = true
* #Y "Yes"
* #N "No"
* #U "Unknown"
