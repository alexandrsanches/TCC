#### Define working directory ####

setwd("~/TCC")

#### Load packages ####

library(lubridate)
library(tidyverse)
library(xts)
library(purrr)

#### Set options and download file ####

options(timeout = 1000000000000000000000000)

download.file("https://olinda.bcb.gov.br/olinda/servico/Expectativas/versao/v1/odata/ExpectativasMercadoInstituicoes?$format=text/csv&$select=Instituicao,Indicador,IndicadorDetalhe,Periodicidade,Data,DataReferencia,Valor",
              destfile = "Dados/Focus.csv")

copom <- readRDS("Dados/copom.rds")

reunioes <- copom %>%
  select(data)

#### Import and clean

focus <- read_csv("Dados/Focus.csv") %>%
  filter(Periodicidade == "Mensal",
         Indicador %in% c("IPCA", "PIB Total", "Selic", "Câmbio"),
         Data >= "2002-01-01" & Data <= "2020-12-31") %>%
  mutate(Indicador = ifelse(IndicadorDetalhe != "null", paste(Indicador, "-", IndicadorDetalhe), Indicador),
         Valor = as.numeric(gsub(Valor, pattern = ",", replacement = "."))) %>%
  select(-IndicadorDetalhe)

focus %<>%
  mutate(Data.Ano = year(Data),
         Data.Mes = month(Data),
         Data.Dia = day(Data),
         Data.AnoMes = floor_date(Data, "month"),
         DataReferencia.Ano = year(DataReferencia),
         DataReferencia.Mes = month(DataReferencia),
         DataReferencia.Dia = day(DataReferencia),
         DataReferencia.AnoMes = floor_date(DataReferencia, "month"),
         DiadaSemana = format(Data, "%a")) %>%
  arrange(Instituicao, Indicador, Data, DataReferencia, DataReferencia.Ano) %>%
  rename(data = Data)

#teste <- focus %>%
#  filter(Indicador == "Selic",
#         data > "2002-01-01")

id <- focus %>%
  filter(Instituicao == 1,
         Indicador == "Selic") %>%
  mutate(id = as.numeric(Instituicao),
         proj = as.numeric(Valor)) %>%
         #DataReferencia = as_date(ifelse(month(DataReferencia) == month(data), DataReferencia, NA))) %>%
  select(id, proj, data, DataReferencia)

id <- na.omit(id)

dados <- data.frame()

for (i in 1:nrow(id)) {
  
  ano <- year(pull(id[i, 3]))
  mes <- month(pull(id[i, 3]))
  
  if (mes == 2) {
    date <- as_date(paste0(ano, "-0", mes, "-28"))
  } else {
    if (mes %in% c(1, 3, 5, 7, 8, 10, 12)) {
      date <- paste0(ano, "-", mes, "-31")
    } else {
      date <- paste0(ano, "-", mes, "-30")
    }
  }
  
  if (mes < 10) {
    date <- as_date(gsub("^(.{5})(.*)$", "\\10\\2", date))
  }

  filter_date <- id %>%
    filter(data <= date,
           month(data) == month(date),
           DataReferencia == as_date(paste0(ano, "-", mes, "-01"))) %>%
    slice(which.min(data)) %>%
    pull(data)
  
  data_reuniao <- reunioes %>%
    filter(data <= date,
           month(data) == month(date))
  
  reference_line <- id %>%
    filter(data == filter_date)
  
  dados <- rbind(dados, reference_line)
  
}

dados <- unique(dados)

dados <- dados %>%
  left_join(copom) %>%
  mutate(surpresa = meta - proj)

teste1 <- map_df(
  .x = datas,
  .f = function(x) id %>%  
    filter(Data < x) %>% 
    slice(1) %>% 
    mutate(ref = x)
)
