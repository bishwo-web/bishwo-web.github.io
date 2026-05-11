#!/usr/bin/env Rscript

library(fs)
library(dplyr)
library(stringr)
library(purrr)

# 1. Anchor script to its own directory
if (!interactive()) {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- "--file="
  script_path <- sub(file_arg, "", args[grep(file_arg, args)])
  if (length(script_path) > 0) setwd(dirname(path_abs(script_path)))
}

authors_csv <- "authors.csv"
posts_csv   <- "../posts/posts.csv"

# 2. Data Loading & Cleaning
if (!file_exists(authors_csv)) stop("authors.csv not found!")
if (!file_exists(posts_csv)) stop("posts.csv not found!")

# strip.white handles spaces after commas in CSV
authors_db <- read.csv(authors_csv, stringsAsFactors = FALSE, encoding = "UTF-8", strip.white = TRUE)
posts_db   <- read.csv(posts_csv, stringsAsFactors = FALSE, encoding = "UTF-8", strip.white = TRUE)

# 3. Process each author in the database
for (i in 1:nrow(authors_db)) {
  # Extract author details
  auth_name  <- authors_db$name[i]
  auth_id    <- authors_db$id[i]
  auth_img   <- authors_db$image[i]
  auth_web   <- authors_db$web[i]
  auth_bio   <- authors_db$bio[i]

  # Filter posts for this specific author
  author_posts <- posts_db %>%
    filter(name == auth_name) %>%
    arrange(desc(date))

  # 4. Build the HTML list of posts
  # Note: image and file_path in posts.csv are relative to the posts/ folder.
  # Since the author page is in authors/, we use ../posts/ to reach them.
  post_list_html <- if (nrow(author_posts) > 0) {
    map_chr(1:nrow(author_posts), function(j) {
      p <- author_posts[j, ]
      paste0(
        "::: {.author-post-item style='display: flex; gap: 20px; margin-bottom: 25px; border-bottom: 1px solid #eee; padding-bottom: 15px;'}\n",
        "![](", "../posts/", p$image, "){width=160px style='border-radius: 5px;'}\n",
        "<div>\n",
        "### [", p$title, "](../posts/", str_replace(p$file_path, ".qmd", ".html"), ")\n",
        "*প্রকাশিত: ", p$date, "* \n",
        p$description, "\n",
        "</div>\n",
        ":::"
      )
    }) %>% paste(collapse = "\n\n")
  } else {
    "_এই লেখকের কোনো নিবন্ধ পাওয়া যায়নি।_"
  }

  # 5. Construct the QMD content
  web_link <- if (auth_web != "#" && auth_web != "") {
    paste0("[ওয়েবসাইট](http://", auth_web, ")")
  } else {
    ""
  }

  qmd_content <- c(
    "---",
    paste0("title: \"", auth_name, "\""),
    "sidebar: false",
    "---",
    "",
    "::: {.author-profile-card style='display: flex; gap: 25px; background: #fdfdfd; border: 1px solid #eee; padding: 25px; border-radius: 15px; margin-bottom: 40px;'}",
    paste0("![", auth_name, "](", auth_img, "){width=150px style='border-radius: 50%; object-fit: cover;'}"),
    "<div>",
    paste0("## ", auth_name),
    auth_bio,
    "",
    web_link,
    "</div>",
    ":::",
    "",
    "---",
    "",
    "## এই লেখকের সকল নিবন্ধ",
    "",
    post_list_html
  )

  # 6. Write the file
  output_file <- paste0(auth_id, ".qmd")
  writeLines(qmd_content, output_file, useBytes = TRUE)
  message(paste("✅ Generated profile for:", auth_name))
}
