#!/usr/bin/env python3
"""Pre-render: Quarto's listing refresh reads read/posts/<x>.html for posts not being rendered.
They live flat at read/<x>.html, so put temporary copies back; flatten_posts.py removes them after."""
import os, shutil
from pathlib import Path
root = Path(os.environ.get("QUARTO_PROJECT_DIR") or Path.cwd()).resolve()
out = root / "read"
for q in (root / "posts").glob("*.qmd"):
    if q.name.startswith("_"): continue
    src, dst = out / (q.stem + ".html"), out / "posts" / (q.stem + ".html")
    if src.exists() and not dst.exists():
        dst.parent.mkdir(exist_ok=True); shutil.copyfile(src, dst)
