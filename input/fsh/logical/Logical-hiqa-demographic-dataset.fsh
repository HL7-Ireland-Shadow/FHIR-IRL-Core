// Logical model of the HIQA Draft National Standard Demographic Dataset (v0.20, public consultation, Feb 2013).
// Source: https://www.hiqa.ie/sites/default/files/2017-01/Draft-Demographic-Dataset-Guidance-18.02.2013.pdf
// Element definitions carry the draft's section number (8.x.y) so every element is traceable to the source.
// Optionality: Required -> 1..1 (or 1..*), Optional -> 0..1 (or 0..*), Conditional -> 0..n plus an invariant where testable.

Invariant: hiqa-address-street-or-locality
Description: "If there is no street name, the townland/locality is required (HIQA 8.4.6 / 8.4.7)."
Expression: "streetName.exists() or localityTownland.exists()"
Severity: #error

Logical: HIQADemographicDataset
Id: hiqa-demographic-dataset
Title: "HIQA Draft National Demographic Dataset"
Description: """
Logical model of the HIQA Draft National Standard Demographic Dataset and Guidance for use in health and social care settings in Ireland (version 0.20, February 2013). The 'subject of care' is any person who uses or may use a health or social care service. Section numbers (8.x.y) refer to the source document.
"""
* ^status = #draft

// 8.1 Subject of care identification
* ihi 1..1 Identifier "Individual Health Identifier (IHI)" "Designation permanently assigned to an individual for the purpose of identification to facilitate the provision of health and social care. Issued nationally for the lifetime of the subject of care. (8.1.1, Required)"
* ihiIssuer 1..1 Identifier "Issuer of subject of care identifier" "The organisation or agency that allocates the subject of care identifier; should be the HPI or HOI when introduced. (8.1.3, Required)"
* healthIdentifierOther 0..* BackboneElement "Health identifier (other)" "Additional number or code assigned to the subject of care by a health or social care provider, e.g. a hospital number. (8.1.2, Optional)"
* healthIdentifierOther.identifier 1..1 Identifier "Identifier" "Identifier value, in the format used by the issuing agency."
* healthIdentifierOther.issuer 1..1 Identifier "Issuer" "Issuer of this identifier (8.1.3, Required)."

// 8.2 Biometric identification
* biometricIdentification 0..* BackboneElement "Subject of care biometric identification" "Biometric identifier, e.g. fingerprint, iris/retinal scan, voice recognition, DNA. (8.2.1, Optional)"
* biometricIdentification.type 1..1 CodeableConcept "Biometric type" "Kind of biometric identifier used."
* biometricIdentification.value 1..1 string "Biometric identifier" "Stand-alone unique identifier; format depends on the biometric type."

// 8.3 Name components
* name 1..* BackboneElement "Name" "A name set for the subject of care. More than one name may be recorded; each may have multiple usages. (8.3)"
* name.title 0..1 CodeableConcept "Name title" "Honorific form of address commencing a name, e.g. Dr, Mr, Prof. (8.3.1, Optional)"
* name.surname 1..* BackboneElement "Surname" "Family or marital name; several surnames may be recorded for one name set. A subject with a single name records it here. (8.3.2, Required)"
* name.surname.value 1..1 string "Surname" "Family name in the format preferred by the subject, mixed case."
* name.surname.sequenceNumber 0..1 positiveInt "Surname sequence number" "Order of use of the surname within the name set (1-4). (8.3.3, Optional)"
* name.givenName 0..* BackboneElement "Given name" "Subject of care's identifying name(s) as per birth certificate or passport. (8.3.4, Conditional: required unless there is no given name)"
* name.givenName.value 1..1 string "Given name" "Given name, mixed case."
* name.givenName.sequenceNumber 0..1 positiveInt "Given name sequence number" "Order of use of the given name (1-3). (8.3.5, Optional)"
* name.preferredName 0..1 string "Preferred name" "Name by which the subject prefers to be identified, displayed on screens, reports and letters. Only one preferred name may be active at any point in time. (8.3.6, Optional)"
* name.suffix 0..1 CodeableConcept "Name suffix" "Term following a person's name, e.g. Jr, Sr, II. (8.3.7, Optional)"
* name.usage 0..* CodeableConcept "Name usage classification" "Classification of how this name is used. (8.3.8, Optional)"
* name.usage from HIQANameUsageVS (extensible)

// 8.4 Address components
* address 0..* BackboneElement "Address" "Address of the subject of care. Multiple addresses may be recorded, with one current home address and one current postal address. (8.4)"
* address.type 0..* CodeableConcept "Address type" "Place of residence or postal address. (8.4.10, Optional)"
* address.type from HIQAAddressTypeVS (required)
* address.buildingSubUnitType 0..1 CodeableConcept "Building/complex sub-unit type" "Type of separately identifiable portion within a building, e.g. APT, F, CTGE, DUP. (8.4.1, Optional)"
* address.buildingSubUnitNumber 0..1 string "Building/complex sub-unit number" "Number or identifier of the sub-unit, e.g. APT 6. (8.4.2, Optional)"
* address.siteName 0..1 string "Address site name" "Full name of the physical building or property, e.g. Hazelwood Apartment Complex. (8.4.3, Optional)"
* address.floorLevel 0..1 string "Floor/level number" "Floor or level of a multi-storey building, with type, e.g. FL 1a, L3. (8.4.4, Optional)"
* address.streetNumber 0..1 string "Street number" "House or property number, unique within the street. (8.4.5, Conditional)"
* address.streetName 0..1 string "Street name including street type" "Name of the public thoroughfare including full street type, e.g. Lissadel Close. (8.4.6, Conditional: required if the address has a street)"
* address.localityTownland 0..1 string "Townland/locality" "Full name of the locality or townland containing the address, using official names. (8.4.7, Conditional: required if there is no street name)"
* address.town 0..1 string "Town" "Town where the subject of care resides. (8.4.8, Required)"
* address.county 0..1 string "County" "County where the subject of care resides. (8.4.9, Required)"
* address.postalCode 0..1 string "Postal code" "Code for the postal delivery area. The draft cites Dublin postal districts (e.g. 6, 8); Eircode post-dates the draft. (8.4.11, Optional)"
* address.country 1..1 CodeableConcept "Country identifier" "Coded country component of the address. (8.4.12, Required)"
* address obeys hiqa-address-street-or-locality

// 8.5 Communication details
* communication 0..* BackboneElement "Electronic communication" "Electronic contact details for the subject of care. (8.5)"
* communication.medium 0..1 CodeableConcept "Electronic communication medium" "Type of communication mechanism. (8.5.1, Optional)"
* communication.medium from HIQACommunicationMediumVS (required)
* communication.detail 0..1 string "Electronic communication details" "Phone number (with country/area codes), email address or URL. (8.5.2, Optional)"
* communication.contactPreference 0..1 CodeableConcept "Electronic contact preference" "Preferred times for use of this contact type. (8.5.3, Optional)"
* communication.contactPreference from HIQAContactPreferenceVS (extensible)
* communication.usage 0..* CodeableConcept "Electronic contact usage" "Business, personal or both. (8.5.4, Optional)"
* communication.usage from HIQAContactUsageVS (required)

// 8.6 Additional demographic details
* dateOfBirth 1..1 date "Date of birth" "Date of birth of the subject of care. Where not accurately known an approximate date is used (the draft records this as 00/00/yyyy; a partial FHIR date yyyy here). (8.6.1, Required)"
* gender 1..1 CodeableConcept "Gender" "Biological sex of the subject of care (not gender identity). (8.6.2, Required)"
* gender from HIQAGenderVS (required)
* mothersBirthSurname 0..1 string "Mother's birth surname" "Original surname of the subject of care's mother; used as further confirmation of identity. (8.6.3, Optional)"
* religion 0..1 CodeableConcept "Religion" "Stated religion of the subject of care. (8.6.4, Optional)"
