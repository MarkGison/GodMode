#!/usr/bin/env python3
"""Portable structural checks only. Apple builds and executable tests are separate gates."""
from pathlib import Path
import json
import plistlib
import re
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
errors = []
checks = 0


def check(condition, message):
    global checks
    checks += 1
    if not condition:
        errors.append(message)


def unique(values, label):
    check(all(values) and len(values) == len(set(values)), f"Invalid/duplicate {label} IDs")


def validate():
    docs = "AGENTS PRODUCT_SPEC ARCHITECTURE DESIGN_SYSTEM GAME_DESIGN DATA_MODEL WORKOUT_ENGINE PROGRESSION_ENGINE QUEST_ENGINE REWARD_ENGINE CHARACTER_SYSTEM INVENTORY_SYSTEM 3D_ENGINE PERFORMANCE_BUDGET ACCESSIBILITY SECURITY_PRIVACY TEST_PLAN RELEASE_CHECKLIST STATUS MASTER_BRIEF README".split()
    for name in docs:
        path = ROOT / f"{name}.md"
        check(path.exists() and path.stat().st_size > 100, f"Missing or empty {name}.md")

    seed = ROOT / "Packages/GodModeCore/Sources/GodModeCore/Resources/home-hypertrophy-v1.json"
    program = json.loads(seed.read_text(encoding="utf-8"))
    check(program["schemaVersion"] == 1 and program["revision"] >= 1, "Unsupported seed version")
    check([day["id"] for day in program["days"]] == ["push", "lower", "pull", "full-body"], "Four-day order changed")
    unique([item["id"] for item in program["exercises"]], "exercise")
    unique([day["id"] for day in program["days"]], "day")
    blocks = [block for day in program["days"] for block in day["blocks"]]
    prescriptions = [p for block in blocks for p in block["prescriptions"]]
    unique([b["id"] for b in blocks], "block")
    unique([p["id"] for p in prescriptions], "prescription")
    exercise_ids = {e["id"] for e in program["exercises"]}
    for exercise in program["exercises"]:
        check(bool(exercise["name"] and exercise["safetyNote"] and exercise["equipment"]), f"Incomplete exercise: {exercise['id']}")
    for block in blocks:
        check(1 <= block["rounds"] <= 10 and 0 <= block["roundRestSeconds"] <= 600 and bool(block["prescriptions"]), f"Invalid block: {block['id']}")
        if block["kind"] in ["straight", "unilateral", "complex"]:
            check(len(block["prescriptions"]) == 1 and block["rounds"] == 1, f"Invalid single exercise block: {block['id']}")
        elif block["kind"] == "superset":
            check(len(block["prescriptions"]) == 2, f"Invalid superset: {block['id']}")
        elif block["kind"] == "circuit":
            check(len(block["prescriptions"]) >= 2, f"Invalid circuit: {block['id']}")
        else:
            check(False, f"Unknown block kind: {block['id']}")
        for p in block["prescriptions"]:
            check(p["exerciseID"] in exercise_ids, f"Missing exercise reference: {p['id']}")
            check(1 <= p["sets"] <= 10 and 0 <= p["restSeconds"] <= 600, f"Invalid set/rest prescription: {p['id']}")
            check(p["suggestedLoadKgPerImplement"] is None, f"Seed load must require user confirmation: {p['id']}")
            check(p["sideTracking"] in ["bilateral", "eachSide"], f"Invalid side: {p['id']}")
            if block["kind"] == "unilateral":
                check(p["sideTracking"] == "eachSide", f"Missing unilateral tracking: {p['id']}")
            if block["kind"] in ["superset", "circuit"]:
                check(p["sets"] == 1, f"Group must have one set per round: {p['id']}")
            if p["target"] == "reps":
                check(0 < p["minimumReps"] <= p["maximumReps"] <= 100 and p["durationSeconds"] is None, f"Invalid rep range: {p['id']}")
            elif p["target"] == "amrap":
                check(all(p[key] is None for key in ["minimumReps", "maximumReps", "durationSeconds"]), f"Invalid AMRAP: {p['id']}")
            elif p["target"] == "timed":
                check(p["minimumReps"] is None and p["maximumReps"] is None and 1 <= p["durationSeconds"] <= 3600, f"Invalid timed work: {p['id']}")
            else:
                check(False, f"Unknown target: {p['id']}")
            if p["tempo"]:
                check(all(0 <= value <= 10 for value in p["tempo"].values()) and sum(p["tempo"].values()) > 0, f"Invalid tempo: {p['id']}")
    push = [p for block in program["days"][0]["blocks"] for p in block["prescriptions"]]
    check([p["sets"] for p in push] == [4, 4, 4, 4, 4, 3], "Push sets drifted from brief")
    check([p["restSeconds"] for p in push] == [60, 60, 60, 45, 45, 45], "Push rests drifted from brief")
    check([p["minimumReps"] for p in push] == [8, 8, 8, 12, 10, None], "Push lower targets drifted")
    check([p["maximumReps"] for p in push] == [12, 12, 12, 15, 15, None], "Push upper targets drifted")
    check([b["rounds"] for b in blocks if b["kind"] == "circuit"] == [3, 3], "Core/finisher need three rounds")

    for name in ["GodMode/Info.plist", "GodMode/Resources/PrivacyInfo.xcprivacy"]:
        with (ROOT / name).open("rb") as source:
            contents = plistlib.load(source)
        check(isinstance(contents, dict), f"Invalid plist: {name}")
    catalog = json.loads((ROOT / "GodMode/Resources/Localizable.xcstrings").read_text(encoding="utf-8"))
    check(catalog["sourceLanguage"] == "en", "Unexpected source language")

    project = (ROOT / "GodMode.xcodeproj/project.pbxproj").read_text(encoding="utf-8")
    definitions = re.findall(r"^\s*([A-F0-9]{24}) = \{isa = (\w+);", project, re.M)
    identifiers = {key for key, _ in definitions}
    check(len(identifiers) == len(definitions), "Duplicate Xcode object identifiers")
    check(set(re.findall(r"\b[A-F0-9]{24}\b", project)) <= identifiers, "Dangling Xcode object references")
    check(sum(kind == "PBXNativeTarget" for _, kind in definitions) == 3, "Expected app/unit/UI targets")
    for name in ["GodMode", "GodModeTests", "GodModeUITests"]:
        for source in (ROOT / name).rglob("*.swift"):
            relative = source.relative_to(ROOT).as_posix()
            check(f'path = "{relative}";' in project, f"Swift file omitted from Xcode: {relative}")
    for relative in re.findall(r'path = "([^"\n]+)"; sourceTree = "<group>";', project):
        check((ROOT / relative).is_file(), f"Missing referenced Xcode file: {relative}")
    check('IPHONEOS_DEPLOYMENT_TARGET = "26.0"' in project, "Wrong deployment target")
    check('SWIFT_VERSION = "6.0"' in project, "Swift 6 required")
    check('SWIFT_TREAT_WARNINGS_AS_ERRORS = "YES"' in project, "Warnings must fail the gate")
    scheme = ET.parse(ROOT / "GodMode.xcodeproj/xcshareddata/xcschemes/GodMode.xcscheme")
    check(len(scheme.findall(".//TestableReference")) == 2, "Unit/UI tests missing from scheme")
    for reference in scheme.findall(".//BuildableReference"):
        check(reference.attrib["BlueprintIdentifier"] in identifiers, "Scheme target reference is invalid")
    check((ROOT / ".github/workflows/ios.yml").exists(), "CI workflow missing")

    production = list((ROOT / "GodMode").rglob("*.swift")) + list((ROOT / "Packages/GodModeCore/Sources").rglob("*.swift"))
    for source in production:
        content = source.read_text(encoding="utf-8")
        check(not re.search(r"\b(?:try!|as!|fatalError\s*\()", content), f"Unsafe crash construct: {source.name}")
        if "Features" in source.parts:
            check(not re.search(r"\.padding\(\d|\.font\(\.system\(size:\s*\d|Color\(red:", content), f"Raw visual value in feature: {source.name}")
    domain_text = "\n".join(p.read_text(encoding="utf-8") for p in (ROOT / "Packages/GodModeCore/Sources").rglob("*.swift"))
    check(not re.search(r"import (SwiftUI|SwiftData|RealityKit|HealthKit)", domain_text), "Domain depends on platform presentation/storage")
    print(f"Portable structure checks: {checks - len(errors)}/{checks} passed")
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    print("Swift compilation, runtime behavior, migration, UI rendering and device performance: NOT verified by this tool.")
    return 1 if errors else 0


if __name__ == "__main__":
    try:
        sys.exit(validate())
    except (OSError, ValueError, KeyError, TypeError, ET.ParseError) as error:
        print(f"Structure validation could not finish: {error}", file=sys.stderr)
        sys.exit(1)
