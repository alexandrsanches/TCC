#### Load packages ####

library(lubridate)
library(tidyverse)

#### Set options and download file ####

options(timeout=1000)

download.file("https://olinda.bcb.gov.br/olinda/servico/Expectativas/versao/v1/odata/ExpectativasMercadoInstituicoes?$format=text/csv&$select=Instituicao,Indicador,IndicadorDetalhe,Periodicidade,Data,DataReferencia,Valor",
              destfile = "~/Downloads/Focus.csv")

#### Import and clean

focus <- read.csv("~/Downloads/Focus.csv",
                  colClasses = c("Data" = "Date", "DataReferencia" = "Date")) %>%
  filter(Periodicidade == "Anual",
         Indicador %in% c("IPCA", "PIB Total", "Meta para taxa over-selic", "Taxa de câmbio")) %>%
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
  arrange(Instituicao, Indicador, Data, DataReferencia.Ano)

