# Privacy policy

See `docs/privacy_policy.html` for the host-ready HTML version.

## Hosting

1. Copy `docs/privacy_policy.html` to your GitHub Pages, Vercel, or Netlify site.
2. Set the URL in the Play Console under App content → Privacy policy.
3. Optionally: update the `kPrivacyPolicyUrl` constant in the app code
   (`lib/core/config/app_config.dart`) so the app can link to it.

## Summary
 
 Loppisfynd is designed to be offline-first.
 
### What data is stored locally
 
 On your device, Loppisfynd stores:
 
 - Hauls (title, date, optional location)
 - Items (keywords, notes, prices, computed stats)
 - Draft listings (title/description/asking price)
 - Scan photos and thumbnails
 - App settings and preferences
 
 This data is never shared with third parties.
 
### What data is stored in the cloud (optional)
 
 If you enable cloud sync and sign in, Loppisfynd may upload:
 
 - Haul and item metadata to Supabase (secure database)
 - Scan photos to encrypted cloud storage
 
 Cloud sync is optional. The app still functions without it.
 
### Online requests
 
 When you are online, the app can fetch sold-price comps from Tradera via a proxy.
 
### AI identification
 
 If cloud identification is enabled, item photos are sent to a secure AI proxy for
 object recognition. Photos are processed in real-time and not stored on the server.
 
### Crash reporting
 
 Anonymous crash reports via Sentry (device model, OS version, stack traces).
 No personal information, photos, or scan data is included.
 
### Export and deletion
 
 In-app you can:
 
 - Export all your data as JSON or CSV
 - Delete all local data
 - Delete all cloud data (when signed in)
 - Request full account deletion
 
### Children
 
 Loppisfynd is not directed at children under 13 and does not knowingly collect
 data from children.
 
### Changes to this policy
 
 We may update this policy from time to time. The latest version is always
 available at this URL.
 
### Contact
 
 Questions? Contact privacy@fyndloppis.se