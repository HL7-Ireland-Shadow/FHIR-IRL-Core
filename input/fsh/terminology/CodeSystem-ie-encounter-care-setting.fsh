CodeSystem: IEEncounterCareSetting
Id: ie-encounter-care-setting
Title: "IE Encounter Care Setting (illustrative)"
Description: "Illustrative national CodeSystem for Encounter.class, needed only because HL7 Europe Core does not yet
define an Encounter profile or terminology to bind to. PLACEHOLDER: to be reconciled with the HSE's official care-setting
taxonomy, or dropped entirely in favour of a European binding, before this IG leaves draft status."
* ^status = #draft
* ^experimental = true
* #primary-care "Primary Care"
* #acute-hospital "Acute Hospital"
* #community-health "Community Health Service"
* #emergency-department "Emergency Department"
* #mental-health "Mental Health Service"
