/**
 * Basic-auth gate in front of the IG published on GitHub Pages.
 *
 * Credentials come from the environment - BASIC_AUTH_USERNAME and
 * BASIC_AUTH_PASSWORD, set as Worker secrets - and the site behind the gate is
 * whatever ORIGIN points at. See ../README.md for setup.
 */

import { credentialsMatch, parseBasicCredentials } from './auth.js';

const DEFAULT_REALM = 'Restricted';

/** All a rendered, read-only IG needs. Anything else is refused at the edge. */
const ALLOWED_METHODS = new Set(['GET', 'HEAD', 'OPTIONS']);

/** Statuses whose responses must not carry a body. */
const BODILESS_STATUSES = new Set([101, 204, 205, 304]);

export default {
  /**
   * @param {Request} request
   * @param {Record<string, string | undefined>} env
   */
  async fetch(request, env) {
    const expected = readExpectedCredentials(env);

    // Fail closed. A deployment missing its secrets must never serve the
    // origin, and must not hand out a challenge it could never satisfy.
    if (!expected) {
      console.error('BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD must both be set');
      return problem(500, 'Authentication is not configured on this deployment.');
    }

    const origin = parseOrigin(env.ORIGIN);
    if (!origin) {
      console.error(`ORIGIN is missing or not an absolute URL: ${env.ORIGIN}`);
      return problem(500, 'Origin is not configured on this deployment.');
    }

    const supplied = parseBasicCredentials(request.headers.get('authorization'));
    if (!supplied || !(await credentialsMatch(supplied, expected))) {
      return challenge(env);
    }

    if (!ALLOWED_METHODS.has(request.method)) {
      return problem(405, 'Method not allowed.', { allow: 'GET, HEAD, OPTIONS' });
    }

    return proxy(request, origin);
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

/** @returns {URL | null} */
function parseOrigin(value) {
  if (typeof value !== 'string' || value === '') return null;
  try {
    const url = new URL(value);
    return url.protocol === 'http:' || url.protocol === 'https:' ? url : null;
  } catch {
    return null;
  }
}

/** 401 with the challenge that makes the browser show its credential prompt. */
function challenge(env) {
  // A realm is an RFC 7230 quoted-string: neither quotes nor backslashes can
  // appear raw, so drop them rather than emit a malformed header.
  const realm = String(env.REALM || DEFAULT_REALM).replace(/["\\]/g, '');

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
 * Forward an authenticated request to the origin.
 *
 * @param {Request} request
 * @param {URL} origin ORIGIN, possibly including a path prefix
 */
async function proxy(request, origin) {
  const incoming = new URL(request.url);
  const basePath = trimTrailingSlash(origin.pathname);
  const target = new URL(basePath + incoming.pathname + incoming.search, origin.origin);

  const headers = new Headers(request.headers);
  // The gate credentials are ours, not the origin's.
  headers.delete('authorization');
  headers.delete('cookie');

  // Methods are restricted to GET/HEAD/OPTIONS above, so there is never a body
  // to forward.
  const upstream = new Request(target, {
    method: request.method,
    headers,
    redirect: 'manual',
  });

  const response = await fetch(upstream);
  return rewriteRedirect(response, origin, incoming);
}

/**
 * Keep the browser on the gated hostname.
 *
 * GitHub Pages redirects to add trailing slashes, and its Location points at
 * github.io. Left alone, following one would escape the gate.
 */
function rewriteRedirect(response, origin, incoming) {
  const location = response.headers.get('location');
  if (!location) return response;

  let resolved;
  try {
    resolved = new URL(location, origin);
  } catch {
    return response;
  }

  // A redirect somewhere else entirely is the origin's business, not ours.
  if (resolved.origin !== origin.origin) return response;

  const basePath = trimTrailingSlash(origin.pathname);
  let path = resolved.pathname;
  if (basePath !== '' && path.startsWith(basePath)) {
    path = path.slice(basePath.length) || '/';
  }

  const headers = new Headers(response.headers);
  headers.set('location', new URL(path + resolved.search + resolved.hash, incoming.origin).toString());

  return new Response(BODILESS_STATUSES.has(response.status) ? null : response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}

function trimTrailingSlash(path) {
  return path === '/' ? '' : path.replace(/\/+$/, '');
}
