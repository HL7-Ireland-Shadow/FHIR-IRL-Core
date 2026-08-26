Profile: ObservationIE
Parent: http://hl7.eu/fhir/base/StructureDefinition/medicalTestResult-eu-core
Id: observation-ie
Title: "Observation: Medical Test Result (FHIR Core Ireland)"
Description: "National constraint of the HL7 Europe Core Medical Test Result Observation profile. Scope note: this profile
covers diagnostic/laboratory test-result observations only, matching the scope of its EU parent. HL7 Europe Core does not
yet define a general-purpose Observation profile (e.g. vital signs, social history). Extending national Observation coverage
to those categories is deferred to a future version once European coverage (HL7 Europe or IPS) is confirmed. Subject is
tightened to the national Patient profile for referential integrity within FHIR Core Ireland bundles."
* subject only Reference(PatientIE)
