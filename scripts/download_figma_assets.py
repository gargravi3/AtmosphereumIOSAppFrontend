#!/usr/bin/env python3
"""
One-shot Figma asset downloader.

Usage:
    FIGMA_TOKEN=figd_xxx python3 scripts/download_figma_assets.py

Reads scripts/assets_manifest.json, calls the Figma REST API for PNG renders at
1x/2x/3x, and writes each image into Resources/Assets.xcassets/<name>.imageset/
with a matching Contents.json.
"""
from __future__ import annotations

import json
import os
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ASSETS_DIR = ROOT / "Resources" / "Assets.xcassets"
MANIFEST = Path(__file__).resolve().parent / "assets_manifest.json"

FIGMA_FILE_KEY = "g4B1cM6dN528mLXR6PWIWp"
FIGMA_API = "https://api.figma.com/v1"
SCALES = (1, 2, 3)


def log(msg: str) -> None:
    print(msg, flush=True)


def http_get_json(url: str, token: str) -> dict:
    req = urllib.request.Request(url, headers={"X-Figma-Token": token})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode("utf-8"))


def http_download(url: str, dest: Path) -> None:
    with urllib.request.urlopen(url, timeout=60) as r:
        data = r.read()
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(data)


def fetch_image_urls(token: str, node_ids: list[str], scale: int) -> dict[str, str]:
    """Returns {node_id: png_url} for the given scale."""
    ids = ",".join(node_ids)
    url = (
        f"{FIGMA_API}/images/{FIGMA_FILE_KEY}"
        f"?ids={urllib.parse.quote(ids)}&scale={scale}&format=png"
    )
    data = http_get_json(url, token)
    if data.get("err"):
        raise RuntimeError(f"Figma error at scale={scale}: {data['err']}")
    return {nid: u for nid, u in (data.get("images") or {}).items() if u}


def write_contents_json(imageset_dir: Path, name: str) -> None:
    contents = {
        "images": [
            {"idiom": "universal", "filename": f"{name}.png",     "scale": "1x"},
            {"idiom": "universal", "filename": f"{name}@2x.png",  "scale": "2x"},
            {"idiom": "universal", "filename": f"{name}@3x.png",  "scale": "3x"},
        ],
        "info": {"author": "xcode", "version": 1},
    }
    (imageset_dir / "Contents.json").write_text(json.dumps(contents, indent=2))


def main() -> int:
    token = os.environ.get("FIGMA_TOKEN")
    if not token:
        log("ERROR: FIGMA_TOKEN env var not set.")
        return 2

    if not MANIFEST.exists():
        log(f"ERROR: manifest not found: {MANIFEST}")
        return 2

    manifest = json.loads(MANIFEST.read_text())
    entries = manifest["assets"]  # [{"name": "...", "node_id": "..."}, ...]

    node_ids = [e["node_id"] for e in entries]
    by_node = {e["node_id"]: e["name"] for e in entries}

    log(f"Requesting {len(node_ids)} asset(s) at scales {SCALES}...")

    # Figma returns URLs per scale; fetch all three.
    urls_by_scale: dict[int, dict[str, str]] = {}
    for scale in SCALES:
        log(f"  -> scale {scale}x")
        urls_by_scale[scale] = fetch_image_urls(token, node_ids, scale)
        time.sleep(0.2)

    # Download and place files.
    total_ok = 0
    total_missing = 0
    for nid, name in by_node.items():
        imageset = ASSETS_DIR / f"{name}.imageset"
        imageset.mkdir(parents=True, exist_ok=True)
        write_contents_json(imageset, name)

        for scale in SCALES:
            url = urls_by_scale[scale].get(nid)
            suffix = "" if scale == 1 else f"@{scale}x"
            dest = imageset / f"{name}{suffix}.png"
            if not url:
                log(f"    MISSING {name} {scale}x (node {nid}) - no URL returned")
                total_missing += 1
                continue
            http_download(url, dest)
            log(f"    wrote {dest.relative_to(ROOT)}")
            total_ok += 1

    log(f"Done. ok={total_ok} missing={total_missing}")
    return 0 if total_missing == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
