/// Privacy Policy and Terms of Service text.
///
/// ─────────────────────────────────────────────────────────────────────────
/// THIS IS A STARTING DRAFT, NOT LEGAL ADVICE.
///
/// It was written to describe accurately what this codebase actually does —
/// every collection listed below maps to a real Firestore path, and every
/// sharing claim maps to a real rule in firestore.rules. That makes it a
/// truthful starting point, which is more than most templates give you.
///
/// It is NOT a substitute for a lawyer. Before you publish, you need review
/// by someone qualified in the jurisdictions you operate in, because this app
/// handles health data and that attracts specific regimes:
///   * India  — DPDP Act 2023 (this app's primary market)
///   * EU/UK  — GDPR Art. 9 "special category" data
///   * US     — state privacy laws; HIPAA if you ever bill through a covered
///              entity or contract with providers as a business associate
///
/// You must also fill in the placeholders marked TODO below before launch.
/// ─────────────────────────────────────────────────────────────────────────
library;

class LegalContent {
  LegalContent._();

  /// TODO: replace with your registered entity name before launch.
  static const companyName = 'HerTwin';

  /// TODO: replace with a monitored inbox before launch. Both the DPDP Act
  /// and GDPR require a working contact route for data-subject requests.
  static const contactEmail = 'privacy@hertwin.app';

  static const lastUpdated = '23 July 2026';

  /// Shown at the top of both documents in the app.
  static const draftBanner =
      'This is a working draft prepared for review. It has not yet been '
      'reviewed by a lawyer. If anything here conflicts with what the app '
      'actually does, the app is the bug — please report it.';

  // =========================================================================

  static const privacyPolicy = '''
$_privacyIntro

## 1. Who we are

$companyName provides a menstrual and hormonal wellness app. This policy
explains what we collect, why, who can see it, and how you get rid of it.

We are the data controller for the information described here. For any
question or request about your data, contact $contactEmail.

## 2. What we collect

**Account information**
Your email address, display name, and profile photo if you upload one. If you
sign in with Google, we receive your email, name, and profile picture from
Google — we never see your Google password.

**Health information you enter**
This is the sensitive part, and we want to be plain about it:

- Menstrual cycle logs — start and end dates, flow intensity, cycle phase
- Symptoms and their severity
- Mood entries and written journal entries
- Sleep, water intake, and exercise logs
- Onboarding assessment answers, and the condition type, severity level and
  score calculated from them
- Medicine reminders and whether you marked them taken
- Health habits and daily completion
- Prescriptions or medical reports you choose to upload as images

**Consultation information**
If you book a consultation: the booking details, the reason for visit you
write, the chat transcript with your clinician, and any notes or plan your
clinician records.

**Community content**
Posts, comments and likes you create in the community feed. These are visible
to every other signed-in user, along with your display name and photo. Treat
that space as public.

**Technical information**
Basic app analytics through Firebase Analytics — app opens, screen views,
device type, and a randomly generated app instance identifier.

## 3. What we do NOT do

- We do not sell your data. Not to advertisers, insurers, employers, data
  brokers, or anyone else.
- We do not use your health data for advertising or ad targeting.
- We do not share your health data with third parties for their own purposes.
- We do not require you to upload a prescription to use the app.

## 4. Who can see your health data

By default, **only you**. Your entries live under your own account and our
security rules deny access to every other user by default.

There is exactly one way another person sees your health data: **you book a
consultation.** Booking creates a consent record naming that specific
clinician, and only then can they read your chart — your assessment, cycle,
symptoms and habit adherence. They can read it; they cannot alter it.

You can withdraw that consent at any time from your profile. Access stops
immediately on withdrawal.

Our infrastructure runs on Google Firebase (Google Cloud Platform), which
stores and processes data on our behalf as a processor. Google does not get
to use your health data for its own purposes.

## 5. Payments

Consultations in this release are in demo mode. No payment is taken and we do
not collect or store card details, UPI IDs, or any other payment instrument.
If we introduce real payments we will update this policy first, and any card
handling will go through a certified payment provider — never our own servers.

## 6. Your rights

You can:

- **Access** everything we hold about you
- **Correct** anything inaccurate — most of it is editable in the app
- **Delete** your account and all associated health data
- **Export** your data in a portable format
- **Withdraw consent** you gave a clinician, at any time
- **Object** to processing, and complain to your data protection authority

To exercise any of these, email $contactEmail. We will respond within 30 days.
Deletion is permanent and we cannot recover data afterwards.

## 7. How long we keep it

We keep your data while your account is active. When you delete your account
we remove your personal and health data.

Consultation records are the exception: where a clinician has recorded notes,
those may need to be retained to meet medical record-keeping obligations. We
will tell you if that applies to you.

## 8. Security

Health data is encrypted in transit and at rest. Access is enforced by
server-side security rules rather than by the app — so a modified or
tampered-with client still cannot read another user's data.

No system is perfectly secure. If a breach affects your data, we will notify
you and the relevant authority as required by law.

## 9. Children

This app is not intended for anyone under 16. We do not knowingly collect
data from children. If you believe a child has given us data, contact
$contactEmail and we will delete it.

## 10. Changes

If we materially change how we handle your data, we will tell you in the app
before the change takes effect — not quietly in a new version of this page.

## 11. Contact

$contactEmail

Last updated: $lastUpdated
''';

  // =========================================================================

  static const termsOfService = '''
$_termsIntro

## 1. Accepting these terms

By creating an account you agree to these terms. If you do not agree, please
do not use the app.

## 2. THIS IS NOT MEDICAL ADVICE

Read this section even if you skip the rest.

$companyName is a **wellness and tracking tool**. It is not a medical device,
not a diagnostic tool, and not a substitute for professional healthcare.

- Cycle predictions are **estimates** based on your logged history. They will
  sometimes be wrong.
- **Do not use this app for contraception or to plan a pregnancy.** It is not
  designed or validated for either.
- Assessment scores indicate *patterns*, not diagnoses. Only a qualified
  clinician who has examined you can diagnose PCOS, PCOD, PMS, PMDD or
  anything else.
- Yoga, breathwork, nutrition and other content is general wellness
  information. Stop if something hurts, and check with your doctor before
  starting a new routine.

**If you have a medical emergency, contact your local emergency services
immediately. Do not use this app.**

## 3. Your account

Keep your credentials secure and don't share your account. Tell us promptly
at $contactEmail if you think someone else has access to it. You must be at
least 16 years old.

## 4. Consultations

The app can connect you with clinicians. Please understand:

- The clinician is responsible for their own clinical advice. $companyName
  provides the platform, not the care.
- Booking a consultation shares your health profile with that clinician. You
  can withdraw that access at any time.
- Consultations are not appropriate for emergencies or acute conditions.
- In this release, consultations run in **demo mode** — no payment is taken.

## 5. Community rules

The community feed is shared with every other user. Do not post:

- Personal information about anyone else
- Medical advice presented as professional guidance
- Harassment, hate speech, or content targeting individuals
- Spam, advertising, or promotional content

We may remove content and suspend accounts that break these rules. Anything
you post is visible to all signed-in users — please don't post what you would
not want seen.

## 6. Third-party content

The app links to and embeds content from third parties, including YouTube
videos and external articles. We curate it but do not control it, and we are
not responsible for it. Third-party content is governed by its own terms.

## 7. Your content

You keep ownership of everything you write. You grant us only the limited
permission needed to operate the service — storing your entries and showing
your community posts to other users. We claim nothing else.

## 8. Availability

We aim for a reliable service but do not guarantee uninterrupted availability.
We may change or discontinue features. If we shut down the service we will
give you reasonable notice and a way to export your data.

## 9. Limitation of liability

To the fullest extent permitted by law, $companyName is not liable for
indirect or consequential loss arising from your use of the app, or for
health decisions you make based on it.

Nothing in these terms limits liability that cannot be limited by law,
including for death or personal injury caused by negligence.

## 10. Termination

You may delete your account at any time. We may suspend accounts that breach
these terms, and will explain why unless we are legally prevented.

## 11. Governing law

TODO: specify the governing jurisdiction before launch.

## 12. Contact

$contactEmail

Last updated: $lastUpdated
''';
}

const _privacyIntro = '''
Your cycle data, symptoms and journal entries are some of the most personal
information you have. This policy explains, without hedging, exactly what we
do with them.
''';

const _termsIntro = '''
The short version: this is a wellness tracking app, not a doctor. It cannot
diagnose you, and it must not be used for contraception. Section 2 matters
most — please read it.
''';
