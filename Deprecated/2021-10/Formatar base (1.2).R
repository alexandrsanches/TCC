#### Set working directory ####

setwd("~/OneDrive/TCC")

#### Load packages ####

library(lubridate)
library(tidyverse)
library(xts)

#### Import and clean data ####

base <- readRDS("Dados/base_mensal.rds")

copom <- readRDS("Dados/copom.rds")

reunioes <- copom %>%
  select(Reuniao, Data)

reunioes <- xts(reunioes[, -2], order.by = reunioes$Data)

#### Import and clean

id <- base %>%
  filter(Indicador == "Selic") %>%
  select(Instituicao, Data, DataReferencia, Valor)

start <- Sys.time()
df <- data.frame()

#### For que necessita de otimização ####

for (i in 1:nrow(id)) {
  
  year <- year(pull(id[i, 2]))
  month <- format(pull(id[i, 2]), "%m")
  
  reunion_date <- reunioes[paste0(year, "-", month, "/", year, "-", month)]
  
  if (is_empty(reunion_date)) {
    if (month == 12) {
      month <- 1
      year <- year(pull(id[i, 2])) + 1
    } else {
      month <- month(pull(id[i, 2])) + 1
    }
    if (month < 10) {
      month <- paste0(0, month)
    }
    reunion_date <- reunioes[paste0(year, "-", month, "/", year, "-", month)]
  }
  
  reunion_date <- data.frame(DataReuniao = index(reunion_date),
                             Reuniao = reunion_date[1,])
  
  initial_month <- as_date(paste0(year(reunion_date[,1]), "-", month(reunion_date[,1]), "-01"))
  
  temp <- id %>%
    filter(row.names(.) == i) %>%
    mutate(DataReuniao = reunion_date[,1],
           Reuniao = reunion_date[,2])
  
  df <- rbind(df, temp)
  
  print(i)
  
}

end <- Sys.time()

start - end

#saveRDS(df, file = "base_final.rds")
