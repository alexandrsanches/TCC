# Resultados

## Sinais esperados

Conforme Gonçalves & Junior (2011), espera-se que o coeficiente da surpresa seja significativo a 1% e apresente sinal negativo.

Em Oliveira & Ramos (2011) o coeficiente do componente não esperado (choque de política monetária) apresenta sinal negativo em todas as maturidades analisadas (2, 3, 6, 9, 12, 15, 18 e 24 meses).

Zabot, Caetano & Caldeira (2013) indicam que as taxas de juros de DI futuro respondem à mudanças não esperadas na Meta Selic, também apresentando coeficiente negativo. No entanto, seus coeficientes dos títulos de menor maturidade são relativamente baixos em comparação ao exposto, por exemplo, em Tabak (2004), possivelmente sendo explicados pelo aumento da capacidade de antecipação das instituições das ações do Bacen.

Kuttner (2001), apresentando uma extensão da equação de Cook & Hahn (1989), chega a um resultado em linha com os anteriores, apresentando os coeficientes da surpresa de política monetária negativos. Entretanto, sua significância estatística é baixa, o que é justificado pelo número pequeno de observações de sua amostra.

## Escolha do método econométrico

Para efetuarmos a escolha do modelo que melhor se adequa aos dados, utilizaremos alguns testes que se seguem abaixo:

| Pergunta                            | Teste utilizado                               | Hipótese nula          | Resultado                                                    |
| ----------------------------------- | --------------------------------------------- | ---------------------- | ------------------------------------------------------------ |
| MQO Agrupado ou Efeitos Fixos?      | F Test for Individual and/or Time Effects     | MQO Agrupado é melhor  | Hipótese aceita para duas das três variáveis ($selic$ e $cambio$) |
| MQO agrupado ou Efeitos Aleatórios? | Lagrange FF Multiplier Tests for Panel Models | MQO Agrupado é melhor  | Hipótese aceita para uma das três séries ($cambio$)          |
| Efeitos fixos ou aleatórios?        | Hausman Test for Panel Models                 | Efeitos Fixos é melhor | Hipótese aceita para duas das três séries ($selic$ e $cambio$) |

De acordo com o resultado apresentado acima, o modelo que melhor se adequa aos nossos propósitos é:

| Variável | Modelo                        |
| -------- | ----------------------------- |
| $cambio$ | MQO Agrupado                  |
| $ipca$   | Modelo com efeitos fixos      |
| $selic$  | Modelo com efeitos aleatórios |

## Resultados das regressões

O modelo aqui proposto procura verificar como as instituições alteram suas projeções quando são surpreendidas por um choque não antecipado de política monetária (aqui chamado de surpresa de política monetária). Assim, a análise empírica baseia-se em regressões com uso das variáveis em primeira diferença como variáveis dependentes e o choque não antecipados de política monetária como regressores. A Tabela 3 ilutras os resultados:

Tabela 3

As regressões foram executadas com 4646 observações para a variável $cambio$, 5194 para o $ipca$ e 5201 para a $selic$. Como dito anteriormente, trata-se de um modelo de regressão de painel desbalanceado, pelo fato de que nem todas as instituições possuem um logo histórico de projeções.

​	No que se refere ao coeficiente de ajustamento $R^2$, observa-se que é relativamente baixo para todas as equações. Este resultado pode ser observado também em Tabak (2004), Tabata & Tabak (2004) e em Wu (2009). Conforme destacado em Zabot, Caetano & Caldeira (2013), ainda existe a dificuldade de se ajustar modelos cujas variáveis dependentes estão em primeira diferença.

De acordo com o diagnóstico feito por Gonçalves & Junior (2011), os coeficientes da surpresa apresentam significância estatística ao intervalo de 1% e apresentam sinal negativo para todas as três equações. As reações das instituições, relativamente pequenas, podem ser explicadas pelo aumento da capacidade das instituições em, pelo menos parcialmente, antecipar as ações do Bacen. 

Como os coeficientes da surpresa apresentam sinal negativo, isso indica que, em média, quando houve uma supresa de política monetária, a decisão do Copom foi abaixo do esperado. Como o Copom vem diminuindo a taxa de juros nos últimos anos, as instruções já esperam que irá ocorrer uma diminuição.

Na Figura X é possível verificar os coeficientes de efeito aleatório ( $\beta_1$) de cada instituição para o modelo de efeitos aleatórios da $selic$, junto com a linha de tendência, demonstrando, portanto, a explicação do coeficiente negativo para a surpresa de política monetária em relação à $selic$. 

![Coeficientes para SELIC](/Users/alexandresanches/OneDrive/TCC/Textos/Imagens/Coeficientes para SELIC.png)

## Diagnósticos dos modelos selecionados

A dependência *cross-sectional* se apresenta em painéis com longas séries de tempo. A hipótese nula é de que os resíduos através dos indivíduos não estão correlacionados. Nossa amostra, para nenhum dos três modelos, aceita a hipótese nula do teste de Pesaran (2015), portanto, os dados estão correlacionados.

 O teste Breusch-Pagan (1979 é usado para testar a heteroscedasticidade em um modelo de regressão linear. A hipótese nula é a de que não há homocedasticidade nos resíduos. Apenas a  $selic$ aceita a hipótese nula, portanto, há problemas nos resíduos das outras duas regressões,  então, as variáveis apresentam problemas de heterocedasticidade. De acordo com Uchôa (2012), não é incomum que modelos de efeito fixo apresentem comportamento heterocedástico, que decorre naturalmente das diferenças individuais. 

> **O que podemos fazer:**
>
> - ~~Detalhar a construção da surpresa~~;
> - Mostrar o impacto da surpresa sobre as previsões Focus;
> - Verificar se há diferença nas alterações das previsões nos momentos onde há surpresa *versus* comentos sem surpresa;
> - Comparar a surpresa que você está propondo com uma medida mais tradicional de choque;

> **Observações:**
>
> - A surpresa também pode ser chamada de *choque de política monetária*;
> - ~~Certamente utilizaremos regressões para dados em painel~~;
> - Tenho um material explicando de forma intuitiva as diferenças entre regressões com painéis com efeitos fixos e aleatórios;
> - Se ficarmos sem tempo podemos usar o Gretl para essas estimações;
> - Testaremos individualmente se a surpresa afeta as previsões das outras variáveis (Selic, IPCA e câmbio)
> - A medida mais tradicional de choque seria simplesmente estimar uma **Regra de Taylor** para a Selic e usar os resíduos dessa equação como sendo os choques não antecipados (ou seja, a surpresa). Isso é fácil fazer.
