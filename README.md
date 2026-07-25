# HerTwin Wellness

**Your body, understood.** A women's wellness and menstrual-cycle companion —
cycle tracking, condition-aware assessments (PCOS/PCOD/PMS/PMDD/irregular),
personalized wellness content, and real doctor consultations.

🌐 **Live:** https://hertwin-wellness.firebaseapp.com

Built with Flutter (from a FlutterFlow export) and wired to Firebase
(Auth · Firestore · Analytics). Runs on Android, iOS, and web.

---

## Features

- **Onboarding assessment** — condition-specific question sets with a pure-Dart
  scoring engine that produces a health-vitality score and care plan.
- **Cycle tracker** — full calendar, phase prediction, symptom & mood logging,
  and habit to-dos.
- **Consultations** — book a free or paid consult with a real clinician, chat
  in real time, join a video call (Jitsi), and get a prescription back that
  surfaces live on your dashboard.
- **Clinician surface** — a role-gated doctor dashboard (queue, consent-gated
  patient charts, notes & prescriptions). Doctor access is approved
  server-side; the client can never self-grant it.
- **Wellness** — guided yoga flows with real follow-along videos, meditation,
  breathwork, articles, and a curated video library.
- **Community** — cross-user feed, interest groups, in-app reporting/blocking.

## Tech stack

- **Flutter 3.44 / Dart 3.12**, `go_router`, `provider`, `fl_chart`,
  `google_fonts`, `youtube_player_iframe`, `image_picker`, `url_launcher`.
- **Firebase** — `firebase_auth`, `cloud_firestore`, `firebase_analytics`,
  Hosting (Spark/free plan). Cloud Storage is intentionally not used; images
  are stored as compressed data URIs in Firestore to stay on the free tier.

## Getting started

```bash
flutter pub get
flutter run -d chrome --web-port 5050        # web (fastest review loop)
flutter analyze                              # static analysis
flutter build web --no-tree-shake-icons      # web build
flutter build apk --release --no-tree-shake-icons   # Android APK
```

Firebase config is generated (`lib/firebase_options.dart`); no secrets live in
the repo. Provision/approve clinicians server-side with `node tool/admin.js`.

Deploy web: `flutter build web --no-tree-shake-icons && firebase deploy --only hosting`

## Project layout

- `lib/pages/<page>/` — one folder per screen (`*_widget.dart` + `*_model.dart`)
- `lib/components/` — reusable FlutterFlow visual components
- `lib/backend/` — Firestore/Storage data layer + record schemas
- `lib/business/` — pure logic (cycle engine, scoring, content catalogs)
- `lib/auth/` — auth + role resolution

See [`context.md`](context.md) for the full architecture, conventions, and
project history.

---

_Private project. Not affiliated with any medical provider; the app does not
provide medical diagnoses._
