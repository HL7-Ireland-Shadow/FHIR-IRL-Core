/**
 * Basic-auth gate for the IG on Cloudflare Workers with static assets.
 *
 * The rendered site is bound as ASSETS (see wrangler.jsonc, which points at
 * ../output). `run_worker_first: true` is what makes this a gate rather than
 * decoration: without it Cloudflare serves a matching static file *before*
 * invoking this script, and every page would bypass the check.
 *
 * Credentials come from the environment: BASIC_AUTH_USERNAME and
 * BASIC_AUTH_PASSWORD, set with `wrangler secret put`. See ../README.md.
 *
 * Kept dependency-free so it needs no bundling. The helpers are exported for
 * the tests.
 */

const DEFAULT_REALM = 'Restricted';

/** All a rendered, read-only IG needs. Anything else is refused at the edge. */
const ALLOWED_METHODS = new Set(['GET', 'HEAD', 'OPTIONS']);

const encoder = new TextEncoder();

export default {
  /**
   * @param {Request} request
   * @param {{ ASSETS: { fetch: (request: Request) => Promise<Response> } } & Record<string, string | undefined>} env
   */
  async fetch(request, env) {
    const expected = readExpectedCredentials(env);

    // Fail closed. A deployment missing its secrets must never serve the site,
    // and must not hand out a challenge it could never satisfy.
    if (!expected) {
      console.error('BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD must both be set');
      return problem(500, 'Authentication is not configured on this deployment.');
    }

    if (!env.ASSETS || typeof env.ASSETS.fetch !== 'function') {
      console.error('The ASSETS binding is missing - check the assets block in wrangler.jsonc');
      return problem(500, 'Static assets are not available on this deployment.');
    }

    const supplied = parseBasicCredentials(request.headers.get('authorization'));
    if (!supplied || !(await credentialsMatch(supplied, expected))) {
      return challenge(env);
    }

    // Checked after authenticating, so an anonymous caller learns nothing about
    // what the deployment does or does not support.
    if (!ALLOWED_METHODS.has(request.method)) {
      return problem(405, 'Method not allowed.', { allow: 'GET, HEAD, OPTIONS' });
    }

    return env.ASSETS.fetch(request);
  },
};

/**
 * Both values must be present and non-empty; an empty secret is treated as
 * unconfigured rather than as a valid empty password.
 *
 * @returns {{ username: string, password: string } | null}
 */
function readExpectedCredentials(env) {
  const username = env.BASIC_AUTH_USERNAME;
  const password = env.BASIC_AUTH_PASSWORD;

  if (typeof username !== 'string' || username === '') return null;
  if (typeof password !== 'string' || password === '') return null;

  return { username, password };
}

/** 401 with the challenge that makes the browser show its credential prompt. */
function challenge(env) {
  // A realm is an RFC 7230 quoted-string: neither quotes nor backslashes may
  // appear raw, so drop them rather than emit a malformed header.
  const realm = [...String(env.REALM || DEFAULT_REALM)]
    .filter((character) => character !== '"' && character !== String.fromCharCode(92))
    .join('');

  return new Response('Authentication required.\n', {
    status: 401,
    headers: {
      'www-authenticate': `Basic realm="${realm}", charset="UTF-8"`,
      'content-type': 'text/plain; charset=utf-8',
      'cache-control': 'no-store',
    },
  });
}

function problem(status, message, extraHeaders = {}) {
  return new Response(`${message}\n`, {
    status,
    headers: {
      'content-type': 'text/plain; charset=utf-8',
      'cache-control': 'no-store',
      ...extraHeaders,
    },
  });
}

/**
 * Decode an `Authorization: Basic ...` header value (RFC 7617).
 *
 * Returns null for anything absent or malformed; callers must treat null
 * exactly as they treat a credential mismatch.
 *
 * @param {string | null} header
 * @returns {{ username: string, password: string } | null}
 */
export function parseBasicCredentials(header) {
  if (typeof header !== 'string') return null;

  const separator = header.indexOf(' ');
  if (separator === -1) return null;
  if (header.slice(0, separator).toLowerCase() !== 'basic') return null;

  const encoded = header.slice(separator + 1).trim();
  if (encoded === '') return null;

  let decoded;
  try {
    // atob yields one character per byte; re-decode those bytes as UTF-8 so
    // non-ASCII passwords survive (RFC 7617 charset="UTF-8").
    const bytes = Uint8Array.from(atob(encoded), (c) => c.charCodeAt(0));
    decoded = new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  } catch {
    return null;
  }

  // Only the first colon separates the pair: a username cannot contain one,
  // a password can.
  const colon = decoded.indexOf(':');
  if (colon === -1) return null;

  return { username: decoded.slice(0, colon), password: decoded.slice(colon + 1) };
}

/**
 * Constant-time string equality.
 *
 * Both inputs are HMAC'd under a per-call random key first. That fixes the
 * comparison at 32 bytes whatever the input length (so nothing leaks the
 * secret's length) and leaves digests uncorrelated between calls.
 *
 * @returns {Promise<boolean>}
 */
export async function secureEqual(a, b) {
  const key = await crypto.subtle.importKey(
    'raw',
    crypto.getRandomValues(new Uint8Array(32)),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const [digestA, digestB] = await Promise.all([
    crypto.subtle.sign('HMAC', key, encoder.encode(a)),
    crypto.subtle.sign('HMAC', key, encoder.encode(b)),
  ]);

  const viewA = new Uint8Array(digestA);
  const viewB = new Uint8Array(digestB);

  let diff = 0;
  for (let i = 0; i < viewA.length; i += 1) diff |= viewA[i] ^ viewB[i];
  return diff === 0;
}

/**
 * Compare supplied credentials against the configured pair.
 *
 * Both halves are always compared - never short-circuited on the username - so
 * response timing does not reveal which half was wrong.
 *
 * @returns {Promise<boolean>}
 */
export async function credentialsMatch(supplied, expected) {
  const [usernameOk, passwordOk] = await Promise.all([
    secureEqual(supplied.username, expected.username),
    secureEqual(supplied.password, expected.password),
  ]);
  return usernameOk && passwordOk;
}
