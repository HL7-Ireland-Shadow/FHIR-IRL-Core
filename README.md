# FHIR Core Ireland

A national, EHDS-aligned Core FHIR Implementation Guide for Ireland — **draft, v0.1.0,
not yet sponsored by an official body.** 
## What's here

- `sushi-config.yaml`, `ig.ini` — FHIR Shorthand (FSH) / SUSHI project configuration.
- `input/fsh/aliases.fsh` — canonical URL and system aliases used across the guide.
- `input/fsh/rulesets.fsh` — shared invariants and RuleSets for the national constraints
  (IHI identifier, HSE organisation code, professional register number, Eircode
  extension application) so each is defined once and inserted where it applies.
- `input/fsh/extensions/Extension-ie-eircode.fsh` — the national Eircode address extension.
- `input/fsh/terminology/` — a small illustrative national CodeSystem/ValueSet for
  `Encounter.class`, needed only because HL7 Europe Core has no Encounter profile yet.
- `input/fsh/profiles/` — the 13 foundational profiles (Patient, Practitioner,
  PractitionerRole, Organization, Location, Encounter, Observation, Condition,
  Procedure, Medication, MedicationRequest, Composition, Bundle), each deriving from its
  HL7 Europe Core parent where one exists.
- `input/pagecontent/` — Home, Background (EHDS/Xt-EHR/HL7 Europe/MyHealth@EU
  landscape), Governance Principles, Requirements Mapping, and National Identifiers pages.

## Governance model

Every profile here follows the rules in [`input/pagecontent/governance.md`](input/pagecontent/governance.md):
reuse HL7 Europe Core wherever it exists; fall back to IPS, then base FHIR, only where
there's a genuine, documented gap (Encounter, Bundle); nationalise only identifiers,
terminology bindings, legally-mandated elements, and local workflow constraints; never
introduce an undocumented constraint. [`input/pagecontent/mapping.md`](input/pagecontent/mapping.md)
is the audit trail tying every profile back to its Xt-EHR logical model, HL7 Europe Core
parent (or gap), and MyHealth@EU relevance.

## Building this IG

This is a standard SUSHI/FHIR IG Publisher project.

### With Docker (recommended)

[`docker/`](docker/) builds an image containing the whole HL7 publishing toolchain — IG
Publisher, FHIR Validator, SUSHI, GoFSH, JDK, Ruby/Jekyll and Graphviz — so nothing has
to be installed on the host:

```
docker compose build
docker compose run --rm publish
```

The rendered site lands in `./output` (start at `output/index.html`, QA report at
`output/qa.html`). Other entry points:

```
docker compose run --rm sushi                 # FSH compile only (fast inner loop)
docker compose run --rm shell                 # interactive toolbox
docker compose run --rm clean                 # delete generated output and caches
docker compose run --rm publish versions      # tool versions baked into the image
```

Useful knobs: `TX_SERVER=n/a` skips terminology validation for a much faster build;
`JAVA_OPTS=-Xmx8g` raises the heap; `IG_PUBLISHER_VERSION` / `VALIDATOR_VERSION` /
`SUSHI_VERSION` are build args (`latest` by default) to pin for a reproducible image.

**[`docker/README.md`](docker/README.md) has the full guide** — services, caching,
configuration, and troubleshooting.

### Continuous publication (GitHub Actions -> GitHub Pages)

[`.github/workflows/publish-ig.yml`](.github/workflows/publish-ig.yml) runs the same
container in CI and deploys the rendered site to GitHub Pages on every push to `main`.
Pull requests build the IG and attach the QA report as an artifact, but do not deploy.

One-time setup: **Settings -> Pages -> Build and deployment -> Source: GitHub Actions**.
The site then serves from `https://<owner>.github.io/<repo>/`.

Run it manually (Actions -> Publish IG -> Run workflow) for two options:

- **Terminology server** - blank uses `tx.fhir.org`; `n/a` builds without one, which is
  much faster but leaves terminology bindings unvalidated.
- **Refresh image** - rebuilds the toolchain ignoring the layer cache, picking up new IG
  Publisher or SUSHI releases. Without it, CI reuses cached layers and so stays on the
  tool versions it last built.

Every run publishes the QA summary (errors, warnings, broken links) to the job summary
and uploads `output/qa.html` as the **qa-report** artifact. QA errors annotate the run
but do not block the deploy - a draft IG with known gaps is still worth publishing.

Note that the Pages URL is not the IG's canonical (`http://hl7ireland.ie/fhir/core`).
Rendering and internal links are unaffected, but the Publisher will keep reporting that
it cannot fetch a publication request or `package-list.json` from the canonical host
until that host actually exists. See the identifiers page for what has to be settled
before v1.0.

### Without Docker

```
npm install -g fsh-sushi
sushi build .
```

Then run the [HL7 FHIR IG Publisher](https://confluence.hl7.org/display/FHIR/IG+Publisher+Documentation)
against the generated `fsh-generated/` output to produce the full rendered site. The
Publisher also needs a JDK, Ruby with Jekyll, and Graphviz on the host.

`sushi build` needs network access to resolve the two package dependencies declared in
`sushi-config.yaml`:

- `hl7.fhir.eu.base#2.0.0` (HL7 Europe Core)
- `hl7.fhir.uv.ips#2.0.1` (International Patient Summary)

If a `Parent` reference or an element path doesn't resolve against those packages once
installed (for example, if an EU Core profile has since changed a cardinality this guide
assumed), SUSHI will report a specific, file-and-line error — that's expected first-build
friction for any IG that derives from external packages, and should be resolved by
adjusting the specific rule against the real installed profile, not by removing the
national constraint outright.

## Before this goes anywhere near production

See "What needs to happen before v1.0" in [`input/pagecontent/identifiers.md`](input/pagecontent/identifiers.md) —
in short: an official sponsoring body, an official IHI identifier system URI, and
resolution of the Encounter/Bundle/general-Observation gaps with HL7 Europe.
