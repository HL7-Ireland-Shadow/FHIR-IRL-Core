// Logical model of the HIQA Draft National Standard for a Demographic Dataset for Health and Social Care (2025).
// Source: https://www.hiqa.ie/sites/default/files/2025-06/Draft-National-Standard-for-a-Demographic-Dataset-for-Healthcare-and-Social-Care.pdf
// Section numbers (n.n) in each definition refer to the source. Conformance is carried as
// Mandatory -> min 1, Required ("if it exists, should be included") -> min 0 as the source also gives 0..n, Optional -> min 0.
// The source states coded values "have not yet been specified" except where bound below.

Invariant: hiqa25-communication-value
Description: "Where a communication type is given, the value is mandatory (HIQA 2025, 5.1.2)."
Expression: "type.exists() implies value.exists()"
Severity: #error

Logical: HIQADemographicDataset2025
Id: hiqa-demographic-dataset-2025
Title: "HIQA Draft National Demographic Dataset (2025)"
Description: """
Logical model of the HIQA Draft National Standard for a Demographic Dataset for Health and Social Care (2025 revision of the 2013 standard). A 'person' is anyone who uses or may use a health or social care service. Clusters in the source are modelled as backbone elements.
"""
* ^status = #draft

// Section 1 Name details
* name 1..* BackboneElement "Name" "A name set for the person; at least one name should be captured and more than one may be recorded. Only one name can be the preferred name at any time. (Section 1)"
* name.title 0..* CodeableConcept "Name title" "Title relevant to a family name, e.g. Dr, Mr. Multiple titles may be recorded. (1.1, Optional)"
* name.forename 1..* string "Forename" "The person's identifying name, also given name or first name, including middle name(s). (1.2, Mandatory)"
* name.surname 1..* string "Surname" "Family or marital name. (1.3, Mandatory)"
* name.suffix 0..* CodeableConcept "Name suffix" "Term following a name, e.g. Sr, Jr, or acknowledging qualifications, positions held and honours. (1.4, Optional)"
* name.usage 0..1 CodeableConcept "Name usage classification" "Classification of how the name is used. The table gives 0..1 although the guidance says a name may have more than one usage. (1.5, Optional)"
* name.usage from HIQA2025NameUsageVS (extensible)
* name.preferredName 0..1 string "Preferred name" "Name by which the person prefers to be identified, other than the forename entered; displayed on screens, reports and letters. Also referred to as patient alias. (1.6, Required)"

// Section 2 Address
* address 0..* BackboneElement "Address" "Address of the person. Multiple addresses may be recorded, with one current home address and one current postal address. (Section 2)"
* address.addressLine 0..* string "Address line(s)" "Free-text first line(s) of address: some or all of building/complex sub-unit type and number, address site name, house or property number, street name and type. (2.1, Required)"
* address.localityTownland 0..1 string "Suburb/Town/Townland/Locality" "Full name of the locality describing the address. 'unknown' where the address is unknown or there is no fixed address. (2.2, Required)"
* address.county 0..1 string "District/County" "Full name of the county (or Dublin district) where the person resides. (2.3, Required)"
* address.country 0..1 CodeableConcept "Country" "Full name of the country where the person resides. (2.4, Required)"
* address.postcode 0..1 string "Postcode" "Code identifying the locality of the address; Eircode for addresses in Ireland, entered only here. (2.5, Required)"
* address.type 0..1 CodeableConcept "Address type" "Type of address record, e.g. place of residence, business, postal address. (2.6, Required)"

// Section 3 Health identifiers
* ppsn 0..1 Identifier "Personal Public Service Number (PPSN)" "Seven numbers followed by one or two letters, no spaces, hyphens or special characters. Only one PPSN is entered if a person has several. (3.1, Required)"
* ihi 0..1 Identifier "Individual Health Identifier (IHI)" "Unique 10-digit number assigned by the HSE under the Health Identifiers Act 2014. Applies to Ireland only. (3.2, Required)"
* otherHealthIdentifier 0..* BackboneElement "Other health identifier details" "Identifiers other than PPSN and IHI, assigned by a provider, insurer, PCRS or another jurisdiction at local, regional or national level. Type and value should both be recorded. (3.3, Required)"
* otherHealthIdentifier.value 1..1 string "Other health identifier - Value" "Alphanumeric identifier value, e.g. MRN, PCRS number, EHIC number. (3.3.1, Required)"
* otherHealthIdentifier.type 1..1 CodeableConcept "Other health identifier - Type" "Type of the identifier recorded in value. (3.3.2, Required)"

// Section 4 Additional demographic details
* dateOfBirth 1..1 date "Date of birth" "YYYY-MM-DD. Where not accurately known an approximate date is used, e.g. 1995-00-00 (a partial FHIR date such as 1995 here). (4.1, Mandatory)"
* placeOfBirth 0..1 string "Place of birth" "County if born in Ireland, otherwise country. (4.2, Optional)"
* sexDetails 1..* BackboneElement "Sex (cluster)" "Sex information and its protection flag. (4.3, Mandatory)"
* sexDetails.sex 1..1 CodeableConcept "Sex" "Sex assigned at birth: M, F or U. (4.3.1, Mandatory)"
* sexDetails.sex from HIQA2025SexVS (required)
* sexDetails.protectionFlag 1..1 boolean "Sex protection flag" "True (Yes - Protected) if the person's sex is to be held in confidence and not shared as part of the demographic record. (4.3.2, Mandatory)"
* genderDetails 0..* BackboneElement "Gender (cluster)" "Self-identified gender and its protection flag; optional, based on the person's consent. (4.4, Optional)"
* genderDetails.gender 0..1 CodeableConcept "Gender" "Self-identified gender, which may differ from sex at birth. (4.4.1, Optional)"
* genderDetails.protectionFlag 0..1 boolean "Gender protection flag" "True (Yes - Protected) if the person's gender is to be held in confidence. (4.4.2, Optional)"
* mothersBirthFamilyName 1..1 string "Mother's birth family name (maiden name)" "The original family name of the person's mother as on her own birth certificate. (4.5, Mandatory)"
* nationality 0..* CodeableConcept "Nationality" "Legal bond between a person and a state; relates to a country, normally that of the passport held. (4.6, Required)"
* ethnicity 0..* CodeableConcept "Ethnicity" "Self-identified ethnic background; special category data requiring explicit consent. Multiple entries allowed. (4.7, Optional)"
* dateOfDeath 0..1 date "Date of death" "YYYY-MM-DD; must be valid and not in the future. (4.8, Required)"

// Section 5 Communication details
* communication 0..* BackboneElement "Communication type details" "Electronic contact details of the person. (5.1, Required)"
* communication.type 0..1 CodeableConcept "Communication details - Type" "Landline telephone, mobile phone, email, URL, other. (5.1.1, Required)"
* communication.value 0..1 string "Communication details - Value" "Full number with prefixes and no punctuation, or email address. Mandatory where a type is given. (5.1.2, Required)"
* communication obeys hiqa25-communication-value

* gp 0..* BackboneElement "General Practitioner (GP) details" "The person's registered GP; may be more than one, e.g. temporary registration. 'Unknown' if not registered with a practice. (5.2, Optional)"
* gp.name 0..* string "GP Name" "Full name (forename and surname) of the GP as on the professional register. (5.2.1, Optional)"
* gp.practice 0..* string "GP Practice details" "Name and address of the GP practice; the address only if the GP is not part of a practice. (5.2.2, Optional)"
* gp.registrationBodyType 0..* CodeableConcept "GP Professional Registration Body - Type" "Regulatory/licensing body holding the GP's registration, e.g. Irish Medical Council, RCGP. (5.2.3, Optional)"
* gp.registrationBodyValue 0..* string "GP Professional Registration Body - Value" "Registration value assigned by that body, e.g. a six-digit MCRN. (5.2.4, Optional)"

* contactPerson 0..* BackboneElement "Contact person details" "Person a provider can communicate with, e.g. emergency contact, legal guardian, decision supporter. Multiple entries allowed. (5.3, Required)"
* contactPerson.indicator 0..1 CodeableConcept "Contact person" "Whether the person has a contact person: Yes, No or Unknown. The table gives 0..*; a single indicator per cluster instance is modelled. (5.3.1, Required)"
* contactPerson.indicator from HIQA2025YesNoUnknownVS (required)
* contactPerson.role 0..* CodeableConcept "Role of that person" "Legal guardian, other person to contact, emergency contact, decision supporter. (5.3.2, Required)"
* contactPerson.relationship 0..* CodeableConcept "Relationship" "Relationship to the person, e.g. father, wife, daughter, neighbour, friend. (5.3.3, Required)"
* contactPerson.forename 0..* string "Forename of contact person" "Given name(s) of the contact person. (5.3.4, Required)"
* contactPerson.surname 0..* string "Surname of contact person" "Family name of the contact person. (5.3.5, Required)"
* contactPerson.telephone 0..* string "Telephone number of contact person" "Full phone number with prefixes and no punctuation. (5.3.6, Required)"
* contactPerson.email 0..* string "Email of contact person" "Email address of the contact person. (5.3.7, Required)"

// Section 6 Personal characteristics
* personalCharacteristic 0..* Attachment "Personal characteristics" "Individual identifying features such as a signature or photograph; free text or multimedia. (6.1, Optional)"
