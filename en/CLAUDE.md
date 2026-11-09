# CLAUDE.md: en/ (Bishwo.com, English edition)

A Quarto blog project modelled on `../../smroot/blograw` (the Stat Mania blog), built on the
blogkit extension in `_extensions/blogkit/` (copied from smroot; **do not edit it**, update it by copying
from smroot or `quarto-blogkit`).

## Layout

- Sources: `posts/*.qmd` (flat, raw files; no `posts/<name>/index.qmd`), `index.qmd`, `about.qmd`,
  `authors.yml`, `site.css`, `starfield-include.html`, `img/`.
- Output: `read/` (`output-dir: read`). **`index.html` is the exception**: `place_index.py` (post-render)
  moves it to `en/index.html`, prefixes its relative URLs with `read/`, and leaves a redirect at `read/index.html`.
- Posts render flat: `posts/x.qmd` becomes `read/x.html` (not `read/posts/`). `unflatten_posts.py` (pre-render) restores temp copies so Quarto's listing refresh works; `flatten_posts.py` (post-render) moves them up, fixes
  relative URLs, and rewrites `posts/` paths in `blogkit-data.js`, `search.json`, `listings.json`, feeds, sitemap and `index.html`.
- Generated, don't hand-edit: `read/`, `index.html`, `_bk-hero-tools.html`, `authors/*.qmd`, `tags.qmd`, `categories.qmd`.
- Fresh checkout: run `QUARTO_PROJECT_DIR=$PWD python3 _extensions/blogkit/build_site_data.py` once (creates
  `_bk-hero-tools.html`), then `quarto render`. Single post: `quarto render posts/<post>.qmd`.
- Starfield: inlined in `starfield-include.html` (same animation as statmania.info); `site.css` holds the hero/starfield styles.

## Posts

- Name files by topic slug (`major-tectonic-plates.qmd`), never with spaces or question marks.
- Front matter: `title`, `author` (must match a name/alias in `authors.yml`), `date` (real date, `date +%F`),
  `categories` (broad: Earth, Solar System, Stars, Cosmology...), `tags` (lowercase, hyphenated, reuse before inventing),
  `description`, `image`.
- Categories are broad sections, in English only (no Bengali names here). Reuse this list; add one only when a new section is needed:
  - `Earth` (every Earth-science post), `Tectonics` and `Geology` (both on tectonics posts), `Earthquakes` (faults, quakes),
    `Landforms` (oceans, mountains, rifts, valleys), `Regions` (posts about one place, e.g. Turkey, Europe), `Climate` (weather, monsoon, rainfall).
  - Planned sections for the rest of the site: `Solar System`, `Stars`, `Night Sky`, `Cosmology`.
  - Use 2 to 4 per post, never the same set on every post.
- Lists and tables: use real Markdown lists/tables, not pasted bullets or tab-separated text. No raw search-engine links.
- Link related posts to each other with a "Related reading" section; keep a "Sources" section when sources were used.

## Images

- Thumbnail (`image:`): look in `img/` and its subfolders first for a fitting picture (`img/earth`, `img/theory`, `img/mission`, ...).
  Many are from the Bengali site and carry Bengali labels, so don't use those on English posts.
- If nothing fits, draw an SVG (dark tinted background, `<title>`/`<desc>`, a palette different from the latest posts) and make
  the PNG with `python3 svg2og.py img/<name>.svg` (needs cairosvg, pillow). Use the SVG in the body (with `fig-alt` and a caption) and
  the PNG as `image:`, both with the same base name.

## Updating this file

Whenever the user writes "note it" (any case: Note it, NOTE IT, note it), add the rule they just stated to the proper section of this
file (or create a section).
