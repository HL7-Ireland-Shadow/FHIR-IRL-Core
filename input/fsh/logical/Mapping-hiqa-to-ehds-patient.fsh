// Mapping from the HIQA draft demographic logical model to the Xt-EHR EHDS Patient logical model
// (EHDSPatient, EHDSHumanName, EHDSAddress, EHDSTelecom; Xt-EHR EHDS Logical Information Models v1.0.0).
// Elements with no Xt-EHR counterpart are mapped to "no equivalent" so the gaps stay visible.

Mapping: HIQADemographicToEHDSPatient
Id: hiqa-demographic-to-ehds-patient
Title: "HIQA Demographic Dataset to Xt-EHR EHDSPatient"
Source: HIQADemographicDataset
Target: "http://www.xt-ehr.eu/fhir/models/StructureDefinition/EHDSPatient"
* -> "EHDSPatient" "HIQA dataset describes one subject of care, equivalent to the EHDS Patient model."

// Identification
* ihi -> "EHDSPatient.identifier" "Identifier.system = IHI system; EHDSPatient.identifier is 1..*, satisfied by the HIQA-required IHI."
* ihiIssuer -> "EHDSPatient.identifier.assigner" "Via the Identifier datatype's assigner; no dedicated EHDS element."
* healthIdentifierOther -> "EHDSPatient.identifier" "Additional repeat of identifier (e.g. hospital number)."
* healthIdentifierOther.identifier -> "EHDSPatient.identifier"
* healthIdentifierOther.issuer -> "EHDSPatient.identifier.assigner"
* biometricIdentification -> "no equivalent" "EHDSPatient has no biometric element. Not mappable without extending the model."
* biometricIdentification.type -> "no equivalent"
* biometricIdentification.value -> "no equivalent"

// Names
* name -> "EHDSPatient.name" "One HIQA name set maps to one EHDSHumanName."
* name.title -> "EHDSPatient.name.prefix" "Honorific placed before the name."
* name.surname -> "EHDSPatient.name.family" "EHDSHumanName.family is 0..*; repeat in sequenceNumber order."
* name.surname.value -> "EHDSPatient.name.family"
* name.surname.sequenceNumber -> "EHDSPatient.name.family" "Expressed by repeat order only; no explicit sequence element."
* name.givenName -> "EHDSPatient.name.given" "Repeat in sequenceNumber order."
* name.givenName.value -> "EHDSPatient.name.given"
* name.givenName.sequenceNumber -> "EHDSPatient.name.given" "Expressed by repeat order only; no explicit sequence element."
* name.preferredName -> "EHDSPatient.name" "Carry as a separate EHDSHumanName with use = usual (text holds the preferred name); no preferred-name flag in EHDS."
* name.suffix -> "EHDSPatient.name.suffix"
* name.usage -> "EHDSPatient.name.use" "Translate M -> maiden, N -> temp (newborn), L -> official, O -> old/nickname/anonymous as appropriate; EHDS use is a CodeableConcept so a local concept map is required."

// Addresses
* address -> "EHDSPatient.address" "One HIQA address maps to one EHDSAddress."
* address.type -> "EHDSPatient.address.type" "R (place of residence) -> physical; P (postal address) -> postal. Where the residence is the home address, also set EHDSPatient.address.use = home."
* address.buildingSubUnitType -> "EHDSPatient.address.street" "No discrete element: fold into street / text."
* address.buildingSubUnitNumber -> "EHDSPatient.address.houseNumber" "Prefix with sub-unit type, e.g. APT 6, together with streetNumber; otherwise fold into text."
* address.siteName -> "EHDSPatient.address.street" "No discrete element: fold into street / text."
* address.floorLevel -> "EHDSPatient.address.street" "No discrete element: fold into street / text."
* address.streetNumber -> "EHDSPatient.address.houseNumber"
* address.streetName -> "EHDSPatient.address.street"
* address.localityTownland -> "EHDSPatient.address.text" "EHDSAddress has no locality/townland/district element; preserve in text. Irish addresses often depend on this, so flag as a national extension candidate."
* address.town -> "EHDSPatient.address.city"
* address.county -> "EHDSPatient.address.text" "EHDSAddress has no state/county element; preserve in text. National extension candidate."
* address.postalCode -> "EHDSPatient.address.postalCode"
* address.country -> "EHDSPatient.address.country"

// Communication
* communication -> "EHDSPatient.telecom" "One HIQA electronic communication maps to one EHDSTelecom."
* communication.medium -> "EHDSPatient.telecom.type" "T/M -> phone, E -> email, U -> url, O -> other."
* communication.detail -> "EHDSPatient.telecom.value" "EHDSTelecom.value is 1..1 so a HIQA entry without detail cannot be carried."
* communication.contactPreference -> "no equivalent" "Preferred contact times have no EHDS element."
* communication.usage -> "EHDSPatient.telecom.use" "P -> home (personal), B -> work (business); A -> repeat for both."

// Additional demographics
* dateOfBirth -> "EHDSPatient.dateOfBirth" "EHDS type is dateTime; a date or partial date is valid."
* gender -> "EHDSPatient.administrativeGender" "HIQA 'gender' is biological sex; M/F/I/U map to male/female/other/unknown."
* mothersBirthSurname -> "no equivalent" "Not in EHDSPatient. R4 core maps this to the patient-mothersMaidenName extension (already aliased in this IG)."
* religion -> "no equivalent" "Not in EHDSPatient."
