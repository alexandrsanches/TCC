# Set working directory ----

switch (Sys.info()["sysname"],
        "Darwin" = setwd("~/OneDrive/TCC"),
        "Linux" = setwd("~/Projetos/TCC")
)

# Load packages ----

library(rio)
library(plm)
library(lmtest)
require(tseries)
library(stargazer)

# Obtenção e formatação dos dados ----

base <- import("Dados/base_regressao.rds")
base <- pdata.frame(base, index = c("Instituicao","Data"))
names(base) <- c("data", "data_previsao", "data_reuniao", "reuniao", "instituicao", "expect_selic",
                 "meta_selic", "expect_ipca", "expect_cambio", "surpresa")

# Modelagem ----

## MQO agrupado ----

### Expectativas da Selic ----

reg.agrupada.selic <- plm(expect_selic ~ surpresa, data = base, model = "pooling")
summary(reg.agrupada.selic)

### Expectativas do câmbio ----

reg.agrupada.cambio <- plm(expect_cambio ~ surpresa, data = base, model = "pooling")
summary(reg.agrupada.cambio)

### Expectativas do IPCA ----

reg.agrupada.ipca <- plm(expect_ipca ~ surpresa, data = base, model = "pooling")
summary(reg.agrupada.ipca)

## Efeitos fixos ----

### Expectativas da Selic ----

reg.ef.selic <- plm(expect_selic ~ surpresa, data = base, index = "data", model = "within")
summary(reg.ef.selic)
summary(fixef(reg.ef.selic))

### Expectativas do câmbio ----

reg.ef.cambio <- plm(expect_cambio ~ surpresa, data = base, index = "data", model = "within")
summary(reg.ef.cambio)
summary(fixef(reg.ef.cambio))

### Expectativas do IPCA ----

reg.ef.ipca <- plm(expect_ipca ~ surpresa, data = base, index = "data", model = "within")
summary(reg.ef.ipca)
summary(fixef(reg.ef.ipca))

## Efeito aleatório ----

### Expectativas da Selic ----

reg.ea.selic <- plm(expect_selic ~ surpresa, data = base, index = "data", model = "random",
                    random.method = "walhus")
summary(reg.ea.selic)

### Expectativas do câmbio ----

reg.ea.cambio <- plm(expect_cambio ~ surpresa, data = base, index = "data", model = "random",
                     random.method = "walhus")
summary(reg.ea.cambio)

### Expectativas do IPCA ----

reg.ea.ipca <- plm(expect_ipca ~ surpresa, data = base, index = "data", model = "random",
                   random.method = "walhus")
summary(reg.ea.ipca)

stargazer(reg.ea.cambio, reg.ea.ipca, reg.ea.selic,
          align = TRUE,
          title = "Resultado das regressões",
          dep.var.labels = c("Expectativa do câmbio", "Expectativa do IPCA", "Expectativa da Selic"),
          covariate.labels = c("Surpresa", "Constante"))

# Escolha do modelo mais adequado ----

## Modelo MQO agrupado x Modelo de Efeitos Fixos ----

pFtest(reg.ef.selic, reg.agrupada.selic)
pFtest(reg.ef.cambio, reg.agrupada.cambio)
pFtest(reg.ef.ipca, reg.agrupada.ipca)

## Modelo MQO agrupado x Modelo de Efeitos Aleatórios ----

plmtest(reg.ef.selic, type = "bp")
plmtest(reg.ef.cambio, type = "bp")
plmtest(reg.ef.ipca, type = "bp")

## Modelo Efeitos Fixos x Modelo de Efeitos Aleatórios ----

phtest(reg.ef.selic, reg.ea.selic)
phtest(reg.ef.cambio, reg.ea.cambio)
phtest(reg.ef.ipca, reg.ea.ipca)

# Diagnósticos dos modelos selecionados ----

## Dependência transversal ----

pcdtest(reg.ea.selic, test = "cd")
pcdtest(reg.ea.cambio, test = "cd")
pcdtest(reg.ea.ipca, test = "cd")

## Normalidade dos resíduos ----

shapiro.test(reg.ea.selic$residuals[0:5000])
shapiro.test(reg.ea.cambio$residuals[0:5000])
shapiro.test(reg.ea.ipca$residuals[0:5000])

## Homocedasticidade dos resíduos ----

bptest(reg.ea.cambio)
bptest(reg.ea.ipca)
bptest(reg.ea.selic)

## Correlação serial ----

pbgtest(reg.ea.cambio)
pbgtest(reg.ea.ipca)
pbgtest(reg.ea.selic)

## Efeitos individuais ou de tempo ----

### Individual ----
pwtest(reg.pooled) 

### Tempo ----
pwtest(reg.pooled, effect = "time") 

## Raiz unitária ----
adf.test(base$surpresa, k = 2)

