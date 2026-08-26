<blockquote style="border-left:4px solid #b30000;padding:0.5em 1em;background:#fff4f4;">
Every identifier system on this page is a <strong>placeholder</strong>. None has been
issued or confirmed by an official Irish body. Do not use these systems for anything
beyond development and demonstration until they are replaced.
</blockquote>

### Individual Health Identifier (IHI)

- **Legal basis**: Health Identifiers Act 2014, which established the National Register
  of Individual Health Identifiers, operated by the HSE.
- **Format**: 18 numeric digits constituting a 10-digit core identifier (positions 8–17) with its
  own modulus-11 check digit, plus a trailing GS1 check digit over the full 18-digit
  number.
- **FHIR modelling**: an `Identifier` slice named `ihi` on `Patient.identifier`, `0..1`,
  Must Support, constrained by the [`ie-ihi-format`](StructureDefinition-patient-ie.html)
  invariant to the 18-digit pattern. Modelled as an ordinary national identifier slice
  (not an extension), consistent with how HL7 Europe Core itself represents
  jurisdiction-specific patient identifiers.
- **System URI**: `http://hl7ireland.ie/fhir/sid/ihi` **PLACEHOLDER**. No official
  government-published OID or URI for the IHI register was found. An existing unofficial
  IG (iEHR.ai's "IE Core") uses an OID drawn from its own private enterprise number; this
  guide does not reuse that, since it is not an officially issued identifier system for
  Ireland.

### Eircode

- **Format**: 7 characters constituting a 3-character routing key followed by a 4-character unique
  identifier (e.g. `D02AF30`).
- **FHIR modelling**: a new `Address` extension, [`ie-eircode`](StructureDefinition-ie-eircode.html),
  since no existing HL7 Europe or IPS extension covers a national postal routing code
  (Governance Rule 7). Applied to `.address` on `PatientIE`, `OrganizationIE`, and
  `LocationIE`.
- Not modelled as `Address.postalCode` directly, because Eircode's routing-key structure
  (each of Ireland's ~139 routing keys can span multiple non-contiguous areas, and the
  unique identifier is issued per-address rather than per-street) doesn't map cleanly onto
  the general-purpose semantics implementers elsewhere associate with `postalCode`; a
  dedicated extension keeps that structure explicit and machine-checkable via the
  `ie-eircode-format` invariant.
