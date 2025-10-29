################ Tutorial - monitoraSom - parte 06 #################
################### Rodando o template matching ####################
############### Gabriel L. M. Rosa UEL/ConservaSom #################

# Seja bem-vindo(a) ao tutorial do monitoraSom! Nessa sexta etapa, vamos
# aprender a organizar os dados e rodar a busca dos sinais alvo por meio do
# algoritmos de template matching usando o monitoraSom.

library(monitoraSom)
library(dplyr)

# 34. Para começar a organizar os dados para rodar a busca, temos que ter
#     dispoíveis os metadados das soundscapes e dos templates. Para não ter que
#     rodar o passo 31 do script 05 novamente, vamos importar os metadados já
#     processados.
df_soundscapes <- read.csv("./soundscapes_metadata/df_soundscapes.csv")
glimpse(df_soundscapes)

# Em seguida, vamos importar os metadados dos templates, conforme demonstrado no
# passo 32 do script 05.
df_templates <- fetch_template_metadata(
    templates_path = "./templates", recursive = TRUE
)
glimpse(df_templates)

# 35. Antes de rodar a busca, precisamos juntar os metadados das soundscapes e
#     dos templates em uma unica tabela e fazer checagens para garantir que o
#     template matching ocorra segundo planejado. O resultado dessa combinção é
#     o que podemos chamar de grade de busca. As função que produz essa grade
#     faz mais do que produzir uma combinação par a par entre todas as
#     soundscapes e templates, ela também faz checagens de compatibilidade entre
#     os arquivos. Uma dessas checagens, por exemplo, garante que a taxa de
#     amostragem das soundscapes seja compatível com a taxa de amostragem dos
#     templates. Casos de incompatibilidade são automaticamente omitidos e
#     retornam alertas para o usuário.
df_grid <- monitoraSom::fetch_match_grid(
    soundscape_data = df_soundscapes, template_data = df_templates
)

# Vamos fazer uma breve checagem para verificar se de fato temos a combinação de
# todos os templates com todas as soundscapes. Como temos 6 templates e 12
# soundscapes, esperamos que a grade de busca tenha 72 combinações.
glimpse(df_grid) # Inspecionando o resultado

# contando o número de ocorrências de cada template
count(df_grid, template_file)

# 36. A seguir vamos rodar a busca usando a grade produzida acima como
#     referencia. Vamos demonstrar diferentes forma e opções para adaptar o
#     processamento às necessidades do usuário.

# 36.1 -  A primeira opção, a mais simples, é usar a função run_matching() no
#   modo padrão.
df_detections <- run_matching(df_grid = df_grid)
#   Os resultados pruduzidos são uma tabela de detecções contendo todos os
#   metadados da grade original da busca juntamente com os metadados das
#   detecções,
glimpse(df_detections)

# Para acelerar um pouco o processamento, vamos distribuir a tarefa para 4
# núcleos ao invés de somente um, como no modo padrão. Quatro núcleos é uma
# quantidade segura para a maior parte dos computadores. Se desejar usar mais,
# recomendamos checar a quantidade de núcleos disponíveis no seu computador
# (usando a função parallel::detectCores()).
df_detections <- run_matching(df_grid = df_grid, ncores = 4)
glimpse(df_detections) # os resultados são os mesmos do modo padrão

# 36.2 - Na segunda opção, vamos usar os argumentos de filtragem para reduzir a
#   quantidade de detecções segundo três critérios: (1) o tamanho do buffer, que
#   exclui detecções com scores menores nas imediações de detecções com scores
#   maiores, para evitar várias detecções sobrepostas, (2) o score mínimo, que
#   exclui todas as detecções com scores inferiores ao valor especificado, (3) o
#   quantil mínimo, que exclui todas as detecções com scores inferiores ao
#   quantil especificado segundo a distribuição de scores e (4) as n detecções
#   com scores mais altos. Todos os filtros realizam essas filtragens somente
#   dentro dos scores obtidos para cada combinação de template e soundscape.
teste01 <- run_matching(
    df_grid = df_grid, ncores = 4,
    buffer_size = "template", min_score = 0.6, min_quant = NULL, top_n = NULL
)
# Agora restam somente 2 detecções. Note que como estabelecemos um limite
# explicito para o score, a maioria das combinações de template e soundscape foram omitidas por não terem produzido scores suficientemente altos e foram omitidas.
glimpse(teste01)
count(teste01, template_file)

# 36.3 - Na terceira opção, vamos usar o argumento top_n para reter somente a
#   melhor detecção em cada combinação de template e soundscape. Note que dessa
#   vez, queremos somente a melhor detecção em cada combinação, independente do
#   score, então vamos ter uma detecção representativa de cada combinação entre
#   template e soundscape.
teste02 <- run_matching(
    df_grid = df_grid, ncores = 4, top_n = 1
)
glimpse(teste02) # Agora restam somente 72 detecções.

# Recomendamos cautela antes de filtrar dados de detecções que ainda serão
# destinadas à validação, produzindo vieses consideráveis nos diagnósticos de
# performance.

# Assim como na obtenção dos metadados das soundscapes, o resultado da busca
# pode demorar para terminar de ser processado. Por isso, desenvolvemos opções
# para o salvamento automático do arquivo CSV contendo as detecções. Repare que
# quando forncecemos um caminho para o arquivo, não foi necessário depositar o
# resultado em um objeto no mesmo comando. Nesse caso, importaremos o resultado
# logo em seguida.
run_matching(
    df_grid = df_grid, ncores = 4, autosave_action = "replace",
    output_file = "./detections/df_detections.csv"
)
df_detections <- read.csv("./detections/df_detections.csv")
glimpse(df_detections)

# Alternativamente, podemos usar a opção autosave_action = "append" para
# adicionar os resultados ao arquivo existente, evitando sobrescrever resultados
# já depositados naquele arquivo. Nesse caso, a função processo somente as
# partes de grade que ainda não foram processadas.

# 36.4 - A nossa quarta opção apresenta o algoritmo Dynamic Time Warping (DTW)
#   como alternativa à correlação de Pearson. O DTW é um algoritmo de
#   alinhamento de sinais que busca a melhor correspondência entre dois sinais,
#   mesmo que eles tenham diferentes durações ou freqüências. Ainda em estágio
#   experimental nessa aplicação, espera-se do DTW uma performance similar à
#   correlação de Pearson, mas com performance mais estável para sinais menos
#   estereotipados.
df_detections_DTW <- run_matching(
    df_grid = df_grid, ncores = 4, score_method = "dtw",
    output_file = "./detections/df_detections_dtw.csv"
)

# 36.5 - A nossa quinta e última opção é destinada aos casos de uso mais
#   específicos, onde se deseja obter os scores brutos, ou seja, reter os
#   vetores brutos com a totalidade dos scores obtidos a cada linha da grade de
#   busca.
df_scores <- run_matching(
    df_grid = df_grid, ncores = 4, output = "scores",
    output_file = "./detections/df_scores.rds"
)
glimpse(df_scores)

# Podemos importar novamente o resultado com os scores usando o seguinte comando
df_scores <- readRDS("./detections/df_scores.rds")
glimpse(df_scores)

# 37 - Uma das principais vantagens de armazenar os dados na forma de scores
# brutos é a possibilidade de ajustar os filtros de forma interativa a partir da
# visualização direta. Veja a sequência de plots a seguir:
plot_scores(df_scores_i = df_scores[1, ])

# 37.1 - Vamos precisar fazer alguns ajustes para poder chegar em uma
# visualização mais útil. Para isso vamos mudar para um match onde detecções
# foram obviamente encontradas e fazer um ajuste na faixa dinâmica do
# espectrograma (contraste de cor) para ver melhor o que está acontencendo.
# Temos várias detecções, algumas mais promissoras que outras, então precisamos
# refinar também a filtragem.
plot_scores(
    df_scores_i = df_scores[20, ],
    ovlp = 90, wl = 2048, dyn_range = c(-96, -48)
)

# 37.2 - Agora vamos ver o que acontece quando alteramos o buffer, desligando ele
# completamente (fornecendo valor 0 para a quantidade de frames ao redor de cada
# pico do score). Note que agora cada pico, por menor que seja, não é mais eliminado pelos filtros.
plot_scores(
    df_scores_i = df_scores[20, ],
    ovlp = 90, wl = 2048, dyn_range = c(-96, -48),
    buffer_size = 0 # desligamos o buffer aqui
)

# 37.3 - Vamos manter o buffer desligado e determinar um nível de corte genérico.
plot_scores(
    df_scores_i = df_scores[20, ],
    ovlp = 90, wl = 2048, dyn_range = c(-96, -48),
    buffer_size = 0, min_score = 0.20 # 0.20 para começar a ajustar
)

# 37.4 - Vamos subindo um pouco o nível de corte...
plot_scores(
    df_scores_i = df_scores[20, ],
    ovlp = 90, wl = 2048, dyn_range = c(-96, -48),
    buffer_size = 0, min_score = 0.25 # subindo um pouco o corte
)

# 37.5 - Até chegar ao corte exato em que retemos somente detecções que
# representam ocorrências reais do pula-pula.
plot_scores(
    df_scores_i = df_scores[20, ],
    ovlp = 90, wl = 2048, dyn_range = c(-96, -48),
    buffer_size = 0, min_score = 0.287 # fazendo um ajuste mais fino
)

# 37.6 - Será que funciona replicar o mesmo corte para um score do mesmo
# template em outra soundscape? Vamos replicar com os mesmos settings para
# visualizar a diferença. Note que existem outros sinais acústicos com maiores
# scores que não são eliminados pelo nível de corte anterior.
plot_scores(
    df_scores_i = df_scores[26, ],
    ovlp = 90, wl = 2048, dyn_range = c(-96, -48),
    buffer_size = 0, min_score = 0.287
)

# 37.7 - Vamos tentar mexer nos outros filtros na busca de melhores resultados.
# Reter somente os top 1% ajuda bastante, mas ainda não resolve. Notem que ainda
# restam algumas regiões mal resolvidas, com vários picos sobrepostos sendo
# mantidos.
plot_scores(
    df_scores_i = df_scores[30, ],
    ovlp = 90, wl = 2048, dyn_range = c(-96, -48),
    buffer_size = 0, min_quant = 0.99
)

# 37.8 - Como raramente achamos mais de 10 cantos de pula-pula por minuto
# gravado, pode ser uma idéia interessante tentar manter somente as detecções
# com os 10 maiores scores. Mas mesmo assim ainda temos a mesma região mal
# resolvida.
plot_scores(
    df_scores_i = df_scores[30, ],
    ovlp = 90, wl = 2048, dyn_range = c(-96, -48),
    buffer_size = 0, top_n = 10
)

# 37.9 - Vamos ligar novamente o buffer para verificar se ele ajuda a resolver
# as regiões mal resolvidas desse vetor de scores. Perceba que agora as 10
# detecções que foram mantidas estão mais "espalhadas". Assim conseguimos evitar
# manter múltiplas detecções sobrepostas, que representam um mesmo trecho da
# soundscape, aumentando a representatividade delas enquanto mantemos a mesma
# quantidade final de detecções.
plot_scores(
    df_scores_i = df_scores[26, ],
    ovlp = 90, wl = 2048, dyn_range = c(-96, -48),
    buffer_size = "template", top_n = 10
)

# 37.10 - Agora que já chegamos aos nossos critérios finais de filtragem,
# podemos seguir com a obtenção da tabela de detecções para seguir com a
# validação. Para ilustrar nosso próximo exemplo, vamos fazer duas versões. Na
# primeira vamos usar a filtragem definida no exemplo acima:
df_detecs_filt <- fetch_score_peaks(
    df_scores = df_scores,
    buffer_size = "template", top_n = 10,
    output_file = "./detections/df_detections_filtered.csv"
)
glimpse(df_detecs_filt)

# Na segunda vamos desligar completamente o filtro e reter detecções
# correspondentes a todos os picos dos vetores de scores.
df_detecs_raw <- fetch_score_peaks(
    df_scores = df_scores,
    buffer_size = 0,
    output_file = "./detections/df_detections_unfiltered.csv"
)
glimpse(df_detecs_raw)

# Vamos rever a quantidade de detecções que obtivemos com cada método
nrow(df_detections) # default - buffer ligado
nrow(df_detecs_raw) # sem filtro - buffer desligado
nrow(df_detecs_filt) # filtro forte - buffer ligado e top 10 por match