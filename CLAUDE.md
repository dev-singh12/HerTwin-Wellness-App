# HerTwin Wellness App — Project Context

> Context file for Claude. Read this first before working on the codebase.
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
- **Routing:** `go_router` 12.1.3 via FlutterFlow's `createRouter` in
  `lib/flutter_flow/nav/nav.dart`.
- **Firebase:** `firebase_core ^4.10`, `firebase_auth ^6.5`,
  `cloud_firestore ^6.5`, `firebase_storage ^13.4`, `firebase_analytics ^12.4`.
- **Other key deps:** `image_picker ^1.2`, `fl_chart 1.0.0`, `google_fonts`,
  `cached_network_image`, `google_sign_in`, `provider`, `intl`.
- **Firebase CLI:** v15.19.1 installed (via nvm node v22).
- **Local run targets available:** `macOS (desktop)` and `Chrome (web)`. No
  iOS/Android device/emulator currently attached. **Web (Chrome) is the
  primary local test target.**

### Common commands
```bash
# Static analysis (run after every change)
~/development/flutter/bin/flutter analyze

# Build web (compilation smoke test; ~1–3 min)
~/development/flutter/bin/flutter build web --no-tree-shake-icons

# Run locally on Chrome
~/development/flutter/bin/flutter pub get
~/development/flutter/bin/flutter run -d chrome           # r=reload R=restart q=quit
~/development/flutter/bin/flutter run -d chrome --web-port 5000   # 2nd instance for cross-user tests

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
  controllers, `initState`/`dispose`). 11 pages (see §4).
- `lib/components/<name>/` — 23 reusable FlutterFlow visual components
  (`*_widget.dart` + `*_model.dart`).
- `lib/flutter_flow/` — FlutterFlow framework (theme, util, nav, widgets).
  **Generally don't touch**, except `nav/nav.dart` to register routes.
- `lib/backend/backend.dart` — **the Firestore/Storage data-access layer**
  (collection refs, streams, CRUD helpers). All DB access goes through here.
- `lib/backend/schema/*_record.dart` — plain Dart record models
  (`fromMap`/`fromSnapshot`/`toMap`/`copyWith`). 11 records (see §5).
- `lib/backend/community_groups.dart` — static catalog of community "circles".
- `lib/business/cycle_engine.dart` — pure cycle-prediction logic.
- `lib/auth/auth_manager.dart` — singleton `AuthManager.instance`
  (email + Google sign-in, sign-out, password reset).
- `lib/auth/error_mapper.dart` — Firebase auth error → user message.
- `lib/index.dart` — barrel that exports all 11 page widgets. Pages import
  `/index.dart` to reference other pages' `routeName`s.

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

## 4. Pages (11) & routes

All registered in `lib/flutter_flow/nav/nav.dart` as `FFRoute(name, path, builder)`:

| Page | routeName | Notes |
|---|---|---|
| `auth_screen` | `AuthScreen` | email + Google sign-in; entry when logged out |
| `onboarding_step_form` | `OnboardingStepForm` | age/conditions/symptoms + **prescription upload** |
| `onboarding_result` | `OnboardingResult` | post-onboarding summary |
| `home_dashboard` | `HomeDashboard` | cycle status, rituals, week strip, entry hub |
| `track_tab` | `TrackTab` | cycle calendar / period logging |
| `log_symptoms_modal` | `LogSymptomsModal` | writes mood/symptom/cycle records |
| `wellness_tab` | `WellnessTab` | practice categories + content cards |
| `community_feed` | `CommunityFeed` | **real cross-user feed** (see §5) |
| `consultation_chat` | `ConsultationChat` | doctor chat (LOCAL auto-reply only) |
| `profile` | `Profile` | photo upload, name edit, sign-out, stats (net-new) |
| `insights` | `Insights` | fl_chart analytics (net-new) |

---

## 5. Data model (Firestore + Storage)

### Per-user (private) — `users/{uid}` and subcollections
`UsersRecord` at `users/{uid}` (uid, email, displayName, photoUrl, age,
conditions[], symptoms[], onboardingComplete, prescriptionUrl, timestamps,
**conditionType, latestAssessmentScore, latestSeverityLabel, carePlanType,
hasUsedFreeConsultation, primaryDoctorId, primaryDoctorName, doctorNotes,
activeHabitIds[], healthVitalityScore, lastLogDate**).

Subcollections (one record class each in `lib/backend/schema/`):
`cycles` (+ flowIntensity, mood, isPeriodDay, phase), `moods`, `symptoms`,
`sleep`, `water`, `exercises`, `journals`, `goals`,
**`assessments`** (OnboardingAssessmentRecord),
**`appointments`** (AppointmentRecord),
**`reminders`** (MedicineReminderRecord),
**`reminder_logs`** (ReminderLogRecord),
**`habits`** (HealthHabitRecord),
**`habit_logs`** (HabitLogRecord),
**`feedback`**, **`score_logs`**.

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
- `lib/business/scoring_engine.dart` — onboarding assessment scoring (pure Dart).
- `lib/business/assessment_questions.dart` — question data for all conditions.
- `lib/business/wellness_content_catalog.dart` — yoga, articles, mindfulness content.
- `lib/backend/seed_data.dart` — doctor seeding function.

### Community (cross-user, top-level) — added most recently
- `posts/{id}` → `PostsRecord` (authorUid, authorName, authorInitials,
  authorPhotoUrl, avatarBgValue:int, category, content, **likeCount**,
  **commentCount**, createdAt). Counters are **denormalized** and kept in sync
  via Firestore **transactions**.
- `posts/{id}/likes/{uid}` → `{ uid, createdAt }` (one doc per liker).
- `posts/{id}/comments/{id}` → `CommentsRecord`.
- `groups/{groupId}/members/{uid}` → `{ createdAt }`. **Group metadata is a
  fixed in-app catalog** in `community_groups.dart` (`kCommunityGroups`); only
  membership is persisted. Displayed count = `baseMembers + live member count`.

Community helpers in `backend.dart`: `streamPosts`, `createPost`, `deletePost`,
`togglePostLike` (atomic), `streamPostLiked`, `streamComments`, `addComment`
(atomic), `streamLikedPostIds` (collection-group → powers the "Saved" tab),
`toggleGroupMembership`, `streamGroupJoined`, `streamGroupMemberCount`.

### Firebase Storage
`lib/backend/backend.dart`: `uploadProfilePhoto(uid, bytes)` →
`users/{uid}/profile.jpg`; `uploadPrescription(uid, bytes)` →
`users/{uid}/prescriptions/{ts}.jpg`. Bytes-based (web + mobile safe).

### Security rules & indexes
- `firestore.rules` — users own their `users/{uid}` tree; community: anyone
  signed-in reads posts; authors create/edit/delete own posts & comments;
  non-authors may update ONLY `likeCount`/`commentCount`; a user manages only
  their own like/membership doc.
- `firestore.indexes.json` — collection-group index on `likes.uid` (required
  by the Saved tab). **Rules + index must be deployed** (see §2) or Community
  fails with `permission-denied` / a missing-index error.

---

## 6. Navigation map (how screens connect)

- Logged out → `AuthScreen`. GoRouter redirect (in `nav.dart`) sends
  authenticated-but-not-onboarded users to onboarding, else to `HomeDashboard`.
- `HomeDashboard` is the hub: avatar → `Profile`; week strip → `TrackTab`;
  "Cycle Yoga" → `YogaDetail`; "Journal" → `MoodJournal`; "Edit" ritual →
  `ReminderManagement`; consultation banner → `ConsultationChat`.
- `WellnessTab`: featured card → `YogaDetail`; "Mood Journal" → `MoodJournal`;
  "Breathwork" → `BreathworkGuide`; articles → `ArticleDetail`.
- `OnboardingResult` → `DoctorSelection` (Book Free Consultation).
- `DoctorSelection` → `AppointmentConfirmation` → `ConsultationChat`.
- `MoodJournal`: "Blogs" tab opens external URLs via url_launcher.
- `Profile`: notifications → `ReminderManagement`.
- `TrackTab`: tune icon & "See All" → `Insights`.
- There is no tab bar; everything is push-based.

---

## 7. Business logic — `CycleEngine`

`lib/business/cycle_engine.dart`: `CycleEngine.compute(List<CyclesRecord>)`
→ `CycleStatus` (current `CyclePhase`, cycleLength, periodLength, day-in-cycle,
predicted next period, etc.). `CyclePhase` enum has `.label`, `.energyLevel`,
`.vitalityMessage`. The dashboard, track tab, and insights derive their copy
and predictions from this. Keep cycle math here, not in widgets.

---

## 8. History — what's been done (PAST)

Delivered in phases (see git log on `flutterflow`):
1. **Firebase setup** — packages, `flutterfire configure`, gradle/Podfile,
   `main.dart` init, fixed pre-existing const compile errors.
2. **Schema + data layer** — 9 original record classes + `backend.dart` +
   `app_date_utils.dart`.
3. **Auth** — `auth_manager.dart`, `error_mapper.dart`, wired `AuthScreen`
   (email form + Google), GoRouter redirect.
4. **Screen wiring (4b–4g)** — HomeDashboard, Track tab (CycleEngine),
   Log Symptoms modal, Wellness/Community/Consultation, **Profile** (new,
   photo upload), **Insights** (new, fl_chart).
5. **`baf84b7` — UX fixes pass** (in the user's requested order):
   - *Dead/unwired buttons:* Auth ToS/Privacy snackbars; Track tune + "See All"
     → Insights.
   - *Blocking bug:* `TrackTab` was unreachable → dashboard week strip now
     navigates to it.
   - *Polish to match screenshots:* dashboard ritual toggle + Edit hint;
     Wellness 5 category chips with active-state, See All, content cards;
     Onboarding "Upload Prescription" → image picker + Storage upload.
6. **`ddc4e40` — Real cross-user Community** (user explicitly approved
   "build full version now"): top-level `posts`/`likes`/`comments` + `groups`
   membership; atomic counters; `StoryCard`/`InterestGroup` made interactive;
   feed rewritten with live `StreamBuilder`s; compose-story sheet, comments
   sheet, share-to-clipboard, author-only delete, Feed/Groups/Saved tabs;
   `firestore.rules` + `likes.uid` index.
7. **V2 Enhancement (local, uncommitted)** — Major feature expansion:
   - **Phase 1:** 7 new Firestore record classes (OnboardingAssessment, Doctor,
     Appointment, MedicineReminder, ReminderLog, HealthHabit, HabitLog) +
     updated CyclesRecord (+4 fields) + updated UsersRecord (+12 fields) +
     ~250 lines of new backend.dart helpers + habit seeding logic.
   - **Phase 2:** ScoringEngine (pure Dart, PCOS/PCOD/PMS/PMDD/irregular
     scoring with focus areas). Assessment questions data. Onboarding now saves
     assessment + condition + health score + auto-generates habits.
   - **Phase 3:** Dashboard seeds doctors on first load (guarded by meta doc).
     "Cycle Yoga" → YogaDetail, "Journal" → MoodJournal, "Edit" ritual →
     ReminderManagement.
   - **Phase 4:** DoctorSelection page (filter by specialty, booking bottom
     sheet with date/time/notes), AppointmentConfirmation page.
   - **Wellness Tab:** Yoga card → YogaDetail (timer + poses), "Mood Journal"
     card → MoodJournal, "Breathwork" card → BreathworkGuide, articles →
     ArticleDetail with full text.
   - **New Pages (7):** doctor_selection, appointment_confirmation,
     reminder_management, yoga_detail, article_detail, breathwork_guide,
     mood_journal. All registered in nav.dart + exported from index.dart.
   - **Business logic:** `scoring_engine.dart`, `assessment_questions.dart`,
     `wellness_content_catalog.dart` (yoga content, articles, mindfulness).
   - **Seed data:** `lib/backend/seed_data.dart` (6 sample doctors).
   - **MoodJournal:** Two tabs — "Mood Journal" (saves to Firestore, condition-
     specific daily prompts) + "Blogs" (10 real health article links that open
     in browser via url_launcher).
   - **All buttons functional:** Report upload (ImagePicker → Storage),
     prescription requests, Edit ritual, notification settings, articles.
   - **Firestore rules updated:** doctors (read any, write auth for dev), meta
     collection, appointments composite index deployed.
   - **Storage rules created:** `storage.rules` (user owns their path, 10MB
     image limit). Needs Firebase Storage to be initialized in console first.

---

## 9. Current state (PRESENT)

- Branch `flutterflow`; last committed HEAD = `ddc4e40`.
- **Local uncommitted changes** contain all of V2 Enhancement (Phase 7 above).
- `flutter analyze` = 2 issues (the 2 pre-existing FlutterFlow warnings only).
- `flutter build web --no-tree-shake-icons` compiles successfully.
- **Firestore rules + indexes deployed** (doctors, meta, appointments index).
- **Firebase Storage NOT yet initialized** on the project — user needs to go to
  Firebase Console → Storage → "Get Started" before uploads work.
- `.claude/` is untracked locally and should NOT be committed.

### Pages (18 total now)

| Page | routeName | Status |
|---|---|---|
| `auth_screen` | `AuthScreen` | Original FF ✓ |
| `onboarding_step_form` | `OnboardingStepForm` | Original FF UI + scoring logic ✓ |
| `onboarding_result` | `OnboardingResult` | Original FF UI ✓ |
| `home_dashboard` | `HomeDashboard` | Original FF UI + seed + navigation fixes ✓ |
| `track_tab` | `TrackTab` | Original FF ✓ |
| `log_symptoms_modal` | `LogSymptomsModal` | Original FF + report upload ✓ |
| `wellness_tab` | `WellnessTab` | FF + navigation to yoga/journal/breathwork ✓ |
| `community_feed` | `CommunityFeed` | Real cross-user feed ✓ |
| `consultation_chat` | `ConsultationChat` | Auto-reply + report upload ✓ |
| `profile` | `Profile` | Photo, name, sign-out + reminder link ✓ |
| `insights` | `Insights` | fl_chart analytics ✓ |
| `doctor_selection` | `DoctorSelection` | NEW — specialist picker + booking ✓ |
| `appointment_confirmation` | `AppointmentConfirmation` | NEW — booking success ✓ |
| `reminder_management` | `ReminderManagement` | NEW — add/edit/delete reminders ✓ |
| `yoga_detail` | `YogaDetail` | NEW — timer + poses, condition-aware ✓ |
| `article_detail` | `ArticleDetail` | NEW — full article text ✓ |
| `breathwork_guide` | `BreathworkGuide` | NEW — 4-7-8 breathing animation ✓ |
| `mood_journal` | `MoodJournal` | NEW — mood + blogs tabs ✓ |

---

## 10. Future / not yet done (FUTURE)

### Remaining Phases (user-approved roadmap):
- **Phase 5:** TrackTab full calendar rewrite + health habit todos
- **Phase 6:** Full medicine reminder system + local notifications (Android)
- **Phase 7:** Wellness tab deep content (more yoga flows, guided meditations)
- **Phase 8:** Community feed category filters + compose category picker
- **Phase 9:** Insights page enhancements (symptom trends, habit completion)
- **Phase 10:** Profile enhancements (condition card, retake assessment, rate app)
- **Phase 11:** Log symptoms modal enhancements (auto-score update, phase detect)
- **Phase 12:** Android/Play Store readiness (build.gradle, icons, proguard)

### Known pending items:
- **Firebase Storage initialization** — user must enable in Firebase Console
  before prescription/report upload works.
- **Consultation real doctor messaging** — INTENTIONALLY still a local,
  phase-aware **auto-reply**. Don't build without asking.
- **Community niceties:** image attachments, report/block, pagination, push notifs.
- **No automated tests** yet. Verification = `analyze` + `build web` + manual.
- **Noto fonts warning on web** — cosmetic only; emoji rendering uses system
  fonts. Can be suppressed by adding `NotoColorEmoji` to assets if desired.

---

## 11. Working agreement / gotchas

- Use the **absolute flutter path** every time.
- After editing a file, run `flutter analyze <path>` on just that file/dir
  before moving on; do a full `flutter analyze` + `flutter build web` before
  committing a feature.
- Respect the **InkWell-wrap paren rule** (§3).
- Only **commit when asked**. Commits here are co-authored:
  `Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>`.
- Don't run `firebase deploy` automatically — give the user the command.
- When adding a new top-level collection, also update `firestore.rules`
  (and `firestore.indexes.json` if you add a collection-group/composite query).
- When adding a new page: create `<page>_widget.dart` + `_model.dart`, register
  it in `nav.dart`, export it from `lib/index.dart`, and add an in-app entry
  point (there's no tab bar).
