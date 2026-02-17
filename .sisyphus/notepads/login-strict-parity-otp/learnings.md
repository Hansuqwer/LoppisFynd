# Learnings (Append-Only)

Append notes discovered during execution.

## Supabase Flutter OTP vs Magic Link Implementation (2026-02-17)

### Key Distinction
- **Magic Link**: Sends a clickable URL in email → user clicks → auto-validates
- **Email OTP**: Sends 6-digit code → user enters manually → `verifyOtp` call needed

Both use the same `signInWithOtp()` API. The difference is in the **email template**.

### How to Force 6-Digit OTP (Not Magic Link)

**Option 1: Edit Magic Link Template** (Hosted Supabase Dashboard)
1. Go to: Authentication → Email Templates → Magic Link
2. Replace `{{ .ConfirmationURL }}` with `{{ .Token }}` 
3. Email now shows: "Please enter this code: 123456"

**Option 2: Custom Template with OTP**
```html
<h2>Your login code</h2>
<p>Use this code: <strong>{{ .Token }}</strong></p>
```

### Dart/Flutter Implementation

**Step 1: Send OTP**
```dart
final supabase = Supabase.instance.client;

await supabase.auth.signInWithOtp(
  email: 'user@example.com',
  options: EmailOptions(
    emailRedirectTo: 'loppisfynd://login-callback',
  ),
);
```

**Step 2: Verify OTP (6-digit code)**
```dart
final response = await supabase.auth.verifyOtp(
  email: 'user@example.com',
  token: '123456',  // 6-digit code user entered
  type: OtpType.email,  // CRITICAL: must be 'email' for OTP
);
```

**CRITICAL GOTCHA**: Use `type: OtpType.email` NOT `type: 'email'` (string). The enum matters for code verification vs link verification.

### config.toml for Local Supabase

```toml
[auth]
enabled = true
site_url = "loppisfynd://"  # Your deep link scheme

# For OTP email templates (local)
[auth.email.template.magic_link]
subject = "Your login code"
content_path = "./supabase/templates/otp_email.html"
```

### Template Variables Reference

| Variable | Description |
|----------|-------------|
| `{{ .Token }}` | 6-digit OTP code (use for OTP flow) |
| `{{ .TokenHash }}` | Hashed token for custom link construction |
| `{{ .ConfirmationURL }}` | Full magic link URL |
| `{{ .SiteURL }}` | Your app's site URL |
| `{{ .RedirectTo }}` | Redirect URL passed in API call |
| `{{ .Email }}` | User's email address |
| `{{ .Data }}` | user_metadata from auth.users |

### Deep Link Setup (Critical for Flutter)

**Android (AndroidManifest.xml)**
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="loppisfynd" />
</intent-filter>
```

**iOS (Info.plist)**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>loppisfynd</string>
    </array>
  </dict>
</array>
```

### Common Gotchas

1. **Wrong type in verifyOtp**: Using `type: 'email'` for magic link verification fails. Magic links use implicit flow, OTPs need explicit `verifyOtp` with `type: OtpType.email`.

2. **Email prefetching**: Some email providers (Microsoft Defender) prefetch links, consuming the magic link. Use OTP to avoid "Token expired" errors.

3. **Rate limiting**: Default 60 seconds between requests, 1 hour expiry. Configurable in Dashboard → Auth → Providers → Email.

4. **Auto-signup**: By default, `signInWithOtp` creates user if not exists. Set `shouldCreateUser: false` to prevent.

5. **emailRedirectTo**: Required for magic link/PKCE flows, specifies deep link callback. For OTP, less critical but good practice.

### Sources
- https://supabase.com/docs/guides/auth/auth-email-passwordless
- https://supabase.com/docs/guides/auth/auth-email-templates

## Login l10n parity (2026-02-17)

- When adding new keys to `lib/l10n/app_*.arb`, run `flutter gen-l10n` (or a build/test) before expecting new getters on `AppLocalizations`.

## Persist last-used email (2026-02-17)

- `LoginScreen` needs `appDatabaseProvider` access to prefill/persist last email, so it must be a `ConsumerStatefulWidget` (not plain `StatefulWidget`).

## OTP service implementation notes (2026-02-17)

- In `supabase_flutter`/Dart the auth method is `verifyOTP(...)` (capitalized), not `verifyOtp(...)`.
- `signInWithOtp(...)` supports `shouldCreateUser` (defaults to true); set it explicitly for auto-create behavior.

## Local email capture API (Inbucket reference + current CLI behavior) (2026-02-17)

Supabase CLI `supabase status --output json` exposes `INBUCKET_URL` for the local email capture server.

### Inbucket endpoints (reference)

- List mailbox: `GET /api/v1/mailbox/{name}`
- Latest message: `GET /api/v1/mailbox/{name}/latest`
- Message JSON: `GET /api/v1/mailbox/{name}/{id}`

Example curls:

```bash
INBUCKET_URL="$(supabase status --output json | python -c 'import json,sys; print(json.load(sys.stdin)["INBUCKET_URL"])')"

curl -sS "$INBUCKET_URL/api/v1/mailbox/test"
curl -sS "$INBUCKET_URL/api/v1/mailbox/test/latest"
curl -sS "$INBUCKET_URL/api/v1/mailbox/test/<id>"
```

### Supabase CLI v2.75.0 note

On this machine, the "inbucket" service is backed by Mailpit (so the Inbucket endpoints return 404). Use Mailpit's API instead:

```bash
MAIL_URL="$(supabase status --output json | python -c 'import json,sys; d=json.load(sys.stdin); print(d.get("INBUCKET_URL") or d["MAILPIT_URL"])')"

# list messages
curl -sS "$MAIL_URL/api/v1/messages"

# fetch message JSON by ID
curl -sS "$MAIL_URL/api/v1/message/<id>"

# extract the first 6-digit token from the message JSON
curl -sS "$MAIL_URL/api/v1/message/<id>" | python -c 'import json,re,sys; d=json.load(sys.stdin); hay=(d.get("Text") or "")+"\n"+(d.get("HTML") or ""); print(re.search(r"\b\d{6}\b", hay).group(0))'
```

## Login UI strict parity implementation notes (2026-02-17)

- For the repeated background motif, use a login-local widget with `LayoutBuilder` + `Positioned` and low-opacity clipped tiles that render `Image.asset('Assets/unnamed.jpg', fit: BoxFit.cover)`.
- Keep blur clipped: `GlassOverlay` already clips its `BackdropFilter`; for a glass pill CTA you can also use `ClipRRect` + `BackdropFilter` around the button itself (avoid any full-screen `BackdropFilter`).
- Implement pill CTAs locally (login-only) with `AppRadius.pill` to avoid changing shared `GlassButton` radii.
- The repo already has tests expecting `maskEmailForUi(...)` behavior (bullet masking + plus-addressing handling); implement to match `test/features_auth/email_masking_test.dart`.

## OTP login UI state machine notes (2026-02-17)

- `LengthLimitingTextInputFormatter(6)` is not `const`, so `inputFormatters` can't be a `const [...]` list.
- To keep strict-parity layout while allowing email edits, make the email field `readOnly` in the code step and use `onTap` to switch back to the email step.
- For reliable focus after switching to the code step, schedule `_codeFocus.requestFocus()` in a post-frame callback.
- Motif marks can be rendered as small circular badges derived from `Assets/unnamed.jpg` by zooming/cropping (`Transform.scale` + `Alignment`) to emphasize the logo mark without introducing new assets; keep mark specs as a fixed const list for stable goldens.

## LoginScreen widget + golden test stability notes (2026-02-17)

- `matchesGoldenFile(...)` paths are relative to the test file; when the test lives under `test/features_auth/`, use `../goldens/...` to keep baselines under `test/goldens/`.
- `LoginScreen` intro uses a post-frame `_introShown` animation; use `pumpAndSettle` long enough (2-3s) so goldens capture the final state.
- Avoid Supabase in widget tests by injecting `EmailOtpAuth` into `LoginScreen` and keeping `EmailOtpAuth.supabase(Supabase.instance.client)` behind a `??` so it is never evaluated in tests.
- Capturing at 390x844 can reveal real layout issues (a Row overflowed); wrapping the app name in `Flexible` prevents overflow and keeps the golden stable.
