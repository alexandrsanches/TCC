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

# Import data ----

## Base final ----
base <- import("Dados/base_final.rds")
copom <- import("Dados/copom.rds") %>%
  select(Reuniao, MetaSelic)

## Bases mensais e anuais ----
#base_mensal <- import("Dados/base_mensal.rds")
base_anual <- import("Dados/base_anual.rds")

# Clean data ----

## Câmbio ----
cambio <- base_anual %>%
  filter(IndicadorDetalhe == "Taxa de câmbio - Taxa no fim do ano",
         Data >= "2003-01-01") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(Cambio = Valor) %>%
  group_by(Instituicao, Data) %>%
  complete(DataReferencia = seq.Date(from = min(DataReferencia), to = max(DataReferencia) + 11, by = "month")) %>%
  fill(c(Cambio, DataReferencia), .direction = "down")

export(cambio, file = "Dados/Arquivos intermediários/cambio.rds")

## IPCA ----
ipca <- base_anual %>%
  filter(IndicadorDetalhe == "IPCA") %>%
  select(Instituicao, Data, DataReferencia, Valor) %>%
  rename(IPCA = Valor) %>%
  complete(DataReferencia = seq.Date(from = min(DataReferencia), to = max(DataReferencia) + 11, by = "month")) %>%
  fill(c(IPCA, DataReferencia), .direction = "down")

export(ipca, file = "Dados/Arquivos intermediários/ipca.rds")

## Base final ----
teste <- base %>%
  mutate_at(vars(contains("Data")), as_date) %>%
  left_join(copom) %>%
  filter(month(DataReferencia) == month(DataReuniao) &
           year(DataReferencia) == year(DataReuniao)) %>%
  left_join(ipca) %>%
  left_join(cambio) %>%
  rename(SELIC = Valor) %>%
  relocate(where(is.numeric), .after = where(is.Date)) %>%
  relocate(Reuniao, .before = Instituicao) %>%
  mutate(Surpresa = MetaSelic - SELIC,
         Instituicao = factor(Instituicao))

### Filtrar instituições com poucas projeções ----
instituicoes <- base %>% 
  group_by(Instituicao) %>%
  distinct(Reuniao) %>%
  mutate(n = max(Reuniao) - min(Reuniao)) %>%
  ungroup() %>%
  distinct(Instituicao, .keep_all = TRUE) %>%
  filter(n > 30) %>%
  pull(Instituicao)

base %>%
  filter(Instituicao %in% instituicoes) %>%
  distinct(Instituicao) %>%
  count()

base <- base %>%
  filter(Instituicao %in% instituicoes) %>%
  
rm(base_mensal,
   cambio,
   copom,
   ipca)

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

# Regressions ----
base <- pdata.frame(base,
                    index = c("Instituicao","Data"))

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

