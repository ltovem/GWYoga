#!/usr/bin/env python3
"""
xcproj.py — GWYoga Xcode Project Manager

同步管理 pbxproj 和 Package.swift，保持一致。
"""

import subprocess, json, re, os, argparse, shutil, sys, tempfile, textwrap, glob
from pathlib import Path

ROOT = Path(__file__).resolve().parent
XCODEPROJ = ROOT / "GWYoga.xcodeproj"
PBXPROJ = XCODEPROJ / "project.pbxproj"
PACKAGE = ROOT / "Package.swift"
SCHEMES = XCODEPROJ / "xcshareddata" / "xcschemes"


# ── helpers ──

def pbx_load() -> dict:
    r = subprocess.run(["plutil", "-convert", "json", "-o", "-", str(PBXPROJ)],
                       capture_output=True, text=True, check=True)
    return json.loads(r.stdout)


def pbx_save(d: dict):
    tmp = tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False)
    json.dump(d, tmp, indent=2, ensure_ascii=False)
    tmp.close()
    subprocess.run(["plutil", "-convert", "ostep", "-o", str(PBXPROJ), tmp.name], check=True)
    os.unlink(tmp.name)


def package_read() -> str:
    with open(PACKAGE) as f:
        return f.read()


def package_write(text: str):
    with open(PACKAGE, "w") as f:
        f.write(text)


def package_target_names(text: str) -> list[str]:
    """Return all target names defined in Package.swift."""
    names = []
    for m in re.finditer(r'\.target\s*\(\s*name:\s*"([^"]+)"', text):
        names.append(m.group(1))
    for m in re.finditer(r'\.testTarget\s*\(\s*name:\s*"([^"]+)"', text):
        names.append(m.group(1))
    return names


def package_product_names(text: str) -> list[str]:
    return re.findall(r'\.library\s*\(\s*name:\s*"([^"]+)"', text)


def pbx_target_names(d: dict) -> dict[str, str]:
    """Return {name: id} for all PBXNativeTarget."""
    result = {}
    for k, v in d["objects"].items():
        if v.get("isa") == "PBXNativeTarget":
            result[v["name"]] = k
    return result


def generate_id(d: dict, prefix: str = "OBJ_") -> str:
    """Generate a unique OBJ_N id."""
    existing = {int(k.split("_")[1]) for k in d["objects"] if k.startswith(prefix) and k.split("_")[1].isdigit()}
    n = 1
    while n in existing:
        n += 1
    return f"{prefix}{n}"


def generate_uuid() -> str:
    """Generate a 24-char hex UUID."""
    import random
    return "".join(random.choices("0123456789ABCDEF", k=24))


# ── workspace commands ──

def cmd_workspace(args):
    name = args.name or "GWYoga"
    ws_dir = ROOT / f"{name}.xcworkspace"
    if args.action == "create":
        if ws_dir.exists():
            print(f"Workspace {ws_dir} already exists.")
            return
        ws_dir.mkdir(parents=True)
        content = textwrap.dedent(f'''\
        <?xml version="1.0" encoding="UTF-8"?>
        <Workspace version="1.0">
           <FileRef location="group:GWYoga.xcodeproj"/>
        </Workspace>
        ''')
        (ws_dir / "contents.xcworkspacedata").write_text(content)
        print(f"Created {ws_dir}")
    elif args.action == "delete":
        if ws_dir.exists():
            shutil.rmtree(ws_dir)
            print(f"Deleted {ws_dir}")
        else:
            print(f"Workspace {ws_dir} not found.")
    else:
        print(f"Unknown action: {args.action}")


# ── target commands ──

def cmd_target(args):
    d = pbx_load()
    text = package_read()

    if args.action == "list":
        pkg_targets = set(package_target_names(text))
        pkg_products = set(package_product_names(text))
        pbx_tgts = pbx_target_names(d)
        all_names = set(pbx_tgts.keys()) | pkg_targets | pkg_products
        print(f"{'Target/Product':<40} {'pbxproj':<10} {'Package.swift':<15}")
        print("-" * 65)
        for name in sorted(all_names):
            in_pbx = "✓" if name in pbx_tgts else ""
            in_pkg = "target" if name in pkg_targets else ("product" if name in pkg_products else "")
            if not in_pbx and not in_pkg:
                continue
            print(f"{name:<40} {in_pbx:<10} {in_pkg:<15}")
        return

    elif args.action == "add":
        name = args.name
        ttype = args.type or "library"  # library, app
        lang = args.lang or "swift"     # swift, objc

        if not name:
            print("--name is required")
            return

        # ── Add to Package.swift for library targets ──
        if ttype == "library":
            path_str = args.path or f"Sources/{name}"
            target_template = textwrap.dedent(f'''\

                // ── {name} ──
                .target(
                    name: "{name}",
                    dependencies: [{','.join(f'"{d}"' for d in (args.depends or []))}],
                    path: "{path_str}"
                ),
            ''')
            # Insert before the last closing bracket of targets array
            # Find the targets array end
            last_target_idx = text.rfind("\n    ]\n)")
            if last_target_idx == -1:
                print("Cannot find targets array end in Package.swift")
                return
            text = text[:last_target_idx] + target_template + text[last_target_idx+1:]

            # Add product
            product_template = textwrap.dedent(f'''\
            .library(name: "{name}", targets: ["{name}"]),
            ''')
            # Insert before the last product
            products_end = text.rfind("\n    ],\n    targets:")
            if products_end == -1:
                # Try alternate pattern
                products_end = text.find("\n    targets: [")
                insert_point = text.rfind("\n", 0, products_end - 5) + 1 if products_end >= 5 else len(text)
            else:
                insert_point = text.rfind("\n    ", 0, products_end) + 1

            text = text[:insert_point] + product_template + text[insert_point:]
            package_write(text)
            print(f"Added target '{name}' to Package.swift. Regenerating xcodeproj…")
            subprocess.run(["swift", "package", "generate-xcodeproj"], cwd=ROOT,
                           capture_output=True, text=True)
            print(f"Done. Target '{name}' added to both Package.swift and xcodeproj.")

        elif ttype == "app":
            path_str = args.path or name
            print(f"Adding app target '{name}' to pbxproj (not applicable for SPM)…")
            # TODO: full app target creation in pbxproj
            print("App target creation in pbxproj not yet implemented.")

    elif args.action == "delete":
        name = args.name
        if not name:
            print("--name is required")
            return

        # Remove from Package.swift
        # Remove target block
        text = re.sub(
            r'\n\s*// ── ' + re.escape(name) + r' ──\n.*?\.target\(\s*name:\s*"' + re.escape(name) + r'"[^)]*\)\s*,',
            "", text, flags=re.DOTALL
        )
        # Remove testTarget block
        text = re.sub(
            r'\n\s*// ── ' + re.escape(name) + r' ──\n.*?\.testTarget\(\s*name:\s*"' + re.escape(name) + r'"[^)]*\)\s*,',
            "", text, flags=re.DOTALL
        )
        # Remove product entry
        text = re.sub(
            r'\n\s*\.library\(\s*name:\s*"' + re.escape(name) + r'"[^)]*\)\s*,',
            "", text
        )
        package_write(text)

        # Remove from pbxproj
        targets = pbx_target_names(d)
        if name in targets:
            tid = targets[name]
            obj = d["objects"].get(tid, {})
            # Remove build phases references
            for phase_ref in obj.get("buildPhases", []):
                phase = d["objects"].get(phase_ref, {})
                if "files" in phase:
                    for fid in phase["files"]:
                        d["objects"].pop(fid, None)
                d["objects"].pop(phase_ref, None)
            # Remove build config list
            bcl = obj.get("buildConfigurationList")
            if bcl:
                bcl_obj = d["objects"].get(bcl, {})
                for cref in bcl_obj.get("buildConfigurations", []):
                    d["objects"].pop(cref, None)
                d["objects"].pop(bcl, None)
            d["objects"].pop(tid, None)
            print(f"Removed target '{name}' from pbxproj.")

        # Regenerate xcodeproj for clean state
        subprocess.run(["swift", "package", "generate-xcodeproj"], cwd=ROOT,
                       capture_output=True, text=True)
        print(f"Target '{name}' deleted and xcodeproj regenerated.")

    else:
        print(f"Unknown action: {args.action}")


# ── add files ──

def cmd_add(args):
    d = pbx_load()
    targets = pbx_target_names(d)
    target_id = targets.get(args.target)
    if not target_id:
        print(f"Target '{args.target}' not found in pbxproj. Available: {list(targets.keys())}")
        return

    files = args.files
    group_path = args.group or ""

    obj = d["objects"]
    target = obj[target_id]

    # Find Sources build phase
    src_phase_id = None
    for pid in target.get("buildPhases", []):
        p = obj.get(pid, {})
        if p.get("isa") == "PBXSourcesBuildPhase":
            src_phase_id = pid
            break
    if not src_phase_id:
        print("No PBXSourcesBuildPhase found for this target.")
        return

    src_phase = obj[src_phase_id]

    # Find or create source group
    main_group = obj[obj[d["rootObject"]]["mainGroup"]]
    source_group = _find_or_create_group(obj, main_group, group_path)

    # Find the target's product reference group for file refs
    products_group_id = None
    for cid in main_group.get("children", []):
        c = obj.get(cid, {})
        if c.get("name") == "Products" or c.get("path") == "Products":
            products_group_id = cid
            break

    added = []
    for f in files:
        fp = Path(f)
        ext = fp.suffix.lower()

        # For ObjC files, ensure .h/.m pairing
        if ext == ".h":
            m_file = fp.with_suffix(".m")
            if m_file.exists() and str(m_file) not in files:
                files.append(str(m_file))

    for f in files:
        fp = Path(f)
        if not fp.exists():
            print(f"Warning: {f} not found, skipping")
            continue

        rel = str(fp.as_posix())
        ext = fp.suffix.lower()

        # Create file reference
        file_ref_id = generate_id(d)
        obj[file_ref_id] = {
            "isa": "PBXFileReference",
            "path": fp.name,
            "sourceTree": "<group>",
        }
        if ext in (".swift", ".m", ".mm", ".cpp", ".c"):
            obj[file_ref_id]["lastKnownFileType"] = "sourcecode.{}.{}".format(
                "swift" if ext == ".swift" else "c" if ext == ".c" else "cpp",
                ext.lstrip(".")
            )
        elif ext in (".h", ".hpp"):
            obj[file_ref_id]["lastKnownFileType"] = "sourcecode.c.h"
        elif ext == ".storyboard":
            obj[file_ref_id]["lastKnownFileType"] = "file.storyboard"
        elif ext == ".xib":
            obj[file_ref_id]["lastKnownFileType"] = "file.xib"
        elif ext == ".plist":
            obj[file_ref_id]["lastKnownFileType"] = "text.plist.xml"

        # Add to group
        if "children" not in source_group:
            source_group["children"] = []
        source_group["children"].append(file_ref_id)

        # Create PBXBuildFile (only for compilable files)
        if ext in (".swift", ".m", ".mm", ".cpp", ".c"):
            build_id = generate_id(d)
            obj[build_id] = {
                "isa": "PBXBuildFile",
                "fileRef": file_ref_id,
            }
            src_phase.setdefault("files", []).append(build_id)
        elif ext == ".h":
            # Header files: add as PBXBuildFile for public/private headers
            build_id = generate_id(d)
            obj[build_id] = {
                "isa": "PBXBuildFile",
                "fileRef": file_ref_id,
                "settings": {"ATTRIBUTES": ["Public"]}
            }
            # Add to Headers build phase if exists
            hdr_phase_id = None
            for pid in target.get("buildPhases", []):
                p = obj.get(pid, {})
                if p.get("isa") == "PBXHeadersBuildPhase":
                    hdr_phase_id = pid
                    break
            if hdr_phase_id:
                obj[hdr_phase_id].setdefault("files", []).append(build_id)

        added.append(f)

    pbx_save(d)
    print(f"Added {len(added)} file(s) to target '{args.target}':")
    for a in added:
        print(f"  + {a}")


def _find_or_create_group(obj: dict, parent: dict, path: str) -> dict:
    """Find or create a group hierarchy from a path like 'Core/Swift'."""
    if not path:
        return parent
    parts = path.split("/")
    current = parent
    for part in parts:
        found = False
        for cid in current.get("children", []):
            c = obj.get(cid, {})
            if c.get("isa") in ("PBXGroup", "PBXVariantGroup") and c.get("name") == part:
                current = c
                found = True
                break
        if not found:
            gid = generate_id(obj)
            obj[gid] = {
                "isa": "PBXGroup",
                "name": part,
                "sourceTree": "<group>",
                "children": [],
            }
            current.setdefault("children", []).append(gid)
            current = obj[gid]
    return current


# ── remove files ──

def cmd_remove(args):
    d = pbx_load()
    targets = pbx_target_names(d)
    target_id = targets.get(args.target)
    if not target_id:
        print(f"Target '{args.target}' not found.")
        return

    obj = d["objects"]
    target = obj[target_id]
    files = args.files

    # Collect all file refs and build files to remove
    refs_to_remove = set()
    builds_to_remove = set()
    for f in files:
        ref_id = _find_file_ref(obj, f, target)
        if ref_id:
            refs_to_remove.add(ref_id)

    # Find build files referencing these refs
    for k, v in obj.items():
        if v.get("isa") == "PBXBuildFile" and v.get("fileRef") in refs_to_remove:
            builds_to_remove.add(k)

    # Remove from build phases
    for pid in target.get("buildPhases", []):
        phase = obj.get(pid, {})
        if "files" in phase:
            phase["files"] = [fid for fid in phase["files"] if fid not in builds_to_remove]

    # Remove from groups
    for k, v in obj.items():
        if v.get("isa") in ("PBXGroup",) and "children" in v:
            v["children"] = [c for c in v["children"] if c not in refs_to_remove]

    # Remove objects
    for rid in refs_to_remove:
        obj.pop(rid, None)
    for bid in builds_to_remove:
        obj.pop(bid, None)

    pbx_save(d)
    print(f"Removed {len(files)} file(s) from target '{args.target}'.")


def _find_file_ref(obj: dict, filename: str, target: dict):  # -> str | None
    """Find a PBXFileReference by filename in the project."""
    for k, v in obj.items():
        if v.get("isa") == "PBXFileReference" and v.get("path") == filename:
            return k
    return None


# ── dependency command ──

def cmd_dependency(args):
    d = pbx_load()
    targets = pbx_target_names(d)
    text = package_read()

    if args.action == "add":
        target_name = args.target
        dep_name = args.depends

        if not target_name or not dep_name:
            print("--target and --depends are required")
            return

        # Add to Package.swift
        # Find the target's dependency list and add the dependency
        pattern = rf'(\.target\(\s*name:\s*"{re.escape(target_name)}"[^)]*?dependencies:\s*\[)([^\]]*)(\])'
        m = re.search(pattern, text, re.DOTALL)
        if m:
            existing_deps = m.group(2).strip()
            if f'"{dep_name}"' not in existing_deps:
                sep = ", " if existing_deps else ""
                old = m.group(0)
                new = m.group(1) + existing_deps + sep + f'"{dep_name}"' + m.group(3)
                text = text.replace(old, new)
                package_write(text)
                print(f"Added dependency '{dep_name}' to target '{target_name}' in Package.swift.")
        else:
            print(f"Could not find target '{target_name}' in Package.swift.")

        # Add to pbxproj
        if dep_name in targets and target_name in targets:
            tid = targets[target_name]
            did = targets[dep_name]
            tobj = d["objects"].get(tid, {})
            existing_deps = tobj.get("dependencies", [])
            # Check if already exists
            already = False
            for dep_ref in existing_deps:
                dep_obj = d["objects"].get(dep_ref, {})
                if dep_obj.get("isa") == "PBXTargetDependency" and dep_obj.get("name") == dep_name:
                    already = True
                    break
            if not already:
                dep_id = generate_id(d)
                d["objects"][dep_id] = {
                    "isa": "PBXTargetDependency",
                    "name": dep_name,
                    "target": did,
                }
                tobj.setdefault("dependencies", []).append(dep_id)
                pbx_save(d)
                print(f"Added dependency '{dep_name}' in pbxproj.")
            else:
                print(f"Dependency '{dep_name}' already exists in pbxproj.")

        # Regenerate
        subprocess.run(["swift", "package", "generate-xcodeproj"], cwd=ROOT,
                       capture_output=True, text=True)
        print("xcodeproj regenerated.")

    elif args.action == "remove":
        target_name = args.target
        dep_name = args.depends
        if not target_name or not dep_name:
            print("--target and --depends are required")
            return

        # Remove from Package.swift
        pattern = rf'(\.target\(\s*name:\s*"{re.escape(target_name)}"[^)]*?dependencies:\s*\[)([^\]]*?)(\]])'
        m = re.search(pattern, text, re.DOTALL)
        if m:
            deps = m.group(2)
            deps = re.sub(rf',?\s*"{re.escape(dep_name)}"', "", deps)
            deps = re.sub(rf'"{re.escape(dep_name)}"\s*,?', "", deps)
            old = m.group(0)
            new = m.group(1) + deps + m.group(3)
            text = text.replace(old, new)
            package_write(text)
            print(f"Removed dependency '{dep_name}' from target '{target_name}' in Package.swift.")

        # Remove from pbxproj
        if target_name in targets:
            tid = targets[target_name]
            tobj = d["objects"].get(tid, {})
            to_remove = []
            for dep_ref in tobj.get("dependencies", []):
                dep_obj = d["objects"].get(dep_ref, {})
                if dep_obj.get("name") == dep_name:
                    to_remove.append(dep_ref)
            for rid in to_remove:
                tobj["dependencies"].remove(rid)
                d["objects"].pop(rid, None)
            pbx_save(d)
            print(f"Removed dependency in pbxproj.")

        subprocess.run(["swift", "package", "generate-xcodeproj"], cwd=ROOT,
                       capture_output=True, text=True)
        print("xcodeproj regenerated.")

    else:
        print(f"Unknown action: {args.action}")


# ── config command ──

def cmd_config(args):
    d = pbx_load()
    targets = pbx_target_names(d)
    target_id = targets.get(args.target)
    if not target_id:
        print(f"Target '{args.target}' not found.")
        return

    obj = d["objects"]
    target = obj[target_id]
    bcl_id = target.get("buildConfigurationList")
    if not bcl_id:
        print("No build config list found.")
        return

    conf_list = obj.get(bcl_id, {})
    for conf_id in conf_list.get("buildConfigurations", []):
        conf = obj.get(conf_id, {})
        if conf.get("name") == args.config or not args.config:
            settings = conf.setdefault("buildSettings", {})
            if args.action == "set":
                settings[args.key] = args.value
                print(f"Set {args.key}={args.value} in {conf.get('name')}")
            elif args.action == "unset":
                settings.pop(args.key, None)
                print(f"Unset {args.key} in {conf.get('name')}")

    pbx_save(d)


# ── info command ──

def cmd_info(args):
    """Generate Info.plist for a target."""
    name = args.name
    ttype = args.type or "APPL"
    bundle_id = args.bundle_id or f"com.gwyoga.{name}"

    info = textwrap.dedent(f'''\
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleExecutable</key>
        <string>$(EXECUTABLE_NAME)</string>
        <key>CFBundleIdentifier</key>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>{name}</string>
        <key>CFBundlePackageType</key>
        <string>{ttype}</string>
        <key>CFBundleShortVersionString</key>
        <string>1.0</string>
        <key>CFBundleVersion</key>
        <string>1</string>
        <key>LSRequiresIPhoneOS</key>
        <true/>
        <key>UILaunchScreen</key>
        <dict/>
        <key>UIRequiredDeviceCapabilities</key>
        <array><string>armv7</string></array>
        <key>UISupportedInterfaceOrientations</key>
        <array>
            <string>UIInterfaceOrientationPortrait</string>
        </array>
        {f"<key>CFBundleDisplayName</key><string>{name}</string>" if args.display_name else ""}
    </dict>
    </plist>
    ''')

    out = args.output or f"{name}/Info.plist"
    Path(out).parent.mkdir(parents=True, exist_ok=True)
    Path(out).write_text(info)
    print(f"Info.plist written to {out}")


# ── scheme command ──

def cmd_scheme(args):
    if args.action == "create":
        name = args.name
        SCHEMES.mkdir(parents=True, exist_ok=True)
        scheme_path = SCHEMES / f"{name}.xcscheme"
        if scheme_path.exists():
            print(f"Scheme '{name}' already exists.")
            return

        d = pbx_load()
        targets = pbx_target_names(d)
        tid = targets.get(name)
        if not tid:
            print(f"Target '{name}' not found in pbxproj.")
            return

        # Generate a minimal scheme
        scheme = textwrap.dedent(f'''\
        <?xml version="1.0" encoding="UTF-8"?>
        <Scheme version="1.7">
           <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
              <BuildActionEntries>
                 <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
                    <BuildableReference
                       BuildableIdentifier="primary"
                       BlueprintIdentifier="{tid}"
                       BuildableName="{name}"
                       BlueprintName="{name}"
                       ReferencedContainer="container:GWYoga.xcodeproj">
                    </BuildableReference>
                 </BuildActionEntry>
              </BuildActionEntries>
           </BuildAction>
           <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
              <Testables>
              </Testables>
           </TestAction>
           <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
              <BuildableProductRunnable runnableDebuggingMode="0">
                 <BuildableReference
                    BuildableIdentifier="primary"
                    BlueprintIdentifier="{tid}"
                    BuildableName="{name}"
                    BlueprintName="{name}"
                    ReferencedContainer="container:GWYoga.xcodeproj">
                 </BuildableReference>
              </BuildableProductRunnable>
           </LaunchAction>
           <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES">
              <BuildableProductRunnable runnableDebuggingMode="0">
                 <BuildableReference
                    BuildableIdentifier="primary"
                    BlueprintIdentifier="{tid}"
                    BuildableName="{name}"
                    BlueprintName="{name}"
                    ReferencedContainer="container:GWYoga.xcodeproj">
                 </BuildableReference>
              </BuildableProductRunnable>
           </ProfileAction>
           <AnalyzeAction buildConfiguration="Debug">
           </AnalyzeAction>
           <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES">
           </ArchiveAction>
        </Scheme>
        ''')
        scheme_path.write_text(scheme)
        print(f"Scheme '{name}' created at {scheme_path}")

    elif args.action == "delete":
        name = args.name
        scheme_path = SCHEMES / f"{name}.xcscheme"
        if scheme_path.exists():
            scheme_path.unlink()
            print(f"Scheme '{name}' deleted.")
        else:
            print(f"Scheme '{name}' not found.")
    else:
        print(f"Unknown action: {args.action}")


# ── verify command ──

def cmd_verify(_args):
    """Check consistency between pbxproj and Package.swift."""
    d = pbx_load()
    text = package_read()
    issues = []

    pbx_names = set(pbx_target_names(d).keys())
    pkg_names = set(package_target_names(text)) | set(package_product_names(text))

    # Check for targets in pbxproj but not in Package.swift
    for name in pbx_names:
        if name not in pkg_names and name != "GWYogaPackageDescription":
            issues.append(f"Target '{name}' in pbxproj but not in Package.swift")

    # Check for targets in Package.swift but not in pbxproj
    for name in pkg_names:
        if name not in pbx_names:
            issues.append(f"Target/product '{name}' in Package.swift but not in pbxproj")

    if issues:
        print(f"Found {len(issues)} inconsistency(ies):")
        for i in issues:
            print(f"  ⚠ {i}")
    else:
        print("✓ pbxproj and Package.swift are in sync.")

    # Check Sources and Tests paths exist
    for name in pkg_names:
        # Try to match target -> path mapping
        for m in re.finditer(r'\.target\s*\(\s*name:\s*"' + re.escape(name) + r'"[^)]*path:\s*"([^"]+)"', text):
            p = m.group(1)
            if not (ROOT / p).exists():
                issues.append(f"Path '{p}' for target '{name}' does not exist")

    if not issues:
        print("✓ All target paths exist.")
    return 1 if issues else 0


# ── sync command: regenerate xcodeproj from Package.swift ──

def cmd_sync(_args):
    print("Regenerating xcodeproj from Package.swift…")
    r = subprocess.run(["swift", "package", "generate-xcodeproj"], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode == 0:
        print("✓ xcodeproj regenerated.")
    else:
        print(f"Error: {r.stderr}")
    return r.returncode


# ── main ──

def main():
    parser = argparse.ArgumentParser(
        prog="xcproj.py",
        description="GWYoga Xcode Project Manager — 同步管理 pbxproj + Package.swift",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent("""\
            Examples:
              python3 xcproj.py target --list
              python3 xcproj.py target --add GWYogaDemo --type app --lang swift
              python3 xcproj.py target --delete GWYogaDemo
              python3 xcproj.py add --target GWYogaKit --files Foo.swift --group Core
              python3 xcproj.py remove --target GWYogaKit --files Foo.swift
              python3 xcproj.py dependency --add --target GWYogaDemo --depends GWYogaKit
              python3 xcproj.py config --set --target GWYogaDemo --key IPHONEOS_DEPLOYMENT_TARGET --value 15.0
              python3 xcproj.py info --name GWYogaDemo --type APPL
              python3 xcproj.py scheme --create GWYogaDemo
              python3 xcproj.py workspace --create GWYoga
              python3 xcproj.py verify
              python3 xcproj.py sync
        """)
    )
    subparsers = parser.add_subparsers(dest="command")

    # target
    tp = subparsers.add_parser("target", help="Manage targets")
    tp.add_argument("action", choices=["list", "add", "delete"])
    tp.add_argument("--name", "-n", help="Target name")
    tp.add_argument("--type", choices=["library", "app"], default="library", help="Target type")
    tp.add_argument("--lang", choices=["swift", "objc"], default="swift", help="Language")
    tp.add_argument("--path", help="Source path (default: Sources/<name>)")
    tp.add_argument("--depends", nargs="*", default=[], help="Dependencies")

    # add
    ap = subparsers.add_parser("add", help="Add files to a target")
    ap.add_argument("--target", "-t", required=True, help="Target name")
    ap.add_argument("--files", "-f", nargs="+", required=True, help="Files to add")
    ap.add_argument("--group", "-g", default="", help="Group path (e.g. Core/Swift)")

    # remove
    rp = subparsers.add_parser("remove", help="Remove files from a target")
    rp.add_argument("--target", "-t", required=True, help="Target name")
    rp.add_argument("--files", "-f", nargs="+", required=True, help="Files to remove")

    # dependency
    dp = subparsers.add_parser("dependency", help="Manage target dependencies")
    dp.add_argument("action", choices=["add", "remove"])
    dp.add_argument("--target", "-t", required=True, help="Target name")
    dp.add_argument("--depends", "-d", required=True, help="Dependency target name")

    # config
    cp = subparsers.add_parser("config", help="Manage build settings")
    cp.add_argument("action", choices=["set", "unset"])
    cp.add_argument("--target", "-t", required=True, help="Target name")
    cp.add_argument("--key", "-k", required=True, help="Build setting key")
    cp.add_argument("--value", "-v", help="Build setting value")
    cp.add_argument("--config", "-c", default="", help="Config name (Debug/Release), empty=all")

    # info
    ip = subparsers.add_parser("info", help="Generate Info.plist")
    ip.add_argument("--name", "-n", required=True, help="Target/bundle name")
    ip.add_argument("--type", choices=["APPL", "FMWK", "BNDL"], default="APPL")
    ip.add_argument("--bundle-id", help="Bundle identifier")
    ip.add_argument("--display-name", help="Display name")
    ip.add_argument("--output", "-o", help="Output path (default: <name>/Info.plist)")

    # scheme
    sp = subparsers.add_parser("scheme", help="Manage schemes")
    sp.add_argument("action", choices=["create", "delete"])
    sp.add_argument("--name", "-n", required=True, help="Scheme/target name")

    # workspace
    wp = subparsers.add_parser("workspace", help="Manage workspaces")
    wp.add_argument("action", choices=["create", "delete"])
    wp.add_argument("--name", "-n", default="GWYoga", help="Workspace name")

    # verify
    subparsers.add_parser("verify", help="Check pbxproj <-> Package.swift consistency")

    # sync
    subparsers.add_parser("sync", help="Regenerate xcodeproj from Package.swift")

    args = parser.parse_args()

    cmds = {
        "workspace": cmd_workspace,
        "target": cmd_target,
        "add": cmd_add,
        "remove": cmd_remove,
        "dependency": cmd_dependency,
        "config": cmd_config,
        "info": cmd_info,
        "scheme": cmd_scheme,
        "verify": cmd_verify,
        "sync": cmd_sync,
    }

    if args.command in cmds:
        cmds[args.command](args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
