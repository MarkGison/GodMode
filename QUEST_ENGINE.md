# Quest and schedule contracts — M6 planned

Main Quest references a persisted scheduled workout occurrence. Daily side quests include warm-up, optional RIR, cooldown, mobility and recovery; reward only once per objective occurrence. Weekly Dungeon requires four distinct scheduled workouts in the training week. Achievements are long-term criteria; repeated evaluation is idempotent.

Schedule stores local calendar day + training time zone + stable occurrence UUID. Default proposed days Monday/Tuesday/Thursday/Saturday are configurable, never assumed active before setup. Changes preserve occurrence identity. Missed day offers move, skip or adjust remaining days; do not pack missed sessions together. Recovery-spacing policy is configurable by program; initial minimum 24 hours between starts and no same-day makeup stacking, with review before release. These are scheduling constraints, not medical prescriptions.

Moving across a week retains reward identity and explicitly reassigns weekly membership. Daylight-saving transitions use Calendar operations, not 86,400-second day arithmetic. Travel does not silently rewrite historical days. Recovery protects adherence; streak definitions exclude planned rest and excused days. Recovery Tokens are earned, never sold, and redemption is a persisted transaction.

State: available → active → completed/expired/skipped; all derived progress comes from committed records. UI explains why an objective is pending. Achievement criteria are versioned so updates cannot silently remove earned cosmetics. Tests cover week boundaries, DST, zone changes, shifted/skipped sessions, rest spacing, duplicate objective events, and reward retries.
