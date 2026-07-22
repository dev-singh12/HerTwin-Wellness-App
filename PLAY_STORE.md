# Play Store release checklist

Status of every Google Play requirement for HerTwin, and exactly what is left
for you to do. Items marked **YOU** need a human — an account, a payment, a
password, or a legal review — and cannot be automated.

---

## 1. Build & signing

| Item | Status |
|---|---|
| Target API level ≥ 35 | ✅ `targetSdkVersion 36` |
| Min SDK | ✅ 23 (Android 6.0+, ~99% of devices) |
| 64-bit support | ✅ arm64-v8a included |
| App Bundle (.aab), not APK | ✅ `flutter build appbundle --release` |
| Code shrinking + obfuscation | ✅ `minifyEnabled`, `shrinkResources`, proguard |
| `allowBackup=false` | ✅ health data not extractable via `adb backup` |
| `usesCleartextTraffic=false` | ✅ |
| Debuggable in release | ✅ no (Flutter release build) |
| **Upload keystore** | ⬜ **YOU** — run `bash tool/create-keystore.sh` |

Until the keystore exists, release builds fall back to the **debug** key.
That installs fine for sideloading but Play rejects it.

```bash
bash tool/create-keystore.sh                              # once
flutter build appbundle --release --no-tree-shake-icons   # every release
# → build/app/outputs/bundle/release/app-release.aab
```

Verify you are not about to upload a debug-signed artifact:

```bash
$ANDROID_HOME/build-tools/36.0.0/apksigner verify --print-certs \
  build/app/outputs/flutter-apk/app-release.apk
```

If the certificate says `CN=Android Debug`, the keystore is not wired up.

**Enrol in Play App Signing.** Google then holds the app signing key and you
hold only an upload key — which means a lost upload key is recoverable. Without
it, losing your keystore permanently ends your ability to update the app.

---

## 2. Versioning

`pubspec.yaml` → `version: 1.0.0+1` (`versionName+versionCode`).

Play rejects any upload whose `versionCode` is not strictly greater than the
last one. Bump the number after the `+` on every single upload, even for a
re-upload of the same build.

---

## 3. Store assets

| Asset | Requirement | Status |
|---|---|---|
| App icon | 512×512 PNG, 32-bit | ✅ `assets/branding/play_store_icon_512.png` |
| Launcher icons | all densities + adaptive | ✅ generated (was the default Flutter logo) |
| Feature graphic | 1024×500 PNG/JPG | ⬜ **YOU** |
| Phone screenshots | 2–8, min 320px, 16:9 or 9:16 | ⬜ **YOU** |
| Short description | ≤ 80 chars | draft below |
| Full description | ≤ 4000 chars | draft below |

You have real screenshots already at
`~/Downloads/her_twin_wellness_screenshots/` — the
`iPhone 6.7" Display` set are iOS-framed, so use the `Android - 1080x2400`
folder for the Play listing.

### Draft short description

> Track your cycle, understand your hormones, and consult specialists — built for PCOS, PMS and PMDD.

### Draft full description

> HerTwin helps you understand what your body is doing and why.
>
> **Track what matters** — log your cycle, symptoms, mood, sleep and habits.
> HerTwin learns your pattern and tells you which phase you're in and what to
> expect next.
>
> **Understand your condition** — a guided assessment for PCOS, PCOD, PMS,
> PMDD and irregular cycles gives you a clear picture and a personalised plan,
> not a generic checklist.
>
> **Feel better day to day** — yoga, breathwork and guided meditation chosen
> for your condition and your current cycle phase, from real teachers.
>
> **Talk to a specialist** — book a chat or video consultation with
> gynaecologists, endocrinologists, nutritionists and psychologists. Your
> health summary is shared only with the clinician you book, and only for as
> long as you allow it.
>
> **You control your data** — your logs are private by default. No selling
> data, no ad targeting, no sharing with insurers or employers. Withdraw a
> clinician's access at any time.
>
> HerTwin is a wellness tool, not a medical device. It cannot diagnose you and
> must not be used for contraception. Always consult a qualified doctor.

---

## 4. Privacy policy — **required, blocking**

Play requires a **publicly reachable URL**, not an in-app page. The in-app
screens (`/legal`) satisfy user-facing disclosure but not the listing field.

Source text lives in `lib/business/legal_content.dart` and has three
placeholders to fill first:

- `companyName` — your registered entity
- `contactEmail` — a monitored inbox (currently `privacy@hertwin.app`)
- Terms §11 — governing jurisdiction

**Have a lawyer review before publishing.** This app handles health data,
which attracts India's DPDP Act 2023 and, for any EU/UK users, GDPR Article 9
"special category" rules. The draft is accurate to what the code does; that is
not the same as being legally sufficient.

Easiest hosting, since the project already has Firebase:

```bash
firebase init hosting        # public dir: web-legal
firebase deploy --only hosting
# → https://hertwin-wellness.web.app/privacy
```

---

## 5. Data Safety form

Answers below are derived from the actual code, not guesswork. Every "yes"
maps to a real Firestore path or SDK call.

**Data collected**

| Category | Type | Collected | Shared | Optional | Purpose |
|---|---|---|---|---|---|
| Personal info | Name | Yes | No | No | Account, community display |
| Personal info | Email | Yes | No | No | Account, sign-in |
| Photos | Profile photo | Yes | No | Yes | Account, community display |
| Photos | Prescriptions / reports | Yes | No | Yes | Share with your clinician |
| Health | Menstrual cycle | Yes | No | No | App functionality |
| Health | Symptoms, mood, sleep, water, exercise | Yes | No | Yes | App functionality |
| Health | Assessment answers & score | Yes | No | No | Personalised care plan |
| Health | Medicine reminders & adherence | Yes | No | Yes | App functionality |
| Messages | Consultation chat | Yes | No | Yes | Clinician consultation |
| App activity | Screen views, app opens | Yes | No | No | Analytics |
| Device ID | Firebase instance ID | Yes | No | No | Analytics |

**Answer "No" to "Is data shared with third parties?"** Firebase is a
processor acting on your behalf, not a third-party recipient. Clinician access
is in-app, user-initiated, and consent-gated — Play does not count that as
third-party sharing.

**Security practices**
- Encrypted in transit — **Yes**
- Users can request deletion — **Yes** (via `contactEmail`)
- Follows Play Families policy — N/A (16+)
- Independent security review — **No**

---

## 6. Content rating & declarations

- **Category**: Health & Fitness
- **Content rating**: complete the IARC questionnaire. Expect Everyone / PEGI 3.
  Declare that the app includes user-generated content (the community feed).
- **Target audience**: 16+. Do **not** tick "children" — it triggers Families
  policy, which this app does not comply with.
- **Health apps declaration**: Play asks whether you provide medical advice.
  Answer **no** — HerTwin is a wellness tracker, and the Terms say so
  explicitly.
- **User-generated content**: yes. You must state how you moderate it.
  ⚠️ **See gap below.**
- **Ads**: no.
- **In-app purchases**: no (consultations are demo mode, no payment taken).

---

## 7. Known gaps before you submit

1. ⬜ **Keystore** — `bash tool/create-keystore.sh`
2. ⬜ **Privacy policy URL** — host it, fill the three placeholders, get it
   reviewed by a lawyer
3. ⬜ **Feature graphic** (1024×500) and store screenshots
4. ⬜ **Community moderation** — Play policy requires apps with user-generated
   content to offer in-app **reporting and blocking**. The community feed has
   neither. This is a likely rejection point and needs building.
5. ⬜ **Account deletion** — Play requires an in-app path to request deletion,
   plus a web URL. Currently only an email address in the policy.
6. ⬜ **Firebase Storage** not initialised — profile photo and prescription
   upload will fail at runtime until you enable it in the console.
7. ⬜ Real consultations need real clinicians. `node tool/admin.js promote
   <email>` turns a signed-up user into one.

Items 4 and 5 are policy requirements, not nice-to-haves. I would fix those
before the first submission rather than after a rejection.
