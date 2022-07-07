# General instructions ----
# 1. Load this script in UTF-8 encoding, because the special characters will not appear. File > Reopen with encoding > UTF-8
# 2. This script was made in R 4.1.1 in macOS

#### MADE BY ALEXANDRE SANCHES ####

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
library(stargazer)
library(xts)
library(openxlsx)

# Set options ----

options(digits = 3)

# Import data ----
copom <- read.xlsx("Dados/Meta para SELIC.xlsx") %>%
  mutate(Data = convertToDate(Data),
         VigenciaInicio = convertToDate(VigenciaInicio),
         VigenciaFim = convertToDate(VigenciaFim))

download.file("https://olinda.bcb.gov.br/olinda/servico/Expectativas/versao/v1/odata/ExpectativasMercadoInstituicoes?$format=text/csv&$select=Instituicao,Indicador,IndicadorDetalhe,Periodicidade,Data,DataReferencia,Valor",
              destfile = "Dados/Focus.csv")

# Clean data ----
## Database ----
base_mensal <- read_csv("Dados/Focus.csv") %>%
  filter(Periodicidade == "Mensal",
         Indicador %in% c("IPCA", "PIB Total", "Selic", "Câmbio"),
         Data >= "2003-01-01" & Data <= "2020-12-31") %>%
  mutate(Indicador = ifelse(IndicadorDetalhe != "null", paste(Indicador, "-", IndicadorDetalhe), Indicador),
         Valor = as.numeric(gsub(Valor, pattern = ",", replacement = "."))) %>%
  select(-IndicadorDetalhe) %>%
  group_by(Instituicao, Indicador, Periodicidade, DataReferencia) %>% 
  arrange(Data) %>% 
  complete(Data = seq.Date(min(Data), max(Data) + 14, by="day")) %>% 
  mutate(Atualizacao = ifelse(is.na(Valor), 0, 1)) %>%
  fill(c(Valor, DataReferencia), .direction = "down") %>% 
  arrange(Instituicao, Indicador, Periodicidade, Data, DataReferencia) %>% 
  ungroup()

## Copom database ----
reunioes <- copom %>%
  select(Reuniao, Data)

reunioes <- xts(reunioes[, -2], order.by = reunioes$Data)

## Look for reunion dates ----
selic <- base_mensal %>%
  filter(Indicador == "Selic") %>%
  select(Instituicao, Data, DataReferencia, Valor)

df <- data.frame()

for (i in 1:nrow(selic)) {
  
  year <- year(pull(selic[i, 2]))
  month <- format(pull(selic[i, 2]), "%m")
  
  reunion_date <- reunioes[paste0(year, "-", month, "/", year, "-", month)]
  
  if (is_empty(reunion_date)) {
    if (month == 12) {
      month <- 1
      year <- year(pull(selic[i, 2])) + 1
    } else {
      month <- month(pull(selic[i, 2])) + 1
    }
    if (month < 10) {
      month <- paste0(0, month)
    }
    reunion_date <- reunioes[paste0(year, "-", month, "/", year, "-", month)]
  }
  
  reunion_date <- data.frame(DataReuniao = index(reunion_date),
                             Reuniao = reunion_date[1,])
  
  initial_month <- as_date(paste0(year(reunion_date[,1]), "-", month(reunion_date[,1]), "-01"))
  
  temp <- selic %>%
    filter(row.names(.) == i) %>%
    mutate(DataReuniao = reunion_date[,1],
           Reuniao = reunion_date[,2])
  
  df <- rbind(df, temp)
  
  print(i)
  
}

base <- df

rm(df, selic)

## Left_join base ----
### Exchange rate ----
cambio <- base_mensal %>%
  filter(Indicador == "Câmbio",
         Data >= "2003-01-01") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(Cambio = Valor)

### IPCA ----
ipca <- base_mensal %>%
  filter(Indicador == "IPCA",
         Data >= "2003-01-01") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(IPCA = Valor)

## Final base ----
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

EXport("Dados/base_regressao.rds")

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

# Descritive statistics ----
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


