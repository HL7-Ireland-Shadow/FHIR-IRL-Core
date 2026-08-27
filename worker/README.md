# Basic-auth gate for the published IG

The IG is published to **Cloudflare Workers** with the rendered site attached as
static assets, and [`src/index.js`](src/index.js) is the gate in front of it: it
checks HTTP Basic credentials taken from the environment, then serves the
requested file from the `ASSETS` binding.

[`.github/workflows/publish-ig.yml`](../.github/workflows/publish-ig.yml)
uploads the Worker and `output/` together on every push to `master`.

## How it gates

[`wrangler.jsonc`](wrangler.jsonc) binds `../output` as the Worker's static
assets and sets:

```jsonc
"run_worker_first": true
```

By default Cloudflare serves a matching static file *before* invoking the Worker, 
so without it every page would be served without ever reaching the credential 
check. 

## One-time setup

### 1. Set the gate credentials

These are Worker secrets, held by Cloudflare and never in the repo. Run them
from this directory:

```
npx wrangler secret put BASIC_AUTH_USERNAME
npx wrangler secret put BASIC_AUTH_PASSWORD
```

Rotating a credential is just re-running `wrangler secret put` - no redeploy
needed.

### 2. Give the workflow its API token

Dashboard -> **Account API tokens** -> **Create Token**. Under **Permission
policies**, open the **Custom** dropdown and select **"Edit Cloudflare
Workers"**. Name it and scope it to the account holding the Worker.

Add both of these as repository secrets (repo **Settings** -> **Secrets and
variables** -> **Actions**):

| Secret                  | Where to find it                                     |
|-------------------------|------------------------------------------------------|
| `CLOUDFLARE_API_TOKEN`  | the token you just created                           |
| `CLOUDFLARE_ACCOUNT_ID` | dashboard URL, or Workers & Pages -> Account details |

### 3. Deploy

Push to `master`, or run the workflow manually (Actions -> Publish IG -> Run
workflow). The job summary links the deployment. There is no project to create
first: `wrangler deploy` creates the Worker on its first run.

Cloudflare creates the DNS record and certificate itself, and the gate applies
there too. The zone must already be on Cloudflare. Note `custom_domain` takes a
bare hostname - no `/*`.

## Local checks

Unit tests for the credential handling and the gate run on Node alone, with
nothing installed:

```
npm test        # or: node --test
```

Validate the config and bundle without deploying - this also reports how many
asset files wrangler sees, so it catches an unbuilt or empty `output/`:

```
npm run check   # wrangler deploy --dry-run
```

To run the real thing locally, put the credentials in a gitignored `.dev.vars`:

```
BASIC_AUTH_USERNAME=ada
BASIC_AUTH_PASSWORD=lovelace
```

```
npm run dev
curl -i http://localhost:8787/                    # 401 + challenge
curl -i -u ada:lovelace http://localhost:8787/    # 200
curl -i -u ada:wrong http://localhost:8787/       # 401
```

## Limitations

Static assets allow 20,000 files per deployment and 25 MiB per file. The
rendered IG is currently ~896 files with a ~10.5 MB largest file
(`full-ig.zip`), so there is headroom, but a much larger IG could approach the
file count.