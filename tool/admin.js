#!/usr/bin/env node
/**
 * HerTwin admin tool — privileged Firestore operations.
 *
 * Doctor profiles live at `doctors/{id}` and, per firestore.rules, are NOT
 * client-creatable. That is deliberate: a `doctors/{uid}` document keyed by an
 * auth uid is what grants a clinician the right to read consenting patients'
 * health data. If a client could write it, any user could self-promote and
 * read other people's medical records. So provisioning happens here, out of
 * reach of the app.
 *
 * Auth: reuses the Firebase CLI's own OAuth refresh token (`firebase login`),
 * or a service account via GOOGLE_APPLICATION_CREDENTIALS. No credentials are
 * ever printed or written to the repo.
 *
 * Usage:
 *   node tool/admin.js seed-doctors        # catalog profiles (bookable)
 *   node tool/admin.js promote <email>     # make an existing user a clinician
 *   node tool/admin.js demote <email>      # revoke clinician access
 *   node tool/admin.js list-doctors
 */

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const PROJECT_ID = 'hertwin-wellness';
const FIRESTORE = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;
const IDENTITY = `https://identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}`;

// Public OAuth client shipped inside firebase-tools. Not a secret — it is an
// installed-app client, which is why it can live in open source.
const CLI_CLIENT_ID =
  '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const CLI_CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

async function getAccessToken() {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    throw new Error(
      'Service-account auth is not implemented here. Unset ' +
        'GOOGLE_APPLICATION_CREDENTIALS to use your `firebase login` session.'
    );
  }

  const configPath = path.join(
    os.homedir(),
    '.config',
    'configstore',
    'firebase-tools.json'
  );
  if (!fs.existsSync(configPath)) {
    throw new Error('Not logged in. Run: firebase login');
  }

  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const refreshToken = config.tokens && config.tokens.refresh_token;
  if (!refreshToken) {
    throw new Error('No refresh token found. Run: firebase login --reauth');
  }

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id: CLI_CLIENT_ID,
      client_secret: CLI_CLIENT_SECRET,
      refresh_token: refreshToken,
      grant_type: 'refresh_token',
    }),
  });

  if (!res.ok) {
    throw new Error(
      `Token refresh failed (${res.status}). Run: firebase login --reauth`
    );
  }
  const json = await res.json();
  return json.access_token;
}

// ---------------------------------------------------------------------------
// Firestore REST value encoding
// ---------------------------------------------------------------------------

function toValue(v) {
  if (v === null || v === undefined) return { nullValue: null };
  if (v instanceof Date) return { timestampValue: v.toISOString() };
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number') {
    return Number.isInteger(v)
      ? { integerValue: String(v) }
      : { doubleValue: v };
  }
  if (typeof v === 'string') return { stringValue: v };
  if (Array.isArray(v)) {
    return { arrayValue: { values: v.map(toValue) } };
  }
  if (typeof v === 'object') {
    return { mapValue: { fields: toFields(v) } };
  }
  throw new Error(`Cannot encode value of type ${typeof v}`);
}

function toFields(obj) {
  const fields = {};
  for (const [k, v] of Object.entries(obj)) fields[k] = toValue(v);
  return fields;
}

function fromValue(v) {
  if (!v || typeof v !== 'object') return v;
  if ('nullValue' in v) return null;
  if ('stringValue' in v) return v.stringValue;
  if ('booleanValue' in v) return v.booleanValue;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return v.doubleValue;
  if ('timestampValue' in v) return new Date(v.timestampValue);
  if ('arrayValue' in v) return (v.arrayValue.values || []).map(fromValue);
  if ('mapValue' in v) {
    const out = {};
    for (const [k, val] of Object.entries(v.mapValue.fields || {})) {
      out[k] = fromValue(val);
    }
    return out;
  }
  return v;
}

// ---------------------------------------------------------------------------
// Firestore operations
// ---------------------------------------------------------------------------

async function writeDoc(token, collection, docId, data) {
  const res = await fetch(`${FIRESTORE}/${collection}/${encodeURIComponent(docId)}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ fields: toFields(data) }),
  });
  if (!res.ok) {
    throw new Error(`Write ${collection}/${docId} failed: ${res.status} ${await res.text()}`);
  }
  return res.json();
}

async function deleteDoc(token, collection, docId) {
  const res = await fetch(`${FIRESTORE}/${collection}/${encodeURIComponent(docId)}`, {
    method: 'DELETE',
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok && res.status !== 404) {
    throw new Error(`Delete ${collection}/${docId} failed: ${res.status}`);
  }
}

async function listDocs(token, collection) {
  const res = await fetch(`${FIRESTORE}/${collection}?pageSize=300`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) throw new Error(`List ${collection} failed: ${res.status}`);
  const json = await res.json();
  return (json.documents || []).map((d) => {
    const out = { _id: d.name.split('/').pop() };
    for (const [k, v] of Object.entries(d.fields || {})) out[k] = fromValue(v);
    return out;
  });
}

async function lookupUserByEmail(token, email) {
  const res = await fetch(`${IDENTITY}/accounts:lookup`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email: [email] }),
  });
  if (!res.ok) {
    throw new Error(`User lookup failed: ${res.status} ${await res.text()}`);
  }
  const json = await res.json();
  return (json.users || [])[0] || null;
}

// ---------------------------------------------------------------------------
// Doctor catalog
//
// These are bookable profiles. Their ids are NOT auth uids, so they grant no
// privileges to anyone — `exists(doctors/$(request.auth.uid))` can never match
// a catalog id. Use `promote <email>` to create a real clinician account whose
// doc id IS their auth uid.
// ---------------------------------------------------------------------------

const DOCTOR_CATALOG = [
  {
    id: 'doctor_0',
    name: 'Dr. Sarah Jenkins',
    specialty: 'Gynaecologist',
    qualifications: 'MBBS, MD (Obstetrics & Gynaecology)',
    rating: 4.9,
    reviewCount: 247,
    isAvailable: true,
    conditionsTreated: ['pcos', 'pcod', 'irregular', 'pms'],
    consultationMode: 'all',
    yearsExperience: 12,
    bio: "Specializing in hormonal disorders and women's reproductive health.",
    languagesSpoken: 'English, Hindi',
    photoUrl: '',
  },
  {
    id: 'doctor_1',
    name: 'Dr. Priya Mehta',
    specialty: 'Endocrinologist',
    qualifications: 'MBBS, MD (Endocrinology)',
    rating: 4.8,
    reviewCount: 183,
    isAvailable: true,
    conditionsTreated: ['pcos', 'pcod'],
    consultationMode: 'all',
    yearsExperience: 9,
    bio: 'Expert in insulin resistance, hormonal balance, and PCOS management.',
    languagesSpoken: 'English, Hindi, Marathi',
    photoUrl: '',
  },
  {
    id: 'doctor_2',
    name: 'Dr. Ananya Roy',
    specialty: 'Gynaecologist',
    qualifications: 'MBBS, DNB (Gynaecology)',
    rating: 4.7,
    reviewCount: 156,
    isAvailable: true,
    conditionsTreated: ['pms', 'pmdd', 'irregular'],
    consultationMode: 'all',
    yearsExperience: 7,
    bio: 'Focused on menstrual disorders and premenstrual syndromes.',
    languagesSpoken: 'English, Bengali, Hindi',
    photoUrl: '',
  },
  {
    id: 'doctor_3',
    name: 'Dr. Kavya Nair',
    specialty: 'Psychologist',
    qualifications: 'MSc (Clinical Psychology), MPhil',
    rating: 4.9,
    reviewCount: 89,
    isAvailable: true,
    conditionsTreated: ['pmdd', 'pms'],
    consultationMode: 'chat',
    yearsExperience: 5,
    bio: "Specializing in PMDD, mood disorders, and women's mental health.",
    languagesSpoken: 'English, Malayalam, Hindi',
    photoUrl: '',
  },
  {
    id: 'doctor_4',
    name: 'Dr. Ritu Sharma',
    specialty: 'Nutritionist & Dietician',
    qualifications: 'MSc (Clinical Nutrition), RD',
    rating: 4.8,
    reviewCount: 201,
    isAvailable: true,
    conditionsTreated: ['pcos', 'pcod', 'pms'],
    consultationMode: 'all',
    yearsExperience: 8,
    bio: 'Evidence-based nutrition plans for hormonal conditions.',
    languagesSpoken: 'English, Hindi, Punjabi',
    photoUrl: '',
  },
  {
    id: 'doctor_5',
    name: 'Dr. Meena Krishnan',
    specialty: 'Gynaecologist',
    qualifications: 'MBBS, MS (Obstetrics & Gynaecology)',
    rating: 4.6,
    reviewCount: 134,
    isAvailable: true,
    conditionsTreated: ['pcos', 'pcod', 'pms', 'pmdd', 'irregular'],
    consultationMode: 'all',
    yearsExperience: 15,
    bio: 'Senior gynaecologist with 15+ years in hormonal care.',
    languagesSpoken: 'English, Tamil, Hindi',
    photoUrl: '',
  },
];

function defaultSlots() {
  return {
    weekday: [
      '09:00', '09:30', '10:00', '10:30', '11:00', '11:30',
      '14:00', '14:30', '15:00', '15:30', '16:00', '16:30',
    ],
  };
}

// ---------------------------------------------------------------------------
// Commands
// ---------------------------------------------------------------------------

async function seedDoctors(token) {
  for (const doc of DOCTOR_CATALOG) {
    const { id, ...rest } = doc;
    await writeDoc(token, 'doctors', id, {
      ...rest,
      doctorId: id,
      verified: true,
      availableSlots: defaultSlots(),
      createdAt: new Date(),
    });
    console.log(`  seeded doctors/${id}  ${doc.name}`);
  }
  await writeDoc(token, 'meta', 'seeded_doctors', { seededAt: new Date() });
  console.log(`\n${DOCTOR_CATALOG.length} doctor profiles seeded.`);
}

async function promote(token, email) {
  const user = await lookupUserByEmail(token, email);
  if (!user) {
    throw new Error(
      `No Firebase Auth user with email ${email}. ` +
        'Have them sign up in the app first, then re-run promote.'
    );
  }
  const uid = user.localId;
  const name = user.displayName || email.split('@')[0];

  await writeDoc(token, 'doctors', uid, {
    doctorId: uid,
    name: name.startsWith('Dr.') ? name : `Dr. ${name}`,
    specialty: 'Gynaecologist',
    qualifications: 'MBBS, MD',
    rating: 5.0,
    reviewCount: 0,
    isAvailable: true,
    conditionsTreated: ['pcos', 'pcod', 'pms', 'pmdd', 'irregular'],
    consultationMode: 'all',
    yearsExperience: 1,
    bio: 'HerTwin clinician.',
    languagesSpoken: 'English',
    photoUrl: user.photoUrl || '',
    verified: true,
    availableSlots: defaultSlots(),
    createdAt: new Date(),
  });

  console.log(`Promoted ${email} to clinician.`);
  console.log(`  uid: ${uid}`);
  console.log('  They will land on the doctor dashboard at next sign-in.');
}

async function demote(token, email) {
  const user = await lookupUserByEmail(token, email);
  if (!user) throw new Error(`No Firebase Auth user with email ${email}.`);
  await deleteDoc(token, 'doctors', user.localId);
  console.log(`Revoked clinician access for ${email}.`);
}

/**
 * Moves legacy bookings from users/{uid}/appointments/{id} to the top-level
 * appointments/{id}, mapping uid -> patientUid and doctorId -> doctorUid.
 *
 * Idempotent: re-running overwrites the same target ids with the same data.
 * The originals are left in place; delete them from the console once the new
 * collection looks right.
 */
async function migrateAppointments(token) {
  const users = await listDocs(token, 'users');
  let moved = 0;

  for (const user of users) {
    const uid = user._id;
    let legacy;
    try {
      legacy = await listDocs(token, `users/${uid}/appointments`);
    } catch {
      continue;
    }
    if (legacy.length === 0) continue;

    for (const old of legacy) {
      const id = old.appointmentId || old._id;
      await writeDoc(token, 'appointments', id, {
        appointmentId: id,
        patientUid: old.uid || uid,
        patientName: user.displayName || '',
        patientPhotoUrl: user.photoUrl || '',
        patientAge: user.age || 0,
        patientCondition: user.conditionType || '',
        patientSeverity: user.latestSeverityLabel || '',
        patientScore: user.healthVitalityScore || 0,
        doctorUid: old.doctorId || '',
        doctorName: old.doctorName || '',
        doctorPhotoUrl: old.doctorPhotoUrl || '',
        doctorSpecialty: old.doctorSpecialty || '',
        consultationType: old.consultationType || 'chat',
        priceRs: old.priceRs || 0,
        paymentStatus: 'demo',
        status: old.status || 'booked',
        scheduledAt: old.scheduledAt || null,
        meetingLink: old.meetingLink || null,
        reasonForVisit: old.notes || null,
        doctorNotes: null,
        prescriptionText: null,
        completedAt: null,
        createdAt: old.createdAt || new Date(),
        updatedAt: new Date(),
      });

      // Preserve the consent the new rules expect, so the doctor can still
      // open charts for bookings made before consent existed.
      if (old.doctorId) {
        await writeDoc(token, `users/${uid}/consents`, old.doctorId, {
          doctorUid: old.doctorId,
          doctorName: old.doctorName || '',
          grantedAt: old.createdAt || new Date(),
          appointmentId: id,
        });
      }

      moved++;
      console.log(`  moved ${uid.slice(0, 8)}…/${id} -> appointments/${id}`);
    }
  }

  console.log(
    moved === 0
      ? 'No legacy appointments found.'
      : `\n${moved} appointment(s) migrated. Originals left in place.`
  );
}

async function listDoctors(token) {
  const docs = await listDocs(token, 'doctors');
  if (docs.length === 0) {
    console.log('No doctors. Run: node tool/admin.js seed-doctors');
    return;
  }
  // A doc id that is 28 chars of Firebase-uid shape is a real account; the
  // seeded catalog uses readable ids like doctor_0.
  for (const d of docs) {
    const isAccount = !/^doctor_\d+$/.test(d._id);
    console.log(
      `  ${isAccount ? '[account] ' : '[catalog] '}${d._id.padEnd(30)} ${d.name || ''} — ${d.specialty || ''}`
    );
  }
  console.log(`\n${docs.length} total.`);
}

// ---------------------------------------------------------------------------

async function main() {
  const [cmd, arg] = process.argv.slice(2);
  if (!cmd) {
    console.log(
      'Usage:\n' +
        '  node tool/admin.js seed-doctors\n' +
        '  node tool/admin.js promote <email>\n' +
        '  node tool/admin.js demote <email>\n' +
        '  node tool/admin.js list-doctors\n' +
        '  node tool/admin.js migrate-appointments'
    );
    process.exit(1);
  }

  const token = await getAccessToken();

  switch (cmd) {
    case 'seed-doctors':
      return seedDoctors(token);
    case 'promote':
      if (!arg) throw new Error('promote requires an email address.');
      return promote(token, arg);
    case 'demote':
      if (!arg) throw new Error('demote requires an email address.');
      return demote(token, arg);
    case 'migrate-appointments':
      return migrateAppointments(token);
    case 'list-doctors':
      return listDoctors(token);
    default:
      throw new Error(`Unknown command: ${cmd}`);
  }
}

main().catch((err) => {
  console.error(`\nError: ${err.message}`);
  process.exit(1);
});
