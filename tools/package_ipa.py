"""Standards-shaped device IPA packaging; unsigned output is explicitly noninstallable."""
from pathlib import Path, PurePosixPath
import os
import plistlib
import stat
import zipfile


def verify_package(path, bundle_id, require_profile=False):
    with zipfile.ZipFile(path) as archive:
        names = archive.namelist()
        if len(names) != len(set(names)):
            raise ValueError("Duplicate IPA entries")
        for name in names:
            parts = PurePosixPath(name)
            if parts.is_absolute() or ".." in parts.parts or "\\" in name:
                raise ValueError("Unsafe IPA path")
        root = "Payload/GodMode.app/"
        info = plistlib.loads(archive.read(root + "Info.plist"))
        if info.get("CFBundleIdentifier") != bundle_id:
            raise ValueError("Bundle identity mismatch")
        if "iPhoneOS" not in info.get("CFBundleSupportedPlatforms", []):
            raise ValueError("A simulator app cannot become a device IPA")
        executable = info.get("CFBundleExecutable", "")
        if not executable or Path(executable).name != executable or "/" in executable or "\\" in executable:
            raise ValueError("Invalid executable name")
        if root + executable not in names:
            raise ValueError("Missing device executable")
        if require_profile and not all(root + p in names for p in ["embedded.mobileprovision", "_CodeSignature/CodeResources"]):
            raise ValueError("Signed IPA requires profile and signature resources")
    return info


def package_unsigned(app, destination, bundle_id):
    app, destination = Path(app), Path(destination)
    if app.name != "GodMode.app" or not app.is_dir():
        raise ValueError("GodMode device app is missing")
    destination.parent.mkdir(parents=True, exist_ok=True)
    pending = destination.with_suffix(".pending")
    try:
        with zipfile.ZipFile(pending, "w", zipfile.ZIP_DEFLATED) as archive:
            for source in sorted(app.rglob("*")):
                relative = source.relative_to(app)
                # No profiles or stale signatures are passed off as valid in an unsigned artifact.
                if relative.parts[0] in {"embedded.mobileprovision", "_CodeSignature"}:
                    continue
                target = "Payload/GodMode.app/" + relative.as_posix()
                if source.is_symlink():
                    if not source.resolve().is_relative_to(app.resolve()):
                        raise ValueError("Asset symlink escapes app")
                    entry = zipfile.ZipInfo(target)
                    entry.create_system = 3
                    entry.external_attr = (stat.S_IFLNK | 0o777) << 16
                    archive.writestr(entry, os.readlink(source))
                elif source.is_file():
                    archive.write(source, target)
        verify_package(pending, bundle_id)
        pending.replace(destination)
    finally:
        pending.unlink(missing_ok=True)
