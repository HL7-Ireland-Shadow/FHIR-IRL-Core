// Shared invariants and RuleSets for national constraints.
// Each RuleSet exists so a national requirement (Governance Rule 3) is defined
// exactly once and inserted wherever it applies, instead of being re-typed per profile.

// ---------------------------------------------------------------------------
// Invariants
// ---------------------------------------------------------------------------


//TODO: confirm long vs short format for messaging support for long GS1 format
Invariant: ie-ihi-format
Description: "IHI value must be 18 numeric digits (a 10-digit core identifier plus a modulus-11 check digit and a trailing
GS1 check digit), matching the HSE National Register of Individual Health Identifiers format under the Health Identifiers Act 2014."
Expression: "value.matches('^[0-9]{18}$')"
Severity: #error

Invariant: hse-ppsn-format
Description: "A PPSN is 7 digits followed by 1 or 2 upper-case letters, with no spaces or punctuation."
Expression: "matches('^[0-9]{7}[A-Z]{1,2}$')"
Severity: #error

Invariant: ie-eircode-format
Description: "Eircode must be 7 characters: a 3-character routing key followed by a 4-character unique identifier (e.g. D02AF30)."
Expression: "matches('^[A-Za-z0-9]{7}$')"
Severity: #error

// ---------------------------------------------------------------------------
// RuleSet: NationalIdentifier: insert into Patient-derived profiles
// ---------------------------------------------------------------------------

RuleSet: IENationalIdentifier
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice by identifier.system"
* identifier contains
    IHI 0..1 MS and
    PPSN 0..1 MS
* identifier[IHI] ^short = "Individual Health Identifier (IHI): Health Identifiers Act 2014"
* identifier[IHI].system = $IHISystem
* identifier[IHI].system ^short = "PLACEHOLDER: pending official OID/URI registration by HSE / Department of Health under the Health Identifiers Act 2014. Do not treat as a live identifier system."
* identifier[IHI].value 1..1 MS
* identifier[IHI] obeys ie-ihi-format
* identifier[PPSN] ^short = "Personal Public Service Number (PPSN)"
* identifier[PPSN].system 1..1
* identifier[PPSN].system = $PPSNSystem (exactly)
* identifier[PPSN].value 1..1
* identifier[PPSN].value obeys hse-ppsn-format
* identifier.type from IEIdentifierTypeVS (extensible)

// ---------------------------------------------------------------------------
// RuleSet: HSEOrganisationIdentifier: insert into Organization-derived profiles
// ---------------------------------------------------------------------------

RuleSet: HSEOrganisationIdentifier
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice by identifier.system to isolate the national HSE organisation code"
* identifier contains hseOrgCode 0..1 MS
* identifier[hseOrgCode] ^short = "HSE Organisation Code: local workflow identifier used for provider/site registration within HSE systems"
* identifier[hseOrgCode].system = $HSEOrgCodeSystem
* identifier[hseOrgCode].system ^short = "PLACEHOLDER: pending confirmation of the canonical HSE organisation code register identifier system"

// ---------------------------------------------------------------------------
// RuleSet: ProfessionalRegisterIdentifier: insert into Practitioner-derived profiles
// ---------------------------------------------------------------------------

RuleSet: ProfessionalRegisterIdentifier
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice by identifier.system to isolate the national statutory professional register number"
* identifier contains professionalRegisterNumber 0..1 MS
* identifier[professionalRegisterNumber] ^short = "Statutory professional register number (Medical Council / NMBI / CORU, as applicable to Practitioner.qualification)"
* identifier[professionalRegisterNumber].system = $ProfessionalRegisterSystem
* identifier[professionalRegisterNumber].system ^short = "PLACEHOLDER: generic slot covering multiple statutory registers;
to be split into per-register systems (e.g. distinct Medical Council / NMBI / CORU systems) once confirmed with each regulator"