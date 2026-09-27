# RealityKit strategy — M7 onward

SwiftUI RealityView hosts a scene adapter; domain services never import RealityKit. Scene requests are small descriptors (Hunter/loadout, dungeon, boss phase, quality policy). AssetManager uses allowlisted bundle identifiers and asynchronous loading with deduplicated in-flight requests, cancellation and bounded cache. Clone entity instances where scene ownership requires; never share one mutable entity between scenes. Reference-count reusable resources, release offscreen scene roots and purge optional caches under memory pressure.

Initial originals may be procedural geometry with physically based materials. Later USD/USDZ pipeline: authored source → named rig/anchors → validated export → mobile LOD/texture tiers → provenance manifest → device QA. Do not claim final art quality for developer placeholders. Each asset manifest includes source/license/author, rig, bounds, scale, triangle count, texture formats/sizes and fallback ID. No third-party assets presently included.

System loads Hunter/lobby only; workout loads current dungeon/boss only; Arsenal loads selected preview. Preload predictable next asset after workout state is ready. Missing/slow asset renders a 2D fallback with Retry; never disables training. Background or inactive tab releases/pause scenes. Scene transitions cancel superseded loading tasks and ignore stale completions.

Lighting favors baked environments, PBR and a small number of controlled lights; expensive shadow casters explicitly budgeted. Aura uses bounded emissive/rim effects; no continuous particle flood. Camera orbit/pinch have bounds/reset and native accessible equivalents. PerformanceManager observes thermal state, Low Power Mode, motion preference and scene visibility; chooses an effective quality at or below user preference. Critical heat can use static presentation.

No custom Metal until profiling proves necessity. Test missing USDZ, cancellation races, repeated navigation, pressure, idle/background behavior, cross-rig equipment and entity release. Budgets in `PERFORMANCE_BUDGET.md` are targets pending physical-device measurement.
