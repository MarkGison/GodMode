# GODMODE — MASTER CODEX BUILD PROMPT

You are the **principal iOS engineer, technical architect, game systems engineer, UI/UX engineer, QA engineer, and performance engineer** responsible for building **GodMode**, a premium native iPhone fitness RPG.

Your responsibility is not to produce a prototype. Build a production-quality application using maintainable architecture, robust testing, strong accessibility, reliable persistence, high-performance 3D rendering, and polished native iOS UX.

Before implementing significant features, create durable project specifications inside the repository so future Codex sessions can understand the product without relying on conversation history.

---

# 1. PRODUCT NAME

**GodMode**

Tagline concept:

**TRAIN. LEVEL UP. EVOLVE.**

Core philosophy:

**The player's character progresses because the player progresses in real life.**

GodMode combines:

- serious workout tracking
- hypertrophy progression
- RPG leveling
- quests
- ranks
- character customization
- equipment
- loot
- achievements
- skill trees
- dungeons
- bosses
- real-time 3D presentation
- premium native iPhone functionality

The application should feel like a high-budget dark-fantasy anime RPG fused with a professional fitness platform.

Do NOT copy copyrighted characters, names, assets, logos, interface designs, music, story elements, monsters, weapons, environments, or artwork from Solo Leveling or any other existing intellectual property.

The creative direction may use general themes such as:

- supernatural progression
- hunter fantasy
- system messages
- dark fantasy
- portals
- dungeons
- ranks
- glowing energy
- cinematic anime-inspired presentation

All GodMode visual assets, terminology, lore, characters, equipment, and environments must remain original.

---

# 2. PRIMARY PRODUCT GOAL

The user owns:

- two 10 kg dumbbells
- one adjustable/foldable bench

The application is centered around a four-day hypertrophy/body-recomposition training program.

The app should guide the user through each workout while making real training feel like an RPG progression journey.

The primary loop is:

1. Open GodMode.
2. See today's Main Quest.
3. Start the prescribed workout.
4. Perform real exercises.
5. Log every set efficiently.
6. Receive automatic rest guidance.
7. Use prescribed tempo.
8. Record RIR/RPE.
9. Complete exercises.
10. Damage/defeat the workout's dungeon boss through legitimate workout completion.
11. Finish the workout.
12. Earn XP, Gold, items, achievements, and progression.
13. View real fitness progress.
14. Equip earned cosmetics.
15. Return for the next scheduled training day.

The game layer must enhance adherence.

It must never interfere with training quality.

---

# 3. PLATFORM

Build for:

**iPhone first**

Minimum deployment target:

**iOS 26**

Primary orientation:

**Portrait**

Support modern iPhones of different screen sizes.

Landscape support is optional except where a particular visual experience benefits from it.

Future architecture should allow Apple Watch support, but Apple Watch is NOT required for version 1.

---

# 4. REQUIRED TECHNOLOGY STACK

Use native Apple technologies.

## Core

- Swift
- SwiftUI
- Swift Concurrency
- async/await
- actors where appropriate
- observation/state management using modern Apple APIs
- protocol-based dependency injection

## Data

- SwiftData for local persistence
- CloudKit/iCloud for optional synchronization

## Health

- HealthKit

## 3D

- RealityKit
- RealityView
- USD/USDZ asset pipeline
- Metal only where custom rendering or shaders genuinely require it
- Physically based materials

## System integration

- ActivityKit
- Live Activities
- Dynamic Island
- WidgetKit
- App Intents
- Siri/Shortcuts exposure
- UserNotifications
- Core Haptics
- Swift Charts

## Testing

- Swift Testing
- XCTest where required
- XCUITest
- performance tests
- data migration tests
- state restoration tests

## Source control

- Git

Do NOT use:

- Flutter
- React Native
- Unity for the main application
- Electron
- webviews as the primary interface
- Firebase in V1
- Supabase in V1
- unnecessary third-party UI frameworks

Third-party dependencies require strong justification and should generally be avoided.

---

# 5. ENGINEERING PHILOSOPHY

GodMode is:

**a native fitness application with an optimized 3D RPG presentation layer.**

It is NOT:

**a mobile game with a workout tracker bolted onto it.**

Fitness functionality must remain reliable even if:

- RealityKit fails to load a cosmetic asset
- the device is offline
- CloudKit is unavailable
- HealthKit permissions are denied
- the device is hot
- Low Power Mode is enabled
- 3D quality is reduced

The user must always be able to complete and save a workout.

---

# 6. REPOSITORY MEMORY

Before building major features, create:

- `AGENTS.md`
- `PRODUCT_SPEC.md`
- `ARCHITECTURE.md`
- `DESIGN_SYSTEM.md`
- `GAME_DESIGN.md`
- `DATA_MODEL.md`
- `WORKOUT_ENGINE.md`
- `PROGRESSION_ENGINE.md`
- `QUEST_ENGINE.md`
- `REWARD_ENGINE.md`
- `CHARACTER_SYSTEM.md`
- `INVENTORY_SYSTEM.md`
- `3D_ENGINE.md`
- `PERFORMANCE_BUDGET.md`
- `ACCESSIBILITY.md`
- `SECURITY_PRIVACY.md`
- `TEST_PLAN.md`
- `RELEASE_CHECKLIST.md`

These documents become the authoritative project memory.

Update specifications whenever architecture or intentional behavior changes.

Do not allow implementation and specifications to silently diverge.

---

# 7. AGENTS.MD RULES

Create `AGENTS.md` containing at minimum these rules:

1. Read relevant project specifications before changing code.
2. Native Swift only.
3. SwiftUI is the application UI layer.
4. RealityKit is the primary real-time 3D layer.
5. SwiftData is the primary local persistence system.
6. Core workout functionality must work offline.
7. No workout session may be lost because the app was backgrounded or terminated.
8. Never put significant business logic directly inside SwiftUI views.
9. Avoid force unwraps in production code.
10. Use proper structured concurrency.
11. Avoid unnecessary global mutable state.
12. Timers must derive from absolute timestamps rather than relying on frame counts.
13. HealthKit is optional.
14. Cloud sync is optional.
15. 3D functionality must gracefully degrade.
16. Accessibility is mandatory.
17. Every meaningful bug requires a regression test.
18. Every major new engine feature requires tests.
19. No feature is complete while its tests fail.
20. Do not copy copyrighted anime/game IP.
21. No unsafe gamification encouraging excessive exercise.
22. Rest and recovery can contribute to progression.
23. No randomized loot mechanics involving real-money gambling.
24. Build must remain free of avoidable compiler warnings.
25. Preserve backward compatibility of persisted data using migrations.
26. Profile CPU/GPU/memory rather than guessing about performance.
27. Commit logical milestones using Git.

---

# 8. APPLICATION ARCHITECTURE

Use a feature-oriented Clean Architecture / MVVM-inspired structure.

Conceptually:

SwiftUI Views  
↓  
View Models / Presentation Models  
↓  
Use Cases / Domain Services  
↓  
Repositories  
↓  
SwiftData / HealthKit / CloudKit / System APIs

Separate major engines:

- Workout Engine
- Progression Engine
- Quest Engine
- Reward Engine
- RPG Progression Engine
- Character Engine
- Inventory Engine
- Achievement Engine
- Analytics Engine
- Schedule Engine
- 3D Engine
- Asset Manager
- Performance Manager

Do not tightly couple fitness logic with rendering logic.

The Workout Engine must be testable without RealityKit.

The RPG Reward Engine must be testable without SwiftUI.

The Progression Engine must be deterministic and extensively testable.

---

# 9. PRIMARY NAVIGATION

Use five major areas.

## SYSTEM

Home/dashboard.

## QUESTS

Workout program and missions.

## HUNTER

3D character and character customization.

## ARSENAL

Inventory, cosmetics, loadouts, equipment.

## PROGRESS

Fitness analytics, history, records, calendar, consistency.

Profile/settings may be accessed through System or Hunter.

---

# 10. REQUIRED SCREEN SET

Implement polished experiences for at least:

1. Splash / Awakening
2. Onboarding
3. User training setup
4. Hunter creation
5. Character customization
6. System Dashboard
7. Today's Main Quest
8. Workout overview
9. World/Dungeon selection presentation
10. Live exercise
11. Tempo Coach
12. Recovery/rest timer
13. Superset mode
14. Circuit mode
15. Workout dungeon/boss
16. Quest Complete
17. Workout summary
18. Level Up
19. Loot reveal
20. Rank Advancement
21. Hunter Profile
22. 3D Character Viewer
23. Arsenal
24. Item Detail
25. Wardrobe/Loadout
26. Skill Tree
27. Achievements
28. Quest/Mission list
29. Progress Dashboard
30. Personal Records
31. Exercise History
32. Workout Calendar
33. Body metrics
34. Exercise Library
35. Exercise Detail
36. Exercise Substitution
37. Settings
38. HealthKit permissions/settings
39. iCloud settings/status
40. Accessibility settings
41. Graphics settings
42. Photo Mode

System surfaces:

- Dynamic Island
- Lock Screen Live Activity
- Home Screen widget
- Lock Screen widget
- App Intent/Siri actions

---

# 11. VISUAL DESIGN DIRECTION

Use an original premium dark supernatural aesthetic.

Base:

- near-black
- graphite
- dark navy

Primary energy accent:

- electric violet
- supernatural blue

Rare emphasis:

- restrained gold

Use:

- strong contrast
- atmospheric lighting
- subtle particles
- luminous edges
- elegant glass only where appropriate
- large typography
- premium card layouts
- smooth motion
- subtle depth
- high-quality 3D renders

Avoid:

- excessive gradients
- cluttered MMORPG interfaces
- unreadably small text
- constant particle spam
- copied anime designs
- cheap gaming aesthetics
- excessive glass on every surface

Use Apple's native visual conventions wherever they improve usability.

Fitness information must always remain easier to read than decorative RPG information.

---

# 12. DESIGN SYSTEM

Create centralized design tokens for:

- spacing
- typography
- corner radius
- materials
- border treatment
- shadows
- animation durations
- haptic patterns
- icon sizes
- layout widths
- rarity colors/effects
- state colors
- success
- warning
- error
- disabled
- system energy effects

Do not invent arbitrary padding, typography, colors, or animation behavior screen-by-screen.

---

# 13. 3D CHARACTER SYSTEM

GodMode requires a real-time 3D Hunter.

The character should support:

- rotation
- pinch zoom
- controlled camera orbit
- idle animations
- equipment preview
- clothing changes
- weapon changes
- aura changes
- poses
- photo mode

Customization categories:

## Face

- face presets
- skin tone
- eyes
- eyebrows
- hairstyles
- hair colors
- optional facial hair

## Body

Use cosmetic presets only.

Avoid promising real-world physical transformations.

## Clothing

- training clothes
- jackets
- armor
- pants
- shoes
- gloves

## Equipment

- swords
- daggers
- great weapons
- gauntlets
- accessories

Weapons are fictional cosmetic RPG items only.

They have no relation to real-world weapon acquisition or use.

## Effects

- aura
- eye glow
- weapon glow
- subtle particles
- profile effects

## Poses

- standard idle
- arms crossed
- combat stance
- weapon resting
- victory
- meditation
- training pose

---

# 14. 3D PERFORMANCE ARCHITECTURE

Use adaptive mobile rendering.

Primary target:

**stable 60 FPS during interactive 3D scenes**

Higher refresh rates may be supported when safe but are not required.

Never sacrifice stability for visual effects.

Priority order:

1. input responsiveness
2. frame pacing
3. workout reliability
4. thermal stability
5. battery efficiency
6. graphical fidelity

Implement graphics profiles internally:

- Efficiency
- Balanced
- High
- Cinematic

Balanced should be the default.

Automatic adaptation should be available.

Reduce quality dynamically when necessary.

Possible adjustable parameters:

- LOD
- texture resolution
- particle density
- shadow quality
- reflection quality
- effect complexity
- render scale
- background animation frequency

---

# 15. THERMAL MANAGEMENT

Observe device thermal state.

When thermal state rises:

## Nominal

Full configured quality.

## Fair

Reduce optional particles/effects.

## Serious

Reduce shadows, LOD, and render intensity.

## Critical

Use minimum viable 3D presentation while preserving workout functionality.

Never lose workout state.

---

# 16. LOW POWER MODE

Detect Low Power Mode.

Automatically enter an efficiency profile.

Reduce:

- unnecessary animation
- particle counts
- refresh-heavy decorative effects
- background rendering

Do not remove workout functionality.

---

# 17. 3D ASSET MANAGEMENT

Create a dedicated `AssetManager`.

Responsibilities:

- load
- preload
- cache
- unload
- reference-count where appropriate
- avoid duplicate assets
- release unused scene resources
- handle unavailable assets gracefully

Do not load every dungeon, character outfit, weapon, and boss at launch.

Examples:

System Dashboard:
load character + lobby assets.

Workout:
load character + current dungeon + current boss.

Arsenal:
load character + selected equipment previews.

Unload unrelated heavy assets.

---

# 18. MODEL OPTIMIZATION

Use realistic mobile budgets.

Approximate guidelines, not absolute hard limits:

Main character at highest LOD:

roughly 50k–100k visible triangles including outfit where practical.

Boss:

roughly 80k–150k highest detail where practical.

Use multiple LOD levels.

Use compressed mobile-friendly textures.

Default important character textures around 2K.

Use 4K only selectively where meaningful and device-safe.

Use smaller textures for distant/background assets.

Prefer good lighting/materials over unnecessary geometry.

---

# 19. LIGHTING

Favor:

- baked/environment lighting
- controlled dynamic character lighting
- efficient reflection techniques
- minimal dynamic lights
- carefully budgeted shadows

Avoid large numbers of fully dynamic lights.

Only visually important elements should cast expensive dynamic shadows.

---

# 20. PARTICLE/AURA SYSTEM

Anime-style energy should use an efficient combination of:

- shaders
- rim lighting
- emissive materials
- limited particles
- texture animation
- restrained distortion

Do not create thousands of expensive transparent particles continuously.

Implement performance-aware particle budgets.

---

# 21. NATIVE UI + 3D

Do NOT make essential workout controls 3D objects.

Use:

SwiftUI for:

- buttons
- reps
- RIR
- timers
- navigation
- accessibility
- settings
- charts
- workout logging

RealityKit for:

- Hunter
- bosses
- environments
- equipment
- cinematic effects
- loot previews

Typical layout:

SwiftUI overlay  
↓  
RealityView  
↓  
3D scene

---

# 22. CORE WORKOUT PROGRAM

Seed the initial application with a four-day home hypertrophy program.

All workout prescriptions must be data-driven and editable later.

Do not hard-code business logic into individual screens.

## DAY 1 — PUSH

Focus:

Chest, shoulders, triceps.

Exercises:

1. Dumbbell Bench Press  
4 sets  
8–12 reps  
Tempo 3-1-1  
Rest 60 sec

2. Incline Dumbbell Press  
4 sets  
8–12 reps  
Tempo 3-1-1  
Rest 60 sec

3. Dumbbell Shoulder Press  
4 sets  
8–12 reps  
Tempo 2-1-1  
Rest 60 sec

4. Dumbbell Lateral Raise  
4 sets  
12–15 reps  
Tempo 2-1-2  
Rest 45 sec

5. Overhead Dumbbell Triceps Extension  
4 sets  
10–15 reps  
Tempo 3-1-1  
Rest 45 sec

6. Close-Grip Push-Up or Bench Dip  
3 sets  
AMRAP within safe technique  
Rest 45 sec

---

## DAY 2 — LOWER + CORE

Focus:

Quads, glutes, hamstrings, calves, core.

Initial exercise sequence:

1. Goblet Squat
2. Bulgarian Split Squat
3. Dumbbell Romanian Deadlift
4. Reverse Lunge
5. Calf Raise
6. Core circuit

Core circuit should support three rounds.

Exact prescription must remain configurable through seed workout data rather than encoded into UI logic.

The engine must support unilateral tracking.

---

## DAY 3 — PULL

Focus:

Back, rear delts, biceps.

Initial exercise sequence:

1. One-Arm Dumbbell Row
2. Renegade Row
3. Rear-Delt Fly
4. Dumbbell Curl
5. Hammer Curl
6. Safe home row variation such as an appropriately configured supported/towel/inverted variation

All exercise substitutions must include appropriate safety guidance.

---

## DAY 4 — FULL BODY HYPERTROPHY

Initial sequence:

1. Dumbbell Thruster
2. Incline Dumbbell Fly
3. Romanian Deadlift to Row
4. Lateral Raise + Front Raise Superset
5. Curl-to-Press Complex
6. Three-round full-body finisher

All exact targets should be stored in editable workout seed configuration.

---

# 23. WORKOUT ENGINE

Support:

- straight sets
- unilateral sets
- supersets
- circuits
- AMRAP
- timed work
- tempo
- rest periods
- complexes
- skipped sets
- skipped exercises
- substitutions
- resumed sessions
- aborted sessions
- partial sessions
- session notes

A workout must not depend on internet connectivity.

---

# 24. SET RECORD MODEL

A working set should be capable of storing:

- exercise ID
- workout ID
- set number
- set type
- reps
- load
- load unit
- side
- RIR
- optional RPE
- eccentric tempo
- pause tempo
- concentric tempo
- set duration
- time under tension when calculable
- prescribed rest
- actual rest
- completion timestamp
- notes
- whether manually edited
- whether it contributed to rewards
- progression metadata

---

# 25. RIR SYSTEM

After relevant working sets, allow fast logging:

- 4+
- 3
- 2
- 1
- 0 / failure

Optimize this for one-handed use.

RIR should help inform progression recommendations.

Do not force RIR entry where inappropriate.

---

# 26. TEMPO COACH

Support tempo such as:

3-1-1.

Optional modes:

- visual
- haptic
- sound
- voice
- silent

Example:

LOWER  
3  
2  
1

HOLD  
1

LIFT  
1

The user must be able to disable tempo coaching while still seeing the prescription.

---

# 27. REST TIMER

Rest starts automatically when a set is completed.

Allow:

- +15 seconds
- skip
- pause when appropriate

Show:

- current rest
- next set
- exercise
- target

Use absolute timestamps so timers remain correct through:

- lock screen
- background
- temporary suspension

---

# 28. LIVE ACTIVITY

During active workouts provide:

- current exercise
- set
- rest timer
- next action
- workout elapsed time where appropriate

Dynamic Island should remain concise.

Do not expose unnecessary sensitive health information on Lock Screen.

---

# 29. WORKOUT STATE RESTORATION

Persist active workout state frequently.

The user must be able to recover after:

- app termination
- accidental swipe-away
- call interruption
- device lock
- backgrounding
- UI reconstruction
- crash where possible

Present:

**Workout in progress — Resume**

Store enough state to reconstruct:

- workout
- exercise
- set
- reps entered
- completed sets
- current rest deadline
- substitutions
- elapsed workout duration
- notes

---

# 30. PROGRESSION ENGINE

The user has fixed 10 kg dumbbells.

Therefore progression cannot depend entirely on load increases.

Implement deterministic progression based on:

- completed reps
- prescribed rep range
- RIR
- number of successful sessions
- tempo
- actual rest
- set completion
- exercise history

Progression ladder:

1. Increase reps.
2. Reach upper rep target across prescribed sets.
3. Slow eccentric.
4. Increase pause.
5. Carefully reduce rest if appropriate.
6. Add a prescribed set when program rules permit.
7. Use 1½ reps.
8. Use harder unilateral variations.
9. Use safe supersets.
10. Use rest-pause only where appropriate.
11. Use mechanical drop sets where appropriate.

Never apply advanced intensity techniques blindly.

Recommendations must remain exercise-specific and programmatically controlled.

---

# 31. PROGRESSION EXAMPLE

If Bench Press history shows:

previous:

10 kg × 10 / 10 / 9 / 8

new:

10 kg × 12 / 12 / 11 / 10

and reported RIR is appropriate,

the system may recommend:

3-1-1  
→  
4-1-1

Do not automatically apply significant progression changes without communicating them.

---

# 32. PERSONAL RECORD SYSTEM

Recognize more than weight PRs.

Support:

- Rep PR
- Session volume PR
- Exercise volume PR
- Time-under-tension PR
- Tempo PR
- AMRAP PR
- Density PR
- consistency milestone
- workout completion milestone

PRs should trigger tasteful celebration and optional bonus game rewards.

---

# 33. RPG LEVEL SYSTEM

Create a global Hunter Level.

XP should come from legitimate behaviors such as:

- prescribed workout completion
- scheduled quest completion
- appropriate consistency
- PRs
- achievements
- recovery objectives

Do NOT disproportionately reward:

- endless extra sets
- multiple excessive workouts per day
- unsafe overtraining

Use a nonlinear level curve.

Level progression should remain satisfying over long-term use.

---

# 34. HUNTER RANK SYSTEM

Ranks:

E  
D  
C  
B  
A  
S  
S+

Rank advancement requires meaningful criteria.

Example:

C-Rank Trial:

- required minimum level
- completed workout milestone
- adherence milestone
- multiple PR milestones
- Rank-Up Quest

Then provide a cinematic Rank Advancement sequence.

---

# 35. QUEST SYSTEM

Support:

## Main Quest

Today's programmed workout.

## Daily Side Quests

Examples:

- perform prescribed warm-up
- log RIR
- complete cooldown
- mobility objective
- recovery objective

## Weekly Dungeon

Complete all four scheduled workouts.

Rewards might include:

- XP
- Gold
- cosmetic chest
- achievement progress

## Achievement Quests

Long-term progression.

---

# 36. DUNGEON SYSTEM

Each workout can have an original themed dungeon.

Examples:

Push:
**Crimson Forge**

Lower:
**Titan Arena**

Pull:
**Abyss Citadel**

Full Body:
**Ascension Tower**

Names and lore may evolve but must remain original.

Each exercise can represent a boss phase.

Each legitimate set can contribute to boss progress.

---

# 37. BOSS COMBAT

Combat is passive visualization tied to workout completion.

The user does NOT play action combat while lifting.

Flow:

Complete Set  
→  
Hunter performs attack animation  
→  
Boss HP decreases  
→  
Recovery timer begins

Workout performance determines visual progress.

Do not turn exercise into twitch gameplay.

Animations must be brief/skippable.

---

# 38. REWARD SYSTEM

Reward categories:

- XP
- Gold
- rare achievement currency
- equipment
- cosmetics
- titles
- poses
- backgrounds
- profile frames
- aura effects
- animations

Rarity tiers:

- Common
- Uncommon
- Rare
- Epic
- Legendary
- Mythic

No paid randomized loot boxes.

---

# 39. EQUIPMENT

Equipment can include:

- armor
- jackets
- shirts
- pants
- gloves
- boots
- accessories
- fictional weapons
- aura
- profile effects

Equipment is primarily cosmetic.

If equipment has game bonuses, bonuses should affect harmless game systems, such as:

- cosmetic XP bonus
- Gold bonus
- quest reroll
- presentation unlock

Equipment must NOT claim to make the user's real body stronger.

---

# 40. INVENTORY

Support:

- owned items
- locked items
- rarity
- acquisition date
- source
- equipped state
- equipment slot
- favorite state
- sorting
- filtering

Filters:

- rarity
- type
- owned
- newly acquired
- equipped

---

# 41. LOADOUT

Allow saveable cosmetic loadouts.

Example slots:

- outfit
- armor
- gloves
- boots
- weapon
- accessory
- aura
- pose
- profile background

---

# 42. LOOT REVEAL

After qualifying events:

- chest appears
- short 3D animation
- item revealed
- rarity displayed
- item can rotate
- equip immediately
- skip animation available

Avoid long unskippable sequences.

---

# 43. SKILL TREE

Create achievement-based skill trees such as:

## Discipline

Consistency.

## Strength

Progression achievements.

## Control

Tempo/RIR mastery.

## Endurance

Training density.

## Recovery

Healthy recovery compliance.

Skills primarily represent milestones and game progression.

Avoid game mechanics that encourage unsafe exercise volume.

---

# 44. RECOVERY SYSTEM

Recovery must be part of the game.

Reward legitimate recovery behaviors such as:

- scheduled rest days
- mobility
- stretching
- deload compliance
- optional sleep/recovery metrics where HealthKit permission exists

Never punish users for respecting recovery.

---

# 45. STREAK SYSTEM

Do not make streaks psychologically punitive.

Support:

**Recovery Tokens**

Earned through consistent legitimate behavior.

Can protect a streak during:

- illness
- travel
- unavoidable schedule conflicts

Do not sell Recovery Tokens for money.

---

# 46. ADAPTIVE SCHEDULING

If a workout is missed:

offer to:

- move the workout
- skip it
- adjust remaining schedule

Maintain reasonable recovery spacing.

Do not simply cram missed sessions together.

---

# 47. ANALYTICS

Progress Dashboard should include:

- workouts completed
- adherence %
- current streak
- longest streak
- total sets
- total reps
- training volume
- workout duration
- average RIR
- exercise progression
- time-under-tension where meaningful
- personal records
- body weight
- body measurements if entered
- muscle group training distribution
- monthly consistency
- weekly consistency

Use Swift Charts.

---

# 48. FANTASY STATS

Optional fantasy stats:

- Power
- Endurance
- Discipline
- Control
- Consistency

These should transparently derive from real behaviors.

Do not pretend they are medical or physiological measurements.

Show real training metrics separately.

---

# 49. CALENDAR

Show completed workouts visually.

Tap date to inspect:

- workout
- exercises
- sets
- PRs
- XP
- items earned
- notes

---

# 50. EXERCISE LIBRARY

Each exercise should support:

- name
- movement category
- primary muscles
- secondary muscles
- equipment
- setup instructions
- execution
- breathing
- form cues
- common mistakes
- prescribed tempo
- progression
- regression
- substitution options
- safety notes
- optional demo media

---

# 51. SUBSTITUTION ENGINE

Allow reason selection:

- equipment unavailable
- discomfort
- space limitation
- preference

Recommend appropriate movement substitutes.

Maintain movement intent where possible.

Do not present substitutions as medical treatment.

---

# 52. HEALTHKIT

HealthKit integration is optional.

With permission, consider:

Read:

- body weight
- relevant workout history
- heart rate data when available
- resting heart rate
- active energy

Write:

- completed eligible workouts
- workout duration
- relevant supported workout metrics

Do not require HealthKit permission to use GodMode.

Use least-privilege permission requests.

Explain why each permission is requested.

---

# 53. ICLOUD

The app works locally first.

SwiftData is primary storage.

Optional iCloud/CloudKit synchronization may sync supported models.

Handle:

- offline state
- delayed synchronization
- conflict scenarios
- unavailable account

Never block training due to cloud failure.

---

# 54. NO REQUIRED ACCOUNT

Do not require an email/password login for V1.

The user should be able to install the app and train.

---

# 55. NOTIFICATIONS

Use notifications carefully.

Examples:

**SYSTEM**

Main Quest available.

Push Day  
6 exercises

Or:

Weekly Dungeon  
1 quest remaining.

Allow notification configuration.

Avoid spam.

If workout already completed, suppress unnecessary reminder.

---

# 56. APP INTENTS

Expose useful actions:

- Start Today's Workout
- Start Push Day
- Start Lower Day
- Start Pull Day
- Start Full Body Day
- Resume Workout
- Show Today's Quest

Where practical support:

- Siri
- Shortcuts
- Spotlight
- Action Button

---

# 57. WIDGETS

Support useful widgets.

Small:

- Hunter level
- today's quest

Medium:

- today's workout
- weekly completion

Lock Screen:

- next workout
- weekly progress

Do not turn widgets into cluttered miniature dashboards.

---

# 58. PHOTO MODE

Allow character screenshots with:

- character rotation
- pose
- camera zoom
- background
- lighting
- aura
- effects
- optional depth-of-field where performant

Export using user-approved Photos access/share sheet.

---

# 59. ACCESSIBILITY

Mandatory support:

- Dynamic Type
- VoiceOver
- sufficient contrast
- Reduce Motion
- Reduce Transparency
- haptic controls
- sound controls
- large touch targets
- readable workout metrics

If Reduce Motion is enabled:

reduce:

- aggressive camera movement
- spin transitions
- flashy level-up motion

Use fades and restrained transitions instead.

---

# 60. PRIVACY

No advertising SDK in V1.

No selling user data.

No unnecessary tracking.

Store sensitive fitness data appropriately.

Request only required permissions.

Create clear privacy descriptions.

Do not expose Health data to RPG systems in misleading ways.

---

# 61. ANTI-EXPLOIT REWARD LOGIC

Users must be able to correct legitimate mistakes.

However, prevent trivial XP farming.

Possible safeguards:

- reward only reasonable number of scheduled training sessions per day
- detect duplicate completion events
- reward once per valid quest
- separate edited workout history from reward transactions
- transaction IDs for rewards
- prevent deleting/recreating sessions from repeatedly generating loot
- persist reward issuance state

Do not make the fitness log hostile or difficult to edit.

---

# 62. DATA MODELS

Create appropriate SwiftData models/domain models conceptually including:

- UserProfile
- UserPreferences
- TrainingSchedule
- TrainingProgram
- WorkoutTemplate
- WorkoutDay
- Exercise
- ExerciseVariant
- ExercisePrescription
- WorkoutSession
- ExerciseSession
- SetRecord
- RestPeriod
- ProgressionRule
- ProgressionRecommendation
- PersonalRecord
- BodyMetric
- Hunter
- HunterStats
- HunterRank
- ExperienceState
- CharacterAppearance
- CharacterLoadout
- ItemDefinition
- InventoryItem
- EquipmentSlot
- Quest
- QuestObjective
- QuestProgress
- RewardDefinition
- RewardTransaction
- Achievement
- AchievementProgress
- SkillDefinition
- SkillProgress
- DungeonDefinition
- BossDefinition
- NotificationPreferences
- GraphicsPreferences

Separate persistent models from domain logic where beneficial.

Plan schema migrations from the beginning.

---

# 63. WORKOUT UI UX

During actual workout execution, speed is critical.

The user should generally be able to:

complete a set with one primary tap.

Essential controls should be reachable one-handed.

Example live set information:

Exercise  
Set 2 of 4  
10 kg  
11 reps  
Target 8–12  
Tempo 3-1-1  
Previous 10 kg × 10  
RIR selector  
Complete Set

The RPG overlay must not obscure these values.

---

# 64. QUEST COMPLETION EXPERIENCE

At workout completion show:

Workout name  
Duration  
Sets  
Reps  
PRs  
Progressions  
XP  
Gold  
Quest completion  
Loot

Then optional cinematic rewards.

All cinematics must be skippable.

---

# 65. LEVEL-UP EXPERIENCE

Brief cinematic:

- environment darkens
- aura grows
- level increments
- haptic effect
- unlocks displayed

No unnecessarily long animation.

---

# 66. RANK-UP EXPERIENCE

Rank advancement should feel more significant than normal leveling.

Use:

- unique animation
- new rank emblem
- new cosmetic unlock
- strong but tasteful haptics
- new aura possibility
- rank reward screen

---

# 67. AUDIO

Sound should be optional.

Categories:

- UI
- workout cues
- tempo
- reward effects
- cinematic effects
- ambient music if original/licensed assets exist

Respect silent mode where appropriate.

Do not depend on audio for essential information.

---

# 68. HAPTICS

Create centralized haptic patterns.

Examples:

- set complete
- countdown
- workout complete
- PR
- loot rarity
- level-up
- rank-up

Use restraint.

Do not vibrate continuously.

---

# 69. PERFORMANCE TESTING

Profile:

- launch time
- CPU
- GPU
- memory
- allocations
- frame pacing
- hangs
- SwiftData queries
- scene loading
- asset unloading
- energy impact

Test long workout sessions.

Test repeated navigation between:

- System
- Hunter
- Arsenal
- Dungeon
- Progress

Watch for memory growth.

---

# 70. RELIABILITY TEST MATRIX

Test:

## Timers

- background
- foreground
- lock
- unlock
- notification interruption
- app suspension
- device time changes where relevant
- pause/resume

## Workout state

- skip exercise
- undo set
- edit reps
- incomplete workout
- terminate mid-workout
- reopen
- continue

## Data

- empty database
- many workouts
- many items
- migration
- iCloud unavailable
- HealthKit denied

## UI

- smallest supported iPhone
- large iPhone
- Light Mode if supported
- Dark Mode
- huge accessibility fonts
- Reduce Motion
- no network

## 3D

- missing model
- slow model load
- thermal state changes
- Low Power Mode
- memory pressure
- background/foreground
- repeated scene switching

---

# 71. TESTING RULES

Every meaningful engine should have unit tests.

Required strong test coverage for:

- progression rules
- XP calculations
- level thresholds
- rank requirements
- reward issuance
- duplicate reward prevention
- quest completion
- schedule shifting
- rest timer calculations
- workout restoration
- persistence migrations

Every fixed bug should receive a regression test where practical.

---

# 72. CI QUALITY GATES

Create a CI workflow where practical.

No milestone is complete unless:

- project builds
- tests pass
- critical UI smoke tests pass
- no obvious concurrency violations
- no new avoidable compiler warnings
- data migration tests pass
- restoration tests pass
- progression tests pass

---

# 73. GIT WORKFLOW

Use logical commits.

Example:

- project foundation
- domain models
- workout engine
- workout persistence
- progression engine
- RPG progression
- quest engine
- character system
- inventory
- RealityKit foundation
- Live Activities
- HealthKit
- analytics
- accessibility
- performance hardening
- release QA

Do not combine unrelated giant changes when avoidable.

---

# 74. BUILD MILESTONES

Follow this order.

## MILESTONE 0 — SPECIFICATION

Create all project memory/specification documents.

No major feature coding until these are coherent.

Deliver:

- product specification
- architecture
- data model
- game systems
- testing strategy
- 3D strategy
- performance budgets

---

## MILESTONE 1 — APP FOUNDATION

Implement:

- Xcode project
- SwiftUI shell
- navigation
- DI/container
- SwiftData foundation
- design tokens
- domain foundations
- seed workout data
- test targets

Acceptance:

- builds
- zero critical warnings
- tests pass

Do NOT prematurely implement every feature.

---

## MILESTONE 2 — WORKOUT ENGINE

Implement:

- workout sessions
- exercises
- sets
- RIR
- tempo
- rest
- supersets
- circuits
- unilateral support
- AMRAP
- workout state

Add extensive tests.

---

## MILESTONE 3 — PERSISTENCE + RESTORATION

Implement robust persistence.

Test:

- termination
- background
- recovery
- partial workout
- timer restoration

---

## MILESTONE 4 — PROGRESSION ENGINE

Implement deterministic fixed-weight progression.

Add comprehensive parameterized tests.

---

## MILESTONE 5 — RPG CORE

Implement:

- Hunter XP
- levels
- ranks
- Gold
- reward ledger
- achievements

---

## MILESTONE 6 — QUEST SYSTEM

Implement:

- Main Quest
- Daily Quest
- Weekly Dungeon
- quest progress
- quest rewards

---

## MILESTONE 7 — 3D FOUNDATION

Implement:

- RealityView
- base character entity
- camera system
- lighting
- idle animation
- asset loading
- performance monitoring
- LOD foundations

Initially use legal placeholder/original developer assets if final art assets are unavailable.

Architecture must support replacing placeholders without rewriting gameplay logic.

---

## MILESTONE 8 — CHARACTER CUSTOMIZATION

Implement:

- character appearance model
- outfit attachment
- equipment slots
- live 3D preview
- loadout persistence

---

## MILESTONE 9 — INVENTORY + LOOT

Implement:

- inventory
- rarity
- loot tables
- equip
- loot reveal
- reward transactions
- duplicate protection

---

## MILESTONE 10 — DUNGEONS + BOSSES

Implement:

- dungeon presentation
- boss state
- workout-to-combat mapping
- short attack animations
- boss HP progression
- scene transitions

The workout remains authoritative.

---

## MILESTONE 11 — PREMIUM UI POLISH

Implement:

- motion
- transitions
- typography polish
- haptics
- rarity effects
- cinematic sequences
- polished empty/loading/error states

---

## MILESTONE 12 — ANALYTICS

Implement:

- Progress Dashboard
- Swift Charts
- history
- PRs
- calendar
- adherence metrics

---

## MILESTONE 13 — HEALTHKIT

Implement optional HealthKit.

Test denied permissions and partial permissions.

---

## MILESTONE 14 — LIVE ACTIVITIES

Implement:

- rest timer
- current workout
- next set

Dynamic Island and Lock Screen.

---

## MILESTONE 15 — WIDGETS + APP INTENTS

Implement:

- widgets
- Siri/App Intents
- Shortcuts exposure
- Action Button-compatible actions where supported

---

## MILESTONE 16 — PHOTO MODE

Implement character photo mode.

---

## MILESTONE 17 — ACCESSIBILITY + PERFORMANCE HARDENING

Audit:

- VoiceOver
- Dynamic Type
- Reduce Motion
- thermal adaptation
- Low Power Mode
- memory
- frame pacing
- launch time

---

## MILESTONE 18 — QA

Do not add unnecessary new features.

Attempt to break the application.

Fix:

- crashes
- data loss
- stuck timers
- duplicate rewards
- memory problems
- scene loading failures
- accessibility regressions
- state bugs

---

## MILESTONE 19 — RELEASE PREPARATION

Prepare:

- App Store metadata placeholders
- privacy descriptions
- permission descriptions
- release checklist
- TestFlight build
- known limitations
- migration plan
- version number

---

# 75. V1 SCOPE

Version 1 should focus on:

- 4-day program
- excellent workout execution
- RIR
- tempo
- rest
- progression engine
- workout recovery
- XP
- levels
- ranks
- quests
- character customization
- inventory
- cosmetic items
- achievements
- skill progression
- 3D Hunter
- 3D dungeon presentation
- bosses
- loot
- analytics
- HealthKit
- iCloud
- Live Activities
- widgets
- App Intents
- notifications
- Photo Mode

---

# 76. FUTURE FEATURES — DO NOT BLOCK V1

Architect for but do not require:

- Apple Watch companion
- AI Coach
- social guilds
- multiplayer challenges
- cloud-hosted account backend
- subscriptions
- coach/client features
- community marketplace

Do not build them unless instructed later.

---

# 77. AI COACH

Do not make generative AI a dependency for V1.

The core training recommendation engine should remain deterministic and testable.

Future AI can explain:

- trends
- workouts
- progress
- history

It must not replace the deterministic progression engine without an intentional architecture change.

---

# 78. ERROR HANDLING

Never silently fail important operations.

Provide graceful states for:

- missing 3D asset
- HealthKit denial
- CloudKit delay
- unsupported feature
- corrupted optional cosmetic data
- notification permission denial

Workout data is the highest priority.

---

# 79. NO FAKE DATA IN PRODUCTION

Mock data may be used for:

- SwiftUI previews
- automated testing
- development builds

Production should not silently display fake progress.

---

# 80. LOADING STATES

Avoid excessive loading screens.

Preload predictable assets.

Use transitions to mask necessary scene changes.

Example:

System Lobby  
→ portal transition  
→ dungeon

Do not block workout start for unnecessary cosmetics.

---

# 81. UX PRIORITY

During training:

1. exercise name
2. set
3. reps
4. load
5. tempo
6. RIR
7. rest
8. completion

RPG visuals are secondary.

One-handed use is important.

---

# 82. SAFETY

GodMode is a fitness tool, not medical software.

Avoid diagnostic claims.

Do not present fantasy stats as health diagnoses.

Do not reward dangerous overtraining.

Do not encourage users to ignore pain.

Exercise discomfort substitutions should be presented conservatively.

Recovery should be treated as legitimate progression.

---

# 83. COMMERCIAL READINESS

Even though the initial build may be personal, architect cleanly enough that GodMode could eventually become a commercial App Store product.

Therefore:

- avoid private APIs
- use proper permission flows
- respect accessibility
- maintain privacy
- avoid copyrighted assets
- avoid hard-coded personal information
- localize strings structurally where practical
- prepare for future localization

---

# 84. LOCALIZATION

Centralize user-facing strings where practical.

Initial language:

English.

Architecture should allow future localization.

---

# 85. DEBUG / DEVELOPER MENU

Create a development-only debug interface for:

- reset database
- seed sample history
- set Hunter level
- unlock test item
- simulate rank-up
- simulate quest completion
- simulate thermal/graphics settings where possible
- inspect reward transactions
- inspect active workout state

Debug controls must not ship exposed to normal users.

---

# 86. DEVELOPMENT ASSET STRATEGY

If final 3D character assets are unavailable:

DO NOT block engineering.

Use original or legally usable placeholder assets/procedural placeholders.

Create stable protocols/interfaces so final:

- characters
- armor
- weapons
- bosses
- environments
- effects

can be replaced later without rewriting domain logic.

---

# 87. CODE REVIEW MODE

After every major milestone:

perform a second-pass audit as a senior iOS engineer.

Inspect specifically for:

- crashes
- state bugs
- concurrency problems
- SwiftData problems
- migration issues
- memory leaks
- retained RealityKit entities
- performance regressions
- asset duplication
- inaccessible controls
- reward exploits
- missing tests
- architectural violations

Fix high-severity issues before proceeding.

---

# 88. DEFINITION OF DONE

A feature is not complete merely because it visually appears.

A feature is complete when:

- architecture is appropriate
- implementation is finished
- expected states work
- failure states work
- accessibility works
- tests exist
- tests pass
- no major warnings exist
- state persists where required
- performance has been considered
- relevant documentation is updated

---

# 89. FINAL PRODUCT EXPERIENCE

The intended experience:

The user launches GodMode.

A real-time 3D Hunter stands in a supernatural training base.

The System shows:

MAIN QUEST  
PUSH DAY

The user taps:

START QUEST.

The character enters an original dungeon.

The user performs real Dumbbell Bench Press sets.

The workout UI shows:

10 kg  
11 reps  
Tempo 3-1-1  
RIR 2

The user taps:

COMPLETE SET.

The Hunter performs a short attack.

The boss loses HP.

A 60-second recovery timer begins.

Dynamic Island displays the rest countdown.

The user completes the workout.

The boss is defeated.

Workout results are saved first.

Then the game reward sequence occurs.

The user receives:

XP  
Gold  
possibly a cosmetic chest  
possibly a PR

The Hunter levels up.

A newly earned jacket can be equipped immediately.

The jacket appears on the 3D character.

The Progress tab reflects the real workout.

The next training day waits as the next Main Quest.

That is GodMode.

---

# 90. FIRST EXECUTION INSTRUCTION

Do not begin by generating the entire application in one uncontrolled pass.

Start with **Milestone 0**.

Perform the following:

1. Inspect the repository.
2. Initialize Git if needed.
3. Create all required specification files.
4. Translate this master instruction into durable project documentation.
5. Resolve contradictions in favor of:
   - workout reliability
   - native iOS conventions
   - performance
   - accessibility
   - maintainability
6. Produce the proposed repository architecture.
7. Create `AGENTS.md`.
8. Create the initial Xcode project only after the specification foundation is coherent.
9. Begin Milestone 1.
10. Build and run tests.
11. Audit your own work.
12. Commit the completed milestone.
13. Continue sequentially through the milestones while respecting dependencies and quality gates.

Do not shortcut foundational architecture just to create flashy screens quickly.

---

# 91. AUTONOMY

Use strong engineering judgment.

If a minor implementation detail is unspecified:

choose the option that best supports:

- native iOS behavior
- maintainability
- performance
- reliability
- accessibility
- privacy
- clean UX

Document significant assumptions.

Do not invent major product changes without recording them.

---

# 92. PRIORITY ORDER

If two requirements conflict, use this order:

1. User safety
2. No workout data loss
3. Correct workout behavior
4. Persistence/recovery
5. Accessibility
6. UI responsiveness
7. Stable performance
8. Battery/thermal efficiency
9. Game systems
10. Visual effects

Never sacrifice the first eight simply to make the RPG presentation more dramatic.

---

# 93. FINAL ENGINEERING STANDARD

Build GodMode as though it will eventually be reviewed by:

- a senior Apple platform engineer
- a senior mobile game engineer
- a professional product designer
- a fitness application product team
- an accessibility specialist
- an App Store review team

The expected result is not merely functional.

It should be:

**stable, testable, beautiful, responsive, accessible, maintainable, offline-capable, privacy-conscious, performant, and genuinely enjoyable to use.**

Proceed with **Milestone 0**, establish the project memory and architecture, then build GodMode systematically.