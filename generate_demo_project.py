#!/usr/bin/env python3
"""Generate GWYogaDemoApp.xcodeproj for iOS visual layout demo.

xcodeproj 放在 GWYoga 根目录（与 Package.swift 同级），
只依赖 GWYogaKit（它自动引入 GWYoga）。
"""

import hashlib, os, textwrap

def uuid(s):
    return hashlib.md5(s.encode()).hexdigest()[:24].upper()

ROOT = "/Users/ltove/Desktop/deepseek/yoga/GWYoga"
OUT  = ROOT  # xcodeproj 放在 GWYoga 根目录

# Source files in GWYoga/GWYogaDemoApp/
SOURCES = [
    "AppDelegate.swift",
    "SceneDelegate.swift",
    "DemoTabBarController.swift",
    "Helpers/YogaLayoutRenderer.swift",
    "Demos/BaseDemoViewController.swift",
    "Demos/FlexboxDemoViewController.swift",
    "Demos/GridDemoViewController.swift",
    "Demos/MarginPaddingDemoViewController.swift",
    "Demos/PositionDemoViewController.swift",
    "Demos/GapDemoViewController.swift",
    "Demos/AspectRatioDemoViewController.swift",
    "Demos/CompositeDemoViewController.swift",
]

# 创建目录
for d in ["GWYogaDemoApp/Demos", "GWYogaDemoApp/Helpers",
          "GWYogaDemoApp.xcodeproj/project.xcworkspace/xcshareddata",
          "GWYogaDemoApp.xcodeproj/xcshareddata/xcschemes",
          "GWYogaDemoApp/Base.lproj"]:
    os.makedirs(f"{OUT}/{d}", exist_ok=True)

# UUIDs
root_uuid           = uuid("root")
main_group_uuid     = uuid("main-group")
products_group_uuid = uuid("products-group")
sources_group_uuid  = uuid("sources-group")
target_uuid         = uuid("app-target")
debug_cfg_uuid      = uuid("debug-cfg")
release_cfg_uuid    = uuid("release-cfg")
cfg_list_uuid       = uuid("cfg-list")
target_cfg_list_uuid= uuid("target-cfg-list")
sources_phase_uuid  = uuid("sources-phase")
frameworks_phase_uuid = uuid("frameworks-phase")
resources_phase_uuid  = uuid("resources-phase")
package_ref_uuid    = uuid("gwyoga-pkg")
product_dep_uuid    = uuid("gwyogakit-product")  # GWYogaKit 产品
gwyoga_dep_uuid     = uuid("gwyoga-product-framework")  # GWYoga 产品（app 直接引用 GWYoga 符号）
product_ref_uuid    = uuid("gwyoga-product-ref")

build_files = {}
file_refs = {}
for s in SOURCES:
    build_files[s] = uuid(f"bf-{s}")
    file_refs[s] = uuid(f"fr-{s}")

gwyogakit_fw_bf = uuid("bf-gwyogakit-fw")
gwyoga_fw_bf = uuid("bf-gwyoga-fw")
plist_ref = uuid("plist")

def write_pbxproj():
    lines = ['// !$*UTF8*$!', '{', 'archiveVersion = 1;', 'objectVersion = 56;', 'objects = {']

    lines.append('/* Begin PBXBuildFile section */')
    for s in SOURCES:
        lines.append(f'{build_files[s]} = {{isa = PBXBuildFile; fileRef = {file_refs[s]}; }};')
    lines.append(f'{gwyogakit_fw_bf} = {{isa = PBXBuildFile; productRef = {product_dep_uuid}; }};')
    lines.append(f'{gwyoga_fw_bf} = {{isa = PBXBuildFile; productRef = {gwyoga_dep_uuid}; }};')
    lines.append('/* End PBXBuildFile section */')

    lines.append('/* Begin PBXFileReference section */')
    for s in SOURCES:
        lines.append(f'{file_refs[s]} = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{s}"; sourceTree = "<group>"; }};')
    lines.append(f'{plist_ref} = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; }};')
    lines.append(f'{product_ref_uuid} = {{isa = PBXFileReference; explicitFileType = "wrapper.application"; includeInIndex = 0; path = GWYogaDemoApp.app; sourceTree = BUILT_PRODUCTS_DIR; }};')
    lines.append('/* End PBXFileReference section */')

    lines.append('/* Begin PBXFrameworksBuildPhase section */')
    lines.append(f'{frameworks_phase_uuid} = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = ({gwyogakit_fw_bf}, {gwyoga_fw_bf}); runOnlyForDeploymentPostprocessing = 0; }};')
    lines.append('/* End PBXFrameworksBuildPhase section */')

    lines.append('/* Begin PBXGroup section */')
    # main group — xcodeproj 在 GWYoga 根目录，source 在 GWYogaDemoApp/ 下
    lines.append(f'{main_group_uuid} = {{isa = PBXGroup; children = ({sources_group_uuid}, {products_group_uuid}); sourceTree = "<group>"; }};')
    lines.append(f'{products_group_uuid} = {{isa = PBXGroup; children = ({product_ref_uuid}); name = Products; sourceTree = "<group>"; }};')
    lines.append(f'{sources_group_uuid} = {{isa = PBXGroup; children = (')
    for s in SOURCES:
        lines.append(f'{file_refs[s]},')
    lines.append(f'{plist_ref},')
    lines.append('); name = Sources; path = GWYogaDemoApp; sourceTree = "<group>"; };')
    lines.append('/* End PBXGroup section */')

    lines.append('/* Begin PBXNativeTarget section */')
    lines.append(f'{target_uuid} = {{isa = PBXNativeTarget; buildConfigurationList = {target_cfg_list_uuid}; buildPhases = ({sources_phase_uuid}, {frameworks_phase_uuid}, {resources_phase_uuid}); buildRules = (); dependencies = (); name = GWYogaDemoApp; packageProductDependencies = ({product_dep_uuid}, {gwyoga_dep_uuid}); productName = GWYogaDemoApp; productReference = {product_ref_uuid}; productType = "com.apple.product-type.application"; }};')
    lines.append('/* End PBXNativeTarget section */')

    lines.append('/* Begin PBXProject section */')
    lines.append(f'{root_uuid} = {{isa = PBXProject; attributes = {{LastSwiftUpdateCheck = 1500; LastUpgradeCheck = 1500; }}; buildConfigurationList = {cfg_list_uuid}; compatibilityVersion = "Xcode 14.0"; developmentRegion = en; hasScannedForEncodings = 0; knownRegions = (en, Base); mainGroup = {main_group_uuid}; packageReferences = ({package_ref_uuid}); productRefGroup = {products_group_uuid}; projectDirPath = ""; targets = ({target_uuid}); }};')
    lines.append('/* End PBXProject section */')

    lines.append('/* Begin PBXResourcesBuildPhase section */')
    lines.append(f'{resources_phase_uuid} = {{isa = PBXResourcesBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};')
    lines.append('/* End PBXResourcesBuildPhase section */')

    lines.append('/* Begin PBXSourcesBuildPhase section */')
    lines.append(f'{sources_phase_uuid} = {{isa = PBXSourcesBuildPhase; buildActionMask = 2147483647; files = (')
    for s in SOURCES:
        lines.append(f'{build_files[s]},')
    lines.append('); runOnlyForDeploymentPostprocessing = 0; };')
    lines.append('/* End PBXSourcesBuildPhase section */')

    lines.append('/* Begin XCBuildConfiguration section */')
    lines.append(f'{debug_cfg_uuid} = {{isa = XCBuildConfiguration; buildSettings = {{ALWAYS_SEARCH_USER_PATHS = NO; CLANG_ENABLE_MODULES = YES; IPHONEOS_DEPLOYMENT_TARGET = 15.0; ONLY_ACTIVE_ARCH = NO; SDKROOT = iphoneos; SWIFT_VERSION = 5.0; }}; name = Debug; }};')
    lines.append(f'{release_cfg_uuid} = {{isa = XCBuildConfiguration; buildSettings = {{ALWAYS_SEARCH_USER_PATHS = NO; CLANG_ENABLE_MODULES = YES; IPHONEOS_DEPLOYMENT_TARGET = 15.0; ONLY_ACTIVE_ARCH = NO; SDKROOT = iphoneos; SWIFT_VERSION = 5.0; }}; name = Release; }};')
    t_debug = uuid("target-debug")
    t_release = uuid("target-release")
    lines.append(f'{t_debug} = {{isa = XCBuildConfiguration; buildSettings = {{ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; CODE_SIGN_STYLE = Automatic; "EXCLUDED_ARCHS[sdk=iphonesimulator*]" = arm64; INFOPLIST_FILE = GWYogaDemoApp/Info.plist; IPHONEOS_DEPLOYMENT_TARGET = 15.0; PRODUCT_BUNDLE_IDENTIFIER = com.gwyoga.demo; PRODUCT_NAME = "$(TARGET_NAME)"; SWIFT_VERSION = 5.0; TARGETED_DEVICE_FAMILY = "1,2"; }}; name = Debug; }};')
    lines.append(f'{t_release} = {{isa = XCBuildConfiguration; buildSettings = {{ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon; CODE_SIGN_STYLE = Automatic; "EXCLUDED_ARCHS[sdk=iphonesimulator*]" = arm64; INFOPLIST_FILE = GWYogaDemoApp/Info.plist; IPHONEOS_DEPLOYMENT_TARGET = 15.0; PRODUCT_BUNDLE_IDENTIFIER = com.gwyoga.demo; PRODUCT_NAME = "$(TARGET_NAME)"; SWIFT_VERSION = 5.0; TARGETED_DEVICE_FAMILY = "1,2"; }}; name = Release; }};')
    lines.append('/* End XCBuildConfiguration section */')

    lines.append('/* Begin XCConfigurationList section */')
    lines.append(f'{cfg_list_uuid} = {{isa = XCConfigurationList; buildConfigurations = ({debug_cfg_uuid}, {release_cfg_uuid}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};')
    lines.append(f'{target_cfg_list_uuid} = {{isa = XCConfigurationList; buildConfigurations = ({t_debug}, {t_release}); defaultConfigurationIsVisible = 0; defaultConfigurationName = Release; }};')
    lines.append('/* End XCConfigurationList section */')

    # XCLocalSwiftPackageReference — 与 Package.swift 同级
    lines.append('/* Begin XCLocalSwiftPackageReference section */')
    lines.append(f'{package_ref_uuid} = {{isa = XCLocalSwiftPackageReference; relativePath = .; }};')
    lines.append('/* End XCLocalSwiftPackageReference section */')

    lines.append('/* Begin XCSwiftPackageProductDependency section */')
    lines.append(f'{product_dep_uuid} = {{isa = XCSwiftPackageProductDependency; productName = GWYogaKit; package = {package_ref_uuid}; }};')
    lines.append(f'{gwyoga_dep_uuid} = {{isa = XCSwiftPackageProductDependency; productName = GWYoga; package = {package_ref_uuid}; }};')
    lines.append('/* End XCSwiftPackageProductDependency section */')

    lines.append('};')
    lines.append(f'rootObject = {root_uuid};')
    lines.append('}')

    return '\n'.join(lines)

# ===== 写入文件 =====

with open(f"{OUT}/GWYogaDemoApp.xcodeproj/project.pbxproj", "w") as f:
    f.write(write_pbxproj())

with open(f"{OUT}/GWYogaDemoApp.xcodeproj/project.xcworkspace/contents.xcworkspacedata", "w") as f:
    f.write('<?xml version="1.0" encoding="UTF-8"?>\n<Workspace version = "1.0">\n</Workspace>\n')

scheme = textwrap.dedent(f'''\
<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1500" version="1.7">
<BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
<BuildActionEntries>
<BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target_uuid}" BuildableName="GWYogaDemoApp.app" BlueprintName="GWYogaDemoApp" ReferencedContainer="container:GWYogaDemoApp.xcodeproj"/>
</BuildActionEntry>
</BuildActionEntries>
</BuildAction>
<TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables/></TestAction>
<LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
<BuildableProductRunnable runnableDebuggingMode="0">
<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target_uuid}" BuildableName="GWYogaDemoApp.app" BlueprintName="GWYogaDemoApp" ReferencedContainer="container:GWYogaDemoApp.xcodeproj"/>
</BuildableProductRunnable>
</LaunchAction>
<ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES">
<BuildableProductRunnable runnableDebuggingMode="0">
<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target_uuid}" BuildableName="GWYogaDemoApp.app" BlueprintName="GWYogaDemoApp" ReferencedContainer="container:GWYogaDemoApp.xcodeproj"/>
</BuildableProductRunnable>
</ProfileAction>
<AnalyzeAction buildConfiguration="Debug"/>
<ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
''')
with open(f"{OUT}/GWYogaDemoApp.xcodeproj/xcshareddata/xcschemes/GWYogaDemoApp.xcscheme", "w") as f:
    f.write(scheme)

info_plist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<key>CFBundleExecutable</key>
<string>$(EXECUTABLE_NAME)</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0</string>
<key>UIApplicationSceneManifest</key>
<dict>
<key>UIApplicationSupportsMultipleScenes</key>
<false/>
<key>UISceneConfigurations</key>
<dict>
<key>UIWindowSceneSessionRoleApplication</key>
<array>
<dict>
<key>UISceneConfigurationName</key>
<string>Default Configuration</string>
<key>UISceneDelegateClassName</key>
<string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
</dict>
</array>
</dict>
</dict>
<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
<key>UIRequiredDeviceCapabilities</key>
<array><string>armv7</string></array>
<key>UISupportedInterfaceOrientations</key>
<array>
<string>UIInterfaceOrientationPortrait</string>
<string>UIInterfaceOrientationLandscapeLeft</string>
<string>UIInterfaceOrientationLandscapeRight</string>
</array>
</dict>
</plist>
'''
with open(f"{OUT}/GWYogaDemoApp/Info.plist", "w") as f:
    f.write(info_plist)

launch_sb = '''<?xml version="1.0" encoding="UTF-8"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="21701" targetRuntime="AppleSDK" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" useTraitCollections="YES" useSafeAreas="YES" colorMatched="YES">
<scenes>
<scene sceneID="01J-lp-oVM">
<objects>
<viewController id="01J-lp-oVM" sceneMemberID="viewController">
<view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
<rect key="frame" x="0.0" y="0.0" width="375" height="812"/>
<autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
<subviews>
<label opaque="NO" clipsSubviews="YES" userInteractionEnabled="NO" contentMode="left" horizontalHuggingPriority="251" verticalHuggingPriority="750" text="GWYoga Demo" textAlignment="center" lineBreakMode="middleTruncation" baselineAdjustment="alignBaselines" minimumFontSize="18" translatesAutoresizingMaskIntoConstraints="NO" id="GJd-Yh-RWb">
<rect key="frame" x="0.0" y="390" width="375" height="32"/>
<fontDescription key="fontDescription" type="system" weight="medium" pointSize="28"/>
<color key="textColor" red="0.0" green="0.0" blue="0.0" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
</label>
</subviews>
<color key="backgroundColor" red="0.94" green="0.94" blue="0.96" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
<constraints><constraint firstItem="GJd-Yh-RWb" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="Q3B-4B-94B"/><constraint firstAttribute="trailing" secondItem="GJd-Yh-RWb" secondAttribute="trailing" id="SVG-6x-vft"/><constraint firstItem="GJd-Yh-RWb" firstAttribute="leading" secondItem="Ze5-6b-2t3" secondAttribute="leading" id="czW-Ln-tS1"/></constraints>
</view>
</viewController>
</objects>
<point key="canvasLocation" x="22" y="88"/>
</scene>
</scenes>
</document>
'''
with open(f"{OUT}/GWYogaDemoApp/Base.lproj/LaunchScreen.storyboard", "w") as f:
    f.write(launch_sb)

# ===== 生成 Demo.xcworkspace（用于正确解析本地 Swift Package）=====
os.makedirs(f"{OUT}/Demo.xcworkspace/xcshareddata/swiftpm/configuration", exist_ok=True)

with open(f"{OUT}/Demo.xcworkspace/contents.xcworkspacedata", "w") as f:
    f.write('''<?xml version="1.0" encoding="UTF-8"?>
<Workspace version = "1.0">
   <FileRef location = "group:GWYogaDemoApp.xcodeproj">
   </FileRef>
   <FileRef location = "group:.">
   </FileRef>
</Workspace>
''')

with open(f"{OUT}/Demo.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings", "w") as f:
    f.write('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEWorkspaceSharedSettings_AutocreateContextsIfNeeded</key>
	<true/>
</dict>
</plist>
''')

with open(f"{OUT}/Demo.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist", "w") as f:
    f.write('''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IDEDidComputeMac32BitWarning</key>
	<true/>
</dict>
</plist>
''')

print(f"✅ Xcode workspace generated at {OUT}/Demo.xcworkspace")
print(f"   只依赖 GWYogaKit（自动引入 GWYoga）")
print(f"   用 Xcode 打开 Demo.xcworkspace 并运行在 iOS 模拟器上")
print(f"   或运行 ./build_and_run_demo.sh 从命令行构建并启动")
