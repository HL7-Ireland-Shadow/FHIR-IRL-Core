/**
 * Exercises the Pages _worker.js fetch handler end to end against a stubbed
 * ASSETS binding.
 *
 * Node 24 supplies Request/Response/Headers, so the real module runs here
 * unmodified - no workerd needed.
 */

import assert from 'node:assert/strict';
import { beforeEach, describe, it } from 'node:test';

import gate from '../src/index.js';

const SITE = 'https://irl-core-ig.pages.dev';

function authHeader(username, password) {
  const bytes = new TextEncoder().encode(`${username}:${password}`);
  return `Basic ${btoa(String.fromCharCode(...bytes))}`;
}

/** Records asset lookups and replies with whatever the test queued. */
let served;
let reply;
let env;

beforeEach(() => {
  served = [];
  reply = () => new Response('<html>the IG</html>', { headers: { 'content-type': 'text/html' } });
  env = {
    BASIC_AUTH_USERNAME: 'ada',
    BASIC_AUTH_PASSWORD: 'lovelace',
    REALM: 'FHIR Core Ireland (draft IG)',
    ASSETS: {
      fetch: async (request) => {
        served.push(request);
        return reply(request);
      },
    },
  };
});

const get = (path = '/', init = {}) => new Request(SITE + path, init);
const authed = (path = '/', init = {}) =>
  get(path, { ...init, headers: { authorization: authHeader('ada', 'lovelace'), ...init.headers } });

describe('the gate', () => {
  it('challenges an unauthenticated request without touching the assets', async () => {
    const response = await gate.fetch(get('/'), env);

    assert.equal(response.status, 401);
    assert.equal(
      response.headers.get('www-authenticate'),
      'Basic realm="FHIR Core Ireland (draft IG)", charset="UTF-8"',
    );
    assert.equal(response.headers.get('cache-control'), 'no-store');
    assert.equal(served.length, 0);
  });

  it('challenges a wrong password', async () => {
    const response = await gate.fetch(
      get('/', { headers: { authorization: authHeader('ada', 'wrong') } }),
      env,
    );

    assert.equal(response.status, 401);
    assert.equal(served.length, 0);
  });

  it('challenges a wrong username', async () => {
    const response = await gate.fetch(
      get('/', { headers: { authorization: authHeader('eve', 'lovelace') } }),
      env,
    );

    assert.equal(response.status, 401);
    assert.equal(served.length, 0);
  });

  it('challenges a malformed Authorization header', async () => {
    const response = await gate.fetch(get('/', { headers: { authorization: 'Bearer abc' } }), env);

    assert.equal(response.status, 401);
    assert.equal(served.length, 0);
  });

  it('falls back to a default realm when REALM is unset', async () => {
    delete env.REALM;
    const response = await gate.fetch(get('/'), env);

    assert.equal(response.headers.get('www-authenticate'), 'Basic realm="Restricted", charset="UTF-8"');
  });

  it('strips quotes and backslashes that would break the realm header', async () => {
    env.REALM = 'a "quoted" ' + String.fromCharCode(92) + ' realm';
    const response = await gate.fetch(get('/'), env);

    assert.equal(response.headers.get('www-authenticate'), 'Basic realm="a quoted  realm", charset="UTF-8"');
  });

  it('serves the asset once authenticated', async () => {
    const response = await gate.fetch(authed('/'), env);

    assert.equal(response.status, 200);
    assert.equal(await response.text(), '<html>the IG</html>');
    assert.equal(served.length, 1);
  });

  it('passes the request through unchanged, path and query intact', async () => {
    await gate.fetch(authed('/StructureDefinition-patient-ie.html?foo=bar'), env);

    assert.equal(served[0].url, `${SITE}/StructureDefinition-patient-ie.html?foo=bar`);
  });

  it('relays an asset 404 rather than masking it', async () => {
    reply = () => new Response('not found', { status: 404 });

    const response = await gate.fetch(authed('/nope.html'), env);

    assert.equal(response.status, 404);
  });
});

describe('fail-closed configuration', () => {
  for (const [name, patch] of [
    ['no username', { BASIC_AUTH_USERNAME: undefined }],
    ['no password', { BASIC_AUTH_PASSWORD: undefined }],
    ['an empty username', { BASIC_AUTH_USERNAME: '' }],
    ['an empty password', { BASIC_AUTH_PASSWORD: '' }],
  ]) {
    it(`refuses everything with ${name}`, async () => {
      const response = await gate.fetch(authed('/'), { ...env, ...patch });

      assert.equal(response.status, 500);
      assert.equal(response.headers.get('cache-control'), 'no-store');
      assert.equal(served.length, 0, 'assets must not be served');
    });
  }

  it('refuses everything when the ASSETS binding is missing', async () => {
    const response = await gate.fetch(authed('/'), { ...env, ASSETS: undefined });

    assert.equal(response.status, 500);
  });

  it('does not leak the secrets in an error body', async () => {
    const response = await gate.fetch(authed('/'), { ...env, BASIC_AUTH_PASSWORD: '' });
    const body = await response.text();

    assert.ok(!body.includes('ada'));
    assert.ok(!body.includes('lovelace'));
  });
});

describe('method policy', () => {
  it('refuses a write method, but only after authenticating', async () => {
    const response = await gate.fetch(authed('/', { method: 'DELETE' }), env);

    assert.equal(response.status, 405);
    assert.equal(response.headers.get('allow'), 'GET, HEAD, OPTIONS');
    assert.equal(served.length, 0);
  });

  it('challenges an unauthenticated write method rather than disclosing the policy', async () => {
    const response = await gate.fetch(get('/', { method: 'DELETE' }), env);

    assert.equal(response.status, 401);
  });

  it('serves HEAD', async () => {
    const response = await gate.fetch(authed('/', { method: 'HEAD' }), env);

    assert.equal(response.status, 200);
    assert.equal(served[0].method, 'HEAD');
  });
});
