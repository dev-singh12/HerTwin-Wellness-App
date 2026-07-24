# HerTwin Wellness App — Project Context

> Context file for AI assistants. Read this first before working on the codebase.
> Covers **what it is**, **how it's built**, **what's done**, and **what's next**.

---

## 1. What this is

**HerTwin** is a women's wellness / menstrual-cycle tracking app (Flutter).
It started as a **FlutterFlow export** (pure UI, no backend) and has been
incrementally wired to **Firebase** (Auth + Firestore + Storage) with real
business logic added by hand.

- **Repo root:** `/Users/devkumarsingh/HerTwin-Wellness-App`
- **Git branch:** `flutterflow`
- **Remote:** `https://github.com/dev-singh12/HerTwin-Wellness-App` (`origin`)
- **Firebase project:** `hertwin-wellness` (default alias in `.firebaserc`)
- **Original design source:** screenshots at
  `~/Downloads/her_twin_wellness_screenshots/` (multiple device sizes; the
  `iPhone 6.7" Display - 1290x2796/` folder is the reference set). The UI is
  meant to match these by construction since the code is a FlutterFlow export
  of the same designs. `Profile` and `Insights` are net-new (not in the
  screenshots).

---

## 2. Tech stack & tooling

- **Flutter 3.44.1 / Dart 3.12.1**, installed at `~/development/flutter`
  (NOT on global PATH). **Always invoke by absolute path:**
  `~/development/flutter/bin/flutter`
- **Android toolchain installed** (`flutter doctor` Android section is green):
  OpenJDK 17 at `/opt/homebrew/opt/openjdk@17`, SDK at
  `~/Library/Android/sdk` (platform 36, build-tools 36.0.0), all licences
  accepted. Both paths are stored via `flutter config`, so `flutter build apk`
  needs no env vars. Full details + reproduction steps in
  `tool/ANDROID_SETUP.md`.
- **Routing:** `go_router` 12.1.3 via FlutterFlow's `createRouter` in
  `lib/flutter_flow/nav/nav.dart`.
- **Firebase:** `firebase_core ^4.10`, `firebase_auth ^6.5`,
  `cloud_firestore ^6.5`, `firebase_storage ^13.4`, `firebase_analytics ^12.4`.
- **Other key deps:** `image_picker ^1.2`, `fl_chart 1.0.0`, `google_fonts`,
  `cached_network_image`, `google_sign_in`, `provider`, `intl`, `url_launcher`,
  `youtube_player_iframe` (embedded video), `flutter_svg`, `lottie`.
  Note: Jitsi video is launched via `url_launcher` to meet.jit.si — there is
  **no** `jitsi_meet_flutter_sdk` dependency despite older notes saying so.
- **Firebase CLI:** v15.19.1 installed (via nvm node v22).
- **Local run targets:** Android (SDK installed, APK + AAB build clean),
  macOS desktop, Chrome/web. No emulator or physical device is attached, so
  **web remains the fastest review loop** — serve with `tool/serve_web.py`.

### Common commands
```bash
# Static analysis (run after every change)
~/development/flutter/bin/flutter analyze

# Build web (compilation smoke test; ~1–3 min)
~/development/flutter/bin/flutter build web --no-tree-shake-icons

# Run locally on Chrome
~/development/flutter/bin/flutter pub get
~/development/flutter/bin/flutter run -d chrome --web-port 5050
~/development/flutter/bin/flutter run -d chrome --web-port 5051   # 2nd instance for cross-user tests

# Deploy Firestore rules + indexes (manual step; do NOT auto-run)
firebase deploy --only firestore:rules,firestore:indexes
```

### Known-harmless analyzer output
- 2 pre-existing FlutterFlow warnings only:
  `lib/flutter_flow/nav/serialization_util.dart:78` and `:233`
  (`unreachable_switch_default`). Leave them. A clean run = "2 issues found".
- The `sqflite … Swift Package Manager` notice on every flutter command is
  noise; ignore it.

---

## 3. Architecture & conventions

### Directory layout
- `lib/pages/<page>/` — one folder per screen: `<page>_widget.dart` (UI +
  logic) and `<page>_model.dart` (FlutterFlow model: child component models,
  controllers, `initState`/`dispose`). 25 pages (see §4).
- `lib/components/<name>/` — 23 reusable FlutterFlow visual components
  (`*_widget.dart` + `*_model.dart`).
- `lib/flutter_flow/` — FlutterFlow framework (theme, util, nav, widgets).
  **Generally don't touch**, except `nav/nav.dart` to register routes.
- `lib/backend/backend.dart` — **the Firestore/Storage data-access layer**
  (collection refs, streams, CRUD helpers). All DB access goes through here.
- `lib/backend/schema/*_record.dart` — plain Dart record models
  (`fromMap`/`fromSnapshot`/`toMap`/`copyWith`). 18 records (see §5).
- `lib/backend/community_groups.dart` — static catalog of community "circles".
- `lib/backend/seed_data.dart` — **DELETED in V3.** Client-side doctor seeding
  was a privilege-escalation hole; provisioning is now `tool/admin.js`.
- `lib/business/video_library.dart` — 24 verified YouTube videos.
- `lib/business/legal_content.dart` — Privacy Policy / Terms draft text.
- `lib/components/app_image.dart` — asset-vs-network image helper.
- `lib/auth/role_manager.dart` — resolves clinician role from `doctors/{uid}`.
- `lib/business/cycle_engine.dart` — pure cycle-prediction logic.
- `lib/business/scoring_engine.dart` — onboarding assessment scoring (pure Dart).
- `lib/business/assessment_questions.dart` — condition-specific question sets.
- `lib/business/wellness_content_catalog.dart` — yoga, articles, mindfulness,
  guided meditation content (13 yoga flows, 4 meditations, 13 articles).
- `lib/auth/auth_manager.dart` — singleton `AuthManager.instance`
  (email + Google sign-in, sign-out, password reset).
- `lib/auth/error_mapper.dart` — Firebase auth error → user message.
- `lib/index.dart` — barrel that exports all 25 page widgets.

### FlutterFlow patterns (important)
- Each stateful page does:
  `_model = createModel(context, () => XModel());` in `initState`,
  `_model.dispose()` in `dispose`. Use `safeSetState(() {...})` not
  `setState`. Child components are attached via
  `wrapWithModel(model: _model.xModel, updateCallback: ..., child: XWidget(...))`.
- **InkWell-wrap rule (critical):** FlutterFlow visual components take state
  via constructor params (`selected`/`active`/`done`/`liked` bool) and usually
  expose **no tap callback**. To make one tappable, wrap it externally:
  ```dart
  InkWell(onTap: ..., child: wrapWithModel(... child: XWidget(...)))
  ```
  **Every InkWell wrap you add needs exactly ONE matching extra `)` at the
  wrapped widget's close.** Mis-counting parens is the #1 source of breakage
  here — count carefully, then `flutter analyze` the single file.
- Navigation: `context.pushNamed(XWidget.routeName)`,
  `context.goNamed(...)`, `context.safePop()`.
- Theme colors via `FlutterFlowTheme.of(context).<token>`:
  `primary 0xFFEFA6B3`, `secondary 0xFF9FA8DA`, `primaryText 0xFF3D3D3D`,
  `secondaryText 0xFF8E8E8E`, `primaryBackground 0xFFFDFBFB`,
  `secondaryBackground 0xFFFFFFFF`, `alternate 0xFFF0F0F0`,
  `success 0xFFA5D6A7`, `warning 0xFFF9CF58`, `error 0xFFF48FB1`,
  `onPrimary 0xFFFFFFFF`, `onSurface 0xFF4A4A4A`, plus `primary10`,
  `secondary10`, `onPrimary20`, `onSurface90`.
- **No bottom navigation bar** (matches the design). Screens are reached via
  in-page entry points (see §6 nav map).
- `Color.value` is deprecated — use `.toARGB32()` when persisting a color int.

---

## 4. Pages (25) & routes

All registered in `lib/flutter_flow/nav/nav.dart` as `FFRoute(name, path, builder)`:

| Page | routeName | Notes |
|---|---|---|
| `auth_screen` | `AuthScreen` | Email + Google sign-in; entry when logged out |
| `onboarding_step_form` | `OnboardingStepForm` | Dynamic condition-specific questions + prescription upload |
| `onboarding_result` | `OnboardingResult` | Post-onboarding score summary + doctor CTA |
| `home_dashboard` | `HomeDashboard` | Cycle status, live Firestore rituals, week strip, entry hub |
| `track_tab` | `TrackTab` | Cycle calendar / period logging + habit todos |
| `log_symptoms_modal` | `LogSymptomsModal` | Writes mood/symptom/cycle records + phase display |
| `wellness_tab` | `WellnessTab` | Dynamic category filtering (Yoga/Mind/Guides/Meditation) |
| `community_feed` | `CommunityFeed` | Real cross-user feed with category filters |
| `consultation_chat` | `ConsultationChat` | Firestore real-time chat + Jitsi Meet video (₹300/₹500) |
| `profile` | `Profile` | Photo upload, name edit, condition card, retake assessment, rate app |
| `insights` | `Insights` | fl_chart analytics (symptom trend, habit completion, vitality score) |
| `doctor_selection` | `DoctorSelection` | Specialist picker + booking (chat/video tiers) |
| `appointment_confirmation` | `AppointmentConfirmation` | Booking success screen |
| `reminder_management` | `ReminderManagement` | Full CRUD + today's view + per-time checkboxes |
| `yoga_detail` | `YogaDetail` | Timer + poses, condition-aware (incl. 30-min Cycle Regularity routine) |
| `article_detail` | `ArticleDetail` | Full article text |
| `breathwork_guide` | `BreathworkGuide` | 4-7-8 breathing animation |
| `mood_journal` | `MoodJournal` | Mood tab (Firestore) + Blogs tab (10 links, Material Icons) |
| `meditation_guide` | `MeditationGuide` | Dark-themed guided meditation timer + pulsing animation |
| `video_library` | `VideoLibrary` | 24 verified YouTube videos, condition-ordered |
| `video_player` | `VideoPlayer` | Embedded iframe player + attribution + watch-on-YouTube |
| `legal_document` | `LegalDocument` | Privacy / Terms, reachable signed-out (`/legal`) |
| `doctor_dashboard` | `DoctorDashboard` | **Clinician** `/clinician/dashboard` — patient-first (Patients/Schedule segments), health snapshots, appointment buckets |
| `doctor_patient_detail` | `DoctorPatientDetail` | **Clinician** `/clinician/patient` — consent-gated chart + Message action |
| `doctor_chat` | `DoctorChat` | **Clinician** `/clinician/chat` — doctor side of the consultation thread |

---

## 5. Data model (Firestore + Storage)

### Per-user (private) — `users/{uid}` and subcollections
`UsersRecord` at `users/{uid}`:
- Core: uid, email, displayName, photoUrl, age, conditions[], symptoms[],
  onboardingComplete, prescriptionUrl, createdAt, updatedAt
- V2 additions: conditionType, latestAssessmentScore, latestSeverityLabel,
  carePlanType, hasUsedFreeConsultation, primaryDoctorId, primaryDoctorName,
  doctorNotes, activeHabitIds[], healthVitalityScore, lastLogDate

Subcollections (18 record classes in `lib/backend/schema/`):
- Original: `cycles` (+flowIntensity, mood, isPeriodDay, phase), `moods`,
  `symptoms`, `sleep`, `water`, `exercises`, `journals`, `goals`
- V2: `assessments` (OnboardingAssessmentRecord), `reminders`
  (MedicineReminderRecord), `reminder_logs` (ReminderLogRecord),
  `habits` (HealthHabitRecord), `habit_logs` (HabitLogRecord),
  `feedback`, `score_logs`
- **V3: `consents/{doctorUid}`** — the patient's explicit, revocable grant
  letting one clinician read their health data. Firestore rules key doctor
  access off `exists()` of this doc, so deleting it revokes immediately.

> **V3 breaking change:** appointments are NO LONGER under `users/{uid}`.
> They moved to top-level `appointments/{id}` with `patientUid` + `doctorUid`,
> and messages to `appointments/{id}/messages/{id}`. A doctor cannot read a
> booking made against them if it is buried in the patient's private tree.
> Legacy data was migrated with `node tool/admin.js migrate-appointments`.

Access via helpers in `backend.dart`: `streamX`, `createX`, `updateX`,
`deleteX`, `newXId(uid)`.

### Top-level collections
- `doctors/{id}` → `DoctorRecord` (admin-seeded, 6 sample doctors).
- `posts/{id}` → `PostsRecord` (cross-user community).
- `posts/{id}/likes/{uid}`, `posts/{id}/comments/{id}`.
- `groups/{groupId}/members/{uid}`.
- `meta/seeded_doctors` → seeding guard flag.

### Business logic files
- `lib/business/cycle_engine.dart` — cycle phase computation.
- `lib/business/scoring_engine.dart` — PCOS 0-5=PCOD/6-10=Mixed/11-16=PCOS;
  PMS 0-10=Normal/11-18=PMS/19-25=Severe/≥26=PMDD; pure Dart, no side effects.
- `lib/business/assessment_questions.dart` — PCOS/PCOD (8+1 qs), PMS/PMDD
  (12 qs), Irregular (5 qs), Unknown (8 qs). Max 7 per screen, mixing for combos.
- `lib/business/wellness_content_catalog.dart` — 13 yoga flows (incl. 30-min
  Cycle Regularity for irregular periods), 4 guided meditations, 13 articles.
- Doctor seeding: `node tool/admin.js seed-doctors` (server-side only).

### Community (cross-user, top-level)
- `posts/{id}` → `PostsRecord` (authorUid, authorName, authorInitials,
  authorPhotoUrl, avatarBgValue:int, category, content, likeCount,
  commentCount, createdAt). Counters denormalized, kept in sync via transactions.
- `posts/{id}/likes/{uid}`, `posts/{id}/comments/{id}` → `CommentsRecord`.
- `groups/{groupId}/members/{uid}`. Group metadata = fixed in-app catalog.

Community helpers in `backend.dart`: `streamPosts(category)`, `createPost`,
`deletePost`, `togglePostLike` (atomic), `streamPostLiked`, `streamComments`,
`addComment` (atomic), `streamLikedPostIds`, `toggleGroupMembership`,
`streamGroupJoined`, `streamGroupMemberCount`.

### Consultation (real-time)
- Messages at `users/{uid}/appointments/{appointmentId}/messages/{messageId}`
- Jitsi Meet video: `https://meet.jit.si/hertwin-{appointmentId}` (free, no API key)
- Tiers: ₹300 chat-only, ₹500 video+chat. Phone call removed.

### Firebase Storage
`uploadProfilePhoto(uid, bytes)` → `users/{uid}/profile.jpg`
`uploadPrescription(uid, bytes)` → `users/{uid}/prescriptions/{ts}.jpg`
Bytes-based (web + mobile safe). **Requires Blaze plan + Storage initialized in console.**

### Security rules & indexes
- `firestore.rules` — users own `users/{uid}` tree; community read for all
  signed-in; non-authors may update ONLY `likeCount`/`commentCount`; doctors
  readable by all; meta readable by all.
- `firestore.indexes.json` — collection-group index on `likes.uid`;
  composite index on `posts` (category + createdAt DESC). Both deployed.

---

## 6. Navigation map (how screens connect)

- Logged out → `AuthScreen`. GoRouter redirect sends authenticated +
  onboarded users to `HomeDashboard`; authenticated + not-onboarded → `OnboardingStepForm`.
- New user: dashboard `initState` checks `getUser(uid)` first; if null/not
  onboarded, redirects immediately before starting Firestore streams (prevents
  permission-denied crash).
- `HomeDashboard` (hub): avatar → `Profile`; week strip → `TrackTab`;
  "Cycle Yoga" → `YogaDetail`; "Journal" → `MoodJournal`;
  "Edit" ritual → `ReminderManagement`; consultation banner → `ConsultationChat`.
- `WellnessTab`: category chips filter dynamically (All/Yoga/Mind/Guides/Meditation);
  yoga card → `YogaDetail`; "Mood Journal" → `MoodJournal`;
  "Breathwork" → `BreathworkGuide`; articles → `ArticleDetail`;
  meditation cards → `MeditationGuide`.
- `OnboardingResult` → `DoctorSelection` (Book Consultation).
- `DoctorSelection` → `AppointmentConfirmation` → `ConsultationChat`.
- `MoodJournal`: "Blogs" tab opens external URLs via url_launcher.
- `Profile`: notifications → `ReminderManagement`; retake → `OnboardingStepForm`.
- `TrackTab`: tune icon & "See All" → `Insights`.
- No tab bar; everything is push-based.

---

## 7. Business logic

### CycleEngine
`lib/business/cycle_engine.dart`: `CycleEngine.compute(List<CyclesRecord>)`
→ `CycleStatus` (current `CyclePhase`, cycleLength, periodLength, day-in-cycle,
predicted next period). `CyclePhase` enum has `.label`, `.energyLevel`,
`.vitalityMessage`. Dashboard, TrackTab, Insights derive from this.

### ScoringEngine
`lib/business/scoring_engine.dart`:
- PCOS/PCOD: 0-5 = PCOD, 6-10 = Mixed PCOS, 11-16 = PCOS
- PMS/PMDD: 0-10 = Normal, 11-18 = PMS, 19-25 = Severe PMS, ≥26 = PMDD
- Outputs: conditionType, severityLabel, healthVitalityScore (0-100), carePlanType, focusAreas[]

### Onboarding logic
- Conditions: PCOS, PCOD, PMS, PMDD, Irregular Periods, Don't Know (max 2 selected)
- Exclusion rules: PCOS ↔ PCOD mutual exclusive, PMS ↔ PMDD mutual exclusive
- Don't Know + Irregular = allowed; Don't Know alone = use Unknown question set
- 7 questions per screen max; combos use proportional mixing
- Skip button removed — assessment is mandatory

---

## 8. History — what's been done

1. Firebase setup, schema + data layer, auth wiring.
2. Screen wiring: HomeDashboard, TrackTab, LogSymptomsModal, Wellness, Community, Consultation, Profile, Insights.
3. UX fixes pass: dead buttons, TrackTab reachability, ritual toggle, prescription upload.
4. Real cross-user Community: top-level posts/likes/comments/groups, atomic counters, compose sheet, comments sheet, Feed/Groups/Saved tabs.
5. V2 Enhancement: 7 new record classes, ScoringEngine, assessment questions, doctor seeding, DoctorSelection, AppointmentConfirmation, 7 new pages, MoodJournal with Blogs tab, Firestore rules + indexes.
6. **Phase 5:** TrackTab full calendar rewrite + health habit todos.
7. **Phase 6:** Full medicine reminder system — dashboard "Today's Rituals" live from Firestore, per-time completion via ReminderLogRecord, ReminderManagement full CRUD.
8. **Phase 7:** Wellness deep content + MeditationGuide page (dark-themed, step-by-step timer, pulsing animation). WellnessTab category chips now actually filter.
9. **Phase 8:** Community category filter chips + composite Firestore index.
10. **Phase 9:** Insights enhancements — symptom severity trend, habit completion %, vitality score trend (fl_chart).
11. **Phase 10:** Profile enhancements — condition card, retake assessment, rate app dialog.
12. **Phase 11:** LogSymptomsModal — phase display, auto-score update on log.
13. **Phase 12:** Android config — app ID `com.hertwin.wellness`, release signing, proguard, minify.
14. **Onboarding rewrite:** Dynamic condition-specific questions, PMDD + Don't Know options, condition exclusion rules, mandatory assessment (no Skip), max 7 questions/set with proportional mixing for combos.
15. **Consultation rewrite:** Firestore real-time messages + Jitsi Meet video (free). ₹300 chat / ₹500 video tiers. Phone call removed.
16. **Dashboard fixes:** Loading spinner (prevents permission-denied flash), score from `healthVitalityScore` (ScoringEngine output, not CycleEngine). Onboarding redirect before Firestore streams.
17. **Blog improvements:** Replaced emojis with Material Icons in MoodJournal Blogs tab.
18. **Yoga content:** Added 30-min "Cycle Regularity" routine (5 poses × 5 min) for irregular periods.

---

## 9. Current state (PRESENT)

- Branch `flutterflow`. V3 work committed on `v3-clinician-security-playstore`.
- Local uncommitted: Phases 5-12 + all additional improvements listed above.
- `flutter analyze` = 2 issues (pre-existing FlutterFlow warnings only — baseline).
- `flutter build web --no-tree-shake-icons` = successful.
- Firestore rules + composite indexes = deployed.
- Firebase Storage = NOT yet initialized (user needs Blaze plan; UPI billing issue — try debit/credit card instead).
- `.claude/` and `.gitignore` cover local-only files.

### Pages (25 total)

| Page | Status |
|---|---|
| `auth_screen` | Original FF + email/Google auth ✓ |
| `onboarding_step_form` | Dynamic questions, condition exclusion, mandatory, PMDD option ✓ |
| `onboarding_result` | ScoringEngine output + doctor CTA ✓ |
| `home_dashboard` | Live Firestore rituals, loading state, healthVitalityScore ✓ |
| `track_tab` | Full calendar + habit todos ✓ |
| `log_symptoms_modal` | Phase display + auto-score update ✓ |
| `wellness_tab` | Dynamic category filtering ✓ |
| `community_feed` | Real cross-user + category filters ✓ |
| `consultation_chat` | Firestore real-time chat + Jitsi video ✓ |
| `profile` | Photo, condition card, retake, rate app ✓ |
| `insights` | Symptom trend + habit completion + vitality score ✓ |
| `doctor_selection` | ₹300 chat / ₹500 video tiers ✓ |
| `appointment_confirmation` | Booking success ✓ |
| `reminder_management` | Full CRUD + today's view + per-time checkboxes ✓ |
| `yoga_detail` | Timer + poses, 30-min routine for irregular ✓ |
| `article_detail` | Full article text ✓ |
| `breathwork_guide` | 4-7-8 animation ✓ |
| `mood_journal` | Mood tab + Blogs tab (Material Icons) ✓ |
| `meditation_guide` | Dark-themed, step timer, pulsing animation ✓ |

---

---

## 9b. V3 — Doctor dashboard, security hardening, real content

### Clinician surface (role-gated, same app)
- **Role = existence of `doctors/{uid}`** keyed by auth uid. Client cannot
  create it (`allow create: if false`), so nobody can self-promote.
  `lib/auth/role_manager.dart` observes it; `main.dart` resolves the role
  BEFORE refreshing the router so a clinician never flashes the patient UI.
- Routes live under **`/clinician/`** — deliberately NOT `/doctor` because
  `/doctor-selection` is a *patient* screen.
- New pages: `doctor_dashboard` (live queue, stats, filters),
  `doctor_patient_detail` (consent-gated chart: assessment, cycle, symptoms,
  habit adherence + notes/prescription + lifecycle actions).
- `AppBootGate` in `nav.dart` holds `/` while the role resolves.

### Provisioning (server-side only)
`lib/backend/seed_data.dart` was **deleted** — client-side doctor seeding is
exactly the privilege-escalation hole the rules now close. Use:
```bash
node tool/admin.js seed-doctors        # bookable catalog profiles
node tool/admin.js promote <email>     # make a real signed-up user a clinician
node tool/admin.js demote <email>
node tool/admin.js migrate-appointments
```
Auth reuses the Firebase CLI's own OAuth refresh token; no service-account key
in the repo. Catalog ids (`doctor_0`…) are not auth uids, so they grant nobody
anything — `exists(doctors/$(request.auth.uid))` can never match them.

### Security fixes (all verified — see below)
1. **Prescriptions were world-readable** to any signed-in user
   (`storage.rules`). Now owner-only. Latent, not live: Storage was never
   initialised, so nothing leaked.
2. **Consultation messages were unreachable** — the rule matched two levels
   (`users/{uid}/{col}/{doc}`) but messages sit four deep, so chat would have
   been permission-denied in production. Recursive `{document=**}` now.
3. **Any signed-in user could create/overwrite/delete `doctors/{id}`** —
   i.e. grant themselves clinician privilege. Client writes forbidden.
4. **`meta/{doc}` was world-writable.** Now read-only.
5. **Post counters had no delta check** — `likeCount` could be set to any
   value. Now ±1 only.
6. Identity fields pinned to `request.auth.uid`; `role`/`isDoctor` immutable;
   every free-text field length-capped; messages immutable; appointments
   undeletable from a client.
7. **Video rooms**: `meet.jit.si` rooms are public to anyone with the URL, so
   the room name now carries 160 bits of CSPRNG entropy stored on the
   appointment (readable only by the two participants).
8. **Android manifest**: `allowBackup` was defaulting to true (health data
   extractable via `adb backup`) → now false; removed
   `requestLegacyExternalStorage`; `usesCleartextTraffic="false"`.

### Verification
```bash
node tool/test_rules.js      # 19 rules assertions vs Google's Rules API
~/development/flutter/bin/flutter test        # 17 business-logic tests
```
The same suite run against the pre-V3 rules **fails 7 of 19** — the
vulnerabilities above were real, not theoretical.

### Real content
- `lib/business/video_library.dart` — 24 curated YouTube videos, every id
  verified public + `playableInEmbed` via oEmbed before shipping. Played
  in-app via `youtube_player_iframe`, always with channel attribution and a
  "watch on YouTube" link. **Never add an id without verifying it.**
- New pages: `video_library`, `video_player`.
- All `dimg.dreamflow.cloud` placeholders are now **bundled assets**
  (`assets/images/`, `assets/jsons/`) behind `lib/components/app_image.dart`,
  which picks asset-vs-network by path prefix. Removes a third-party runtime
  dependency with no SLA.
- Fixed: chat consultation charged ₹200 while the UI advertised ₹300.
- `ScoringEngine._boundMax` guards against a "24/16" style ratio if a question
  set ever outgrows its hard-coded maximum.

### Play Store readiness (V3.1)
See `PLAY_STORE.md` for the full checklist, Data Safety answers and store copy.

- **App icon** was the default Flutter logo (an automatic Play rejection).
  Replaced with a generated brand mark in `assets/branding/`, wired through
  `flutter_launcher_icons` (all densities + Android adaptive + iOS + web).
  Regenerate with `dart run flutter_launcher_icons`.
- **Community moderation** — Play requires in-app reporting *and* blocking for
  user-generated content. Added: report sheet with five reasons writing to a
  top-level `reports` collection, and per-user blocking at
  `users/{uid}/blocked/{uid}` filtered client-side. `reports` is **write-only**
  from the client — a readable queue would let an abuser check whether they had
  been reported; a deletable one would let them erase the evidence.
- **Account deletion** — Play requires an in-app route. Profile → "Delete my
  account and data": type-to-confirm, wipes all 17 user subcollections in
  paged batches, anonymises community posts rather than deleting them (so
  other people's threads survive), then deletes the auth user. Handles
  `requires-recent-login` by signing out with an explanatory message.
  Appointments are deliberately retained (clinical record), but the consent
  docs go, which cuts off clinician access immediately.
- **Signing** — `tool/create-keystore.sh` is interactive by design: `keytool`
  prompts for the password directly and it is never passed as an argument or
  echoed. Run it yourself; it also verifies `key.properties` is gitignored.

### Web deployment (live)
Deployed to Firebase Hosting on the **Spark (free)** plan — billing is not
enabled on this project, so it cannot incur charges.

| URL | Google sign-in |
|---|---|
| **https://hertwin-wellness.firebaseapp.com** | ✅ works |
| https://hertwin-wellness.web.app | ❌ `Error 400: redirect_uri_mismatch` |

Same site on both domains. Only `firebaseapp.com` works with Google because
there the page origin *is* the `authDomain`, so auth cookies are first-party
and the OAuth client already lists that redirect URI. To enable `.web.app`,
add `https://hertwin-wellness.web.app/__/auth/handler` to the OAuth 2.0 Web
client's authorised redirect URIs in Google Cloud Console (no API for this).

Redeploy: `flutter build web --release --no-tree-shake-icons && firebase deploy --only hosting`
Take offline: `firebase hosting:disable --project hertwin-wellness`

`firebase.json` sets SPA rewrites, immutable caching for hashed JS/wasm,
`no-cache` on index.html, and security headers (HSTS, nosniff, SAMEORIGIN,
Referrer-Policy, Permissions-Policy denying geolocation/mic/camera/payment).

### Google sign-in on web — the third-party cookie problem
`authDomain` is `hertwin-wellness.firebaseapp.com`. Whenever the app is served
from a *different* origin (localhost, `.web.app`), Firebase's sign-in cookies
are third-party cookies, which Chrome blocks. The popup then closes itself and
Firebase reports **`popup-closed-by-user`** — the browser's doing, surfaced as
the user's. Do not "fix" this by showing a cancellation message.

Three mitigations, all in place:
1. `AuthManager` falls back from popup → `signInWithRedirect` on
   `popup-blocked` / `operation-not-supported-in-this-environment` /
   `web-storage-unsupported` / a 90 s timeout. `main.dart` calls
   `completePendingRedirect()` before the first frame to finish the round trip.
   A genuine dismissal (>3 s) still reports "cancelled"; a sub-3-second close
   is treated as the browser and falls back instead.
2. `_firebaseOptions()` in `main.dart` pins `authDomain` to the current origin
   when served over **https** from an origin that serves `/__/auth/*`
   (Hosting domains, or localhost running `tool/serve_web.py`). Gated on https
   deliberately: the auth handler forces a secure context, so doing this over
   plain http sends the browser to `https://localhost:<port>` and yields a
   blank page — worse than the bug.
3. `tool/serve_web.py` reverse-proxies `/__/auth/*` and `/__/firebase/*` for
   local dev, plus SPA fallback and no-store caching.

Local review: `python3 tool/serve_web.py 5051`. Over plain http, prefer
**email sign-in** — it needs no popup at all.

### Test accounts
| Account | Method | Role |
|---|---|---|
| `ultimatewarriordev@gmail.com` | password | **clinician** (Dr. Dev) |
| `dev.singh@adypu.edu.in` | password | patient |
| `anirudhbsb@gmail.com` | password | patient |
| `auditorsingh48@gmail.com` | Google only | patient |
| `watsonmateo14@gmail.com` | Google only | patient |

A clinician account has **no patient surface** — the router sends it straight
to the doctor dashboard. Use two accounts to exercise the booking loop.

### CI
`.github/workflows/build-apk.yml` builds APK + AAB on GitHub's runners, so no
local Android SDK is needed. Signing uses repo secrets
(`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`) and
falls back to debug signing when absent.

---

## 10. Future / not yet done (FUTURE)

- **Terms of Service and Privacy Policy are stubs** ("will be available
  soon", `auth_screen_widget.dart`). Google Play **requires** a working
  privacy-policy URL for an app handling health data. Launch blocker.
- **Play Store signing** — the release build currently falls back to the DEBUG
  key because `android/key.properties` does not exist. That APK installs fine
  for demos but Play will reject it. Run `bash tool/create-keystore.sh`
  (interactive; keytool prompts for the password directly, it is never passed
  as an argument). See `tool/ANDROID_SETUP.md`.
- **Community moderation queue has no reader.** Reports land in `reports/`
  but nothing surfaces them — build an admin view or a scheduled export.
- **Account deletion leaves the auth user** if the session is stale
  (`requires-recent-login`); the data is deleted and the user is signed out
  with an explanation, but the auth record needs a second sign-in to clear.
- **`.web.app` Google sign-in** needs a redirect URI added in Cloud Console.
- **Firebase Storage still not initialised** → profile photo and prescription
  upload will fail until enabled in the console (needs Blaze).
  `storage.rules` is written and ready but undeployed for the same reason.

- **Firebase Storage initialization** — user must enable in Firebase Console (Blaze plan required).
- **Community niceties:** image attachments, report/block, pagination, push notifications.
- **Real doctor backend** — consultation auto-reply is intentionally local/phase-aware. Don't build real doctor side without explicit ask.
- **No automated tests** — verification = `analyze` + `build web` + manual Chrome testing.
- **Noto fonts warning on web** — cosmetic only; can suppress by adding `NotoColorEmoji` to assets.
- **Apple Sign-In** — stub only (needs Apple Developer account).
- **Razorpay integration** — consultation payment is UI-only (no real payment gateway yet).

---

## 11. Working agreement / gotchas

- Use the **absolute flutter path** every time: `~/development/flutter/bin/flutter`
- After editing a file, run `flutter analyze <path>` on that file before moving on.
- Respect the **InkWell-wrap paren rule** (§3) — mis-counting parens = #1 breakage source.
- Only **commit when asked**. Co-author line:
  `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
- Don't run `firebase deploy` automatically — give the user the command.
- When adding a new top-level collection: update `firestore.rules` + `firestore.indexes.json`.
- When adding a new page: create `_widget.dart` + `_model.dart`, register in `nav.dart`,
  export from `lib/index.dart`, add an in-app entry point.
- `safeSetState` not `setState`. `Color.toARGB32()` not `.value`.
