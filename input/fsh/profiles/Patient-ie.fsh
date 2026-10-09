Profile: PatientIE
Parent: http://hl7.eu/fhir/base/StructureDefinition/patient-eu-core
Id: patient-ie
Title: "Patient (FHIR Core Ireland)"
Description: "National constraint of the HL7 Europe Core Patient profile aligned to the HIQA National Standard Demographic Dataset"
* insert IENationalIdentifier
* address.postalCode ^short = "Eircode / postal code"
* address.postalCode ^definition = "The Eircode for the address or other national postal code for non-Ireland addresses. Only the complete postal code should be populated; partial codes should not be used"
