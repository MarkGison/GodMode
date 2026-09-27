# Character system — M7/M8/M16 planned

CharacterAppearance: face preset, skin, eyes, brows, hair/color, optional facial hair, cosmetic body preset. CharacterLoadout: outfit, armor, gloves, boots, weapon, accessory, aura, pose, profile background. Store stable definition IDs, never asset paths controlled by user input. Cosmetic bodies make no transformation promises.

Character Engine validates available definitions and owned items, then emits a presentation descriptor. RealityKit adapter resolves descriptors to assets. Missing/incompatible item keeps last valid base appearance and displays nonblocking information. Skin/rig versions declare compatibility; anchors have documented stable names. Save loadout before indicating equip success; failed persistence retains previous equipped state.

Viewer: rotation, bounded zoom/orbit, idle animation, equipment preview and poses (idle, crossed arms, stance, weapon rest, victory, meditation, training). Native controls provide equivalent VoiceOver actions and reset camera. Preview does not grant ownership. Scene work pauses offscreen/background; Reduce Motion disables automatic orbit and strong camera movement.

Photo Mode selects pose/background/lighting/aura/effects, captures only scene, then presents native share sheet. Photos write permission only if the user chooses save; cancellation is normal. M16 must verify RealityKit capture path on physical devices. No fabricated character renders in M1.

Tests: invalid definitions, missing slots, cross-rig outfit rejection, persistence retry, preview cancel, loadout restore, memory release, accessible camera actions and export denial.
