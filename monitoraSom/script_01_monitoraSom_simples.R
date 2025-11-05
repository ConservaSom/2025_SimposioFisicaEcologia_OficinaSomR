
### 1. Carregar o monitoraSom e outros pacotes necessários.
library(monitoraSom)
library(dplyr)
library(ggplot2)
library(patchwork)

### 2. Organizando o ambiente de trabalho.
# Vamos verificar e, se necessário, ajustar manualmente o
# diretório de trabalho da sessão atual.
getwd()
project_path <- paste0(getwd(), "/monitoraSom")
setwd(project_path)
getwd()

# 3. Verificando os arquivos de exemplo do monitoraSom.
list.files("./soundscapes/", full.names = TRUE)
list.files("./recordings/", full.names = TRUE)
list.files("./roi_tables/", full.names = TRUE)

# 4. Usando o app de segmentação para escolher os templates.
launch_segmentation_app(
    user = "User", project_path = "./", preset_path = "./app_presets/",
    soundscapes_path = "./recordings/", roi_tables_path = "./roi_tables/",
    cuts_path = "./templates/", dyn_range = c(-102, -42),
    wl = 1024, ovlp = 50, color_scale = "greyscale 1", nav_autosave = TRUE
)

# 5. Usando o app de segmentação para segmentar as soundscapes.
launch_segmentation_app(
    user = "User", project_path = "./", preset_path = "./app_presets/",
    soundscapes_path = "./soundscapes/", roi_tables_path = "./roi_tables/",
    dyn_range = c(-102, -42), wl = 1024, ovlp = 50,
    color_scale = "greyscale 1", visible_bp = TRUE, nav_autosave = TRUE
)

# 6. Extraindo os templates das tabelas de ROIs. Importando
# as tabelas de ROIs. Note que com o processo abaixo
# selecionamos apenas um template de cada tipo (Substructure
# C e Complete Song).
df_templates <- fetch_rois(rois_path = "./roi_tables/") %>%
    filter(roi_comment %in% c("Substructure C", "Complete Song")) %>%
    group_by(roi_comment) %>%
    sample_n(1)
glimpse(df_templates)

# 7. Exportando os cortes de audio dos templates.
export_roi_cuts(df_rois = df_templates, roi_cuts_path = "./templates/")

# 8. Obtendo as detecções (processo simplificado)
df_detecs <- template_matching(
    soundscapes_path = "./soundscapes/", # local de origem das soundscapes
    templates_path = "./templates/", # local de origem dos templates
    output_file = "./detections/df_detecs.csv", # resultado (detecções)
    ncores = 4
)
glimpse(df_detecs)

### 9. Validando as detecções (método a priori)
df_validated <- validate_by_overlap(
    df_detecs = df_detecs, df_rois = df_rois, validation_user = "User"
)
glimpse(df_validated)


### 10. Diagnósticos de performance.
ls_val_apriori <- diagnostic_validations(
    df_validated = df_validated, pos_prob = 0.90, val_a_priori = TRUE
)

# 11. Filtrando as detecções finais.
template1_score <- ls_val_apriori[[1]]$score_cut
template2_score <- ls_val_apriori[[2]]$score_cut
template1_name <- ls_val_apriori[[1]]$diagnostics$template_name[1]
template2_name <- ls_val_apriori[[2]]$diagnostics$template_name[1]

detecs_final <- df_detecs %>%
    filter(
        (template_name == template1_name & peak_score >= template1_score) |
        (template_name == template2_name & peak_score >= template2_score)
    )
glimpse(detecs_final)


# 12. Transformando as detecções finais em tabelas de ROIs
dir.create("./final_detecs")
df_rois_final <- detecs_to_rois(
    df_detecs = df_final, username = "User",
    output_path = "./final_detecs/"
)
