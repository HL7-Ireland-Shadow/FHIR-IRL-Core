The principles listed below exist to stop the Irish Core IG from drifting into
a parallel, incompatible standard which is the single biggest risk for any Member State
implementing EHDS.

### Rule 1: Reuse European profiles whenever possible

Unless national legislation requires an additional constraint, a FHIR Core Ireland
profile adds nothing beyond a `Parent` declaration and a description. Several profiles in
this guide (`PractitionerRoleIE`, `MedicationIE`) are intentionally unconstrained beyond
their parent for exactly this reason. Resisting temptation to add "just in case"
constraints is as much a governance discipline as adding constraints where they're
justified.

### Rule 2: Do not re-profile something already defined in a European IG

If HL7 Europe Core (or, failing that, IPS) has already made a design decision (a
cardinality, a terminology binding, a slicing strategy) this guide does not restate or
override it. Narrowing a reference target to a national child profile (e.g.
`subject only Reference(PatientIE)`) is not treated as a violation of this rule, since it
narrows to a *subtype* of what the European parent already allows rather than contradicting
it; see Rule 5 for why that narrowing still needs its own justification.

### Rule 3: Only nationalise these four things

1. **Identifiers**: e.g. the Individual Health Identifier (IHI), the HSE Organisation
   Code, statutory professional register numbers.
2. **Terminology bindings**: only where Irish law or the absence of a European binding
   requires one (e.g. the temporary Encounter care-setting binding, itself a Rule 4 gap).
3. **Mandatory elements required by law**: e.g. Must Support flags tied to a named Act
   or HSE policy, not editorial preference.
4. **Local workflows**: e.g. tightening a reference target to a national profile for
   referential integrity within FHIR Core Ireland bundles.

Anything outside these four categories belongs upstream, in HL7 Europe Core or IPS and not
in a national fork.

### Rule 4: Gap fallback order, and gaps are logged, not absorbed

When a resource genuinely has no HL7 Europe Core profile, the fallback order is:

**HL7 Europe Core > International Patient Summary (IPS) > base FHIR R4.**

Every profile that falls back below HL7 Europe Core (`EncounterIE` > base FHIR;
`BundleIE` > IPS) says so explicitly in its own `Description`, and is listed as an open
gap in [Requirements Mapping](mapping.html) with a note on what would retire the
workaround. 

### Rule 5: No silent forks

Every national constraint's short description should cite the reason for it: legislation or policy, 
an Irish healthcare operational need, or an explicit internal-consistency rationale. 

### Rule 6: Provisional artefacts are marked

Any identifier system, OID, or canonical URL that lacks an official government/HSE
registration is labelled `PLACEHOLDER` in both the FSH source (`^short` on the relevant
element) and the rendered narrative. This guide's own canonical URL and package ID are
themselves provisional and marked as such on every page: see the banner on
[Home](index.html). An implementer must never be able to mistake draft plumbing for a
live national identifier system.

### Rule 7: Extensions are a last resort

Before authoring a new extension, check the HL7 Europe Extensions IG and IPS for one that
already covers the need. This mirrors Rule 2, applied specifically to extensions,
since extension duplication is easy to introduce by accident and hard to unwind once
data are flowing.