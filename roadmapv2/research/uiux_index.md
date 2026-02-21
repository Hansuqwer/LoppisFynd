# UI/UX Index - Nature Distilled

This folder is the docs-first UI/UX spec for the FyndLoppis refresh.

## System Specs (Source of Truth)

- Full compiled UI system PDF: `roadmapv2/LoppisFynd_UI_System_v2_MinimalisticPalette.pdf`
- PDF page index (grep-friendly): `roadmapv2/research/ui_system_v2_minimalistic_palette_pdf_index.md`

- Palette + ramps: `roadmapv2/research/color_palette_tokens.md`
- Typography: `roadmapv2/research/typography_tokens.md`
- Spacing + elevation: `roadmapv2/research/spacing_elevation_tokens.md`
- Glass components: `roadmapv2/research/glassmorphism_components.md`
- Textures: `roadmapv2/research/textures.md`
- Item cards: `roadmapv2/research/item_cards.md`
- Motion + micro-interactions: `roadmapv2/research/motion_microinteractions.md`

## Screen Specs

- Auth/login
  - `roadmapv2/research/auth_gate_screen.md`
  - `roadmapv2/research/login_screen.md`
- Onboarding
  - `roadmapv2/research/onboarding_gate_screen.md`
  - `roadmapv2/research/onboarding_screen.md`
- Core flow
  - `roadmapv2/research/dashboard_screen.md`
  - `roadmapv2/research/scanner_screen.md`
  - `roadmapv2/research/item_detail_screen.md`
- Browse/edit
  - `roadmapv2/research/history_screen.md`
  - `roadmapv2/research/drafts_screen.md`
  - `roadmapv2/research/draft_editor_screen.md`
- Hauls
  - `roadmapv2/research/haul_screen.md`
  - `roadmapv2/research/haul_summary_screen.md`
- Settings + trust
  - `roadmapv2/research/settings_screen.md`
  - `roadmapv2/research/privacy_screen.md`
  - `roadmapv2/research/privacy_policy_screen.md`
  - `roadmapv2/research/sync_status_screen.md`
  - `roadmapv2/research/account_deletion_screen.md`
- Deep links
  - `roadmapv2/research/deep_link_gate_screen.md`
- AI & Offline
  - `roadmapv2/research/model_manager_screen.md`

## Typography Rules (Quick)

- Body/UI: Outfit
- Numbers (prices, KPIs, progress bytes): Space Grotesk

## Background Asset Defaults

- Primary atmospheric background: `roadmapv2/images/loppis_background.png`
- Alternate mood shots:
  - `roadmapv2/images/antique_store.png`
  - `roadmapv2/images/furniture_items.png`
  - `roadmapv2/images/vintage_sweaters.png`

Rule: if a screen is text-heavy (policy/privacy), prefer a flat neutral background.

## Suggested Implementation Order

1) Tokens (palette + typography + spacing/elevation) wired into ThemeData
2) Glass components (surface/card/button/input/chip)
3) Dashboard + Scanner
4) Item cards + Item detail
5) Drafts + Draft editor
6) History + Hauls + Summary
7) Settings + Privacy + Sync + Deletion
8) Login + Onboarding + gates
