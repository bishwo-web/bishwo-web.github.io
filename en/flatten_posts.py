#!/usr/bin/env python3
"""Post-render: Quarto writes posts/x.qmd to read/posts/x.html; this project wants read/x.html.
Moves each page (and its x_files dir) up one level, fixes its relative URLs, and rewrites
'posts/x.html' to 'x.html' in the data/feed/search files and in the homepage. Idempotent."""
import os, re, shutil
from pathlib import Path
root = Path(os.environ.get("QUARTO_PROJECT_DIR") or Path.cwd()).resolve()
read, posts = root / "read", root / "read" / "posts"

def up(m):                       # ../x -> x  (one level up from posts/ is read/)
    return f'{m.group(1)}="{m.group(2)}"'

if posts.is_dir():
    for f in list(posts.iterdir()):
        dest = read / f.name
        if f.suffix == ".html":
            h = f.read_text(encoding="utf-8")
            h = re.sub(r'\b(href|src)="\.\./([^"]*)"', up, h)
            h = h.replace('name="quarto:offset" content="../"', 'name="quarto:offset" content="./"')
            h = re.sub(r'\b(href|src)="posts/', lambda m: m.group(1) + '="', h)
            h = re.sub(r'(url\()\.\./', r'\1', h)
            dest.write_text(h, encoding="utf-8"); f.unlink()
        elif f.is_dir():
            if dest.exists(): shutil.rmtree(dest)
            shutil.move(str(f), str(dest))
    if not any(posts.iterdir()):
        posts.rmdir()

pat = re.compile(r'(?:(?<=")|(?<=/read/))posts/(?=[\w.-]+\.html)')
for name in ("blogkit-data.js", "search.json", "listings.json", "sitemap.xml", "index.xml", "index-earth.xml"):
    p = read / name
    if p.exists():
        t = p.read_text(encoding="utf-8"); n = pat.sub("", t)
        if n != t: p.write_text(n, encoding="utf-8")
for p in (root / "index.html",):
    if p.exists():
        t = p.read_text(encoding="utf-8"); n = t.replace("read/./posts/", "read/./").replace("read/posts/", "read/")
        if n != t: p.write_text(n, encoding="utf-8")
