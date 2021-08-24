library(tidyverse)
library(scales)
library(lubridate)
library(ggridges)
library(chron)

setwd("L:/Area Macro/Modelagem/Metas de inflação/junho 2021")

base <- readRDS(file = "Expectativas - Focus/base.rds")

dados <- base %>%
  select(-c(Periodicidade, Atualizacao, DataReferencia.Mes, DataReferencia.Dia, DataReferencia.AnoMes, DiadaSemana)) %>%
  filter(IndicadorDetalhe %in% c("IPCA", "Meta para taxa over-selic - Taxa no fim do ano")) %>%
  pivot_wider(values_from = Valor,
              names_from = IndicadorDetalhe) %>%
  group_by(Instituicao) %>%
  mutate(JuroReal = 100 * ((1 + `Meta para taxa over-selic - Taxa no fim do ano` / 100) / (1 + IPCA  / 100) - 1))
  
# Juro Real

anoProjecao <- 2018
anosReferencia <- c(2015, 2016, 2017)

dados %>% filter(DataReferencia.Ano == anoProjecao,
                Data.Ano %in% anosReferencia,
                Data.Mes %in% c(1,2,3,4,5,6,7,8,9,10,11,12)) %>% 
  group_by(Instituicao, Data.Ano, Data.Mes) %>%
  filter(Data.Dia == max(Data.Dia)) %>%
  ungroup() %>% 
  arrange(Instituicao, Data.AnoMes) %>%
  ggplot(aes(x = JuroReal, y = Data.AnoMes, group = Data.AnoMes)) +
  #geom_hline(yintercept=as.Date('2017-06-01'), color = 'red', linetype = "dashed", size = 0.8) +
  stat_density_ridges(rel_min_height = 0.005, quantile_lines = TRUE, quantiles = 2, fill = 'blue', alpha = 0.4)  +
  #annotate("text", x = 5.75, y = as.Date('2017-06-15'), label = "Anúncio da Mudança de Meta", color = 'red') +
  coord_cartesian(xlim = c(1.5, 7)) +
  scale_y_date(date_labels = "%b-%Y", breaks = "1 month") +
  labs(y = "", 
       x = "",
       caption = "As distribuições se referem às expectativas no último dia de cada mês.") +
  theme(panel.background = element_rect(fill = "white", colour = "grey10"))


# Outros indicadores
anoProjecao <- 2010
anosReferencia <- c(2006, 2007, 2008)

base %>% filter(IndicadorDetalhe == 'IPCA',
                DataReferencia.Ano == anoProjecao,
                Data.Ano %in% anosReferencia,
                Data.Mes %in% c(1,2,3,4,5,6,7,8,9,10,11,12),
                Periodicidade == 'Anual') %>% 
  group_by(Instituicao, Data.Ano, Data.Mes) %>% 
  filter(Data.Dia == max(Data.Dia)) %>%
  ungroup() %>% 
  arrange(Instituicao, Data.AnoMes) %>%
  ggplot(aes(x = Valor, y = as.Date(Data.AnoMes), group = Data.AnoMes)) +
  #geom_hline(yintercept=as.Date('2019-06-01'), color = 'red', linetype = "dashed", size = 0.8) +
  #geom_hline(yintercept=as.Date('2020-06-01'), color = 'red', linetype = "dashed", size = 0.8) +
  stat_density_ridges(rel_min_height = 0.005, quantile_lines = TRUE, quantiles = 2, fill = 'blue', alpha = 0.4)  +
  #annotate("text", x = 4.75, y = as.Date('2019-06-15'), label = "Anúncio da Mudança de Meta para 2022", color = 'red', size = 4.5) +
  #annotate("text", x = 4.75, y = as.Date('2020-06-15'), label = "Anúncio da Mudança de Meta para 2023", color = 'red', size = 4.5) +
  coord_cartesian(xlim = c(3, 5.5)) +
  scale_y_date(date_labels = "%b-%Y", breaks = "1 month") +
  labs(y = "", 
       x = "",
       caption = "As distribuições se referem às expectativas no último dia de cada mês.") +
  theme(panel.background = element_rect(fill = "white", colour = "grey10"))
