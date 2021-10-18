switch (Sys.info()["sysname"],
        "Darwin" = setwd("~/OneDrive/TCC"),
        "Linux" = setwd("~/Projetos/TCC")
)

library(rio)
library(tidyverse)
library(lubridate)
library(plm)
library(lmtest)
library(tseries)

base <- import("Dados/base_final.rds")
base_mensal <- import("Dados/base_mensal.rds")
copom <- import("Dados/copom.rds") %>%
  select(Reuniao, MetaSelic)

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
  mutate(Surpresa = MetaSelic - SELIC)

base <- pdata.frame(base,
                    index = c("Instituicao", "Data"))

coplot(SELIC ~ Data|Instituicao, type = "b", data = base)

# Pooled OLS
reg.pooled <- plm(SELIC ~ Surpresa, 
               data = base,
               model = "pooling")

summary(reg.pooled)

# Efeito fixo
reg.ef <- plm(SELIC ~ Surpresa, 
              data = base,
              index = "Data",
              model = "within")

summary(reg.ef)
summary(fixef(reg.ef))

# Efeito aleatório
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

# Individual
pwtest(reg.pooled) 

# Tempo
pwtest(reg.pooled, effect = "time") 

## Raiz unitária ----
adf.test(base$Surpresa, k = 2)

