# Proposta: reposicionar o educabr2 no BRverse (2026-09)

> **Status:** em discussão — nada implementado. Decisões abertas no fim.
> **Substitui em parte:** [`integration-educabR.md`](integration-educabR.md)
> (cenários A/B/C) e [`integration-pnadc.md`](integration-pnadc.md)
> (que supõe população 25+; a série de Walter & Kang é de **15–64**).

## 1. O problema

Quem quer estudar a educação brasileira no longo prazo precisa
descobrir, do zero, onde estão as séries, como elas se sobrepõem e
como compatibilizá-las. A auditoria de 2026-09-24 mostrou o custo
disso na prática: fontes que se repetem, categorias administrativas
classificadas de forma diferente (INEP "Especial"), séries "totais"
que na verdade são só presenciais (Kang 2000–2008), tabelas impressas
que não fecham (Durham 2005).

A contribuição do pacote **não são os datasets** (são de outros
autores e devem ser citados como tal), e sim o **trabalho de
harmonização**: as decisões, os testes de consistência e a ligação
entre fontes. Um depósito com DOI publicaria dados alheios; o pacote
publica o método, pronto para reuso.

## 2. Posicionamento proposto

> **educabr2 é a camada de séries históricas harmonizadas da educação
> brasileira no BRverse.** Ele não baixa microdados: entrega as séries
> longas prontas, documenta cada decisão de compatibilização e liga
> essas séries ao presente usando os pacotes que já baixam os dados.

| Pacote | Papel | Relação com o educabr2 |
|---|---|---|
| `educabR` (Bissoli) | Microdados e indicadores atuais do INEP (Censo Escolar, Censo Superior, IDEB, SAEB…) | Fonte dos anos recentes; educabr2 agrega e emenda |
| `PNADcIBGE` (IBGE) | PNAD Contínua | Anos de estudo após 2015 |
| `censobr` (IPEA) | Censos demográficos | Escolaridade por UF/município em 2000/2010/2022 |
| `geobr` (IPEA) | Malhas | Mapas das séries por UF |
| `ipeadatar` | Séries do Ipeadata | Comparação/validação de séries agregadas |

A separação de papéis deixa o educabr2 **complementar** ao educabR,
não concorrente: um responde "me dê o dado do INEP de 2023", o outro
responde "me dê a série de 1933 até hoje, compatibilizada".

## 3. Frentes de trabalho

### F1 — API: nomes e consistência (antes do CRAN)

Problemas atuais:

- `get_*` é o mesmo verbo do educabR, com semântica diferente
  (educabR: por fonte; educabr2: por tema harmonizado).
- `get_schooling()` × `get_attainment()`: nomes que não se distinguem
  (anos médios de estudo no Brasil × % que concluiu cada nível, entre
  países).
- `get_progression()` existe para um único indicador (GDR6).
- Argumentos inconsistentes: `indicator = "count"` num lugar, chave
  completa em outro; `get_expenditure()` sem `geo_level`; `dimension`
  com valores diferentes por função.

Duas opções:

**Opção A — verbo `read_*` por tema (padrão IPEA: geobr, censobr,
aopdata)** ← recomendada

| Hoje | Proposto |
|---|---|
| `get_enrollment()` | `read_enrollment()` |
| `get_schooling()` | `read_years_of_schooling()` |
| `get_expenditure()` | `read_education_spending()` |
| `get_progression()` | `read_grade_progression()` |
| `get_attainment()` | `read_attainment_world()` (ou remover — ver D2) |
| `list_sources()` | mantém; + `list_series()` (catálogo de indicadores × cobertura) |

**Opção B — função única por catálogo (padrão WDI/ipeadatar):**
`list_series()` + `read_series("enrollment_rate", level = "medio",
geo_level = "UF")`. Mais enxuta, mas esconde a estrutura temática que
orienta quem está começando.

Em qualquer opção, fixar um conjunto único de argumentos:
`indicator, level, year, geo_level, geo, breakdown, source,
include_derived, wide, lang` — com os mesmos valores aceitos em todas
as funções. Nomes antigos viram aliases com `lifecycle::deprecate_soft()`
por uma versão.

### F2 — O registro de decisões de harmonização

Tornar explícito o que hoje está espalhado em comentários de ETL e no
NEWS. Um arquivo estruturado (`inst/dict/decisions.yaml`), uma entrada
por decisão:

```yaml
- id: D003
  dataset: enrollment_tertiary
  years: [2012, 2024]
  problem: INEP microdata aggregation put "Especial" (art. 242 CF) in privada
  evidence: privada != lucrativa + nao_lucrativa; Power BI puts it in municipal
  decision: move Especial to municipal/publica
  alternatives: [keep as private, drop category]
  test: tests/testthat/test-get-enrollment-tertiary.R
```

Primeiras entradas, já tomadas nesta auditoria: Kang 2000–2008 é só
presencial; "Especial" → municipal; Durham removido; Sinopse repetida
fundida; Lee & Lee (conclusão ⊂ nível frequentado). Faltam as da
dissertação (reforma do EF de 8 para 9 anos; totais reconstruídos
2000–2008).

Expor com `harmonization_notes(dataset = ...)` e renderizar um
artigo pkgdown: **"Como compatibilizar séries educacionais: as
decisões por trás do educabr2"**. Esse é o material que serve de
exemplo de método para quem usa PNADcIBGE, educabR etc.

### F3 — Emenda com o educabR (anos recentes do INEP)

Caso piloto: **matrículas de EF e EM por UF, 1955 → presente**
(Kang até 2010 + Censo Escolar do INEP a partir de 2011).

Decisão de arquitetura (D4): usar o educabR **na hora do build**
(em `data-raw/`), não em tempo de execução. O mantenedor roda o ETL
uma vez por ano, grava agregados pequenos em `data/`, e o usuário
final não precisa baixar gigabytes nem instalar o educabR. Uma
vinheta mostra o caminho sob demanda para cortes que o pacote não
traz (município, rede, escola).

Passos:

- [ ] Spike: conferir o que `educabR::get_censo_escolar()` devolve
      (nível escola? colunas `QT_MAT_*`?) e o custo de baixar 2011–2024.
- [ ] Definir o crosswalk de etapas (EF de 8 → 9 anos, 2006–2010;
      EJA dentro ou fora).
- [ ] Ano de sobreposição (2010: Kang × Censo Escolar) como teste de
      emenda: diferença documentada no registro de decisões.
- [ ] Taxas brutas exigem população por idade/UF: decidir fonte
      (projeções IBGE via `sidrar`, ou PNADc).

### F4 — Anos de estudo após 2015 (PNADcIBGE, censobr)

Retomar [`integration-pnadc.md`](integration-pnadc.md) corrigindo a
população para **15–64** (a série de Walter & Kang). Mesma regra de
F3: agregados construídos em `data-raw/`, vinheta para o caminho sob
demanda. Validar a emenda no ano de sobreposição (2012–2015).
`censobr` entra como checagem por UF nos anos de censo.

### F5 — Ecossistema

- [ ] README: tabela "Pacotes relacionados" (seção 2) e a frase de
      posicionamento.
- [ ] Abrir issue no educabR propondo a divisão de papéis e links
      recíprocos nos READMEs (substitui o cenário de fusão, que o
      conflito de licença MIT × GPL torna caro).
- [ ] Contato com a equipe do IPEA sobre listar o educabr2 no BRverse.

## 4. Sequência sugerida

| Ordem | Frente | Versão | Por quê nessa ordem |
|---|---|---|---|
| 1 | F1 API | 0.2.0 | Renomear é grátis antes do CRAN e caro depois |
| 2 | F2 decisões | 0.2.x | Barato, e é a contribuição central |
| 3 | F5 README + issue educabR | 0.2.x | Sem código; alinha expectativas antes de F3 |
| 4 | F3 emenda educabR | 0.3.0 | Depende do spike |
| 5 | F4 PNADc | 0.4.0 | Mesma arquitetura de F3 |

## 5. Decisões abertas

- [ ] **D1 — Convenção de nomes:** Opção A (`read_*` por tema) ou
      Opção B (`read_series()` com catálogo)?
- [ ] **D2 — Lee & Lee:** manter (renomeado) ou remover? Não é
      brasileiro e já está publicado pelos autores; só se justifica como
      comparação internacional no dashboard.
- [ ] **D3 — CRAN:** o reenvio 0.1.1 já foi feito? Se não, segurar
      até a 0.2.0 com a API nova.
- [ ] **D4 — Emendas:** agregados construídos no build (recomendado)
      ou busca sob demanda em tempo de execução?
