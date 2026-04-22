#!/usr/bin/env python3
"""
Build the iOS app icon by compositing the Atmosm logo onto a 1024x1024 navy
background. iOS app icons must be fully opaque (Apple rounds the corners for us).

Usage:
    FIGMA_TOKEN=figd_xxx python3 scripts/build_app_icon.py

The script fetches the logo at a higher scale (4x) for quality, composites it
centered on a 1024x1024 navy square, and writes the result to:
    Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png
"""
from __future__ import annotations

import io
import json
import os
import sys
import urllib.parse
import urllib.request
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
APPICON_DIR = ROOT / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"
FIGMA_FILE_KEY = "g4B1cM6dN528mLXR6PWIWp"
LOGO_NODE_ID = "17:574"
FIGMA_API = "https://api.figma.com/v1"

# Navy brand color (same as AppColor.primaryNavy = #1E3A8A).
NAVY_RGB = (0x1E, 0x3A, 0x8A)

# Icon canvas + logo dimensions.
ICON_SIZE = 1024
LOGO_TARGET_HEIGHT = 680  # leaves breathing room on all sides


def fetch_logo_png(token: str) -> Image.Image:
    ids = urllib.parse.quote(LOGO_NODE_ID)
    url = f"{FIGMA_API}/images/{FIGMA_FILE_KEY}?ids={ids}&scale=4&format=png"
    req = urllib.request.Request(url, headers={"X-Figma-Token": token})
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.loads(r.read().decode("utf-8"))
    if data.get("err"):
        raise RuntimeError(f"Figma error: {data['err']}")
    png_url = data["images"][LOGO_NODE_ID]
    with urllib.request.urlopen(png_url, timeout=60) as r:
        png_bytes = r.read()
    return Image.open(io.BytesIO(png_bytes)).convert("RGBA")


def build_icon(logo: Image.Image) -> Image.Image:
    # Keep aspect ratio; size logo to LOGO_TARGET_HEIGHT.
    ratio = LOGO_TARGET_HEIGHT / logo.height
    new_w = max(1, int(round(logo.width * ratio)))
    resized = logo.resize((new_w, LOGO_TARGET_HEIGHT), Image.LANCZOS)

    # Navy canvas (opaque).
    canvas = Image.new("RGB", (ICON_SIZE, ICON_SIZE), NAVY_RGB)
    # Paste logo centered, using its own alpha channel as mask.
    x = (ICON_SIZE - resized.width) // 2
    y = (ICON_SIZE - resized.height) // 2
    canvas.paste(resized, (x, y), mask=resized.split()[3])
    return canvas


def write_contents_json() -> None:
    contents = {
        "images": [
            {
                "idiom": "universal",
                "filename": "AppIcon.png",
                "platform": "ios",
                "size": "1024x1024"
            }
        ],
        "info": {"author": "xcode", "version": 1}
    }
    (APPICON_DIR / "Contents.json").write_text(json.dumps(contents, indent=2))


def main() -> int:
    token = os.environ.get("FIGMA_TOKEN")
    if not token:
        print("ERROR: FIGMA_TOKEN env var not set.", file=sys.stderr)
        return 2

    APPICON_DIR.mkdir(parents=True, exist_ok=True)

    print("Fetching logo at 4x from Figma...")
    logo = fetch_logo_png(token)
    print(f"  got logo {logo.size}")

    icon = build_icon(logo)
    out = APPICON_DIR / "AppIcon.png"
    icon.save(out, "PNG", optimize=True)
    print(f"Wrote {out.relative_to(ROOT)} ({icon.size})")

    write_contents_json()
    print("Updated Contents.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
