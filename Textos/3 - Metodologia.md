# Metodologia

> **O que já dá para fazer?**
>
> - Dizer qual a amostra foi utilizada na análise;
> - Justificar o motivo de ter usado essa amostra;
> - ~~Descrever a base de dados~~;
> - Colocar os gráficos das séries utilizadas.

Para a análise da reação das instituições frente às surpresas de política monetária, foram utilizados os microdados do Relatório de Mercado Focus (disponíveis em <**url**>), onde cada seção transversal semanal fornece uma amostra representativa das instituições. O Bacen realiza, semanalmente, uma pesquisa com a projeção de cerca de 150 instituições financeiras com as principais estatísticas do cenário econômico. O Boletim Focus também destaca as cinco empresas que mais acertam em suas projeções. Toda segunda-feira ele é publicado no site oficial do Bacen com um compilado dos indicadores macroeconômicos mais importantes para a economia. Entre os indicadores analisados estão o IPCA, o IGP-M, a taxa de câmbio, a taxa de crescimento do PIB e a taxa Selic. 

Os indicadores são compilados na sexta-feira anterior à publicação a partir de informações repassadas pelos principais bancos, agentes econômicos e instituições financeiras. As expectativas projetadas para o fechamento daquele ano são reunidas durante a semana e compiladas na sexta-feira. Os dados no relatório costumam ser apresentados em forma de tabela e em formato de gráfico. A tabela traz o comportamento dos indicadores na data de publicação do relatório, da semana anterior e do último mês. 

O Boletim Focus é divulgado às 08:00 de todas as segundas-feiras do ano no site oficial do Banco Central do Brasil. Na primeira página, encontramos uma tabela anual intitulada “Mediana – Agregado”. Isso significa que os números na tabela são a mediana de todos os agentes consultados pelo Bacen que fazem esse tipo de projeção. As sessões mostram a expectativa para o ano vigente e para os próximos três anos. As três primeiras colunas da tabela mostram, respectivamente, a expectativa do comportamento dos indicadores no dia da publicação, na semana anterior e no último mês (quatro semanas antes). 

## Especificação dos dados utilizados

Para atender aos propósitos deste ensaio, utilizaremos os microdados do Boletim Focus, contendo o código identificador da instituição, o indicador projetado, a data onde a projeção foi realizada, o mês de referência dessa projeção, a data da reunião do Copom correspondente à projeção e a meta da taxa Selic definida na reunião. Usamos as projeções anualizadas, ou seja, a projeção realizada no mês $t$ refere-se ao ano corrente daquele mês. Utilizaremos as projeções das seguintes variáveis:

| Variável                             | Abreviação     | Período           |
| ------------------------------------ | -------------- | ----------------- |
| Taxa básica de juros                 | $selic^{meta}$ | 2003:01 - 2020:12 |
| Taxa nominal de câmbio               | $cambio$       | 2003:01 - 2020:12 |
| Índice de Preços ao Consumidor Amplo | $ipca$         | 2003:01 - 2020:12 |
| Produto Interno Bruto                | $pib$          | 2003:01 - 2020:12 |

Com essa amostra é possível verificar, por instituição, se suas projeções são modificadas com uma surpresa de política monetária. 

Diferente de outros ensaios presentes na literatura, conseguimos ver, por cada instituição, historicamente, como suas projeções são modificadas com uma surpresa de política monetária. 

Visto que, na literatura, outros ensaios buscam verificar como uma surpresa de política monetária impacta o mercado de capitais ou as taxas de juros de mercado e utilizam-se de medidas de tendência central, como a média de fim de período ou, mais comumente, a mediana, com essa amostra de dados, será possível verificar como as instituições alteram, historicamente, suas projeções quando ocorre uma surpresa de política monetária.

### Taxa básica de juros - Selic

A meta da Selic é a taxa básica de juros da economia definida a cada 45 dias. É o principal instrumento de política monetária utilizado pelo Bacen para controlar a inflação. Ela influencia todas as taxas de juros do país, como as taxas de juros dos empréstimos, dos financiamentos e das aplicações financeiras. A taxa Selic refere-se à taxa de juros apurada nas operações de empréstimos de um dia entre as instituições financeiras que utilizam títulos públicos federais como garantia. O Bacen opera no mercado de títulos públicos para que a taxa Selic efetiva esteja em linha com a meta da Selic definida na reunião do Copom.

O nome da taxa Selic vem da sigla do Sistema Especial de Liquidação e de Custódia. Trata-se de uma infraestrutura do mercado financeiro administrada pelo Bacen. Nele são negociados títulos públicos federais. A taxa média ajustada dos financiamentos diários apurados nesse sistema corresponde à taxa Selic. As infraestruturas do mercado financeiro como um todo desempenham um papel fundamental no âmbito do SFN. Seu funcionamento adequado é essencial para a estabilidade financeira e condição necessária para salvaguardar os canais de transmissão da política monetária. 

O sistema Selic é fundamental em possíveis casos de falência ou insolvência de instituições financeiras. A liquidação em tempo real e o registro das transações com títulos públicos federais em seu banco de dados pode coibir fraudes e prevenir o contágio em outras instituições. Esta série será utilizada como base para o cálculo da surpresa de política monetária.

### Taxa nominal de câmbio

Taxa de câmbio nominal é a taxa que expressa a relação de valor entre duas moedas de países diferentes. Outra forma de defini-la é como o custo de uma moeda em relação a outra. Por definição, a taxa nominal são os numerais expressos diretamente como taxa de câmbio, que são as divulgadas pelas casas de câmbio.

As taxas de câmbio entre as diversas moedas variam a todo instante. Essas variações são denominadas de apreciação nominais ou depreciação nominais. A apreciação de uma moeda domestica é o aumento do seu preço em relação à outra estrangeira e a depreciação, de maneira inversa, significa que o preço da moeda nacional em relação à estrangeira esta caindo.

### Índice de Preços ao Consumidor Amplo - IPCA

O Sistema Nacional de Índices de Preços ao Consumidor (SNIPC) consiste em uma combinação de processos destinados a produzir índices de preços ao consumidor. O objetivo é acompanhar a variação de preços de um conjunto de produtos e serviços consumidos pelas famílias.

O sistema abrange as regiões metropolitanas do Rio de Janeiro, Porto Alegre, Belo Horizonte, Recife, São Paulo, Belém, Fortaleza, Salvador e Curitiba, além do Distrito Federal e do município de Goiânia. É a partir da agregação dos índices regionais referentes a uma mesma faixa de renda que se obtém o índice nacional.

A população-objetivo do IPCA é referente a famílias residentes nas áreas urbanas das regiões de abrangência do SNIPC com rendimentos de 1 (hum) e 40 (quarenta) salários-mínimos, qualquer que seja a fonte de rendimentos. A Pesquisa é realizada em estabelecimentos comerciais, prestadores de serviços, domicílios e concessionárias de serviços públicos mensalmente.

### PIB

O Produto Interno Bruto (PIB) representa a soma (em valores monetários) de todos os bens e serviços finais produzidos numa determinada região, sejam países, estados ou cidades, durante um período determinado (mês, trimestre, ano, etc). 

Na contagem do PIB, considera-se apenas bens e serviços finais, excluindo da conta todos os bens de consumo de intermediário. Isso é feito com o intuito de evitar o problema da dupla contagem, quando valores gerados na cadeia de produção aparecem contados duas vezes na soma do PIB.

Conforme abordado anteriormente, apesar de o Boletim Focus fornecer projeções para três anos a frente, a análise focará apenas no curto prazo (de 1 a 12 meses).

Dado que as instituições realizam projeções em datas diferentes, para conseguirmos realizar análises com datas equivalentes, o valor projetado no instante $t$ foi estendido para as datas posteriores até a próxima projeção realizada.

### Surpresa de política monetária

> **O que precisa ser feito:**
>
> - Definir o que é a surpresa, sem equações, só a ideia.

## Estratégia econométrica

> **O que podemos fazer:**
>
> - Detalhar a construção da surpresa;
> - Mostrar o impacto da surpresa sobre as previsões Focus;
> - Verificar se há diferença nas alterações das previsões nos momentos onde há surpresa *versus* comentos sem surpresa;
> - Comparar a surpresa que você está propondo com uma medida mais tradicional de choque;

> **Observações:**
>
> - A surpresa também pode ser chamada de *choque de política monetária*;
> - Certamente utilizaremos regressões para dados em painel;
> - Tenho um material explicando de forma intuitiva as diferenças entre regressões com painéis com efeitos fixos e aleatórios;
> - Se ficarmos sem tempo podemos usar o Gretl para essas estimações;
> - A medida mais tradicional de choque seria simplesmente estimar uma **Regra de Taylor** para a Selic e usar os resíduos dessa equação como sendo os choques não antecipados (ou seja, a surpresa). Isso é fácil fazer.