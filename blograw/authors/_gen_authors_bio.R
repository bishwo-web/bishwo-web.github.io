#!/usr/bin/env Rscript

library(fs)
library(dplyr)
library(stringr)

# 1. Anchor script location
if (!interactive()) {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- "--file="
  script_path <- sub(file_arg, "", args[grep(file_arg, args)])
  if (length(script_path) > 0) setwd(dirname(path_abs(script_path)))
}

authors_csv <- "authors.csv"
posts_csv   <- "../posts/posts.csv"
POSTS_PER_PAGE <- 10  # You can change this number

# 2. Load Data
authors_db <- read.csv(authors_csv, stringsAsFactors = FALSE, encoding = "UTF-8", strip.white = TRUE)
posts_db   <- read.csv(posts_csv, stringsAsFactors = FALSE, encoding = "UTF-8", strip.white = TRUE)

for (i in 1:nrow(authors_db)) {
  auth_name  <- authors_db$name[i]
  auth_id    <- authors_db$id[i]
  auth_img   <- authors_db$image[i]
  auth_web   <- authors_db$web[i]
  auth_bio   <- authors_db$bio[i]

  author_posts <- posts_db %>%
    filter(name == auth_name) %>%
    arrange(desc(date))

  # 3. Build the Post Items with specific Image Fixes
  post_items_html <- if (nrow(author_posts) > 0) {
    post_rows <- lapply(1:nrow(author_posts), function(j) {
      p <- author_posts[j, ]
      # 'paginated-post' class added for the JS to find
      paste0(
        "::: {.author-post-item .paginated-post style='display: flex; gap: 20px; margin-bottom: 25px; border-bottom: 1px solid #eee; padding-bottom: 15px;'}\n",
        # FIXED: width and height set with object-fit to prevent distortion
        "![](", "../posts/", p$image, "){width=160px height=100px style='object-fit: cover; border-radius: 5px; flex-shrink: 0;'}\n",
        "<div>\n",
        "### [", p$title, "](../posts/", str_replace(p$file_path, ".qmd", ".html"), ")\n",
        "*প্রকাশিত: ", p$date, "* \n\n",
        p$description, "\n",
        "</div>\n",
        ":::"
      )
    })
    paste(unlist(post_rows), collapse = "\n\n")
  } else {
    "_এই লেখকের কোনো নিবন্ধ পাওয়া যায়নি।_"
  }

  # 4. Pagination Controls (HTML/JS)
  pagination_controls <- if (nrow(author_posts) > POSTS_PER_PAGE) {
    paste0(
      "\n::: {#pagination-controls style='display: flex; justify-content: center; gap: 10px; margin-top: 20px;'}\n",
      "<button id='prevPage' class='btn btn-outline-primary'>আগের পাতা</button>\n",
      "<span id='pageInfo' style='align-self: center;'></span>\n",
      "<button id='nextPage' class='btn btn-outline-primary'>পরের পাতা</button>\n",
      ":::\n",
      "\n```{=html}\n<script>\ndocument.addEventListener('DOMContentLoaded', function() {\n",
      "  const posts = document.querySelectorAll('.paginated-post');\n",
      "  const perPage = ", POSTS_PER_PAGE, ";\n",
      "  let currentPage = 1;\n",
      "  const totalPages = Math.ceil(posts.length / perPage);\n",
      "\n  function showPage(page) {\n",
      "    posts.forEach((post, index) => {\n",
      "      post.style.display = (index >= (page - 1) * perPage && index < page * perPage) ? 'flex' : 'none';\n",
      "    });\n",
      "    document.getElementById('pageInfo').innerText = `পাতা ${page} / ${totalPages}`;\n",
      "    document.getElementById('prevPage').disabled = (page === 1);\n",
      "    document.getElementById('nextPage').disabled = (page === totalPages);\n",
      "  }\n",
      "\n  document.getElementById('prevPage').addEventListener('click', () => { if(currentPage > 1) showPage(--currentPage); });\n",
      "  document.getElementById('nextPage').addEventListener('click', () => { if(currentPage < totalPages) showPage(++currentPage); });\n",
      "\n  showPage(currentPage);\n});\n</script>\n```\n"
    )
  } else { "" }

# ... (পূর্বের কোড ঠিক থাকবে)

  # ৫. Final QMD Assembly
  # ওয়েবসাইট লিংকের জন্য চেক
  web_info <- if (!is.na(auth_web) && auth_web != "#" && auth_web != "") {
    paste0("**ওয়েব:** [", auth_web, "](http://", auth_web, ")")
  } else { "" }

  qmd_content <- c(
    "---",
    paste0("title: \"", auth_name, "-এর সকল লেখা\""),
    "sidebar: false",
    "---",
    "",
    # লেখক পরিচিতি সেকশন (Callout-tip layout)
    paste0("::: {.callout-tip title=\"লেখক পরিচিতি\"}"),
    paste0("<img src=\"", auth_img, "\" style=\"border-radius: 50%; width: 100px; float: left; margin-right: 20px; object-fit: cover; height: 100px;\">"),
    "",
    paste0("**", auth_name, "** "),
    auth_bio,
    "",
    web_info,
    ":::",
    "",
    "---",
    "",
    "## এই লেখকের সকল নিবন্ধ",
    "",
    post_items_html,
    pagination_controls
  )

  writeLines(qmd_content, paste0(auth_id, ".qmd"), useBytes = TRUE)
}
