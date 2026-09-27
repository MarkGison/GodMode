# Accessibility acceptance

All essential training actions are SwiftUI/native controls. Dynamic Type throughout; no fixed-height text containers. Minimum 44-point touch targets. VoiceOver labels expose exercise/set/load/reps/RIR/rest state in a sensible order without speaking every timer tick. Decorative SF Symbols and particles hidden. Use labels alongside rarity/state color. Inspect contrast (ordinary text 4.5:1, large text 3:1 targets) in actual output.

Reduce Motion: static or gentle transitions, no forced orbit/flash/portal spin, skippable reward sequences. Reduce Transparency: opaque surfaces. Sound and haptics independently disabled; silent mode respected, visual alternatives always available. Timers should not trap focus or constantly announce. Native adjustable controls for reps and RIR, optional numeric input for precision.

Required checks: smallest/large iPhone, default/largest accessibility fonts, VoiceOver full start/log/rest/finish/resume flow, external keyboard/Switch Control focus where supported, no network, missing 3D model, Reduce Motion/Transparency, denied permissions. Photo/camera orbit actions have native alternatives. No health data accidentally spoken on privacy-sensitive surfaces without user action.

M1 UI smoke tests cover setup validation, tabs and catalog navigation. Manual rendering and assistive-technology checks require Mac/device and remain pending. Extend XCUITest and Accessibility Inspector coverage as each flow becomes available; automated checks do not replace hands-on VoiceOver testing.
