library(tidyverse)
library(fs)
library(RegistersClientR)
library(here)

extract_fields <- function(rsf_path) {
  # This is a hack.
  # The correct way is to take lines like the following
  # append-entry	system	field:jobcentre	2018-02-19T13:57:54Z	sha-256:3ea6c1136b57da474702a10e6145d8bf04e57877142850f1ed092a31171c6f9e
  rsf <- read_lines(rsf_path)
  field_rsf <- rsf[str_detect(rsf, "\"field\":")]
  field_names <- str_extract(field_rsf, "(?<=\"field\":\")[a-z-]+(?=\")")
  field_descriptions <- str_extract(field_rsf, "(?<=\"text\":\").+(?=\")")
  field_datatypes <- str_extract(field_rsf, "(?<=\"datatype\":\")[a-z-]+(?=\")")
  field_cardinalities <- str_extract(field_rsf, "(?<=\"cardinality\":\")[1n](?=\")")
  tibble(field_name = field_names,
         field_description = field_descriptions,
         field_datatype = field_datatypes,
         field_cardinality = field_cardinalities)
}

dir_create(here("rsf", c("beta", "alpha", "discovery")))

registers <-
  bind_rows(rr_records("register", "beta"),
            rr_records("register", "alpha")) %>%
  select(register, phase) %>%
  mutate(url = paste0("https://", register, ".register.gov.uk/download-rsf"),
       path = here("rsf", phase, paste0(register, ".rsf")))

maybe_download <- function(url, destfile) {
  cat("Downloading ", destfile, " ...\n")
  if(!file_exists(destfile)) {
    tryCatch(download.file(url, destfile),
             error = function(e) simpleWarning('Register not found'))
  }
}

pwalk(registers, ~ maybe_download(..3, ..4))

dir_ls(here("rsf"), recursive = TRUE) %>%
  as.character() %>%
  tibble(path = .) %>%
  inner_join(registers, by = "path") %>%
  mutate(field = map(path, extract_fields)) %>%
  select(register, phase, field) %>%
  unnest() %>%
  write_tsv(here("fields.tsv"))
