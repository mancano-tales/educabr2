# Rascunho: issue para SidneyBissoli/educabR

> Publicado em 2026-10-26 como SidneyBissoli/educabR#29 (texto abaixo). Repositório:
> <https://github.com/SidneyBissoli/educabR/issues/29>

---

**Título:** Proposta de contribuição: Sinopse da Educação Superior 1995–2008 e séries históricas

Olá, Sidney!

Sou Tales Mançano, mestrando na USP. Para a minha dissertação, sobre a
expansão da educação superior no Brasil, construí o
[`educabr2`](https://github.com/mancano-tales/educabr2), um pacote R com
séries históricas da educação brasileira: matrícula desde 1871, anos médios
de estudo desde 1925, gasto público desde 1933, compiladas a partir de
reconstruções acadêmicas (Kang et al., Walter & Kang, Maduro Junior) e dos
registros do INEP, e harmonizadas entre fontes e quebras de série.

Os dois pacotes já se citam como complementares: o README do `educabr2`
indica o `educabR` para microdados atuais. Mas o nome quase igual e o mesmo
público me fizeram pensar que faria mais sentido somar do que manter dois
pacotes paralelos no CRAN. Gostaria de propor duas contribuições, pensadas
para caber na arquitetura do `educabR` (download sob demanda, cache, nomes em
português), sem dados embutidos e sem dependências novas:

**1. `get_sinopse_superior()` — Sinopse Estatística da Educação Superior,
1995–2008.** O `get_censo_superior()` começa em 2009. Antes disso, o INEP
publicou as sinopses em xlsx, com matrícula por categoria administrativa,
organização acadêmica e (a partir de 2000) EAD em tabela separada. Eu já
tratei essas tabelas para a dissertação e posso escrever a função no padrão
das demais (download do portal do INEP, cache, colunas como o INEP publica),
com testes e documentação.

**2. `get_series_historicas()` — séries harmonizadas de longo prazo.** As
séries do `educabr2` seriam publicadas como um conjunto de dados versionado,
com DOI (release no GitHub + Zenodo), e o `educabR` ganharia uma função que
baixa e guarda esse arquivo em cache, como já faz com os arquivos do INEP.
Exemplo: `get_series_historicas(tema = "matriculas", nivel = "superior")`.
Sei que isso foge um pouco do "direto das agências" do README; por isso
deixo como proposta separada, para você decidir se faz sentido.

Da minha parte, eu escreveria e manteria esse código, seguindo o estilo do
pacote (Air, testes, NEWS), e licenciaria as contribuições como MIT. Se
fizer sentido para você, a primeira seria um PR com o item 1, que é útil
independentemente do item 2.

O que acha? Fico à vontade para ajustar o escopo, os nomes ou o formato.

Obrigado pelo pacote — o `get_censo_escolar()` me poupou muito trabalho na
dissertação.

Tales

Agent: Claude Code / Opus 5.5 / desktop
