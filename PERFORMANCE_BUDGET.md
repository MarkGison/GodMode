# Performance budgets — unmeasured targets

Priority: responsiveness, frame pacing, workout reliability, thermal stability, battery, fidelity. Interactive 3D target 60 FPS; 120 FPS optional. Frame budget 16.7 ms; record p50/p95/p99 frame duration, hitch counts and thermal state on the oldest supported and a recent iPhone. These are acceptance targets, not observed results.

| Budget | Initial target | Measurement |
| --- | --- | --- |
| Cold usable shell | ≤2 seconds, no scene prerequisite | Instruments App Launch, release build |
| Local set commit | p95 ≤100 ms, correctness first | signposts with no health payload |
| Touch feedback | next display frame where possible | responsiveness/hang instruments |
| Interactive scene | stable 60 FPS in Balanced nominal | Metal/System Trace, device capture |
| Foreground memory | initial 350 MB target; no monotonic growth | Allocations/VM Tracker across 30 scene cycles |
| Long workout | 90 minutes without lost records/hangs | real device and interruption matrix |
| Asset transition | nonblocking UI; placeholders immediately | load/cancel/unload signposts |

Efficiency: static/simple scene, lowest LOD, no optional particles or expensive shadows. Balanced default: mobile LOD, restrained effects. High: optional better textures/shadows with thermal headroom. Cinematic: brief foreground photo/reward use only; never a permanent workout rendering requirement. Automatic adaptation reduces optional effects at fair, shadows/LOD/intensity at serious, minimum or static at critical. Low Power Mode forces Efficiency. Persist selected and effective profile separately.

Guidelines: Hunter 50–100k triangles at top LOD including outfit; boss 80–150k. At least lower tiers with measured savings. Important textures around 2K; selective 4K only after memory profiling. Background textures smaller. Scene visibility, not animation timers, governs work. Avoid busy timers offscreen. Validate energy impact with display brightness/temperature recorded.

M17 exit requires attached trace summaries, device/OS/build details, peak memory and recovery after pressure. A simulated quality selector does not prove thermal behavior.
