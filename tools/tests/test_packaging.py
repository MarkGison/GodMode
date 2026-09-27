from datetime import datetime, timedelta, timezone
from pathlib import Path
import plistlib
import sys
import tempfile
import unittest
import zipfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from package_ipa import package_unsigned, verify_package
from signing import validate_profile


class PackagingTests(unittest.TestCase):
    def test_unsigned_package_structure_and_mode(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            app = root / "GodMode.app"
            app.mkdir()
            (app / "Info.plist").write_bytes(plistlib.dumps({
                "CFBundleIdentifier": "com.markgison.godmode", "CFBundleExecutable": "GodMode",
                "CFBundleSupportedPlatforms": ["iPhoneOS"],
            }))
            executable = app / "GodMode"
            executable.write_bytes(b"test fixture only; not a runnable binary")
            executable.chmod(0o755)
            (app / "embedded.mobileprovision").write_bytes(b"do not copy stale profile")
            destination = root / "unsigned.ipa"
            package_unsigned(app, destination, "com.markgison.godmode")
            verify_package(destination, "com.markgison.godmode")
            with zipfile.ZipFile(destination) as package:
                self.assertNotIn("Payload/GodMode.app/embedded.mobileprovision", package.namelist())
            with self.assertRaises(ValueError):
                verify_package(destination, "com.markgison.godmode", require_profile=True)

    def test_simulator_bundle_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            app = root / "GodMode.app"
            app.mkdir()
            (app / "Info.plist").write_bytes(plistlib.dumps({
                "CFBundleIdentifier": "com.markgison.godmode", "CFBundleExecutable": "GodMode",
                "CFBundleSupportedPlatforms": ["iPhoneSimulator"],
            }))
            (app / "GodMode").write_bytes(b"simulator")
            with self.assertRaises(ValueError):
                package_unsigned(app, root / "invalid.ipa", "com.markgison.godmode")
            self.assertFalse((root / "invalid.ipa").exists())

    def test_path_traversal_is_rejected_before_extraction(self):
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "invalid.ipa"
            with zipfile.ZipFile(destination, "w") as package:
                package.writestr("../outside", b"invalid")
            with self.assertRaises(ValueError):
                verify_package(destination, "com.markgison.godmode")


class SigningProfileTests(unittest.TestCase):
    def profile(self):
        return {
            "ExpirationDate": datetime(2030, 1, 1), "TeamIdentifier": ["TEAM"],
            "UUID": "12345678-1234-1234-1234-123456789ABC", "ProvisionedDevices": ["test-device"],
            "DeveloperCertificates": [b"fixture"],
            "Entitlements": {"application-identifier": "TEAM.com.markgison.godmode", "get-task-allow": True},
        }

    def test_identity_and_expiry_validation(self):
        now = datetime(2026, 9, 27, tzinfo=timezone.utc)
        profile = self.profile()
        self.assertEqual(validate_profile(profile, "com.markgison.godmode", now), "TEAM")
        with self.assertRaises(ValueError):
            validate_profile(profile, "com.someone.else", now)
        profile["ExpirationDate"] = now - timedelta(days=1)
        with self.assertRaises(ValueError):
            validate_profile(profile, "com.markgison.godmode", now)

    def test_non_device_profile_is_rejected(self):
        profile = self.profile()
        profile["ProvisionedDevices"] = []
        with self.assertRaises(ValueError):
            validate_profile(profile, "com.markgison.godmode", datetime(2026, 9, 27, tzinfo=timezone.utc))
