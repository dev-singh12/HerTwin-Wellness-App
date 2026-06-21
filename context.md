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
- **Routing:** `go_router` 12.1.3 via FlutterFlow's `createRouter` in
  `lib/flutter_flow/nav/nav.dart`.
- **Firebase:** `firebase_core ^4.10`, `firebase_auth ^6.5`,
  `cloud_firestore ^6.5`, `firebase_storage ^13.4`, `firebase_analytics ^12.4`.
- **Other key deps:** `image_picker ^1.2`, `fl_chart 1.0.0`, `google_fonts`,
  `cached_network_image`, `google_sign_in`, `provider`, `intl`, `url_launcher`,
  `jitsi_meet_flutter_sdk` (video calls).
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
  controllers, `initState`/`dispose`). 19 pages (see §4).
- `lib/components/<name>/` — 23 reusable FlutterFlow visual components
  (`*_widget.dart` + `*_model.dart`).
- `lib/flutter_flow/` — FlutterFlow framework (theme, util, nav, widgets).
  **Generally don't touch**, except `nav/nav.dart` to register routes.
- `lib/backend/backend.dart` — **the Firestore/Storage data-access layer**
  (collection refs, streams, CRUD helpers). All DB access goes through here.
- `lib/backend/schema/*_record.dart` — plain Dart record models
  (`fromMap`/`fromSnapshot`/`toMap`/`copyWith`). 18 records (see §5).
- `lib/backend/community_groups.dart` — static catalog of community "circles".
- `lib/backend/seed_data.dart` — 6 sample doctors, auto-seeded on first dashboard load.
- `lib/business/cycle_engine.dart` — pure cycle-prediction logic.
- `lib/business/scoring_engine.dart` — onboarding assessment scoring (pure Dart).
- `lib/business/assessment_questions.dart` — condition-specific question sets.
- `lib/business/wellness_content_catalog.dart` — yoga, articles, mindfulness,
  guided meditation content (13 yoga flows, 4 meditations, 13 articles).
- `lib/auth/auth_manager.dart` — singleton `AuthManager.instance`
  (email + Google sign-in, sign-out, password reset).
- `lib/auth/error_mapper.dart` — Firebase auth error → user message.
- `lib/index.dart` — barrel that exports all 19 page widgets.

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

## 4. Pages (19) & routes

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
- V2: `assessments` (OnboardingAssessmentRecord), `appointments`
  (AppointmentRecord), `reminders` (MedicineReminderRecord),
  `reminder_logs` (ReminderLogRecord), `habits` (HealthHabitRecord),
  `habit_logs` (HabitLogRecord), `feedback`, `score_logs`
- Consultation: `appointments/{id}/messages/{id}` (Firestore real-time chat)

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
- `lib/backend/seed_data.dart` — doctor seeding function.

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

- Branch `flutterflow`; last committed HEAD = `c8ca1f1`.
- Local uncommitted: Phases 5-12 + all additional improvements listed above.
- `flutter analyze` = 2 issues (pre-existing FlutterFlow warnings only — baseline).
- `flutter build web --no-tree-shake-icons` = successful.
- Firestore rules + composite indexes = deployed.
- Firebase Storage = NOT yet initialized (user needs Blaze plan; UPI billing issue — try debit/credit card instead).
- `.claude/` and `.gitignore` cover local-only files.

### Pages (19 total)

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

## 10. Future / not yet done (FUTURE)

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
