switch (Sys.info()["sysname"],
        "Darwin" = setwd("~/OneDrive/TCC"),
        "Linux" = setwd("~/Projetos/TCC")
)

library(rio)
library(tidyverse)
library(lubridate)
library(plm)

base <- import("Dados/base_final.rds")
copom <- import("Dados/copom.rds") %>%
  select(Reuniao, MetaSelic)

base_mensal <- import("Dados/base_mensal.rds")

cambio <- base_mensal %>%
  filter(Indicador == "Câmbio") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(Cambio = Valor)

ipca <- base_mensal %>%
  filter(Indicador == "Selic") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(IPCA = Valor)

base <-  base %>%
  mutate_at(vars(contains("Data")), as_date) %>%
  left_join(copom) %>%
  filter(month(DataReferencia) == month(DataReuniao) &
         year(DataReferencia) == year(DataReuniao)) %>%
  left_join(ipca) %>%
  left_join(cambio) %>%
  rename(SELIC = Valor) %>%
  relocate(where(is.numeric), .after = where(is.Date)) %>%
  relocate(Reuniao, .before = Instituicao) %>%
  mutate(Surpresa = MetaSelic - SELIC) %>%
  select(-MetaSelic)

reg.pooled <- plm(SELIC ~ Surpresa, 
               data = base, 
               index = "Data",
               model = "pooling")

summary(reg.pooled)

