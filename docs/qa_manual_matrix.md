# QA manual matrix (v1.0)

Use this as the minimum pre-release checklist. Goal: catch regressions across offline-first behavior, permissions, and sync.

## Device matrix

- Low-end Android (Android Go class): 2GB RAM, slow storage
- Mid-range Android: 4-6GB RAM
- iPhone (any supported iOS target)

## Locales

- Swedish (default)
- English (if enabled)

## Core loop scenarios

- Scan 1 item -> keywords -> comps -> save to haul -> draft listing
- Scan 5 items rapidly (batch tray) and confirm no jank/crashes
- Manual keyword refine (add/edit/delete chips) and re-fetch comps
- Profit calc: purchase price + fees + shipping -> net profit changes as expected

## Offline-first scenarios

- Start offline -> scan + save items -> app remains usable
- Go online -> pending comps and pending cloud sync resolve
- Toggle airplane mode during cloud sync -> no data loss, resumes when online

## Permissions

- Camera permission denied -> education and graceful error state
- Location permission denied -> history still works (no location)
- Location permission granted -> haul location saved and reverse geocode appears

## Auth + data scoping

- Guest flow: create haul/items, confirm data stays local
- Sign in: confirm cloud sync triggers; guest data is claimed to user
- Sign out: confirm user-scoped data is not shown to guest session

## Privacy & trust

- Export JSON + CSV succeeds and files open
- Delete local data removes DB rows and cached scan images
- Account deletion invokes Edge Function and user data disappears after re-login

## Play readiness smoke

- `flutter build appbundle --flavor prod --release` succeeds locally
- CI builds staging + prod AAB
