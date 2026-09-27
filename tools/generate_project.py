#!/usr/bin/env python3
"""Generate the committed native Xcode project with Python's standard library only.

Source files are discovered inside this project. Run after adding/removing Swift files.
This is a build-file generator, not an iOS compiler or a replacement for Xcode validation.
"""
from pathlib import Path
import hashlib
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def identity(name):
    return hashlib.sha256(name.encode()).hexdigest()[:24].upper()


def quoted(value):
    return json.dumps(str(value))


def generate():
    objects = {}
    build = json.loads((ROOT / "Config/build.json").read_text(encoding="utf-8"))

    def obj(name, isa, body):
        key = identity(name)
        objects[key] = f"\t\t{key} = {{isa = {isa}; {body} }};"
        return key

    def refs(values):
        return "(" + ", ".join(values) + ("," if values else "") + ")"

    def settings(values):
        return "{ " + " ".join(f"{key} = {quoted(value)};" for key, value in values.items()) + " }"

    def configs(name, common, debug=None, release=None):
        ids = []
        for config, extra in [("Debug", debug or {}), ("Release", release or {})]:
            ids.append(obj(name + config, "XCBuildConfiguration",
                           f"name = {config}; buildSettings = {settings(common | extra)};"))
        return obj(name + "configs", "XCConfigurationList",
                   f"buildConfigurations = {refs(ids)}; defaultConfigurationIsVisible = 0; defaultConfigurationName = Release;")

    def file_ref(path, kind):
        return obj("file:" + path, "PBXFileReference", f"lastKnownFileType = {kind}; path = {quoted(path)}; sourceTree = \"<group>\";")

    package = obj("package", "XCLocalSwiftPackageReference", 'relativePath = Packages/GodModeCore;')
    target_ids = []
    group_ids = []
    product_ids = []
    target_names = ["GodMode", "GodModeTests", "GodModeUITests"]
    for name in target_names:
        sources = sorted((ROOT / name).rglob("*.swift"))
        file_ids, build_ids = [], []
        for path in sources:
            relative = path.relative_to(ROOT).as_posix()
            file = file_ref(relative, "sourcecode.swift")
            file_ids.append(file)
            build_ids.append(obj("build:" + relative, "PBXBuildFile", f"fileRef = {file};"))
        resources = []
        if name == "GodMode":
            for relative, kind in [
                ("GodMode/Resources/PrivacyInfo.xcprivacy", "text.xml"),
                ("GodMode/Resources/Localizable.xcstrings", "text.json.xcstrings")
            ]:
                file = file_ref(relative, kind)
                file_ids.append(file)
                resources.append(obj("build:" + relative, "PBXBuildFile", f"fileRef = {file};"))
            file_ids.append(file_ref("GodMode/Info.plist", "text.plist.xml"))
        group_ids.append(obj(name + "group", "PBXGroup", f"children = {refs(file_ids)}; name = {name}; sourceTree = \"<group>\";"))
        source_phase = obj(name + "sources", "PBXSourcesBuildPhase", f"buildActionMask = 2147483647; files = {refs(build_ids)}; runOnlyForDeploymentPostprocessing = 0;")
        resource_phase = obj(name + "resources", "PBXResourcesBuildPhase", f"buildActionMask = 2147483647; files = {refs(resources)}; runOnlyForDeploymentPostprocessing = 0;")
        package_products, frameworks = [], []
        if name != "GodModeUITests":
            dependency = obj(name + "core", "XCSwiftPackageProductDependency", f"package = {package}; productName = GodModeCore;")
            package_products.append(dependency)
            frameworks.append(obj(name + "corebuild", "PBXBuildFile", f"productRef = {dependency};"))
        framework_phase = obj(name + "frameworks", "PBXFrameworksBuildPhase", f"buildActionMask = 2147483647; files = {refs(frameworks)}; runOnlyForDeploymentPostprocessing = 0;")
        extension = "app" if name == "GodMode" else "xctest"
        product = obj(name + "product", "PBXFileReference", f"explicitFileType = {'wrapper.application' if extension == 'app' else 'wrapper.cfbundle'}; includeInIndex = 0; path = {name}.{extension}; sourceTree = BUILT_PRODUCTS_DIR;")
        product_ids.append(product)
        common = {
            "PRODUCT_NAME": "$(TARGET_NAME)",
            "PRODUCT_BUNDLE_IDENTIFIER": build["bundleIdentifier"] + ("" if name == "GodMode" else "." + name),
            "CODE_SIGN_STYLE": "Automatic",
            "MARKETING_VERSION": build["version"],
            "CURRENT_PROJECT_VERSION": build["buildNumber"],
            "LD_RUNPATH_SEARCH_PATHS": "$(inherited) @executable_path/Frameworks @loader_path/Frameworks",
            "SWIFT_EMIT_LOC_STRINGS": "YES" if name == "GodMode" else "NO",
        }
        dependencies = []
        if name == "GodMode":
            common |= {"GENERATE_INFOPLIST_FILE": "NO", "INFOPLIST_FILE": "GodMode/Info.plist"}
            product_type = "com.apple.product-type.application"
        else:
            common["GENERATE_INFOPLIST_FILE"] = "YES"
            proxy = obj(name + "proxy", "PBXContainerItemProxy", f"containerPortal = {identity('project')}; proxyType = 1; remoteGlobalIDString = {identity('GodModetarget')}; remoteInfo = GodMode;")
            dependencies.append(obj(name + "dependency", "PBXTargetDependency", f"target = {identity('GodModetarget')}; targetProxy = {proxy};"))
            if name == "GodModeTests":
                common |= {"TEST_HOST": "$(BUILT_PRODUCTS_DIR)/GodMode.app/GodMode", "BUNDLE_LOADER": "$(TEST_HOST)"}
                product_type = "com.apple.product-type.bundle.unit-test"
            else:
                common["TEST_TARGET_NAME"] = "GodMode"
                product_type = "com.apple.product-type.bundle.ui-testing"
        config_list = configs(name, common)
        target_ids.append(obj(name + "target", "PBXNativeTarget",
                              f"buildConfigurationList = {config_list}; buildPhases = {refs([source_phase, framework_phase, resource_phase])}; buildRules = (); dependencies = {refs(dependencies)}; name = {name}; packageProductDependencies = {refs(package_products)}; productName = {name}; productReference = {product}; productType = {quoted(product_type)};"))

    products = obj("products", "PBXGroup", f"children = {refs(product_ids)}; name = Products; sourceTree = \"<group>\";")
    main = obj("main", "PBXGroup", f"children = {refs(group_ids + [products])}; sourceTree = \"<group>\";")
    project_configs = configs("project", {
        "SDKROOT": "iphoneos", "IPHONEOS_DEPLOYMENT_TARGET": build["deploymentTarget"],
        "SUPPORTED_PLATFORMS": "iphoneos iphonesimulator", "TARGETED_DEVICE_FAMILY": "1",
        "SWIFT_VERSION": "6.0", "SWIFT_STRICT_CONCURRENCY": "complete",
        "SWIFT_TREAT_WARNINGS_AS_ERRORS": "YES", "GCC_TREAT_WARNINGS_AS_ERRORS": "YES",
        "CLANG_ENABLE_MODULES": "YES", "CLANG_ENABLE_OBJC_ARC": "YES",
        "CLANG_WARN_DOCUMENTATION_COMMENTS": "YES", "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",
        "GCC_WARN_UNUSED_VARIABLE": "YES", "GCC_WARN_UNUSED_FUNCTION": "YES",
        "ENABLE_USER_SCRIPT_SANDBOXING": "YES", "ALWAYS_SEARCH_USER_PATHS": "NO",
        "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES", "DEVELOPMENT_LANGUAGE": "en",
    }, {
        "SWIFT_OPTIMIZATION_LEVEL": "-Onone", "ENABLE_TESTABILITY": "YES",
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEBUG", "ONLY_ACTIVE_ARCH": "YES",
        "DEBUG_INFORMATION_FORMAT": "dwarf",
    }, {
        "SWIFT_OPTIMIZATION_LEVEL": "-O", "SWIFT_COMPILATION_MODE": "wholemodule",
        "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym", "VALIDATE_PRODUCT": "YES",
    })
    obj("project", "PBXProject",
        f"attributes = {{LastUpgradeCheck = 2600; BuildIndependentTargetsInParallel = YES;}}; buildConfigurationList = {project_configs}; compatibilityVersion = \"Xcode 14.0\"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en, Base); mainGroup = {main}; packageReferences = ({package},); productRefGroup = {products}; projectDirPath = \"\"; projectRoot = \"\"; targets = {refs(target_ids)};")
    directory = ROOT / "GodMode.xcodeproj"
    directory.mkdir(exist_ok=True)
    text = "// !$*UTF8*$!\n{\n\tarchiveVersion = 1;\n\tclasses = {};\n\tobjectVersion = 56;\n\tobjects = {\n"
    text += "\n".join(objects.values()) + f"\n\t}};\n\trootObject = {identity('project')};\n}}\n"
    (directory / "project.pbxproj").write_text(text, encoding="utf-8", newline="\n")
    scheme = ET.Element("Scheme", LastUpgradeVersion="2600", version="1.3")

    def reference(parent, name):
        return ET.SubElement(parent, "BuildableReference", BuildableIdentifier="primary",
                             BlueprintIdentifier=identity(name + "target"),
                             BuildableName=name + (".app" if name == "GodMode" else ".xctest"),
                             BlueprintName=name, ReferencedContainer="container:GodMode.xcodeproj")

    build = ET.SubElement(scheme, "BuildAction", parallelizeBuildables="YES", buildImplicitDependencies="YES")
    entries = ET.SubElement(build, "BuildActionEntries")
    for name in target_names:
        entry = ET.SubElement(entries, "BuildActionEntry", buildForTesting="YES",
                              buildForRunning="YES" if name == "GodMode" else "NO",
                              buildForProfiling="YES" if name == "GodMode" else "NO",
                              buildForArchiving="YES" if name == "GodMode" else "NO",
                              buildForAnalyzing="YES")
        reference(entry, name)
    test = ET.SubElement(scheme, "TestAction", buildConfiguration="Debug", selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB", selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB", shouldUseLaunchSchemeArgsEnv="YES")
    testables = ET.SubElement(test, "Testables")
    for name in target_names[1:]:
        reference(ET.SubElement(testables, "TestableReference", skipped="NO", parallelizable="NO"), name)
    launch = ET.SubElement(scheme, "LaunchAction", buildConfiguration="Debug", selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB", selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB", launchStyle="0", useCustomWorkingDirectory="NO", ignoresPersistentStateOnLaunch="NO", debugDocumentVersioning="YES", debugServiceExtension="internal", allowLocationSimulation="YES")
    reference(ET.SubElement(launch, "BuildableProductRunnable", runnableDebuggingMode="0"), "GodMode")
    profile = ET.SubElement(scheme, "ProfileAction", buildConfiguration="Release", shouldUseLaunchSchemeArgsEnv="YES", savedToolIdentifier="", useCustomWorkingDirectory="NO", debugDocumentVersioning="YES")
    reference(ET.SubElement(profile, "BuildableProductRunnable", runnableDebuggingMode="0"), "GodMode")
    ET.SubElement(scheme, "AnalyzeAction", buildConfiguration="Debug")
    ET.SubElement(scheme, "ArchiveAction", buildConfiguration="Release", revealArchiveInOrganizer="YES")
    ET.indent(scheme)
    path = directory / "xcshareddata/xcschemes/GodMode.xcscheme"
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(ET.tostring(scheme, encoding="UTF-8", xml_declaration=True).decode("utf-8") + "\n", encoding="utf-8", newline="\n")
    print(f"Generated Xcode project: {len(target_names)} targets, {len(objects)} objects")


if __name__ == "__main__":
    generate()
