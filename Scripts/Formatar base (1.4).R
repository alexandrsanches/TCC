# Set working directory ----

switch (Sys.info()["sysname"],
        "Darwin" = setwd("~/OneDrive/TCC"),
        "Linux" = setwd("~/Projetos/TCC")
)

# Load packages ----

library(rio)
library(tidyverse)
library(lubridate)
library(plm)
library(lattice)
library(latticeExtra)

# Import data ----

## Base final ----
base <- import("Dados/base_final.rds")
copom <- import("Dados/copom.rds") %>%
  select(Reuniao, MetaSelic)

## Bases mensais e anuais ----
base_mensal <- import("Dados/base_mensal.rds")
base_anual <- import("Dados/base_anual.rds")

# Clean data ----

## Câmbio ----
cambio <- base_mensal %>%
  filter(Indicador == "Câmbio") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(Cambio = Valor)

## IPCA ----
ipca <- base_mensal %>%
  filter(Indicador == "Selic") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(IPCA = Valor)

## PIB ----
pib <- base_anual %>%
  filter(IndicadorDetalhe == "PIB Total") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(PIB = Valor)

## Base final ----
base <-  base %>%
  mutate_at(vars(contains("Data")), as_date) %>%
  left_join(copom) %>%
  filter(month(DataReferencia) == month(DataReuniao) &
           year(DataReferencia) == year(DataReuniao)) %>%
  left_join(ipca) %>%
  left_join(cambio) %>%
  left_join(pib) %>%
  rename(SELIC = Valor) %>%
  relocate(where(is.numeric), .after = where(is.Date)) %>%
  relocate(Reuniao, .before = Instituicao) %>%
  mutate(Surpresa = MetaSelic - SELIC,
         Instituicao = factor(Instituicao))

rm(base_mensal,
   base_anual,
   cambio,
   copom,
   ipca,
   pib)

# Generate charts ----
plot1 <- xyplot(IPCA ~ Data | Instituicao, 
                base, 
                type = "l", 
                as.table = TRUE,
                auto.key = TRUE,
                lwd = 2,
                col = "#084184",
                ylab = "", 
                xlab = "")

plot1

# Regressions ----
## Pooled OLS ----
reg.pooled <- plm(SELIC ~ Surpresa, 
               data = base,
               model = "pooling")

summary(reg.pooled)

## Efeito fixo ----
reg.ef <- plm(SELIC ~ Surpresa, 
              data = base,
              index = "Data",
              model = "within")

summary(reg.ef)
summary(fixef(reg.ef))

## Efeito aleatório ----
reg.ea <- plm(SELIC ~ Surpresa,
              data = base,
              index = "Data",
              model = "random", 
              random.method = "walhus")

summary(reg.ea)

# Comparação entre modelos ----

## Modelo Pooled x Modelo de Efeitos Fixos ----
pFtest(reg.ef,reg.pooled)

## Modelo Pooled x Modelo de Efeitos Aleatórios ----
plmtest(reg.pooled, type = "bp")

## Modelo Efeitos Fixos x Modelo de Efeitos Aleatórios ----
phtest(reg.ef,reg.ea)

# Testes para o modelo ----

## Dependência transversal ----
pcdtest(reg.ea, test="cd")

## Normalidade dos resíduos ----
shapiro.test(reg.ea$residuals)

## Homocedasticidade dos resíduos ----
bptest(reg.ea)

## Correlação serial ----
pbgtest(reg.ea) 

## Efeitos individuais ou de tempo ----

### Individual ----
pwtest(reg.pooled) 

### Tempo ----
pwtest(reg.pooled, effect = "time") 

## Raiz unitária ----
adf.test(base$Surpresa, k = 2)

