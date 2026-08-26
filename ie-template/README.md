# ie.core.template

Custom IG template for FHIR Core Ireland. Extends `fhir.base.template`; contains only
the national deltas, never a copy of the base.

Referenced from `ig.ini` as `template = #ie-template` (the leading `#` means "contained
template folder under the IG root"). The IG Publisher installs the base first, then
overlays these files, and writes the merged result to `../template/` which is
generated output and is gitignored.

## Layout

`package/package.json` declares the template and its base. Everything else sits at the
folder root, mirroring `HL7/ig-template-base`:

| Path                                    | Purpose                                                |
|-----------------------------------------|--------------------------------------------------------|
| `package/package.json`                  | template id, `base`, and matching `dependencies` entry |
| `content/assets/css/ie-core.css`        | national palette + wordmark styling                    |
| `includes/_append.fragment-css.html`    | links the stylesheet into `<head>`                     |
| `includes/_append.fragment-header.html` | text wordmark in the page header                       |
| `includes/_append.fragment-footer.html` | provisional-status footer line                         |

A file whose name matches one in the base **replaces** it; a file named
`_append.xyz` is **appended** to the base's `xyz`. The base ships
`fragment-header.html` and `fragment-css.html` as empty placeholders precisely as
child-template hooks.

## Branding status

The colours are **placeholders**: `#169B62` green on white chosen only to be
legible and obviously national, not to match any official identity. Contrast is
checked against white text: `#0F7A4D` passes WCAG AA at 5.4:1; `#169B62` is 3.5:1 and
is therefore used only for accents, never body text. Replace both with the real
palette once a sponsoring body exists.

The wordmark is text, not an image, so there is no logo licensing question yet. To
switch to a logo later, add `content/assets/images/<file>.png` and swap the `<span>`
in `_append.fragment-header.html` for an `<img/>`.

## Rules to keep the ci-build working

- **Content only.** Do not add `script` or `targets` to a `config.json` here. Active
  content triggers a trust check that only passes for allowlisted template *package
  ids* loaded by id; a contained template can never pass it, and a failure silently
  disables scripts for the whole build. Staying content-only inherits the base's
  (trusted) ant script.
- **Safe file types only**: `.html .css .png .gif .json .xml .ico .jpg .md .ini .svg
  .ttf .woff .woff2 .txt .yml .yaml .liquid`. Anything else is treated as active
  content, with the same consequence.
- **Fragments must be well-formed XHTML**: every page is XHTML-validated. The footer
  fragment is injected inside a `<span>` inside a `<p>`, so it may contain **inline
  elements only** (no `<div>`, no `<p>`).

## Promoting to a published package

Move this folder to its own repo, add `package-list.json`, register the id in
[FHIR/ig-registry `templates.json`](https://github.com/FHIR/ig-registry/blob/master/templates.json),
then reference it as `template = hl7.ie.fhir.template#current`. Note that the
`hl7.<cc>.fhir.template` convention asserts affiliate ownership, so the id stays
`ie.core.template` until that is real.
