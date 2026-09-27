"""Optional standard Xcode manual signing. Never logs credentials or provisioning payloads."""
from datetime import datetime, timezone
from pathlib import Path
import base64
import hashlib
import json
import os
import plistlib
import re
import secrets
import shlex
import shutil
import subprocess
import tempfile
import zipfile

from package_ipa import verify_package


def validate_profile(profile, bundle_id, now=None):
    now = now or datetime.now(timezone.utc)
    expiry = profile.get("ExpirationDate")
    if not isinstance(expiry, datetime) or expiry.replace(tzinfo=timezone.utc) <= now:
        raise ValueError("Provisioning profile is missing expiry or expired")
    teams = profile.get("TeamIdentifier", [])
    entitlements = profile.get("Entitlements", {})
    if not teams or entitlements.get("application-identifier") != teams[0] + "." + bundle_id:
        raise ValueError("Provisioning identity does not match the stable bundle identifier")
    if not profile.get("ProvisionedDevices") or entitlements.get("get-task-allow") is not True:
        raise ValueError("This path requires a personal/development device provisioning profile")
    if not re.fullmatch(r"[A-Fa-f0-9-]{36}", profile.get("UUID", "")):
        raise ValueError("Invalid provisioning profile UUID")
    if not profile.get("DeveloperCertificates"):
        raise ValueError("Profile contains no signing certificates")
    return teams[0]


class PersonalSigner:
    def __init__(self, output, environment, config):
        self.output, self.environment, self.config = Path(output), environment, config
        self.events = []

    def quiet(self, step, command):
        result = subprocess.run(command, env=self.environment, capture_output=True)
        self.events.append({"step": step, "exitCode": result.returncode})
        if result.returncode:
            raise RuntimeError("Signing step failed: " + step)
        return result.stdout

    def export(self, archive):
        installed = []
        keychain = None
        original_keychains = None
        try:
            with tempfile.TemporaryDirectory(prefix="godmode-signing-", dir=os.environ.get("RUNNER_TEMP")) as folder:
                folder = Path(folder)
                p12 = folder / "identity.p12"
                profile_path = folder / "profile.mobileprovision"
                p12.write_bytes(base64.b64decode(self.environment["GODMODE_CERTIFICATE_P12_BASE64"], validate=True))
                profile_path.write_bytes(base64.b64decode(self.environment["GODMODE_PROFILE_BASE64"], validate=True))
                os.chmod(p12, 0o600)
                os.chmod(profile_path, 0o600)
                profile = plistlib.loads(self.quiet("decode-profile", ["security", "cms", "-D", "-i", str(profile_path)]))
                try:
                    team = validate_profile(profile, self.config["bundleIdentifier"])
                except ValueError as error:
                    # The validator emits fixed messages only, never profile values or credentials.
                    self.events.append({"step": "validate-profile", "status": "FAIL", "reason": str(error)})
                    raise
                self.events.append({"step": "validate-profile", "status": "PASS"})
                keychain = folder / "personal.keychain-db"
                password = secrets.token_urlsafe(32)
                self.quiet("create-keychain", ["security", "create-keychain", "-p", password, str(keychain)])
                self.quiet("keychain-timeout", ["security", "set-keychain-settings", "-lut", "1800", str(keychain)])
                self.quiet("unlock-keychain", ["security", "unlock-keychain", "-p", password, str(keychain)])
                self.quiet("import-identity", ["security", "import", str(p12), "-P", self.environment.get("GODMODE_CERTIFICATE_PASSWORD", ""), "-T", "/usr/bin/codesign", "-T", "/usr/bin/security", "-k", str(keychain)])
                self.quiet("key-partition", ["security", "set-key-partition-list", "-S", "apple-tool:,apple:,codesign:", "-k", password, str(keychain)])
                original_keychains = shlex.split(self.quiet("read-search-list", ["security", "list-keychains", "-d", "user"]).decode())
                self.quiet("set-search-list", ["security", "list-keychains", "-d", "user", "-s", *original_keychains, str(keychain)])
                identities = self.quiet("find-identity", ["security", "find-identity", "-v", "-p", "codesigning", str(keychain)]).decode()
                certificates = {hashlib.sha1(cert).hexdigest().upper() for cert in profile["DeveloperCertificates"]}
                identity = next((value for value in re.findall(r"\b[A-Fa-f0-9]{40}\b", identities) if value.upper() in certificates), None)
                if not identity:
                    self.events.append({"step": "match-identity", "status": "FAIL"})
                    raise ValueError("Imported valid identity does not match the provisioning profile")
                for relative in ["Library/MobileDevice/Provisioning Profiles", "Library/Developer/Xcode/UserData/Provisioning Profiles"]:
                    directory = Path.home() / relative
                    directory.mkdir(parents=True, exist_ok=True)
                    target = directory / (profile["UUID"] + ".mobileprovision")
                    if target.exists():
                        if target.read_bytes() != profile_path.read_bytes():
                            raise ValueError("Existing profile UUID conflicts")
                    else:
                        shutil.copy2(profile_path, target)
                        installed.append(target)
                options = folder / "ExportOptions.plist"
                options.write_bytes(plistlib.dumps({
                    "method": "debugging", "destination": "export", "signingStyle": "manual",
                    "teamID": team, "signingCertificate": identity,
                    "provisioningProfiles": {self.config["bundleIdentifier"]: profile["UUID"]},
                }))
                exported = folder / "export"
                self.quiet("xcode-export", ["xcodebuild", "-exportArchive", "-archivePath", str(archive), "-exportPath", str(exported), "-exportOptionsPlist", str(options)])
                packages = list(exported.glob("*.ipa"))
                if len(packages) != 1:
                    raise ValueError("Expected one exported IPA")
                verify_package(packages[0], self.config["bundleIdentifier"], require_profile=True)
                unpacked = folder / "verify"
                with zipfile.ZipFile(packages[0]) as package:
                    package.extractall(unpacked)
                self.quiet("verify-signature", ["codesign", "--verify", "--deep", "--strict", str(unpacked / "Payload/GodMode.app")])
                shutil.copy2(packages[0], self.output / "GodMode.ipa")
        finally:
            # WHY: CI secrets remain in temporary files/keychain, never in downloadable artifacts.
            if original_keychains is not None:
                subprocess.run(["security", "list-keychains", "-d", "user", "-s", *original_keychains], capture_output=True)
            if keychain is not None:
                subprocess.run(["security", "delete-keychain", str(keychain)], capture_output=True)
            for profile in installed:
                profile.unlink(missing_ok=True)
            (self.output / "logs/signing-status.json").write_text(json.dumps(self.events, indent=2), encoding="utf-8")
