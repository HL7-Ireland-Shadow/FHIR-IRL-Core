Profile: EncounterIE
Parent: Encounter
Id: encounter-ie
Title: "Encounter (FHIR Core Ireland)"
Description: "As of hl7.fhir.eu.base#2.0.0 and hl7.fhir.uv.ips#2.0.1, neither HL7 Europe Core nor
IPS defines an Encounter profile, even though several EU Core profiles reference Reference(Encounter) untyped. This profile
constrains base FHIR R4 Encounter directly rather than a European parent, and should be retired in favour of a European
profile if/when HL7 Europe publishes one: see mapping.md for the tracked gap. The care-setting binding below is a temporary
national placeholder, not a substitute for a future European terminology binding."
* subject 1..1 MS
* subject only Reference(PatientIE)
* class from IEEncounterCareSettingVS (extensible)
