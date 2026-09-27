# Design system

Source of truth for implemented values: `GodMode/DesignSystem/DesignTokens.swift`. Values below define purpose; consumers use semantic tokens. SwiftUI native materials, fonts, controls and SF Symbols retain platform behavior. No external component framework.

## Visual language

Near-black canvas, graphite panels, white primary text, muted blue-gray secondary text, electric violet actions, blue informational emphasis, gold limited to rare accomplishments. Original restrained supernatural direction; no copied IP. Fitness values dominate visual hierarchy. Dark appearance is intentional for V1; contrast must be checked in actual renders.

Tokens: `Color.canvas/surface/textPrimary/textSecondary/energy/information/gold/success/warning/error/disabled/border`; rarity aliases common/uncommon/rare/epic/legendary/mythic. `Space.inline/content/section/page` scale layout. `Type.hero/title/section/body/caption` uses Dynamic Type text styles, not fixed point sizes. `Radius.card/control`, `Line.border`, `Size.minimumTarget/icon/contentMaximum`, `Motion.feedback/transition`, `Shadow.card`, `Opacity.subtle`, `Haptics` symbolic patterns and `Material.panel` complete the foundation. Native tab-bar spacing is OS owned. Introduce additional named tokens only when consumed or needed by a planned primitive.

## Components and states

Page: scrollable, centered maximum readable width, semantic page insets. Card: opaque surface with border and scalable title/body. Primary action: native button, violet tint, minimum 44-point target, explicit disabled/save-in-flight state. Errors: text + icon + recovery action; never color only. Empty state: truthful explanation and only implemented actions. Loading: labeled native progress indicator. Success: persists before navigation; native announcements where needed.

## Responsive behavior

Small iPhone: single-column cards and controls; no decorative fixed-height hero. Large iPhone: cap text width and retain one-handed actions. Accessibility Dynamic Type: multiline titles, vertical metrics, no clipped text or horizontal scrolling for essential controls. All pages scroll, with safe-area awareness. Future metric grids use `ViewThatFits`/adaptive layout rather than device-name checks.

M1 hierarchy: GodMode title → tagline → profile → program link. Quests list → day details → exercise prescriptions/safety notes. No animation or 3D in this milestone. Later Reduce Motion disables orbit/portal/flash effects; Reduce Transparency uses opaque cards. Audio/haptics independently optional. Tests must cover VoiceOver labels, focus, text growth, and native back navigation.

## Verification

Inspect CI screenshots from small/large supported iPhone simulators, default and largest accessibility type, then the owner's iPhone when personal signing is available. Compare against this written brief; no supplied visual reference exists. Preserve screenshots/test attachments as CI artifacts for Windows review. No native render has yet been verified.
