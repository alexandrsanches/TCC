# Set working directory ----

switch (Sys.info()["sysname"],
        "Darwin" = setwd("~/OneDrive/TCC"),
        "Linux" = setwd("~/Projetos/TCC")
)

# Load packages ----

library(rio)
library(tidyverse)
library(lubridate)
library(lattice)

# Import data ----

## Bases mensais e anuais ----
base_mensal <- import("Dados/base_mensal.rds")

# Clean data ----

## Câmbio ----
cambio <- base_mensal %>%
  filter(Indicador == "Câmbio",
         Data >= "2003-01-01") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(Cambio = Valor)

## IPCA ----
ipca <- base_mensal %>%
  filter(Indicador == "IPCA",
         Data >= "2003-01-01") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(IPCA = Valor)

## Base final ----
base <- base %>%
  mutate_at(vars(contains("Data")), as_date) %>%
  left_join(copom) %>%
  filter(month(DataReferencia) == month(DataReuniao) &
           year(DataReferencia) == year(DataReuniao),
         Data == DataReuniao - 1) %>%
  left_join(ipca) %>%
  left_join(cambio) %>%
  rename(SELIC = Valor) %>%
  relocate(where(is.numeric), .after = where(is.Date)) %>%
  relocate(Reuniao, .before = Instituicao) %>%
  group_by(Instituicao) %>%
  mutate(Surpresa = (MetaSelic - dplyr::lag(MetaSelic)) - (SELIC - dplyr::lag(SELIC)),
         Instituicao = factor(Instituicao))

### Filtrar instituições com poucas projeções ----
instituicoes <- base %>% 
  group_by(Instituicao) %>%
  distinct(Reuniao) %>%
  mutate(n = max(Reuniao) - min(Reuniao)) %>%
  ungroup() %>%
  distinct(Instituicao, .keep_all = TRUE) %>%
  filter(n > 30) %>%
  pull(Instituicao)

base %>%
  #filter(Instituicao %in% instituicoes) %>%
  distinct(Instituicao) %>%
  count()

base <- base %>%
  filter(Instituicao %in% instituicoes)
  
rm(base_mensal,
   cambio,
   copom,
   ipca)

export(base, file = "Dados/base_regressao.rds")

# Generate charts ----
xyplot(IPCA ~ Data | Instituicao, 
                base, 
                type = "l", 
                as.table = TRUE,
                auto.key = TRUE,
                lwd = 2,
                col = "#084184",
                ylab = "", 
                xlab = "Data")
