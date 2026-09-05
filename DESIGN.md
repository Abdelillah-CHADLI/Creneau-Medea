# Créneau Médéa — Product Design System

This document is derived from the Google Stitch project **Creneau Medea**
(`projects/5634583296858392273`). That project is the visual source of truth;
the existing Flutter application remains the behavioral source of truth.

## Brand

- **Name:** Créneau Médéa
- **Arabic descriptor:** نظّم مباراتك والعب مع مجتمعك
- **Tagline:** رتّب لعبتك، واجمع فريقك
- **Character:** local, athletic, dependable, fast to scan outdoors, and free of
  betting/casino visual language.
- **Mark:** a white football inside a pitch-line hexagon, surrounded by a dashed
  community ring on Algerian turf green.

## Screen mapping

| Stitch reference | Flutter implementation |
| --- | --- |
| شاشة البداية | `screens/onboarding/splash_screen.dart` |
| الترحيب والتعريف | `screens/onboarding/onboarding_screen.dart` |
| تسجيل الدخول | `screens/auth/sign_in.dart` |
| إنشاء حساب جديد | `screens/auth/sign_up.dart` |
| الرئيسية | `screens/home/home.dart` |
| استكشاف المباريات | `screens/discover/available_matches.dart` |
| تفاصيل المباراة | `screens/discover/match_details.dart` |
| إنشاء طلب مباراة + الخطوات 1، 3، 4 | `screens/request/*` wizard |
| مبارياتي | `screens/my_matches/joined_and_organized_matches.dart` |
| إدارة المباراة والحضور | `screens/my_matches/match_management.dart` |
| تعديل المباراة | `screens/my_matches/edit_organized_matches.dart` |
| الملف الشخصي للاعب | `screens/my_matches/player_profile.dart` |
| المباريات المؤرشفة | `screens/my_matches/archived_matches.dart` |
| الإشعارات | `screens/notifications/notification.dart` |
| حسابي | `settings/profile.dart` |
| سجل المباريات | `settings/match_history.dart` |
| Créneau Médéa Logo | reusable brand mark and launcher icons |

Stitch does not show every application state. Loading, empty, error, disabled,
pending, accepted, rejected, full, cancelled, archived, in-progress and finished
states therefore reuse the semantic rules below while retaining existing behavior.

## Color tokens

| Token | Value | Purpose |
| --- | --- | --- |
| `primary` | `#0E7845` | primary actions, selected navigation, confirmed state |
| `primaryDark` | `#005D33` | pressed state, hero depth |
| `primarySoft` | `#EBF5F0` | selected rows, open-slot and success backgrounds |
| `slate` | `#1E293B` | headings, secondary structure |
| `ink` | `#0F172A` | body text with maximum contrast |
| `muted` | `#64748B` | secondary text and inactive controls |
| `canvas` | `#F8FAFC` | application background |
| `surface` | `#FFFFFF` | cards, sheets, inputs |
| `surfaceAlt` | `#F1F5F9` | segmented controls and quiet blocks |
| `outline` | `#E2E8F0` | crisp card/input boundaries |
| `amber` | `#D97706` | ratings, urgency, pending states |
| `amberSoft` | `#FEF3C7` | urgency and pending backgrounds |
| `danger` | `#991B1B` | cancellation, rejection and absence |
| `dangerSoft` | `#FEE2E2` | destructive backgrounds |
| `info` | `#356B8C` | neutral attendance and completed state |
| `infoSoft` | `#E8F0F7` | informational backgrounds |

Color is semantic, never decorative. Statuses always combine color with a label
and/or icon.

## Typography

Use **IBM Plex Sans Arabic** for Arabic and mixed Arabic/Latin interface text.
It matches the Stitch proportions while providing Arabic-specific glyph metrics.

| Role | Size / line height | Weight |
| --- | --- | --- |
| Display | `28 / 38` mobile, `36 / 48` wide | 700 |
| Headline large | `24 / 34` | 700 |
| Headline medium | `20 / 30` | 700 |
| Headline small | `18 / 28` | 600 |
| Title | `16 / 25` | 600 |
| Body large | `16 / 27` | 400 |
| Body | `14 / 23` | 400 |
| Body small | `12 / 20` | 400 |
| Label | `12–14 / 20–23` | 600 |

Arabic labels must not be vertically squeezed. Buttons reserve at least 48 logical
pixels, use a 1.4–1.55 text height, and allow their contents to determine any
additional height. Dates, prices, times and squad counters use tabular figures.

## Spacing and layout

- Base rhythm: 4px; primary rhythm: 8px.
- Scale: 4, 8, 12, 16, 20, 24, 32 and 40px.
- Mobile page gutter: 16px. Dense internal gap: 8–12px.
- Phone: one column. Tablet: content is constrained to 760px; roster/stat blocks
  may use two columns. Desktop: centered content, maximum 1200px.
- Bottom bars include the device safe area and never cover scroll content.
- All directional padding uses RTL-aware `start`/`end` intent.

## Shape and elevation

- Standard card/input/button radius: 8–12px.
- Feature and hero radius: 16px.
- Chips, badges and avatars: full pill/circle.
- Cards: white, 1px `outline`, subtle `0 1 2 / 5%` shadow only when useful.
- Sticky navigation/sheets: upper divider plus `0 4 12 / 8%` shadow.
- Dialogs/sheets: `0 8 24 / 14%` over a 40% slate scrim.
- The former purple vertical screen frame is removed; it is not part of Stitch.

## Core components

### Brand mark

Use the Stitch logo asset, never the Flutter logo or a generic football glyph.
The mark can appear alone in 36–48px chrome or on a white elevated tile at
72–120px in authentication and launch flows.

### Top bar

Compact 56px bar with the logo/title pair on the reading side and icon actions on
the opposite side. Back arrows follow RTL navigation. Actions use 44–48px touch
targets and explicit tooltips/semantics.

### Buttons

- Primary: green fill, white label, 48px minimum height, 8px radius.
- Secondary: white fill, slate/green border, 48px minimum height.
- Urgent: amber fill and white label.
- Destructive: pale red fill, dark red label and border.
- Loading replaces the leading icon with an 18–20px progress indicator without
  shifting the label.

### Match card

The core unit combines:

1. purpose/status eyebrow and price;
2. user-written match title;
3. stadium/date/time metadata;
4. segmented confirmed-player meter;
5. need chips;
6. organizer avatar/name/rating strip;
7. a clear full-width action or disclosure affordance.

No question-mark placeholder icon is permitted. Cards use football, stadium,
calendar, equipment or organizer imagery tied to the content.

### Status pills

- Open/confirmed: green on `primarySoft`.
- Pending/urgent: amber on `amberSoft`.
- Cancelled/rejected/absent: red on `dangerSoft`.
- Finished/completed/info: blue on `infoSoft`.
- Full/inactive/archived: muted slate on `surfaceAlt`.

### Form controls

- White input, 1px outline, 48px minimum height and 8px radius.
- Focus: 2px green stroke with no glow.
- Required labels remain visible above fields; validation appears below without
  changing label position.
- Number-of-players uses one dropdown for 1–13, not thirteen visible choices.
- Equipment uses independent multi-select cards so ball and pump persist together.

### Squad meter

Use up to 13 equal segments. Confirmed segments are green, available segments are
outline gray, and a full roster becomes slate. Always pair it with a textual
`confirmed / capacity` value.

### Player and organizer rows

Avatar on the RTL leading side, then real display name and position/level. Never
show an internal user UUID. Tapping the avatar or identity area opens the existing
read-only player profile with phone, position, level and rating data.

## Navigation

- Four primary destinations remain: الرئيسية، استكشاف، مبارياتي، حسابي.
- Home is the personal dashboard; Explore is the public searchable catalogue.
- The bottom bar is white. Only the selected destination receives a green circular
  background and white icon; inactive destinations remain unfilled.
- Page changes use a 220–280ms fade plus subtle directional slide. Navigation state
  is retained with an indexed stack.

## Screen-specific patterns

- **Splash:** quiet off-white canvas, centered elevated logo tile, subtle pitch-line
  geometry and a short green progress stroke.
- **Onboarding:** image/illustration-led match card, one decisive headline, three
  compact benefit cells, progress dots and a fixed primary action.
- **Authentication:** compact brand header, white grouped form blocks, inline trust
  reassurance, autofill and recovery affordances.
- **Home:** greeting/status header, green personal summary hero, three quick stats,
  next match, then a small discovery preview—not the full Explore feed.
- **Explore:** persistent search/filter controls, active-filter count, result count,
  dense match cards and a bottom filter sheet.
- **Match details:** visual pitch hero, high-priority time/price/roster facts,
  segmented meter, need chips, organizer identity, roster preview and sticky action.
- **Creation wizard:** one consistent 4-step header/progress system. Review uses the
  same match-card language as Explore.
- **My Matches:** organized/joined segmented tabs, actionable cards and archive
  affordance. Archived records remain in the database.
- **Management:** summary strip, pending/confirmed sections, explicit accept/reject,
  attendance and polished star-rating sheets.
- **Profiles:** identity, position/level, rating reliability, real personal stats and
  per-match ratings. Other players are read-only.
- **Notifications/history/archive:** filterable chronological utility lists with
  strong unread/status markers and useful empty/error states.

## RTL and Arabic rules

- The application locale and root direction are Arabic/RTL.
- Leading identity icons appear on the right; trailing disclosure chevrons appear
  on the left and point left.
- Back navigation points right.
- Start time is the right-hand field; end time is the left-hand field.
- Use `مباراة` for one, `مباراتان/مباراتين` for two depending on grammar,
  `مباريات` for 3–10, and singular counted form from 11 upward.
- Use `مضخة` for pump. Do not substitute `إضاءة`.
- Mixed Latin codes (`CRN-2048`, `5v5`) remain isolated and use tabular figures.

## Accessibility and states

- Minimum interactive target: 44px; preferred: 48px.
- All icon-only controls require tooltip and semantic label.
- Primary workflows remain keyboard reachable; fields expose suitable input types,
  autofill hints and next/done actions.
- Loading uses progress/skeleton states; never a blank page.
- Empty states explain the next action. Error states include retry.
- Disabled buttons preserve readable contrast and explain their state in their label.
- Text scaling must not clip; rows that carry Arabic labels may grow vertically.

## Known behavior/UI conflict resolutions

- Stitch shows representative photos, names and counts. Runtime data always wins.
- Stitch shows one onboarding composition; the existing three-slide behavior stays,
  using its visual pattern on every slide.
- Stitch does not include all backend states; they use the semantic status system.
- Profile images are not currently a backend field. The logo/initial treatment stays
  truthful rather than assigning a stock face to real users.
- Match history must be scoped to the signed-in player's organized/joined matches;
  the existing global-feed query is a defect, not intentional behavior.
