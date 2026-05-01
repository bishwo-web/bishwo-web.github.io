1. In blograw/posts/post.qmd

---
title: "সেরেস: গ্রহাণু নাকি বামন গ্রহ?"
author:
  - name: "আব্দুল্যাহ আদিল মাহমুদ"
    id: adil
date: "2026-04-25"
image: ../img/solar-system/ceres.jpg
categories: [সৌরজগৎ, বামন গ্রহ, গ্রহ]

so just the author name and id here.


2. In blograw/_authors_db.yml,

author:
  - name: আব্দুল্যাহ আদিল মাহমুদ
    id: adil
    orcid: 0000-0002-1825-0097
    email: example@example.org
    image: ../img/site/adil.jpg # field made up by my me
    desc: author Detailed Info # field made up by my me
author:
  - name: Other
    id: other
    orcid: 0000-0002-1825-0097
    email: other@example.org
    image: ../img/site/other.png
    desc: author Detailed Info

3. Run blograw/gen_authors.R to generate authors dir with adil.qmd, other.qmd (id.qmd) etc inside. These are not quarto listing pages.

They will extract all qmd where name field matches.Each id.qmd will have author image and desc from blograw/authors_db.yml, followed by all the posts listed (image, title, date).

MY output dir is
project:
  type: website
  output-dir: ../
  pre-render:
    - python3 related_posts.py

so author.qmd rendered to author.html should be in "../authors/"

How's this plan?


--
Let's restart.
I have posts dir inside blograw.
In posts, I have many qmd files. In their yaml, one of the fields is
author:
  - name: "আব্দুল্যাহ আদিল মাহমুদ"
    url: "abdullah-adil-mahmud"

I want an R script gen_authors.R to generate a authors.qmd in blograw dir, listing all unique authors with hyperlink to authors/author.qmd. author.qmd part would be taken from url: "abdullah-adil-mahmud".

author.qmd for each author should be a quarto listing like this

---
title: "আব্দুল্যাহ আদিল মাহমুদ-এর সকল লেখা"
sidebar: abdullah-adil-mahmud
listing:
  contents: posts
  categories: true
  type: grid
#  max-items: 6
  feed: true
  sort-ui: true
  filter-ui: true
  sort: "date desc"
  field-display-names:
    title: "আব্দুল্যাহ আদিল মাহমুদ"
  include:
    author: "{আব্দুল্যাহ আদিল মাহমুদ}*"
---
