#!/usr/bin/env Rscript

library(yaml)
library(fs)
library(stringr)
library(dplyr)
library(purrr)

# 1. Setup paths relative to script location
# Since the script is inside posts/, the current directory (.) is the target
if (!interactive()) {
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- "--file="
  script_path <- sub(file_arg, "", args[grep(file_arg, args)])
  if (length(script_path) > 0) setwd(dirname(path_abs(script_path)))
}

output_file <- "posts.csv"
message(paste("Working in:", getwd()))

# 2. Get all .qmd files in the current folder
qmd_files <- dir_ls(".", glob = "*.qmd")
message(paste("Processing", length(qmd_files), "files..."))

# 3. Extract and flatten data
posts_df <- map_df(qmd_files, function(file) {
  content <- readLines(file, encoding = "UTF-8", warn = FALSE)
  yaml_indices <- which(content == "---")

  if (length(yaml_indices) < 2) return(NULL)

  # Parse YAML block
  yaml_block <- content[(yaml_indices[1] + 1):(yaml_indices[2] - 1)]
  header <- tryCatch(yaml.load(paste(yaml_block, collapse = "\n")), error = function(e) NULL)

  if (is.null(header)) return(NULL)

  # Process Author: Fetch only the first name string
  author_name <- if (is.list(header$author)) {
    if (!is.null(header$author[[1]]$name)) header$author[[1]]$name else header$author[[1]]
  } else {
    header$author
  }

  # Process Categories and Tags: Join into a single comma-separated string
  collapse_list <- function(x) {
    if (is.null(x)) return("")
    paste(unlist(x), collapse = ", ")
  }

  # Build the row
  tibble(
    title       = as.character(header$title %||% ""),
    name        = as.character(author_name %||% ""),
    date        = as.character(header$date %||% ""),
    image       = as.character(header$image %||% ""),
    categories  = collapse_list(header$categories),
    tags        = collapse_list(header$tags),
    description = as.character(header$description %||% ""),
    file_path   = path_file(file)
  )
})

# 4. Save to CSV
if (nrow(posts_df) > 0) {
  write.csv(posts_df, output_file, row.names = FALSE, fileEncoding = "UTF-8")
  message(paste("🚀 Success! Created:", path_abs(output_file)))
} else {
  message("❌ No data found to write.")
}
