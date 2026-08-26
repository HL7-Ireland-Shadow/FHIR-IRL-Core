### Status

<blockquote style="border-left:4px solid #b30000;padding:0.5em 1em;background:#fff4f4;">
<strong>Draft, v0.1.0 - provisional.</strong> No government or HL7 Ireland sponsoring body has
formally adopted this guide yet. The canonical URL (<code>http://hl7ireland.ie/fhir/core</code>),
package id (<code>hl7.fhir.ie.core</code>), and every national identifier system in this guide
are placeholders pending confirmation: see <a href="identifiers.html">National Identifiers</a>
for the specific items that must be replaced before any production use.
</blockquote>

### Purpose

**FHIR Core Ireland** is a national Core FHIR Implementation Guide that establishes the
foundational resource profiles Irish health information systems should build on, in a way
that is deliberately and traceably aligned with the European Health Data Space (EHDS)
interoperability stack rather than developed in isolation.

Concretely, this means:

- Wherever the **HL7 Europe Core** IG (`hl7.fhir.eu.base`) already defines a profile for a
  resource, this guide derives from it and adds only what Irish legislation or national
  infrastructure genuinely requires.
- Where HL7 Europe Core has a gap, this guide falls back to the **International Patient
  Summary (IPS)** before ever profiling directly from base FHIR and documents the gap
  rather than treating the workaround as permanent.
- Every national addition (identifier / terminology binding / mandatory element / 
  workflow constraint) is traceable to a specific legal or operational reason.

See [Governance Principles](governance.html) for the rules that were applied *before* any
profiling decision was made, and [Requirements Mapping](mapping.html) for how each
foundational resource maps to its Xt-EHR logical model, its HL7 Europe Core parent (or
documented gap), and its relevance to MyHealth@EU.

### Scope of v0.1

Thirteen foundational profiles: Patient, Practitioner, PractitionerRole, Organization,
Location, Encounter, Observation, Condition, Procedure, Medication, MedicationRequest,
Composition, and Bundle. This is deliberately a *Core* layer - domain content (Patient
Summary, ePrescription/eDispensation, Laboratory Report) is out of scope here and is
expected to be built as separate national IGs on top of this Core, mirroring how HL7
Europe itself separates its base/core layer from its domain IGs (Patient Summary,
Laboratory Report, Medication Prescription and Dispense).

### National requirements addressed

- **Individual Health Identifier (IHI)**: the patient identifier established under the
  Health Identifiers Act 2014 and operated by the HSE. See [Patient](StructureDefinition-patient-ie.html)
  and [National Identifiers](identifiers.html).
- **Eircode**: the national postcode system, modelled as a new address extension since no
  equivalent exists in HL7 Europe or IPS. See [National Identifiers](identifiers.html).
