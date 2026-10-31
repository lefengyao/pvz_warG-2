"""Check resource links, layout, UIDs and integrity without relying on Godot's cache."""
from pathlib import Path
import hashlib
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
TEXT = {".gd", ".gdshader", ".tscn", ".tres", ".godot", ".import"}
MEDIA = {".png", ".svg", ".jpg", ".jpeg", ".webp", ".wav", ".mp3", ".ogg", ".ttf", ".otf"}


def verify():
    errors = []
    files = [p for p in ROOT.rglob("*") if p.is_file() and not any(part in {".godot", ".git", ".codex", "__pycache__", "logs"} for part in p.relative_to(ROOT).parts)]
    by_path = {p.relative_to(ROOT).as_posix(): p for p in files}
    uids = {}
    texts = {}
    for rel, p in by_path.items():
        if p.suffix.lower() not in TEXT | {".uid"} or rel.startswith(("tests/", "tools/", "docs/")):
            continue
        content = p.read_text(encoding="utf-8-sig")
        texts[rel] = content
        uid = None
        if p.suffix == ".uid":
            uid = content.strip()
        elif p.suffix in {".tscn", ".tres", ".import"}:
            match = re.search(r'\buid="(uid://[^"\s]+)"', content)
            if match:
                uid = match[1]
        if uid:
            owner = rel.removesuffix(".uid").removesuffix(".import")
            if uid in uids and uids[uid] != owner:
                errors.append(f"Duplicate UID {uid}: {uids[uid]} / {owner}")
            uids[uid] = owner
    links = 0
    for rel, content in texts.items():
        if rel.endswith(".uid"):
            continue
        for match in re.finditer(r'"\*?(res://[^"\r\n]+)"', content):
            target = match[1][6:]
            # Import destination hashes are generated and validated by the editor import.
            if target.startswith(".godot/"):
                continue
            links += 1
            if target not in by_path:
                errors.append(f"Missing or wrong-case resource: {rel} -> {target}")
        for uid in re.findall(r'uid://[a-z0-9]+', content):
            if uid not in uids:
                errors.append(f"Unknown UID: {rel} -> {uid}")
    for legacy in ("Scrips", "UI", "plant", "plants", "maps", "object", "bullet", "zombies", "autoloads"):
        if (ROOT / legacy).exists():
            errors.append(f"Legacy directory still exists: {legacy}")
    for required in ("assets", "src", "scenes", "resources", "docs", "tests", "tools"):
        if not (ROOT / required).is_dir():
            errors.append(f"Required directory missing: {required}")
    manifest_path = ROOT / "docs/maintenance/migration_manifest.json"
    preserved = 0
    preserved_uids = 0
    if not manifest_path.exists():
        errors.append("Migration manifest missing")
    else:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        for old, new in manifest["moves"].items():
            target = ROOT / new
            if not target.is_file():
                errors.append(f"Migration target missing: {old} -> {new}")
                continue
            if target.suffix.lower() in MEDIA | {".uid"}:
                if hashlib.sha256(target.read_bytes()).hexdigest() != manifest["sha256_before"][old]:
                    errors.append(f"Original data changed: {new}")
                else:
                    preserved += 1
        for old, expected in manifest.get("resource_uids_before", {}).items():
            new = manifest["moves"][old]
            content = (ROOT / new).read_text(encoding="utf-8-sig") if (ROOT / new).is_file() else ""
            match = re.search(r'\buid="(uid://[^"\s]+)"', content)
            current = content.strip() if new.endswith(".uid") else match[1] if match else None
            if current != expected:
                errors.append(f"Original UID changed: {new}: {expected} -> {current}")
            else:
                preserved_uids += 1
    summary = {"files": len(files), "resource_links": links, "registered_uids": len(uids), "unchanged_media_and_uid_files": preserved, "preserved_original_uids": preserved_uids, "errors": sorted(set(errors))}
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(verify())
