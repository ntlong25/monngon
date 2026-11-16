#!/usr/bin/env python3
"""Chuyển SVG minh họa (docs/research/illustrations) sang PNG @1x/2x/3x cho mobile (T-107, T-108).

Không cần thêm gói nào: dùng Edge hoặc Chrome có sẵn ở chế độ headless để vẽ SVG. SVG gốc vẫn là nguồn,
chạy lại script mỗi khi SVG đổi. Kết quả theo bố cục ảnh nhiều độ phân giải của Flutter:

    mobile/assets/illustrations/<tên>.png        (1x)
    mobile/assets/illustrations/2.0x/<tên>.png   (2x)
    mobile/assets/illustrations/3.0x/<tên>.png   (3x)

Cạnh 1x: hình mục tiêu (goal-*) 240 px (hiện tới 240 dp trên thẻ quẹt), hình dụng cụ (dungcu-*) 128 px.

Dùng:  python tools/svg_to_png.py            (từ thư mục gốc repo)
"""
from __future__ import annotations

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "docs" / "research" / "illustrations"
OUT = ROOT / "mobile" / "assets" / "illustrations"

BROWSERS = [
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "msedge",
    "google-chrome",
    "chromium",
]


def base_size(name: str) -> int:
    return 240 if name.startswith("goal-") else 128


def find_browser() -> str:
    for b in BROWSERS:
        if Path(b).exists() or shutil.which(b):
            return b
    sys.exit("Không tìm thấy Edge/Chrome để vẽ SVG.")


def render(browser: str, svg: Path, size: int, out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        tmp_dir = Path(tmp)
        html = tmp_dir / "page.html"
        html.write_text(
            "<!doctype html><html><head><meta charset='utf-8'><style>"
            "html,body{margin:0;padding:0;background:transparent;overflow:hidden}"
            f"img{{display:block;width:{size}px;height:{size}px}}"
            f"</style></head><body><img src='{svg.as_uri()}'></body></html>",
            encoding="utf-8",
        )
        subprocess.run(
            [
                browser,
                "--headless=new",
                "--disable-gpu",
                "--hide-scrollbars",
                "--force-device-scale-factor=1",
                "--default-background-color=00000000",
                f"--window-size={size},{size}",
                f"--screenshot={out}",
                f"--user-data-dir={tmp_dir / 'profile'}",
                html.as_uri(),
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            timeout=60,
        )


def main() -> None:
    browser = find_browser()
    svgs = sorted(SRC.glob("*.svg"))
    if not svgs:
        sys.exit(f"Không có SVG trong {SRC}")
    for svg in svgs:
        name = svg.stem
        base = base_size(name)
        for scale, folder in ((1, ""), (2, "2.0x"), (3, "3.0x")):
            out = OUT / folder / f"{name}.png"
            render(browser, svg, base * scale, out)
        print(f"{name}: {base}/{base * 2}/{base * 3} px")


if __name__ == "__main__":
    main()
