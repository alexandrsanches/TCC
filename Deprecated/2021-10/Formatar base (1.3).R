#### Set working directory ####

switch (Sys.info()["sysname"],
        "Darwin" = setwd("~/OneDrive/TCC"),
        "Linux" = setwd("~/Projetos/TCC")
)

#### Load packages ####

library(lubridate)
library(tidyverse)
library(xts)

#### Import and clean data ####

base_mensal <- readRDS("Dados/base_mensal.rds")
base_anual <- readRDS("Dados/base_anual.rds")

copom <- readRDS("Dados/copom.rds")

reunioes <- copom %>%
  select(Reuniao, Data)

reunioes <- xts(reunioes[, -2], order.by = reunioes$Data)

#### Import and clean

id <- base_mensal %>%
  filter(Indicador == "Selic") %>%
  select(Instituicao, Data, DataReferencia, Valor)

cambio <- base_mensal %>%
  filter(Indicador == "Câmbio") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(Cambio = Valor)

ipca <- base_mensal %>%
  filter(Indicador == "Selic") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(IPCA = Valor)

pib <- base_anual %>%
  filter(IndicadorDetalhe == "PIB") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(PIB = Valor)


start <- Sys.time()
df <- data.frame(matrix(ncol = 6, nrow = nrow(id),
                        dimnames = list(NULL, c("Instituicao", "Data", "DataReferencia", "Valor",
                                                "DataReuniao", "Reuniao"))))

#### For que necessita de otimização ####

for (i in 1:nrow(id)) {

  date <- pull(id[i, 2])
  year <- year(date)
  month <- format(date, "%m")

  reunion_date <- reunioes[paste0(year, "-", month)]
  
  if (is_empty(reunion_date)) {
    if (month == 12) {
      month <- 1
      year <- year(date) + 1
    } else {
      month <- month(date) + 1
    }
    reunion_date <- reunioes[paste0(year, "-", month)]
  }

  temp <- id[i,] %>%
    add_column(DataReuniao = index(reunion_date),
               Reuniao = reunion_date[1,])
  
  df[i, ] <- temp

  print(i)
}

end <- Sys.time()

end - start

saveRDS(df, file = "base_final.rds")
