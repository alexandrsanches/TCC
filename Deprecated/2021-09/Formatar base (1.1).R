#### Set working directory ####

setwd("~/OneDrive/TCC")

#### Load packages ####

library(lubridate)
library(tidyverse)
library(magrittr)
library(xts)

#### Set options and download file ####

options(timeout=1000)

#copom <- read.xlsx("Dados/Meta para SELIC.xlsx") %>%
#  mutate(Data = convertToDate(Data),
#         VigenciaInicio = convertToDate(VigenciaInicio),
#         VigenciaFim = convertToDate(VigenciaFim))

#download.file("https://olinda.bcb.gov.br/olinda/servico/Expectativas/versao/v1/odata/ExpectativasMercadoInstituicoes?$format=text/csv&$select=Instituicao,Indicador,IndicadorDetalhe,Periodicidade,Data,DataReferencia,Valor",
#              destfile = "Dados/Focus.csv")

base <- readRDS("Dados/base_mensal.rds")

copom <- readRDS("Dados/copom.rds")

reunioes <- copom %>%
  select(Reuniao, Data)

reunioes <- xts(reunioes[, -2], order.by = reunioes$Data)

#### Import and clean

#base <- read_csv("Dados/Focus.csv") %>%
#  filter(Periodicidade == "Mensal",
#         Indicador %in% c("IPCA", "PIB Total", "Selic", "Câmbio"),
#         Data >= "2003-01-01" & Data <= "2020-12-31") %>%
#  mutate(Indicador = ifelse(IndicadorDetalhe != "null", paste(Indicador, "-", IndicadorDetalhe), Indicador),
#         Valor = as.numeric(gsub(Valor, pattern = ",", replacement = "."))) %>%
#  select(-IndicadorDetalhe) %>%
#  group_by(Instituicao, Indicador, Periodicidade, DataReferencia) %>% 
#  arrange(Data) %>% 
#  complete(Data = seq.Date(min(Data), max(Data) + 14, by="day")) %>% 
#  mutate(Atualizacao = ifelse(is.na(Valor), 0, 1)) %>%
#  fill(c(Valor, DataReferencia), .direction = "down") %>% 
#  arrange(Instituicao, Indicador, Periodicidade, Data, DataReferencia) %>% 
#  ungroup()

#base %<>%
#  mutate(Data.Ano = year(Data),
#         Data.Mes = month(Data),
#         Data.Dia = day(Data),
#         Data.AnoMes = floor_date(Data, "month"),
#         DataReferencia.Ano = year(DataReferencia),
#         DataReferencia.Mes = month(DataReferencia),
#         DataReferencia.Dia = day(DataReferencia),
#         DataReferencia.AnoMes = floor_date(DataReferencia, "month"),
#         DiadaSemana = format(Data, "%a"))

id <- base %>%
  filter(Indicador == "Selic")

start <- Sys.time()
df <- data.frame()

#### For que necessita de otimização ####

for (i in 1:1000000) {
  
  year <- year(pull(id[i, 5]))
  month <- format(pull(id[i, 5]), "%m")
  
  reunion_date <- reunioes[paste0(year, "-", month, "/", year, "-", month)]
  
  if (is_empty(reunion_date)) {
    if (month == 12) {
      month <- 1
      year <- year(pull(id[i, 5])) + 1
    } else {
      month <- month(pull(id[i, 5])) + 1
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

# mutate(DataReuniao = case_when(Data >= initial_month & Data <= reunion_date[,1] ~ reunion_date[, 1]))

#dados <- data.frame()
#
#for (i in 1:nrow(id)) {
#  
#  ano <- year(pull(id[i, 3]))
#  mes <- month(pull(id[i, 3]))
#  
#  if (mes == 2) {
#    mes_proj <- paste0(ano, "-0", mes, "-28")
#  } else {
#    if (mes %in% c(1, 3, 5, 7, 8, 10, 12)) {
#      mes_proj <- paste0(ano, "-", mes, "-31")
#    } else {
#      mes_proj <- paste0(ano, "-", mes, "-30")
#    }
#  }
#  
#  if (mes < 10) {
#    mes_proj <- as_date(gsub("^(.{5})(.*)$", "\\10\\2", mes_proj))
#  } else {
#    mes_proj <- as_date(mes_proj)
#  }
#  
#  filter_date <- id %>%
#    filter(Data <= mes_proj,
#           month(Data) == month(mes_proj),
#           DataReferencia == as_date(paste0(ano, "-", mes, "-01"))) %>%
#    slice(which.min(Data)) %>%
#    pull(Data)
#  
#  data_reuniao <- reunioes %>%
#    filter(data <= date,
#           month(data) == month(date))
#  
#  reference_line <- id %>%
#    filter(data == filter_date)
#  
#  dados <- rbind(dados, reference_line)
#  
#}

teste1 <- map_df(
  .x = datas,
  .f = function(x) id %>%  
    filter(Data < x) %>% 
    slice(1) %>% 
    mutate(ref = x)
)

