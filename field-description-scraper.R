library(tidyverse)
library(registr)
library(here)

beta <- rr_registers("beta")

map_dfr(beta,
        ~ .x %>%
          pluck("schema", "fields") %>%
          arrange(field, timestamp) %>%
          group_by(field) %>%
          slice(n()) %>%
          ungroup() %>%
          select(field, text),
        .id = "register") %>%
  write_tsv(here("field-descriptions.tsv"))

beta %>%
  pluck("register", "data") %>%
  arrange(register, timestamp) %>%
  group_by(register) %>%
  slice(n()) %>%
  select(register, text) %>%
  write_tsv(here("register-descriptions.tsv"))
