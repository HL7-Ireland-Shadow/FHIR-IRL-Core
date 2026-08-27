/**
 * Exercises the Worker's fetch handler end to end against a stubbed origin.
 *
 * Node 24 supplies Request/Response/Headers/fetch, so the real module runs here
 * unmodified - no workerd needed.
 */

import assert from 'node:assert/strict';
import { afterEach, beforeEach, describe, it } from 'node:test';

import worker from '../src/index.js';

const ORIGIN = 'https://example.github.io/FHIR-IRL-Core';
const GATE = 'https://ig.example.ie';

const ENV = {
  BASIC_AUTH_USERNAME: 'ada',
  BASIC_AUTH_PASSWORD: 'lovelace',
  ORIGIN,
  REALM: 'FHIR Core Ireland (draft IG)',
};

function authHeader(username, password) {
  const bytes = new TextEncoder().encode(`${username}:${password}`);
  return `Basic ${btoa(String.fromCharCode(...bytes))}`;
}

/** Records origin calls and replies with whatever the test queued. */
let calls;
let reply;
const realFetch = globalThis.fetch;

beforeEach(() => {
  calls = [];
  reply = () => new Response('<html>the IG</html>', { headers: { 'content-type': 'text/html' } });
  globalThis.fetch = async (request) => {
    calls.push(request);
    return reply(request);
  };
});

afterEach(() => {
  globalThis.fetch = realFetch;
});

const get = (path = '/', init = {}) => new Request(GATE + path, init);
const authed = (path = '/', init = {}) =>
  get(path, { ...init, headers: { authorization: authHeader('ada', 'lovelace'), ...init.headers } });

describe('the gate', () => {
  it('challenges an unauthenticated request without touching the origin', async () => {
    const response = await worker.fetch(get('/'), ENV);

    assert.equal(response.status, 401);
    assert.equal(
      response.headers.get('www-authenticate'),
      'Basic realm="FHIR Core Ireland (draft IG)", charset="UTF-8"',
    );
    assert.equal(response.headers.get('cache-control'), 'no-store');
    assert.equal(calls.length, 0);
  });

  it('challenges a wrong password', async () => {
    const response = await worker.fetch(
      get('/', { headers: { authorization: authHeader('ada', 'wrong') } }),
      ENV,
    );

    assert.equal(response.status, 401);
    assert.equal(calls.length, 0);
  });

  it('challenges a wrong username', async () => {
    const response = await worker.fetch(
      get('/', { headers: { authorization: authHeader('eve', 'lovelace') } }),
      ENV,
    );

    assert.equal(response.status, 401);
    assert.equal(calls.length, 0);
  });

  it('challenges a malformed Authorization header', async () => {
    const response = await worker.fetch(get('/', { headers: { authorization: 'Bearer abc' } }), ENV);

    assert.equal(response.status, 401);
    assert.equal(calls.length, 0);
  });

  it('proxies an authenticated request and returns the origin body', async () => {
    const response = await worker.fetch(authed('/'), ENV);

    assert.equal(response.status, 200);
    assert.equal(await response.text(), '<html>the IG</html>');
    assert.equal(calls.length, 1);
  });

  it('re-adds the project path prefix and preserves path and query', async () => {
    await worker.fetch(authed('/StructureDefinition-patient-ie.html?foo=bar'), ENV);

    assert.equal(
      calls[0].url,
      'https://example.github.io/FHIR-IRL-Core/StructureDefinition-patient-ie.html?foo=bar',
    );
  });

  it('does not forward the gate credentials to the origin', async () => {
    await worker.fetch(authed('/', { headers: { cookie: 'session=abc' } }), ENV);

    assert.equal(calls[0].headers.get('authorization'), null);
    assert.equal(calls[0].headers.get('cookie'), null);
  });
});

describe('fail-closed configuration', () => {
  for (const [name, env] of [
    ['no username', { ...ENV, BASIC_AUTH_USERNAME: undefined }],
    ['no password', { ...ENV, BASIC_AUTH_PASSWORD: undefined }],
    ['an empty username', { ...ENV, BASIC_AUTH_USERNAME: '' }],
    ['an empty password', { ...ENV, BASIC_AUTH_PASSWORD: '' }],
  ]) {
    it(`refuses everything with ${name}`, async () => {
      const response = await worker.fetch(authed('/'), env);

      assert.equal(response.status, 500);
      assert.equal(calls.length, 0, 'origin must not be reached');
    });
  }

  for (const [name, origin] of [
    ['missing', undefined],
    ['empty', ''],
    ['not absolute', '/FHIR-IRL-Core'],
    ['a non-HTTP scheme', 'file:///etc/passwd'],
  ]) {
    it(`refuses everything when ORIGIN is ${name}`, async () => {
      const response = await worker.fetch(authed('/'), { ...ENV, ORIGIN: origin });

      assert.equal(response.status, 500);
      assert.equal(calls.length, 0);
    });
  }
});

describe('method policy', () => {
  it('refuses a write method, but only after authenticating', async () => {
    const response = await worker.fetch(authed('/', { method: 'DELETE' }), ENV);

    assert.equal(response.status, 405);
    assert.equal(response.headers.get('allow'), 'GET, HEAD, OPTIONS');
    assert.equal(calls.length, 0);
  });

  it('challenges an unauthenticated write method rather than disclosing the policy', async () => {
    const response = await worker.fetch(get('/', { method: 'DELETE' }), ENV);

    assert.equal(response.status, 401);
  });

  it('proxies HEAD', async () => {
    const response = await worker.fetch(authed('/', { method: 'HEAD' }), ENV);

    assert.equal(response.status, 200);
    assert.equal(calls[0].method, 'HEAD');
  });
});

describe('redirect rewriting', () => {
  it('rewrites an origin redirect back onto the gated host', async () => {
    reply = () =>
      new Response(null, {
        status: 301,
        headers: { location: `${ORIGIN}/artifacts/` },
      });

    const response = await worker.fetch(authed('/artifacts'), ENV);

    assert.equal(response.status, 301);
    assert.equal(response.headers.get('location'), `${GATE}/artifacts/`);
  });

  it('rewrites a relative redirect', async () => {
    reply = () => new Response(null, { status: 302, headers: { location: '/FHIR-IRL-Core/toc.html' } });

    const response = await worker.fetch(authed('/toc'), ENV);

    assert.equal(response.headers.get('location'), `${GATE}/toc.html`);
  });

  it('leaves a redirect to a third party alone', async () => {
    reply = () =>
      new Response(null, { status: 302, headers: { location: 'https://hl7.org/fhir/' } });

    const response = await worker.fetch(authed('/spec'), ENV);

    assert.equal(response.headers.get('location'), 'https://hl7.org/fhir/');
  });

  it('handles a bodiless 304 without constructing an invalid response', async () => {
    reply = () => new Response(null, { status: 304, headers: { location: `${ORIGIN}/x` } });

    const response = await worker.fetch(authed('/x'), ENV);

    assert.equal(response.status, 304);
    assert.equal(response.headers.get('location'), `${GATE}/x`);
  });
});
