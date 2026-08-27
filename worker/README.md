# Basic-auth gate for the published IG

A Cloudflare Worker that puts HTTP Basic authentication in front of the rendered
IG. It checks credentials from its environment, then reverse-proxies to the
GitHub Pages site; unauthenticated requests never reach the origin.

The IG itself is still built and published by
[`.github/workflows/publish-ig.yml`](../.github/workflows/publish-ig.yml) to
GitHub Pages. This Worker only controls who can read it.

## Configuration

| Name | Kind | Purpose |
|------|------|---------|
| `BASIC_AUTH_USERNAME` | secret | The single username accepted. |
| `BASIC_AUTH_PASSWORD` | secret | Its password. |
| `ORIGIN` | var | Absolute URL of the site to proxy, including any path prefix. |
| `REALM` | var | Optional. Shown in the browser's credential prompt. |

`ORIGIN` and `REALM` live in [`wrangler.jsonc`](wrangler.jsonc). The two
credentials are secrets and must never be committed there.

GitHub Pages project sites are served under a repository path, so `ORIGIN`
keeps that prefix and the Worker re-adds it to every request:

```
ORIGIN = https://hl7-ireland-shadow.github.io/FHIR-IRL-Core
GET /StructureDefinition-patient-ie.html
  -> https://hl7-ireland-shadow.github.io/FHIR-IRL-Core/StructureDefinition-patient-ie.html
```

## Deploy

```
npm install

npx wrangler secret put BASIC_AUTH_USERNAME
npx wrangler secret put BASIC_AUTH_PASSWORD

npm run deploy
```

`workers_dev` is on, so the gate lands on
`irl-core-ig.<your-subdomain>.workers.dev`. To serve it from a custom domain
instead, uncomment `routes` in `wrangler.jsonc` (the zone must be on
Cloudflare) and set `workers_dev` to `false`.

Secrets are per-environment and are not stored in the repo, so re-running
`wrangler secret put` is how you rotate credentials - no redeploy needed.

## Local development

Put the credentials in `.dev.vars` (gitignored):

```
BASIC_AUTH_USERNAME=ada
BASIC_AUTH_PASSWORD=lovelace
```

Then:

```
npm run dev
```

## Verify

```
# 401 with a challenge
curl -i http://localhost:8787/

# 200
curl -i -u ada:lovelace http://localhost:8787/

# 401 - wrong password
curl -i -u ada:wrong http://localhost:8787/
```

Unit tests for the credential parsing and comparison run on Node alone, with no
dependencies installed:

```
npm test        # or: node --test
```

## Behaviour notes

- **Fails closed.** If either secret is missing or empty, every request gets a
  500 and nothing is proxied. A misconfigured deployment cannot serve the site.
- **Constant-time comparison.** Username and password are HMAC'd under a random
  per-request key and compared byte-by-byte, so neither their contents nor
  their lengths leak through response timing. Both halves are always compared,
  so timing does not reveal which one was wrong.
- **Credentials stop here.** The `Authorization` and `Cookie` headers are
  stripped before the request goes to the origin.
- **Redirects are rewritten.** GitHub Pages redirects to add trailing slashes
  and points `Location` at `github.io`; the Worker rewrites those back to the
  gated hostname so following one cannot leave the gate.
- **Read-only.** Only `GET`, `HEAD` and `OPTIONS` are proxied; anything else
  gets a 405, since a rendered IG has nothing to write to.
- **One shared credential.** This is a single username/password for gating a
  draft, not user management. Cloudflare Access is the better tool if you need
  per-person identity, SSO, or an audit trail.
