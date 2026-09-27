# Windows development workflow

The owner needs Windows, a GitHub account and an iPhone for personal testing. No local Xcode, local/rented Mac, TestFlight or paid developer membership is part of the routine workflow. Automated macOS CI performs native compilation; GitHub allowance/quota availability governs when it can run.

1. Ask Codex to read `AGENTS.md`, `STATUS.md` and relevant specs. Implement/review the smallest coherent change and add focused tests.
2. Run `python tools/validate_repository.py` and `python -m unittest discover -s tools/tests -v`. After adding Swift files or changing identity/version configuration, run `python tools/generate_project.py` and review the diff.
3. Use `git status`, `git diff --check`, `git add <related files>`, `git commit -m "Describe the change"`, then `git push origin main` when authorized/authenticated. No force-push. Never commit backups, credentials, provisioning files or built artifacts.
4. For a meaningful checkpoint, visit the private repository → Actions → **GodMode checkpoint** → Run workflow → select branch and **full / none**. Pushes do not automatically spend macOS minutes. UI labels may evolve; workflow name is authoritative.
5. Open the run summary. Compilation and Tests must both PASS with suite full for the native M1 gate. On failure, download the run artifact and share the specific failing log with Codex. Preserve commit SHA and build-status report so a fix targets the same source.
6. At later install checkpoints choose full/unsigned or full/signed as described in `PERSONAL_INSTALLATION.md`. No credentials are needed to validate source.

Git remote: `https://github.com/MarkGison/GodMode.git`. If Git is not authenticated, use its normal GitHub browser/device authorization; never paste tokens/passwords into chat. The current Codex host has a bundled Git helper-path quirk and different sandbox/host ownership; command-scoped configuration can be used by Codex without changing global settings. Remote is connected and authentication succeeded; upload is currently blocked by the automatic approval review usage limit, not by repository code.

On Windows you can edit all Swift, JSON, documents, assets, project configuration and tests; run Python structural/orchestration tests; review logs/screenshots. SwiftUI/SwiftData/RealityKit compilation, native unit/UI execution, device archives and standard Xcode export require the macOS runner. Physical frame pacing/heat/battery/VoiceOver checks use the owner's legitimately installed iPhone app. CI simulator success cannot establish those device claims.

Artifacts appear at the bottom of a completed run; download and unzip on Windows. `summary.md` and `build-status.json` summarize the result, `logs/` contains per-stage text logs. Raw `.xcresult` is preserved for tooling; CI attempts coverage and standalone attachment exports, including screenshots, even after UI test failure. Inspect `attachments/` from Windows when that export succeeds; inspect the export log if it is absent. No manual project repair on another computer is expected.

If CI cannot run due to quota, runner tools, or access, record NOT RUN rather than PASS. Continue independent work, but do not claim the native gate passed. Signing NOT CONFIGURED is normal until deployment configuration is supplied.
