#!/usr/bin/env node
/**
 * Security-rules test suite.
 *
 * Runs firestore.rules against Google's Security Rules `projects:test` API,
 * which evaluates the real rule source against simulated requests. This is
 * how we prove the rules deny what we claim they deny, rather than asserting
 * it in a commit message.
 *
 * Usage: node tool/test_rules.js
 */

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const PROJECT_ID = 'hertwin-wellness';
const DB = `/databases/(default)/documents`;

const CLI_CLIENT_ID =
  '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const CLI_CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

const PATIENT = 'patient_alice';
const ATTACKER = 'attacker_mallory';
const DOCTOR = 'doctor_dana';

async function getAccessToken() {
  const configPath = path.join(
    os.homedir(), '.config', 'configstore', 'firebase-tools.json'
  );
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: CLI_CLIENT_ID,
      client_secret: CLI_CLIENT_SECRET,
      refresh_token: config.tokens.refresh_token,
      grant_type: 'refresh_token',
    }),
  });
  if (!res.ok) throw new Error('Token refresh failed. Run: firebase login --reauth');
  return (await res.json()).access_token;
}

/** Mock `exists(doctors/{uid})` — the check that grants clinician privilege. */
function doctorExistsMock(uid, exists) {
  return {
    function: 'exists',
    args: [{ exactValue: `${DB}/doctors/${uid}` }],
    result: { value: exists },
  };
}

/** Mock `exists(users/{patient}/consents/{doctor})` — the consent grant. */
function consentExistsMock(patientUid, doctorUid, exists) {
  return {
    function: 'exists',
    args: [{ exactValue: `${DB}/users/${patientUid}/consents/${doctorUid}` }],
    result: { value: exists },
  };
}

function tc(name, expectation, testCase, functionMocks = []) {
  return { name, expectation, ...testCase, functionMocks };
}

/**
 * Builds a TestCase.
 *
 * The Rules test API exposes two separate documents and conflating them makes
 * tests pass for the wrong reason:
 *   - `request.resource.data` — the INCOMING document (`data` below)
 *   - `resource.data`         — the document ALREADY STORED (`existing` below)
 *
 * `update` and `delete` rules read both. An earlier version of this harness
 * only ever set the incoming one, so every update rule evaluated against a
 * null `resource` and short-circuited to deny — which looks like a passing
 * DENY test while actually testing nothing.
 */
function req({ uid, path: p, method, data, existing }) {
  const testCase = {
    request: {
      path: `${DB}${p}`,
      method,
      auth: uid ? { uid, token: { sub: uid } } : null,
    },
  };
  if (data) testCase.request.resource = { data };
  if (existing) testCase.resource = { data: existing };
  return testCase;
}

const TESTS = [
  // --- users -------------------------------------------------------------
  tc('owner reads own profile', 'ALLOW',
    req({ uid: PATIENT, path: `/users/${PATIENT}`, method: 'get' })),

  tc('stranger CANNOT read another user profile', 'DENY',
    req({ uid: ATTACKER, path: `/users/${PATIENT}`, method: 'get' }),
    [doctorExistsMock(ATTACKER, false)]),

  tc('stranger CANNOT read another user cycle logs', 'DENY',
    req({ uid: ATTACKER, path: `/users/${PATIENT}/cycles/c1`, method: 'get' }),
    [doctorExistsMock(ATTACKER, false)]),

  tc('nested consultation data is reachable by owner (4 levels deep)', 'ALLOW',
    req({ uid: PATIENT, path: `/users/${PATIENT}/appointments/a1/messages/m1`, method: 'get' })),

  // --- doctor consent ----------------------------------------------------
  tc('consented doctor CAN read patient chart', 'ALLOW',
    req({ uid: DOCTOR, path: `/users/${PATIENT}/symptoms/s1`, method: 'get' }),
    [doctorExistsMock(DOCTOR, true), consentExistsMock(PATIENT, DOCTOR, true)]),

  tc('doctor WITHOUT consent CANNOT read patient chart', 'DENY',
    req({ uid: DOCTOR, path: `/users/${PATIENT}/symptoms/s1`, method: 'get' }),
    [doctorExistsMock(DOCTOR, true), consentExistsMock(PATIENT, DOCTOR, false)]),

  tc('consented doctor still CANNOT write patient data', 'DENY',
    req({ uid: DOCTOR, path: `/users/${PATIENT}/symptoms/s1`, method: 'create',
          data: { note: 'x' } }),
    [doctorExistsMock(DOCTOR, true), consentExistsMock(PATIENT, DOCTOR, true)]),

  // --- privilege escalation ---------------------------------------------
  tc('user CANNOT create a doctor profile for themselves', 'DENY',
    req({ uid: ATTACKER, path: `/doctors/${ATTACKER}`, method: 'create',
          data: { doctorId: ATTACKER, name: 'Dr Mallory' } })),

  tc('user CANNOT overwrite an existing doctor profile', 'DENY',
    req({ uid: ATTACKER, path: `/doctors/doctor_0`, method: 'update',
          data: { doctorId: 'doctor_0', name: 'hijacked', rating: 5.0 },
          existing: { doctorId: 'doctor_0', name: 'Dr Real', rating: 4.9 } })),

  tc('user CANNOT delete a doctor profile', 'DENY',
    req({ uid: ATTACKER, path: `/doctors/doctor_0`, method: 'delete',
          existing: { doctorId: 'doctor_0', name: 'Dr Real' } })),

  tc('user CANNOT write the meta seeding flag', 'DENY',
    req({ uid: ATTACKER, path: `/meta/seeded_doctors`, method: 'create',
          data: { seededAt: 'now' } })),

  // --- appointments ------------------------------------------------------
  tc('third party CANNOT read someone else appointment', 'DENY',
    req({ uid: ATTACKER, path: `/appointments/appt1`, method: 'get',
          existing: { patientUid: PATIENT, doctorUid: DOCTOR, status: 'booked', priceRs: 300 } })),

  tc('the patient CAN read their own appointment', 'ALLOW',
    req({ uid: PATIENT, path: `/appointments/appt1`, method: 'get',
          existing: { patientUid: PATIENT, doctorUid: DOCTOR, status: 'booked', priceRs: 300 } })),

  tc('the assigned doctor CAN read the appointment', 'ALLOW',
    req({ uid: DOCTOR, path: `/appointments/appt1`, method: 'get',
          existing: { patientUid: PATIENT, doctorUid: DOCTOR, status: 'booked', priceRs: 300 } })),

  tc('the patient CANNOT mark their own consultation completed', 'DENY',
    req({ uid: PATIENT, path: `/appointments/appt1`, method: 'update',
          data: { patientUid: PATIENT, doctorUid: DOCTOR, status: 'completed', priceRs: 300 },
          existing: { patientUid: PATIENT, doctorUid: DOCTOR, status: 'booked', priceRs: 300 } })),

  tc('the patient CANNOT change the price', 'DENY',
    req({ uid: PATIENT, path: `/appointments/appt1`, method: 'update',
          data: { patientUid: PATIENT, doctorUid: DOCTOR, status: 'cancelled', priceRs: 0 },
          existing: { patientUid: PATIENT, doctorUid: DOCTOR, status: 'booked', priceRs: 300 } })),

  tc('appointments cannot be deleted from a client', 'DENY',
    req({ uid: PATIENT, path: `/appointments/appt1`, method: 'delete',
          existing: { patientUid: PATIENT, doctorUid: DOCTOR, status: 'booked', priceRs: 300 } })),

  // --- community counters -----------------------------------------------
  tc('post cannot be created pre-loaded with fake likes', 'DENY',
    req({ uid: ATTACKER, path: `/posts/p1`, method: 'create',
          data: { authorUid: ATTACKER, content: 'hi', category: 'general',
                  likeCount: 5000, commentCount: 0 } })),

  tc('post cannot be created impersonating another author', 'DENY',
    req({ uid: ATTACKER, path: `/posts/p1`, method: 'create',
          data: { authorUid: PATIENT, content: 'hi', category: 'general',
                  likeCount: 0, commentCount: 0 } })),

  tc('valid post creation is allowed', 'ALLOW',
    req({ uid: PATIENT, path: `/posts/p1`, method: 'create',
          data: { authorUid: PATIENT, content: 'hello', category: 'general',
                  likeCount: 0, commentCount: 0 } })),

  tc('like doc cannot be written on behalf of another user', 'DENY',
    req({ uid: ATTACKER, path: `/posts/p1/likes/${PATIENT}`, method: 'create',
          data: { uid: PATIENT } })),

  // --- moderation --------------------------------------------------------
  tc('a user can file a report', 'ALLOW',
    req({ uid: PATIENT, path: `/reports/r1`, method: 'create',
          data: { reporterUid: PATIENT, contentType: 'post', contentId: 'p1',
                  reason: 'Spam or advertising', status: 'open' } })),

  tc('a report cannot be filed in someone else name', 'DENY',
    req({ uid: ATTACKER, path: `/reports/r1`, method: 'create',
          data: { reporterUid: PATIENT, contentType: 'post', contentId: 'p1',
                  reason: 'Spam', status: 'open' } })),

  tc('the moderation queue is NOT readable by users', 'DENY',
    req({ uid: PATIENT, path: `/reports/r1`, method: 'get',
          existing: { reporterUid: PATIENT, contentId: 'p1', status: 'open' } })),

  tc('a report cannot be deleted to hide evidence', 'DENY',
    req({ uid: ATTACKER, path: `/reports/r1`, method: 'delete',
          existing: { reporterUid: ATTACKER, contentId: 'p1', status: 'open' } })),

  tc('a report cannot be created pre-resolved', 'DENY',
    req({ uid: PATIENT, path: `/reports/r1`, method: 'create',
          data: { reporterUid: PATIENT, contentType: 'post', contentId: 'p1',
                  reason: 'Spam', status: 'closed' } })),

  tc('author may anonymise their own post on account deletion', 'ALLOW',
    req({ uid: PATIENT, path: `/posts/p1`, method: 'update',
          data: { authorUid: PATIENT, content: 'hello', category: 'general',
                  likeCount: 3, commentCount: 2,
                  authorName: 'Deleted user', authorInitials: '?',
                  authorPhotoUrl: '' },
          existing: { authorUid: PATIENT, content: 'hello', category: 'general',
                      likeCount: 3, commentCount: 2,
                      authorName: 'Asha', authorInitials: 'A',
                      authorPhotoUrl: 'x' } })),

  tc('like counter may move by exactly one', 'ALLOW',
    req({ uid: ATTACKER, path: `/posts/p1`, method: 'update',
          data: { authorUid: PATIENT, content: 'hello', category: 'general',
                  likeCount: 4, commentCount: 2 },
          existing: { authorUid: PATIENT, content: 'hello', category: 'general', likeCount: 3, commentCount: 2 } })),

  tc('like counter CANNOT be set to an arbitrary number', 'DENY',
    req({ uid: ATTACKER, path: `/posts/p1`, method: 'update',
          data: { authorUid: PATIENT, content: 'hello', category: 'general',
                  likeCount: 999999, commentCount: 2 },
          existing: { authorUid: PATIENT, content: 'hello', category: 'general', likeCount: 3, commentCount: 2 } })),

  tc('comment counter CANNOT be decremented', 'DENY',
    req({ uid: ATTACKER, path: `/posts/p1`, method: 'update',
          data: { authorUid: PATIENT, content: 'hello', category: 'general',
                  likeCount: 3, commentCount: 1 },
          existing: { authorUid: PATIENT, content: 'hello', category: 'general', likeCount: 3, commentCount: 2 } })),

  tc('a stranger CANNOT edit the text of someone else post', 'DENY',
    req({ uid: ATTACKER, path: `/posts/p1`, method: 'update',
          data: { authorUid: PATIENT, content: 'defaced', category: 'general',
                  likeCount: 3, commentCount: 2 },
          existing: { authorUid: PATIENT, content: 'hello', category: 'general', likeCount: 3, commentCount: 2 } })),

  tc('a stranger CANNOT delete someone else post', 'DENY',
    req({ uid: ATTACKER, path: `/posts/p1`, method: 'delete',
          existing: { authorUid: PATIENT, content: 'hello', category: 'general', likeCount: 3, commentCount: 2 } })),

  tc('the author CAN delete their own post', 'ALLOW',
    req({ uid: PATIENT, path: `/posts/p1`, method: 'delete',
          existing: { authorUid: PATIENT, content: 'hello', category: 'general', likeCount: 3, commentCount: 2 } })),

  tc('a stranger CANNOT rewrite another user post author fields', 'DENY',
    req({ uid: ATTACKER, path: `/posts/p1`, method: 'update',
          data: { authorUid: PATIENT, content: 'hello', category: 'general',
                  likeCount: 3, commentCount: 2,
                  authorName: 'hijacked' },
          existing: { authorUid: PATIENT, content: 'hello', category: 'general', likeCount: 3, commentCount: 2 } })),

  tc("a user's block list is private to them", 'DENY',
    req({ uid: ATTACKER, path: `/users/${PATIENT}/blocked/${ATTACKER}`,
          method: 'get' }),
    [doctorExistsMock(ATTACKER, false)]),

  // --- unauthenticated ---------------------------------------------------
  tc('signed-out user CANNOT read the feed', 'DENY',
    req({ uid: null, path: `/posts/p1`, method: 'get' })),

  tc('signed-out user CANNOT read any profile', 'DENY',
    req({ uid: null, path: `/users/${PATIENT}`, method: 'get' })),
];

async function main() {
  const token = await getAccessToken();
  const source = fs.readFileSync(
    path.join(__dirname, '..', 'firestore.rules'), 'utf8'
  );

  const res = await fetch(
    `https://firebaserules.googleapis.com/v1/projects/${PROJECT_ID}:test`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        source: { files: [{ name: 'firestore.rules', content: source }] },
        // The API rejects unknown fields, so `name` is kept only locally for
        // reporting and stripped from the wire payload.
        testSuite: {
          testCases: TESTS.map(({ name, ...wire }) => wire),
        },
      }),
    }
  );

  if (!res.ok) {
    console.error(`API error ${res.status}: ${await res.text()}`);
    process.exit(1);
  }

  const json = await res.json();

  if (json.issues && json.issues.length) {
    console.error('Rules failed to compile:');
    for (const i of json.issues) {
      console.error(`  ${i.severity}: ${i.description} (line ${i.sourcePosition?.line})`);
    }
    process.exit(1);
  }

  const results = json.testResults || [];
  let passed = 0;
  let failed = 0;

  results.forEach((r, i) => {
    const name = TESTS[i].name;
    const want = TESTS[i].expectation;
    if (r.state === 'SUCCESS') {
      passed++;
      console.log(`  PASS  [${want.padEnd(5)}] ${name}`);
    } else {
      failed++;
      console.log(`  FAIL  [${want.padEnd(5)}] ${name}`);
      (r.errorPosition ? [r.errorPosition] : []).forEach((e) =>
        console.log(`          at line ${e.line}`)
      );
      if (r.debugMessages) {
        r.debugMessages.slice(0, 2).forEach((m) => console.log(`          ${m}`));
      }
    }
  });

  console.log(`\n${passed} passed, ${failed} failed, ${results.length} total.`);
  process.exit(failed === 0 ? 0 : 1);
}

main().catch((e) => {
  console.error(`Error: ${e.message}`);
  process.exit(1);
});
