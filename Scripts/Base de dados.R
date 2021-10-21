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
library(fBasics)
library(stargazer)

options(digits = 3)

# Import data ----
base <- import("Dados/base_final.rds")
copom <- import("Dados/copom.rds") %>%
  select(Reuniao, MetaSelic)

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
  mutate(Cambio = Cambio - dplyr::lag(Cambio),
         SELIC = SELIC - dplyr::lag(SELIC),
         Surpresa = (MetaSelic - dplyr::lag(MetaSelic)) - SELIC,
         Instituicao = factor(Instituicao))

### Filtrar instituições com poucas projeções ----
#instituicoes <- base %>% 
#  group_by(Instituicao) %>%
#  distinct(Reuniao) %>%
#  mutate(n = max(Reuniao) - min(Reuniao)) %>%
#  ungroup() %>%
#  distinct(Instituicao, .keep_all = TRUE) %>%
#  filter(n > 30) %>%
#  pull(Instituicao)

#base %>%
#  #filter(Instituicao %in% instituicoes) %>%
#  distinct(Instituicao) %>%
#  count()
#
#base <- base %>%
#  filter(Instituicao %in% instituicoes)
  
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

# Estatísticas descritivas ----
desc <- data.frame(variavel = c("Câmbio", "IPCA", "Selic", "Surpresa"),
                   Média = rep(NA, 4),
                   Mediana = rep(NA, 4),
                   Máximo = rep(NA, 4),
                   Mínimo = rep(NA, 4),
                   `Desvio padrão` = rep(NA, 4),
                   Curtose = rep(NA, 4),
                   Assimetria = rep(NA, 4))

# Media
desc[1, 2] <- mean(base$expect_cambio, na.rm = TRUE)
desc[2, 2] <- mean(base$expect_ipca, na.rm = TRUE)
desc[3, 2] <- mean(base$expect_selic, na.rm = TRUE)
desc[4, 2] <- mean(base$surpresa, na.rm = TRUE)

# Mediana
desc[1, 3] <- median(base$expect_cambio, na.rm = TRUE)
desc[2, 3] <- median(base$expect_ipca, na.rm = TRUE)
desc[3, 3] <- median(base$expect_selic, na.rm = TRUE)
desc[4, 3] <- median(base$surpresa, na.rm = TRUE)

# Maximo
desc[1, 4] <- max(base$expect_cambio, na.rm = TRUE)
desc[2, 4] <- max(base$expect_ipca, na.rm = TRUE)
desc[3, 4] <- max(base$expect_selic, na.rm = TRUE)
desc[4, 4] <- max(base$surpresa, na.rm = TRUE)

# Minimo
desc[1, 5] <- min(base$expect_cambio, na.rm = TRUE)
desc[2, 5] <- min(base$expect_ipca, na.rm = TRUE)
desc[3, 5] <- min(base$expect_selic, na.rm = TRUE)
desc[4, 5] <- min(base$surpresa, na.rm = TRUE)

# Desvio padrão
desc[1, 6] <- sd(base$expect_cambio, na.rm = TRUE)
desc[2, 6] <- sd(base$expect_ipca, na.rm = TRUE)
desc[3, 6] <- sd(base$expect_selic, na.rm = TRUE)
desc[4, 6] <- sd(base$surpresa, na.rm = TRUE)

# Curtose
desc[1, 7] <- kurtosis(base$expect_cambio, na.rm = TRUE)
desc[2, 7] <- kurtosis(base$expect_ipca, na.rm = TRUE)
desc[3, 7] <- kurtosis(base$expect_selic, na.rm = TRUE)
desc[4, 7] <- kurtosis(base$surpresa, na.rm = TRUE)

# Assimetria
desc[1, 8] <- skewness(base$expect_cambio, na.rm = TRUE)
desc[2, 8] <- skewness(base$expect_ipca, na.rm = TRUE)
desc[3, 8] <- skewness(base$expect_selic, na.rm = TRUE)
desc[4, 8] <- skewness(base$surpresa, na.rm = TRUE)

desc <- t(desc)

stargazer(desc)
