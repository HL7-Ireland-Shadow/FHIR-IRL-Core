Profile: MedicationRequestIE
Parent: http://hl7.eu/fhir/base/StructureDefinition/medicationRequest-eu-core
Id: medicationrequest-ie
Title: "MedicationRequest (FHIR Core Ireland)"
Description: "National constraint of the HL7 Europe Core MedicationRequest profile. Subject is tightened to the national
Patient profile for referential integrity within FHIR Core Ireland bundles; no other
constraints are introduced. Cross-border exchange of prescriptions remains governed by the MyHealth@EU ePrescription artefacts
(currently CDA-based) and the emerging HL7 Europe Medication Prescription and Dispense IG."
* subject only Reference(PatientIE)
