#!/usr/bin/env python3
"""Checkpoint build driver. Runs on macOS CI; policy tests run on Windows/Linux."""
from pathlib import Path
import argparse
import json
import os
import platform
import subprocess
import sys
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]


class Report:
    def __init__(self, suite, package, output=None):
        self.output = output
        self.data = {
            "suite": suite, "requestedPackage": package,
            "commit": os.environ.get("GITHUB_SHA", "local"),
            "Environment": "NOT RUN", "Compilation": "NOT RUN", "Tests": "NOT RUN",
            "Archive": "NOT CONFIGURED", "Signing": "NOT CONFIGURED", "IPA": "NOT GENERATED",
            "ipaKind": None, "installable": False, "physicalDeviceVerified": False, "errors": [],
        }

    def save(self):
        if self.output:
            self.output.parent.mkdir(parents=True, exist_ok=True)
            self.output.write_text(json.dumps(self.data, indent=2) + "\n", encoding="utf-8")

    def stage(self, name, action):
        self.data[name] = "RUNNING"
        self.save()
        try:
            action()
        except Exception as error:
            self.data[name] = "FAIL" if name != "IPA" else "NOT GENERATED"
            # WHY: Arbitrary signing exceptions may contain credentials; serialize only a safe type.
            self.data["errors"].append({"stage": name, "type": type(error).__name__})
            self.save()
            return False
        self.data[name] = "PASS" if name != "IPA" else "GENERATED"
        self.save()
        return True


def pipeline(suite, package, actions, report, signing_configured=False):
    if suite not in {"compile", "unit", "full"} or package not in {"none", "unsigned", "signed"}:
        raise ValueError("Unknown build mode")
    if package != "none" and suite != "full":
        raise ValueError("Packaging requires the full test suite")
    for stage in ["Environment", "Compilation"]:
        if not report.stage(stage, actions[stage]):
            return 1
    if suite != "compile" and not report.stage("Tests", actions["Tests"]):
        return 1
    if package == "none":
        return 0
    if not report.stage("Archive", actions["Archive"]):
        return 1
    if package == "signed":
        if not signing_configured:
            report.data["signingNote"] = "Valid signing configuration not supplied; source validation is independent."
            report.save()
            return 0
        if not report.stage("Signing", actions["Signing"]):
            return 1
    if not report.stage("IPA", actions["IPA"]):
        return 1
    report.data["ipaKind"] = package
    report.data["installable"] = package == "signed"
    report.data["installationNote"] = (
        "Signed package; provisioning/device compatibility still requires owner-device validation."
        if package == "signed" else "UNSIGNED: cannot install until a compatible tool legitimately signs/provisions it."
    )
    report.save()
    return 0


class Runner:
    def __init__(self, suite, package):
        self.suite, self.package = suite, package
        self.config = json.loads((ROOT / "Config/build.json").read_text())
        run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S") + "-" + str(os.getpid())
        self.output = ROOT / "artifacts" / run_id
        self.logs = self.output / "logs"
        self.logs.mkdir(parents=True, exist_ok=True)
        self.archive = self.output / "GodMode.xcarchive"
        self.environment = os.environ.copy()
        self.destination = None

    def run(self, name, command):
        print(f"Running {name}", flush=True)
        with (self.logs / f"{name}.log").open("w", encoding="utf-8") as log:
            result = subprocess.run(command, cwd=ROOT, env=self.environment, stdout=log, stderr=subprocess.STDOUT)
        if result.returncode:
            print(f"{name} failed; inspect {self.logs / (name + '.log')}", flush=True)
            raise RuntimeError(name)

    def setup(self):
        if platform.system() != "Darwin":
            print("Environment unavailable: run this native gate on the automated macOS runner.")
            raise RuntimeError("Native validation requires a macOS CI runner")
        version = self.config["xcodeVersion"]
        developer = Path(f"/Applications/Xcode_{version}.app/Contents/Developer")
        if not developer.is_dir():
            print(f"Runner image does not contain pinned Xcode {version}; review Config/build.json.")
            raise RuntimeError("Pinned Xcode is missing from runner image")
        self.environment["DEVELOPER_DIR"] = str(developer)
        self.run("environment", ["xcodebuild", "-version"])
        self.run("portable-validation", [sys.executable, "tools/validate_repository.py"])
        devices = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "devices", "available", "-j"], env=self.environment))
        candidates = devices["devices"].get(self.config["simulatorRuntime"], [])
        phone = next((d for d in candidates if d.get("isAvailable") and d["name"].startswith("iPhone")), None)
        if not phone:
            print(f"Runner has no available iPhone for {self.config['simulatorRuntime']}.")
            raise RuntimeError("Pinned iOS simulator runtime has no available iPhone")
        self.destination = f"platform=iOS Simulator,id={phone['udid']}"
        (self.output / "environment.json").write_text(json.dumps({
            "xcode": version, "runtime": self.config["simulatorRuntime"], "simulator": phone["name"],
            "runnerImage": os.environ.get("ImageVersion", "unknown")
        }, indent=2), encoding="utf-8")

    def xcode(self, configuration="Debug", device=False):
        return ["xcodebuild", "-project", "GodMode.xcodeproj", "-scheme", "GodMode",
                "-configuration", configuration, "-destination", "generic/platform=iOS" if device else self.destination,
                "-derivedDataPath", "DerivedData", "CODE_SIGNING_ALLOWED=NO", "CODE_SIGNING_REQUIRED=NO"]

    def compile(self):
        self.run("compile-debug", self.xcode() + ["-enableCodeCoverage", "YES", "build-for-testing"])
        self.run("compile-release", self.xcode("Release") + ["build"])

    def tests(self):
        self.run("core-tests", ["swift", "test", "--package-path", "Packages/GodModeCore", "--parallel",
                                "--enable-code-coverage", "-Xswiftc", "-warnings-as-errors"])
        results = str(self.output / "GodMode-tests.xcresult")
        command = self.xcode() + ["-enableCodeCoverage", "YES", "-resultBundlePath", results, "test-without-building"]
        if self.suite == "unit":
            command.append("-only-testing:GodModeTests")
        try:
            self.run("apple-tests", command)
        finally:
            for name, export in [
                ("coverage", ["xcrun", "xccov", "view", "--report", "--json", results]),
                ("attachments", ["xcrun", "xcresulttool", "export", "attachments", "--path", results,
                                 "--output-path", str(self.output / "attachments")]),
            ]:
                try:
                    self.run(name, export)
                except RuntimeError:
                    print(f"Optional {name} export unavailable; raw xcresult is retained when produced.")

    def archive_build(self):
        self.run("device-archive", self.xcode("Release", device=True) + ["-archivePath", str(self.archive), "archive"])
        if not (self.archive / "Products/Applications/GodMode.app/Info.plist").is_file():
            raise RuntimeError("Archive does not contain the device application")

    def sign(self):
        from signing import PersonalSigner
        PersonalSigner(self.output, self.environment, self.config).export(self.archive)

    def package_ipa(self):
        from package_ipa import package_unsigned, verify_package
        if self.package == "unsigned":
            source = self.archive / "Products/Applications/GodMode.app"
            target = self.output / "GodMode-unsigned-for-resigning.ipa"
            package_unsigned(source, target, self.config["bundleIdentifier"])
        else:
            verify_package(self.output / "GodMode.ipa", self.config["bundleIdentifier"], require_profile=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--suite", choices=["compile", "unit", "full"], default="full")
    parser.add_argument("--package", choices=["none", "unsigned", "signed"], default="none")
    args = parser.parse_args()
    runner = Runner(args.suite, args.package)
    report = Report(args.suite, args.package, runner.output / "build-status.json")
    actions = {"Environment": runner.setup, "Compilation": runner.compile, "Tests": runner.tests,
               "Archive": runner.archive_build, "Signing": runner.sign, "IPA": runner.package_ipa}
    configured = all(os.environ.get(key) for key in ["GODMODE_CERTIFICATE_P12_BASE64", "GODMODE_PROFILE_BASE64"])
    try:
        result = pipeline(args.suite, args.package, actions, report, configured)
    except ValueError as error:
        print(str(error), file=sys.stderr)
        result = 2
    finally:
        report.save()
        summary = "## GodMode build status\n\n" + "\n".join(f"- {key}: **{report.data[key]}**" for key in ["Environment", "Compilation", "Tests", "Archive", "Signing", "IPA"])
        summary += f"\n\nSuite: {args.suite}; package: {report.data['ipaKind'] or 'none'}.\n"
        summary += report.data.get("installationNote", report.data.get("signingNote", "No installable IPA produced.")) + "\n"
        (runner.output / "summary.md").write_text(summary, encoding="utf-8")
        if os.environ.get("GITHUB_STEP_SUMMARY"):
            with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as target:
                target.write(summary)
        print(summary)
    return result


if __name__ == "__main__":
    sys.exit(main())
