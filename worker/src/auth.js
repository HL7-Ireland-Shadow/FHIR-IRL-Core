/**
 * RFC 7617 Basic authentication helpers.
 *
 * Deliberately free of Workers-specific globals so the same code runs under
 * `node --test`. Everything used here (atob, TextDecoder, crypto.subtle) is
 * present in both runtimes.
 */

const encoder = new TextEncoder();

/**
 * Decode an `Authorization: Basic ...` header value.
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
 * @param {string} a
 * @param {string} b
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
 * Both halves are always compared - never short-circuited on the username -
 * so response timing does not reveal which half was wrong.
 *
 * @param {{ username: string, password: string }} supplied
 * @param {{ username: string, password: string }} expected
 * @returns {Promise<boolean>}
 */
export async function credentialsMatch(supplied, expected) {
  const [usernameOk, passwordOk] = await Promise.all([
    secureEqual(supplied.username, expected.username),
    secureEqual(supplied.password, expected.password),
  ]);
  return usernameOk && passwordOk;
}
