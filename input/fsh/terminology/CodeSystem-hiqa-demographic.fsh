// Closed code lists from the HIQA Draft National Demographic Dataset (v0.20, Feb 2013), section 8.
// Lists the draft describes as "indicative / non-exhaustive" (name title, suffix, religion, building
// sub-unit type, floor/level type, biometric type, county) are deliberately left unbound in the logical model.

CodeSystem: HIQANameUsageCS
Id: hiqa-name-usage
Title: "HIQA Name Usage Classification"
Description: "Name usage classification (HIQA 8.3.8). The draft lists these as examples; its numeric codes are not aligned to the letter codes in the source table, so the alternative letter codes are used."
* ^status = #draft
* ^caseSensitive = true
* #M "Pre-marriage name" "Name used prior to marriage, often referred to as maiden name."
* #N "Newborn name" "Reserved for unnamed newborn babies; acts as the preferred name until an actual name is available."
* #L "Registered name"
* #O "Other name" "Any other name the subject is or has been known by, including misspellings and retained variations."

CodeSystem: HIQAAddressTypeCS
Id: hiqa-address-type
Title: "HIQA Address Type"
Description: "Address type (HIQA 8.4.10)."
* ^status = #draft
* ^caseSensitive = true
* #R "Place of residence"
* #P "Postal address"

CodeSystem: HIQACommunicationMediumCS
Id: hiqa-communication-medium
Title: "HIQA Electronic Communication Medium"
Description: "Electronic communication medium (HIQA 8.5.1)."
* ^status = #draft
* ^caseSensitive = true
* #T "Telephone (excluding mobile)"
* #M "Mobile phone"
* #E "Email"
* #U "URL/web address"
* #O "Other"

CodeSystem: HIQAContactPreferenceCS
Id: hiqa-contact-preference
Title: "HIQA Electronic Contact Preference"
Description: "Electronic contact preference code (HIQA 8.5.3). Draft list is non-exhaustive."
* ^status = #draft
* ^caseSensitive = true
* #B "Business hours"
* #D "Day time hours"
* #W "Weekend hours"
* #A "At all times"
* #E "Evening/night hours"

CodeSystem: HIQAContactUsageCS
Id: hiqa-contact-usage
Title: "HIQA Electronic Contact Usage"
Description: "Electronic contact usage code (HIQA 8.5.4)."
* ^status = #draft
* ^caseSensitive = true
* #B "Business"
* #P "Personal"
* #A "Both business and personal use"

CodeSystem: HIQAGenderCS
Id: hiqa-gender
Title: "HIQA Gender"
Description: "Gender (HIQA 8.6.2). The draft defines this as the biological sex of the subject of care, not gender identity."
* ^status = #draft
* ^caseSensitive = true
* #M "Male"
* #F "Female"
* #I "Intersex or indeterminate" "Should not be asked on collection forms; only recorded if volunteered or evident."
* #U "Not stated/inadequately described" "Should not be used on primary collection forms."
