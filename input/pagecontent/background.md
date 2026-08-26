This guide sits inside a layered EU interoperability stack. Understanding the layers 
and which are logical models versus implementable FHIR profiles versus live cross-border
services is what makes the [Governance Principles](governance.html) and [Requirements Mapping](mapping.html) legible.

### European Health Data Space (EHDS)

EHDS is the EU regulation establishing a common framework for both primary use (direct
care, cross-border access to health data) and secondary use (research, policy,
innovation) of electronic health data across Member States. It is the policy driver; it
does not itself publish FHIR artefacts. The technical realisation of EHDS's primary-use,
cross-border exchange requirements is delivered through Xt-EHR, HL7 Europe, and
MyHealth@EU, described below.

### Xt-EHR (Cross-border eHealth information services)

Xt-EHR is an EU Joint Action that publishes FHIR logical models (abstract
`StructureDefinition` resources of `kind = logical`, not implementable profiles) for the
clinical domains EHDS primary use needs to cover: Patient Summary, ePrescription,
eDispensation, Medical Test Results, Medical Images, and Hospital Discharge Report.
Published at `xt-ehr.github.io` / `xt-ehr.eu/fhir/models`.

Because these are logical models, they define the semantic content and structure of a
domain (what a Patient Summary *means*) without committing to a specific FHIR profiling
approach. HL7 Europe's domain IGs (Patient Summary, Laboratory Report, Medication
Prescription and Dispense) are the emerging FHIR-profile realisation of that semantic
layer; Xt-EHR itself states this Patient Summary work is being done jointly with HL7
Europe. This guide treats Xt-EHR logical models as the *source of truth for meaning*, and
HL7 Europe Core / domain IGs as the *source of truth for FHIR shape*.

### HL7 Europe Core

`hl7.fhir.eu.base` (canonical `http://hl7.eu/fhir/base`, current version 2.0.0, FHIR R4)
is the pan-European base and core profile set this guide builds on directly. As verified
against its published artefact list, it currently defines:

| Resource          | Base profile (`-eu`) | Core profile (`-eu-core`)                               |
|-------------------|----------------------|---------------------------------------------------------|
| Patient           | ✓                    | ✓                                                       |
| Practitioner      | ✓                    | ✓                                                       |
| PractitionerRole  | ✓                    | ✓                                                       |
| Organization      | ✓                    | ✓                                                       |
| Location          | -                    | ✓                                                       |
| Condition         | -                    | ✓                                                       |
| Procedure         | -                    | ✓                                                       |
| Medication        | -                    | ✓                                                       |
| MedicationRequest | -                    | ✓                                                       |
| Composition       | -                    | ✓                                                       |
| Observation       | -                    | ✓ (`medicalTestResult-eu-core`, scoped to test results) |
| Encounter         | -                    | - (not yet defined)                                     |
| Bundle            | -                    | - (not yet defined)                                     |

This guide derives every national profile from the `-eu-core` variant, as that is the
layer HL7 Europe intends Member States to profile from. Sibling domain IGs under the same
`hl7-eu` GitHub organisation: Patient Summary (`hl7-eu/eps`), Laboratory Report
(`hl7-eu/laboratory`), Medication Prescription and Dispense (`hl7-eu/mpd`), and a shared
Extensions IG are out of scope for this Core guide but are the natural next layer for a
future Irish domain IG.

### MyHealth@EU

MyHealth@EU is the operational cross-border infrastructure connecting Member States' National Contact Points for
eHealth. Its technical basis is mixed:

- **Patient Summary and ePrescription/eDispensation**: still CDA R2.0-based (the
  legacy eHDSI/epSOS artefacts), continuing in production for the near term. A FHIR-based
  Patient Summary is under active development via the HL7 Europe Patient Summary IG,
  intended as the eventual basis for both national guides and MyHealth@EU's future
  cross-border service, but it is not yet the live cross-border standard.
- **Laboratory Report, Hospital Discharge Report, Medical Imaging, Vaccination/EU
  Digital COVID Certificate successor domains**: already FHIR R4-native, published at
  `fhir.ehdsi.eu`.

Where this guide's foundational profiles feed a domain that MyHealth@EU exchanges
cross-border, that relevance is noted per-row in [Requirements Mapping](mapping.html),
but implementers should not assume FHIR Core Ireland profiles are directly consumable by
the *current* CDA-based MyHealth@EU Patient Summary/ePrescription services without a
CDA-to-FHIR transformation layer, which is out of scope here.

### International Patient Summary (IPS)

`hl7.fhir.uv.ips` (current version 2.0.1, FHIR R4) is the HL7-international,
non-EU-specific patient summary standard that both IPS itself and HL7 Europe Core align
with. This guide uses it strictly as a fallback for the two
resources (Bundle, and by extension any document-bundling need) where HL7 Europe Core has
no profile at all, rather than jumping straight to unprofiled base FHIR.

### Existing related work

An unofficial **"IE Core" Implementation Guide** (`iehr.fhir.ie.core`, canonical
`http://iehr.ai/fhir/ie/core`) exists, published by iEHR.ai in consultation with several
Irish stakeholders but not itself an HSE- or government-sponsored artefact. It defines a
broader set of profiles than this guide and includes an IHI identifier system built on
iEHR.ai's own private OID enterprise number. This guide deliberately does not reuse
that OID (it is not an officially issued Irish identifier system) and instead uses a
clearly marked placeholder.
