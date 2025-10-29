################ Tutorial - monitoraSom - parte 07 #################
################### Validando as detecções ##########################
############### Gabriel L. M. Rosa UEL/ConservaSom #################

# Seja bem-vindo(a) ao tutorial do monitoraSom! Nessa sétima etapa, vamos
# aprender a validar as detecções produzidas pelo monitoraSom.

library(monitoraSom)
library(dplyr)

# Antes de começar a validar as detecções, vamos importar os resultados da busca realizada no script 06.

# As detecções com o modo padrão de processamento (somente o buffer ligado)
df_detecs <- read.csv("./detections/df_detections.csv") %>%
    glimpse()
# As detecções feitas a partir dos scores brutos usando o algoritmo Dynamic Time Warping (DTW)
df_detecs_dtw <- read.csv("./detections/df_detections_dtw.csv") %>%
    glimpse()
# As detecções com o filtro de scores forte (buffer ligado e top 10 por match)
df_detecs_filt <- read.csv("./detections/df_detections_filtered.csv") %>%
    glimpse()
# As detecções feitas a partir dos scores brutos (sem filtro e sem buffer)
df_detecs_raw <- read.csv("./detections/df_detections_unfiltered.csv") %>%
    glimpse()

# Vamos rever a quantidade de detecções que obtivemos com cada método
nrow(df_detecs) # default - buffer ligado
nrow(df_detecs_dtw) # scores brutos - DTW
nrow(df_detecs_filt) # filtro forte - buffer ligado e top 10 por match
nrow(df_detecs_raw) # scores brutos - sem filtro e sem buffer

## VALIDAÇÃO A PRIORI (automática)

# 38 - Se vamos conduzir a validação pelo método a priori, precisamos importar os dados de segmentação manual.
df_rois_raw <- fetch_rois(rois_path = "./roi_tables/") %>%
    glimpse()
# Como temos a segmentação das gravações de onde extraímos os templates, vamos precisar fazer uma pequena filtragem antes de prosseguir.
df_rois <- df_rois_raw %>%
    filter(!grepl("Bcu", soundscape_file)) %>%
    glimpse()

# 39 - Agora sim, podemos validar as detecções. A função validate_by_overlap()
# produz uma tabela com a validação cruzada entre as detecções e os dados de
# segmentação manual (tabelas de ROIs). O processo de atribuição do status de
# verdadeiro ou falso é realizado de forma automatizada com base na sobreposição
# entre a detecção e a ROI no eixo do tempo. Note que como o processo não
# envolve o processamento de arquivos, somente a checagem de sobreposição, o
# tempo de processamento é praticamente instantâneo.
df_val <- validate_by_overlap(
    df_detecs = df_detecs, df_rois = df_rois,
    validation_user = "Informe seu nome aqui",
    output_path = "./validation_outputs/df_val-auto.csv"
)
glimpse(df_val)

df_val_dtw <- validate_by_overlap(
    df_detecs = df_detecs_dtw, df_rois = df_rois,
    validation_user = "Informe seu nome aqui",
    output_path = "./validation_outputs/df_val-auto_dtw.csv"
)
glimpse(df_val_dtw)

df_val_filt <- validate_by_overlap(
    df_detecs = df_detecs_filt, df_rois = df_rois,
    validation_user = "Informe seu nome aqui",
    output_path = "./validation_outputs/df_val-auto_filt.csv"
)
glimpse(df_val_filt)

df_val_raw <- validate_by_overlap(
    df_detecs = df_detecs_raw, df_rois = df_rois,
    validation_user = "Informe seu nome aqui",
    output_path = "./validation_outputs/df_val-auto_raw.csv"
)
glimpse(df_val_raw)

# 40. Vamos explorar um pouco esses resultados para ver mais detalhes sobre o
#     que acontecer por detras dos panos:
count(df_val, validation)
# Notem que nesse caso temos vários FP (False Positives), que são detecções que
# não correspondem a nenhuma ROI, vários TP (True Positives), que são detecções
# que correspondem a uma ROI, mas temos 2 FN (False Negatives), que são ROIs que
# não foram alcançadas por nenhuma detecção. Vamos checar os demais casos:

count(df_val, template_name, validation)
count(df_val_dtw, template_name, validation)
count(df_val_filt, template_name, validation)
count(df_val_raw, template_name, validation)

# VALIDAÇÃO A POSTERIORI (manual)

# 41. Vamos considerar um cenário alternativo, onde não temos tabelas de ROIs
#     que nos permitam validar as detecções de forma automática. Nesse caso,
#     vamos validar as detecções manualmente. Para isso, vamos usar o app de
#     validação manual do monitoraSom.

# Como esse processo altera as tabelas de detecções, é uma boa prática trabalhar com cópias das tabelas originais.
write.csv(
    df_detecs, "./validation_outputs/df_val-manual.csv", row.names = FALSE
)
write.csv(
    df_detecs_dtw, "./validation_outputs/df_val-manual_dtw.csv", row.names = FALSE
)
write.csv(
    df_detecs_filt, "./validation_outputs/df_val-manual_filt.csv", row.names = FALSE
)
write.csv(
    df_detecs_raw, "./validation_outputs/df_val-manual_raw.csv", row.names = FALSE
)

launch_validation_app(
    project_path = "./",
    preset_path = "./app_presets/",
    validation_user = "Informe seu nome aqui",
    input_path =
)