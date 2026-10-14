// Mappings from the HIQA 2025 demographic logical model to the Xt-EHR EHDS logical models (v1.0.0).
// Three mappings are needed because the HIQA dataset spans person, related-person and GP concepts that
// Xt-EHR holds in separate models. Elements with no Xt-EHR counterpart are mapped to "no equivalent".

// ---------------------------------------------------------------------------
// Person -> EHDSPatient (with EHDSHumanName, EHDSAddress, EHDSTelecom)
// ---------------------------------------------------------------------------
Mapping: HIQA2025ToEHDSPatient
Id: hiqa-2025-to-ehds-patient
Title: "HIQA Demographic Dataset (2025) to Xt-EHR EHDSPatient"
Source: HIQADemographicDataset2025
Target: "http://www.xt-ehr.eu/fhir/models/StructureDefinition/EHDSPatient"
* -> "EHDSPatient" "A HIQA 'person' is the EHDS patient (subject of care)."

* name -> "EHDSPatient.name" "One HIQA name set maps to one EHDSHumanName."
* name.title -> "EHDSPatient.name.prefix"
* name.forename -> "EHDSPatient.name.given"
* name.surname -> "EHDSPatient.name.family"
* name.suffix -> "EHDSPatient.name.suffix"
* name.usage -> "EHDSPatient.name.use" "EHDS use is a CodeableConcept; a concept map is needed: M -> maiden, N -> temp, B -> official/professional, R and O have no direct EHDS value."
* name.preferredName -> "EHDSPatient.name" "Carry as an additional EHDSHumanName with use = usual and the preferred name in text; EHDS has no preferred flag."

* address -> "EHDSPatient.address"
* address.addressLine -> "EHDSPatient.address.street" "Parse into street / houseNumber where possible; otherwise carry the line(s) in street or text. Sub-unit, site name and floor have no discrete EHDS element."
* address.localityTownland -> "EHDSPatient.address.city" "Suburb/town/townland/locality all map to the single city element."
* address.county -> "EHDSPatient.address.text" "EHDSAddress has no district/county element; preserve in text. National extension candidate."
* address.country -> "EHDSPatient.address.country"
* address.postcode -> "EHDSPatient.address.postalCode" "Eircode for Irish addresses."
* address.type -> "EHDSPatient.address.type" "Place of residence -> physical (use home); postal address -> postal; 'business' -> use work."

* ppsn -> "EHDSPatient.identifier" "Identifier.system = PPSN system."
* ihi -> "EHDSPatient.identifier" "Identifier.system = IHI system; satisfies the EHDS 1..* identifier requirement."
* otherHealthIdentifier -> "EHDSPatient.identifier"
* otherHealthIdentifier.value -> "EHDSPatient.identifier.value"
* otherHealthIdentifier.type -> "EHDSPatient.identifier.type"

* dateOfBirth -> "EHDSPatient.dateOfBirth" "EHDS type is dateTime; an approximate/partial HIQA date remains valid as a partial date."
* placeOfBirth -> "no equivalent" "Not in EHDSPatient. R4 has the patient-birthPlace extension (already aliased in this IG)."
* sexDetails -> "EHDSPatient.administrativeGender"
* sexDetails.sex -> "EHDSPatient.administrativeGender" "M/F/U -> male/female/unknown. EHDS has no 'other' mapping for sex at birth."
* sexDetails.protectionFlag -> "no equivalent" "Confidentiality of sex is not in EHDSPatient; consider security labels."
* genderDetails -> "no equivalent" "EHDSPatient has administrative gender only, no gender identity. Gender identity is not mappable without extending the model."
* genderDetails.gender -> "no equivalent"
* genderDetails.protectionFlag -> "no equivalent"
* mothersBirthFamilyName -> "no equivalent" "Not in EHDSPatient. R4 has the patient-mothersMaidenName extension (already aliased in this IG)."
* nationality -> "no equivalent" "Not in EHDSPatient. R4 has the patient-nationality extension (already aliased in this IG)."
* ethnicity -> "no equivalent" "Not in EHDSPatient."
* dateOfDeath -> "EHDSPatient.deceased[x]" "Use the dateTime choice."

* communication -> "EHDSPatient.telecom" "One HIQA communication entry maps to one EHDSTelecom."
* communication.type -> "EHDSPatient.telecom.type" "Landline/mobile -> phone, email -> email, URL -> url, other -> other."
* communication.value -> "EHDSPatient.telecom.value"

* gp -> "no equivalent" "EHDSPatient has no care-team or GP link; see HIQA2025ToEHDSHealthProfessional for the GP cluster."
* contactPerson -> "no equivalent" "EHDSPatient has no contact element; see HIQA2025ToEHDSRelatedPerson."
* personalCharacteristic -> "no equivalent" "Signature or photograph is not in EHDSPatient."

// ---------------------------------------------------------------------------
// Contact person cluster -> EHDSRelatedPerson
// ---------------------------------------------------------------------------
Mapping: HIQA2025ToEHDSRelatedPerson
Id: hiqa-2025-to-ehds-relatedperson
Title: "HIQA Demographic Dataset (2025) contact person to Xt-EHR EHDSRelatedPerson"
Source: HIQADemographicDataset2025
Target: "http://www.xt-ehr.eu/fhir/models/StructureDefinition/EHDSRelatedPerson"
* contactPerson -> "EHDSRelatedPerson" "One contact person cluster = one EHDSRelatedPerson; EHDSRelatedPerson.subject refers to the patient."
* contactPerson.indicator -> "no equivalent" "Yes = a RelatedPerson instance exists; No/Unknown = none. Not a data element in EHDS."
* contactPerson.role -> "no equivalent" "EHDSRelatedPerson has no role element (legal guardian, emergency contact, decision supporter); at best fold into relationship."
* contactPerson.relationship -> "EHDSRelatedPerson.relationship" "EHDS relationship is 0..1, HIQA 0..*."
* contactPerson.forename -> "EHDSRelatedPerson.name.given"
* contactPerson.surname -> "EHDSRelatedPerson.name.family"
* contactPerson.telephone -> "EHDSRelatedPerson.telecom.value" "EHDSTelecom.type = phone."
* contactPerson.email -> "EHDSRelatedPerson.telecom.value" "EHDSTelecom.type = email."

// ---------------------------------------------------------------------------
// GP cluster -> EHDSHealthProfessional (+ EHDSOrganisation)
// ---------------------------------------------------------------------------
Mapping: HIQA2025ToEHDSHealthProfessional
Id: hiqa-2025-to-ehds-healthprofessional
Title: "HIQA Demographic Dataset (2025) GP details to Xt-EHR EHDSHealthProfessional"
Source: HIQADemographicDataset2025
Target: "http://www.xt-ehr.eu/fhir/models/StructureDefinition/EHDSHealthProfessional"
* gp -> "EHDSHealthProfessional" "One GP cluster = one EHDSHealthProfessional. Linking it to the patient is outside EHDSPatient and must be done by the carrying document."
* gp.name -> "EHDSHealthProfessional.name" "EHDS name is 0..1 and structured; HIQA gives free-text full name, 0..*."
* gp.practice -> "EHDSHealthProfessional.professionalRole.organisation" "EHDSOrganisation.name and .address; HIQA holds a single free-text value, so it must be parsed."
* gp.registrationBodyType -> "EHDSHealthProfessional.identifier.assigner" "Registration body (e.g. Irish Medical Council) is the identifier assigner / system."
* gp.registrationBodyValue -> "EHDSHealthProfessional.identifier.value" "e.g. MCRN."
