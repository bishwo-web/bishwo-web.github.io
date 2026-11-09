#!/usr/bin/env python3
"""Post-render: move read/index.html to ../en/index.html (this project's root), prefixing its
relative URLs with read/, and leave a redirect at read/index.html so links to it keep working."""
import os, re
from pathlib import Path
root = Path(os.environ.get("QUARTO_PROJECT_DIR") or Path.cwd()).resolve()
src = root / "read" / "index.html"
if not src.exists():
    raise SystemExit(0)
h = src.read_text(encoding="utf-8")
if "http-equiv=\"refresh\"" in h and len(h) < 600:
    raise SystemExit(0)                       # already a redirect
def fix(m):
    return f'{m.group(1)}="read/{m.group(2)}"'
h = re.sub(r'\b(href|src)="(?!https?:|//|#|/|mailto:|data:|javascript:|read/)([^"]*)"', fix, h)
h = h.replace('href="read/./index.html"', 'href="index.html"')
h = h.replace('name="quarto:offset" content="./"', 'name="quarto:offset" content="read/"')
(root / "index.html").write_text(h, encoding="utf-8")
src.write_text('<!doctype html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=../index.html"><link rel="canonical" href="../index.html">\n', encoding="utf-8")
