# Resultados

## Sinais esperados

>Conforme Gonçalves & Junior (2011), espera-se que o coeficiente da surpresa seja significativo a 1% e apresente sinal negativo.
>
>Em Oliveira & Ramos (2011) o coeficiente do componente não esperado (choque de política monetária) apresenta sinal negativo em todas as maturidades analisadas (2, 3, 6, 9, 12, 15, 18 e 24 meses).
>
>Zabot, Caetano & Caldeira (2013) indicam que as taxas de juros de DI futuro respondem à mudanças não esperadas na Meta Selic, também apresentando coeficiente negativo. No entanto, seus coeficientes dos títulos de menor maturidade são relativamente baixos em comparação ao exposto, por exemplo, em Tabak (2004), possivelmente sendo explicados pelo aumento da capacidade de antecipação das instituições das ações do Bacen.
>
>Kuttner (2001), apresentando uma extensão da equação de Cook & Hahn (1989), chega a um resultado em linha com os anteriores, apresentando os coeficientes da surpresa de política monetária negativos. Entretanto, sua significância estatística é baixa, o que é justificado pelo número pequeno de observações de sua amostra.

## Escolha do método econométrico

| Pergunta                            | Teste utilizado                               | Hipótese nula          | Resultado |
| ----------------------------------- | --------------------------------------------- | ---------------------- | --------- |
| MQO Agrupado ou Efeitos Fixos?      | F Test for Individual and/or Time Effects     | MQO Agrupado é melhor  |           |
| MQO agrupado ou Efeitos Aleatórios? | Lagrange FF Multiplier Tests for Panel Models |                        |           |
| Efeitos fixos ou aleatórios?        | Hausman Test for Panel Models                 | Efeitos Fixos é melhor |           |

## Parâmetros estimados

## Diagnósticos dos modelos selecionados

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
