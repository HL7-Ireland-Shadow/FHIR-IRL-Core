import assert from 'node:assert/strict';
import { describe, it } from 'node:test';

import { credentialsMatch, parseBasicCredentials, secureEqual } from '../src/auth.js';

/** Build an `Authorization: Basic ...` value the way a client would. */
function basic(username, password) {
  const bytes = new TextEncoder().encode(`${username}:${password}`);
  return `Basic ${btoa(String.fromCharCode(...bytes))}`;
}

describe('parseBasicCredentials', () => {
  it('decodes a well-formed header', () => {
    assert.deepEqual(parseBasicCredentials(basic('ada', 'lovelace')), {
      username: 'ada',
      password: 'lovelace',
    });
  });

  it('splits on the first colon only, so passwords may contain colons', () => {
    assert.deepEqual(parseBasicCredentials(basic('ada', 'a:b:c')), {
      username: 'ada',
      password: 'a:b:c',
    });
  });

  it('round-trips non-ASCII passwords as UTF-8', () => {
    assert.deepEqual(parseBasicCredentials(basic('sean', 'pasfhocal-éáíóú')), {
      username: 'sean',
      password: 'pasfhocal-éáíóú',
    });
  });

  it('accepts the scheme case-insensitively', () => {
    assert.deepEqual(parseBasicCredentials(basic('ada', 'x').replace('Basic', 'bAsIc')), {
      username: 'ada',
      password: 'x',
    });
  });

  it('allows an empty password', () => {
    assert.deepEqual(parseBasicCredentials(basic('ada', '')), { username: 'ada', password: '' });
  });

  for (const [name, header] of [
    ['a missing header', null],
    ['a non-string header', undefined],
    ['an empty string', ''],
    ['no scheme separator', 'Basic'],
    ['an empty payload', 'Basic '],
    ['the wrong scheme', 'Bearer YWRhOng='],
    ['invalid base64', 'Basic !!!not-base64!!!'],
    ['invalid UTF-8', `Basic ${btoa('\xff\xfe:x')}`],
    ['no colon in the payload', `Basic ${btoa('adalovelace')}`],
  ]) {
    it(`rejects ${name}`, () => {
      assert.equal(parseBasicCredentials(header), null);
    });
  }
});

describe('secureEqual', () => {
  it('matches identical strings', async () => {
    assert.equal(await secureEqual('correct horse', 'correct horse'), true);
  });

  it('rejects differing strings of equal length', async () => {
    assert.equal(await secureEqual('abcdef', 'abcdeg'), false);
  });

  it('rejects strings of differing length', async () => {
    assert.equal(await secureEqual('short', 'considerably longer'), false);
  });

  it('matches empty strings', async () => {
    assert.equal(await secureEqual('', ''), true);
  });

  it('is not fooled by a prefix', async () => {
    assert.equal(await secureEqual('secret', 'secretplus'), false);
  });
});

describe('credentialsMatch', () => {
  const expected = { username: 'ada', password: 'lovelace' };

  it('accepts the configured pair', async () => {
    assert.equal(await credentialsMatch({ ...expected }, expected), true);
  });

  it('rejects a wrong password', async () => {
    assert.equal(await credentialsMatch({ username: 'ada', password: 'nope' }, expected), false);
  });

  it('rejects a wrong username', async () => {
    assert.equal(await credentialsMatch({ username: 'eve', password: 'lovelace' }, expected), false);
  });

  it('rejects a swapped pair', async () => {
    assert.equal(await credentialsMatch({ username: 'lovelace', password: 'ada' }, expected), false);
  });
});
