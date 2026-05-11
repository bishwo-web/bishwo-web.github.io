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

Let's start over. Any qmd within blograw/authors/ also maintains the layout of the site; only problem is author-specific posts are not listed by listing mechanism of Quarto. So We do the following:

1. Read blograw/posts/posts.csv

its contents are like
"title","name","date","image","categories","tags","description","file_path"
"এ মাসের তারা: রোহিণী","আব্দুল্যাহ আদিল মাহমুদ","2023-09-10","../img/star/aldebaran.jpg","নক্ষত্র, রাতের আকাশ","আকাশ","রাতের আকাশের চতুর্দশ উজ্জ্বল তারার গল্প দিয়ে। নাম রোহিণী। অবস্থান বৃষমণ্ডলে (Taurus)। এ মণ্ডলটা রাশিচক্রের ১২টি (বর্তমানে ১৩টি) মণ্ডলের অন্যতম।","aldebaran.qmd"
"আর্টিমিস ২ পৃথিবী ছেড়ে যায়নি!","আব্দুল্যাহ আদিল মাহমুদ","2026-04-15","../img/mission/artemis-ii-trajectory.jpg","মহাকাশযান, চাঁদ, সৌরজগৎ","চাঁদ, কক্ষপথ","পৃথিবী সূর্যের চারদিকে চলছে সেকেন্ডে ৩০ কিলোমিটার বেগে। ঘণ্টায় ১ লাখ কিলোমিটারের বেশি। তারমানে আর্টিমিস ২ পৃথিবীতে আসতে আসতে পৃথিবী আগের জায়গা থেকে দূরে সরেছে ২ কোটি ১৭ লাখ ৬৬ হাজার কিলোমিটার। অথচ পুরো ভ্রমণপথে যানটি নিজে চলেছে মাত্র প্রায় ১১ লাখ ২৭ হাজার কিলোমিটার পথ। তাহলে পৃথিবীকে ধরার জন্য বাড়তি দূরত্বটা কীভাবে পার হলো?","artemis-did-not-leave.qmd"

2. create one qmd inside blograw/authors for each unique name column (it's author name actually)
3. The qmd will list all the posts by the name.
4. Above the list will be author bio, taken from blograw/authors/authors.csv

Its contents are like
name, id, image, web, bio
আব্দুল্যাহ আদিল মাহমুদ, adil, ../img/site/adil.jpeg, www.thinkermahmud.com, অনলাইন পোর্টাল বিশ্ব ডট কম-এর প্রতিষ্ঠাতা ও সম্পাদক। প্রকাশিত বইয়ের সংখ্যা ছয়টি। ক্যাডেট কলেজে শিক্ষকতা পেশায় নিয়োজিত আছেন।
মোকারম হোসাইন, mokarom, ../img/site/mokarom.png, #, বৈজ্ঞানিক কর্মকর্তা, বিসিএসআইআর। পড়াশোনা করেছেন ঢাকা বিশ্ববিদ্যালয়ে। ছাত্রজীবন থেকেই বিজ্ঞান লেখালেখির সাথে যুক্ত।
নাসরুল্লাহ মাসুদ, nasrullah, ..img/site/nasrullah.jpeg, #, বরেন্দ্র বিশ্ববিদ্যালয়ের শিক্ষক হিসেবে কর্মরত আছেন।

The author file would be named blograw/authors/id.qmd and will have
name, image, website and bio (profile)

Make _gen_authors_bio.R for this.
