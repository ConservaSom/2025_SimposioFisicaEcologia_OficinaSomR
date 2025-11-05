### 1. Baixar e instalar o R.
# - Verifique se já existe alguma versão instalada.
# - Ao fazer uma nova instalação, dê preferência para a versão mais recente.
# - link para download: https://cran.r-project.org/bin/windows/base/

### 2. Baixar e instalar o Rstudio.
# - Após instalar o R, instale o Rstudio.
# - Atenção: se houver mais de uma versão do R instalada, certifique-se qual
#   está sendo usada ao abrir o Rstudio.
# - link para download: https://posit.co/download/rstudio-desktop/

### 3. Instalar o Rtools (passo necessário apenas para usuários do Windows)
# - Rtools é necessário para compilar pacotes do R que foram instalados a partir
#   do GitHub.
# - Verifique se já existe alguma versão instalada. Caso exista, verifique se é
#   adequada ao projeto. Se não for, desinstale a versão existente.
# - Neste momento, a versão mais recente é a 4.5.
# - link para download: https://cran.r-project.org/bin/windows/Rtools/

### 4. Criar uma nova pasta para conter os arquivos usandos pelo monitoraSom.
# qPara usuários do Windows, recomendamos criar uma pasta para análises na raiz
# do sistema, e dentro dela uma pasta para este projeto, por exemplo, "C:/Meus
# Projetos/monitoraSom_tutorial". Dessa forma o caminho para os arquivos será o
# mesmo mesmo que os arquivos sejam movidos para outro computador.

### 5. Instalar o devtools para poder instalar pacotes a partir do GitHub.
# Esse comando deve ser executado no Rstudio após a instalação do Rtools.
install.packages("devtools")

### 6. Carregar o devtools para o ambiente de trabalho.
library(devtools)

### 7. Instalar o monitoraSom
# - O monitoraSom depende de outros pacotes do R para funcionar adequadamente.
# - Atenção 1: A isntalação poderá solicitar a confirmação de instalação das
#   dependências. Recomendamos que seja feita a instalação ou atualização de
#   todas as dependências respondendo '1' ("All").
# - Atenção 2: Pode ser solictada também a resposta sobre instalação de pacotes
#   de precisam de compilação. Nesse caso, responda 'Yes'.
install_github("ConservaSom/monitoraSom", dependencies = TRUE)

### 8. Carregar o monitoraSom no ambiente de trabalho do R para testar a instalação.
library(monitoraSom)
library(dplyr)
library(ggplot2)
library(patchwork)

### 9. Salvar esse script no diretório de trabalho conforme descrito no passo 4.
# Priorize salvar com um nome informativo e que mantenha a sequência de passos
# desse e dos tutoriais seguintes, por exemplo, "script_01_instalação.R".

### Checkpoint 01
# Você instalou o monitoraSom e está pronto para começar a usar. Salve esse
# script no diretório de trabalho conforme descrito no passo 4.

### 10. Organizando o ambiente de trabalho.
# Vamos seguir a partir deste ponto assumindo que o diretório de trabalho está
# organizado conforme descrito no passo 4 e que o código está salvo em um
# arquivo em formato de script ou notebook (Rmarkdown ou Quarto).

# Vamos verificar e, se necessário, ajustar manualmente o diretório de trabalho da sessão atual.
getwd()
project_path <- paste0(getwd(), "/monitoraSom")
setwd(project_path)
getwd()

### 11. Povoando o diretório de trabalho com os arquivos de exemplo do monitoraSom.
set_workspace(project_path = "./", example_data = TRUE)

list.files("./soundscapes/", full.names = TRUE)
list.files("./recordings/", full.names = TRUE)
list.files("./roi_tables/", full.names = TRUE)

### 12. (Opcional) Limpeza de arquivos pre-carregados
# Vamos apagar os arquivos de exemplo para continuar o tutorial como um novo
# projeto. Pule esta etapa se quiser obter os mesmos resultados do tutorial.
file.remove(list.files("./detections/", full.names = TRUE))
file.remove(list.files("./match_grid_metadata/", full.names = TRUE))
file.remove(list.files("./match_scores/", full.names = TRUE))
file.remove(list.files("./soundscapes_metadata/", full.names = TRUE))
file.remove(list.files("./templates/", full.names = TRUE))
file.remove(list.files("./templates_metadata/", full.names = TRUE))
file.remove(list.files("./validation_outputs/", full.names = TRUE))

### Checkpoint 02
# Você povoou o diretório de trabalho com os arquivos de exemplo do monitoraSom
# e está pronto para seguir com o uso do pacote. Apague os arquivos de exemplo
# se quiser começar um novo projeto.

### 13. Usar o app de segmentação para escolher os templates.
launch_segmentation_app(
    user = "User", # Nome do usuário
    project_path = "./", # Caminho para a pasta do projeto
    preset_path = "./app_presets/", # Caminho para a pasta de presets
    soundscapes_path = "./recordings/", # Caminho onde ler as gravações
    roi_tables_path = "./roi_tables/", # Caminho para onde exportar as ROIs
    cuts_path = "./templates/", # Caminho para onde exportar cortes de audio
    dyn_range = c(-102, -42), # Ajuste do contraste do espectrograma
    wl = 1024, # Ajuste do comprimento da janela do fft (parametro espectral)
    ovlp = 50, # Ajuste da sobreposição do fft (parametro espectral)
    color_scale = "greyscale 1", # Ajuste da escala de cores do espectrograma
    nav_autosave = TRUE # Auomtação de salvamento ao trocar de soundscape
)

### 14. Usar o app de segmentação para segmentar as soundscapes.
launch_segmentation_app(
    user = "User", project_path = "./", preset_path = "./app_presets/",
    soundscapes_path = "./soundscapes/", roi_tables_path = "./roi_tables/",
    dyn_range = c(-102, -42), wl = 1024, ovlp = 50,
    color_scale = "greyscale 1", visible_bp = TRUE, nav_autosave = TRUE
)

### 15. Preparando os templates.

df_rois <- fetch_rois(rois_path = "./roi_tables/")
unique(df_rois$soundscape_file) # Verificando os nomes das gravações

df_templates <- df_rois %>%
    filter(roi_comment %in% c("Substructure C", "Complete Song")) %>%
    group_by(roi_comment) %>%
    sample_n(1)
glimpse(df_templates)

### 16. Exportando os cortes de audio dos templates.
export_roi_cuts(df_rois = df_templates, roi_cuts_path = "./templates/")
list.files(path = "./templates/", pattern = "Bcu", full.names = TRUE)

### Checkpoint 03
# Aqui você deve decidir: se deseja seguir com o processo simplificado (função
# `template matching()`) execute o passo 17, ou se deseja seguir com o processo
# detalhado, execute os passos 18-21.

### 17. Obtendo as detecções (processo simplificado)
template_matching(
    soundscapes_path = "./soundscapes/", # local de origem das soundscapes
    templates_path = "./templates/", # local de origem dos templates
    output_file = "./detections/df_detecs.csv", # resultado (detecções)
    ncores = 4
)

### 18. Processando os metadados das soundscapes (processo detalhado).
df_soundscapes <- fetch_soundscape_metadata(
    soundscapes_path = "./soundscapes", # caminho para as soundscapes
    recursive = TRUE, # se TRUE, lê subdiretórios de forma recursiva
    # caminho para onde exportar o arquivo de metadados
    output_file = "./soundscapes_metadata/df_soundscapes.csv",
    ncores = 4, # quantidade de núcleos para processamento paralelo
    # se TRUE, pula o processamento de arquivos já registrados nos metadados
    skip_processed = TRUE
)
glimpse(df_soundscapes)

cowplot::plot_grid(
    tuneR::readWave(filename = df_soundscapes$soundscape_path[1]) %>%
        fast_spectro(
            rec = ., f = .@samp.rate, wl = 1024, ovlp = 70,
            dyn_range = c(-102, -42), color_scale = "inferno",
            freq_guide_interval = 0, time_guide_interval = 0,
            tlim = c(0, 30)
        ) +
        theme_bw() +
        theme(legend.position = "none"),
    tuneR::readWave(filename = df_soundscapes$soundscape_path[4]) %>%
        fast_spectro(
            rec = ., f = .@samp.rate, wl = 1024, ovlp = 70,
            dyn_range = c(-102, -42), color_scale = "inferno",
            freq_guide_interval = 0, time_guide_interval = 0,
            tlim = c(0, 30)
        ) +
        theme_bw() +
        theme(legend.position = "none"),
    ncol = 1
)


### 19. Processando os metadados dos templates (processo detalhado).
df_templates <- fetch_template_metadata(
    templates_path = "./templates/", recursive = TRUE
)
glimpse(df_templates)

templates_plots <- purrr::map(df_templates$template_path, ~ {
    wav <- tuneR::readWave(filename = .x)
    res <- fast_spectro(
        rec = wav, f = wav@samp.rate, wl = 1024, ovlp = 70,
        dyn_range = c(-102, -42), color_scale = "greyscale 1",
        freq_guide_interval = 0, time_guide_interval = 0,
        flim = c(
            min(df_templates$template_min_freq),
            max(df_templates$template_max_freq)
        )
    ) +
        theme_bw() +
        theme(legend.position = "none")
    return(res)
})
cowplot::plot_grid(
    templates_plots[[1]], templates_plots[[2]],
    ncol = 2, rel_widths = c(1, 0.35)
)


### 20. Juntando os metadados das soundscapes e dos templates (processo detalhado).
df_grid <- fetch_match_grid(
    soundscape_data = df_soundscapes, template_data = df_templates
)
glimpse(df_grid)


### 21. Obtendo as detecções (processo detalhado)
run_matching(
    df_grid = df_grid,
    output_file = "./detections/df_detecs.csv", # arquivo com as detecções
    autosave_action = "replace", # ação ao salvar o arquivo
    buffer_size = "template", # buffer para evitar detecções sobrepostas
    ncores = 4 # quantidade de núcleos para processamento em paralelo
)
df_detecs <- read.csv(file = "./detections/df_detecs.csv")
glimpse(df_detecs)

### 22. Caso especial: Obtendo os scores brutos.
run_matching(
    df_grid = df_grid,
    output = "scores", # arquivo com os scores brutos
    output_file = "./detections/df_scores.rds", # arquivo com os scores brutos
    ncores = 4 # quantidade de núcleos para processamento em paralelo
)
glimpse(df_scores)

df_scores <- readRDS(file = "./detections/df_scores.rds")
glimpse(df_scores)
glimpse(df_scores$score_vec[[20]])


### 23. Visualizando os scores brutos.
# Visualização bruta
plot_scores(df_scores_i = df_scores[7, ])

# Scores ajustados para melhor visualização.
plot_scores(
    df_scores_i = df_scores[7, ], ovlp = 90, wl = 1024,
    dyn_range = c(-96, -48), color_scale = "inferno"
)

# Mais um pouco de zoom agora para ver o pico correspondente a uma detecção mais
# promissora.
plot_scores(
    df_scores_i = df_scores[7, ], ovlp = 70, wl = 1024,
    dyn_range = c(-96, -48), color_scale = "inferno", zoom_time = c(5, 10)
)

# Explorando os filtros
plot_scores(
    df_scores_i = df_scores[7, ], ovlp = 70, wl = 1024,
    dyn_range = c(-96, -48), color_scale = "inferno",
    buffer_size = "template", top_n = 6
)

# Agora vamos desligar o buffer e reter somente as detecções com scores acima de
# 0.1.
plot_scores(
    df_scores_i = df_scores[7, ], ovlp = 70, wl = 1024,
    dyn_range = c(-96, -48), color_scale = "inferno",
    buffer_size = 0, min_score = 0.1
)

plot_scores(
    df_scores_i = df_scores[11, ], ovlp = 70, wl = 1024,
    dyn_range = c(-96, -48), color_scale = "inferno",
    buffer_size = "template", min_score = 0.1
)

# Detecções sem filtros
df_detecs_nofilt <- fetch_score_peaks(
    df_scores = df_scores,
    buffer_size = 0,
    output_file = "./detections/df_detecs_nofilt.csv"
)
glimpse(df_detecs_nofilt)


### Checkpoint 04
# Você obteve as detecções, mas veja que ainda não sabe quais são verdadeiras ou
# falsas. Nesse checkpoint você poderá fazer fitragens adicionais às
# demonstradas no passo acima segundo os critérios do seu projeto. Nesse ponto
# será necessário determinar qual método de validação será usado.

### 23. Validando as detecções (método a priori)
df_validated <- validate_by_overlap(
    df_detecs = df_detecs, df_rois = df_rois, validation_user = "User"
)
glimpse(df_validated)


### 24. Checagens sanitárias das detecções validadas.
table(df_validated$validation, df_validated$template_name)
nrow(df_detecs)
nrow(df_detecs_nofilt)

### 25. Validando as detecções (método a posteriori)
file.copy(
    from = "./detections/df_detecs.csv",
    to = "./detections/df_detecs_aposteriori.csv",
    overwrite = FALSE # para evitar sobrescrever a cópia, caso já exista
)

launch_validation_app(
    project_path = ".", validation_user = "User",
    templates_path = "./templates/", soundscapes_path = "./soundscapes/",
    input_path = "./detections/df_detecs_aposteriori.csv",
    output_path = "./detections/df_detecs_aposteriori.csv",
    dyn_range_templ = c(-78, -30), dyn_range_detec = c(-78, -30), wl = 1024,
    ovlp = 70, time_guide_interval = 0, freq_guide_interval = 0,
    overwrite = TRUE
)


### 26. Importando e inspecionando os resultados da validação a posteriori.
df_detecs_aposteriori <- read.csv(
    file = "./detections/df_detecs_aposteriori.csv"
)
glimpse(df_detecs_aposteriori)

table(
    df_detecs_aposteriori$validation, df_detecs_aposteriori$template_name
)

### 27. Comparando os resultados das validações a priori e a posteriori.
df_rois %>%
    filter(!grepl("Bcu", soundscape_file)) %>%
    nrow()
nrow(df_detecs_aposteriori)
table(df_detecs_aposteriori$validation, df_detecs_aposteriori$template_name)

### 28. Diagnósticos de performance.
ls_val_apriori <- diagnostic_validations(
    df_validated = df_validated, pos_prob = 0.90, val_a_priori = TRUE
)
# Separando os resultados para cada template
res_template1 <- ls_val_apriori[[1]]
res_template2 <- ls_val_apriori[[2]]

res_template1$diagnostics %>% glimpse()
res_template2$diagnostics %>% glimpse()

cowplot::plot_grid(
    res_template1$mod_plot, res_template2$mod_plot,
    res_template1$precrec_plot, res_template2$precrec_plot,
    ncol = 2
)

### 29. Obtendo o conjunto final de detecções.
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
write.csv(
    detecs_final, "./detections/df_detecs_soundmeter.csv"
)


detection_plots1 <- detecs_subC %>%
    split(., seq(nrow(.))) %>%
    purrr::map(., ~ {
        wav <- tuneR::readWave(
            filename = .x$soundscape_path, from = .x$detection_start, to = .x$detection_end, units = "seconds"
        )
        res <- fast_spectro(
            rec = wav, f = wav@samp.rate, wl = 1024, ovlp = 70,
            dyn_range = c(-102, -42), color_scale = "greyscale 1",
            freq_guide_interval = 0, time_guide_interval = 0,
            zoom_freq = c(
                .x$template_min_freq,
                .x$template_max_freq
            )
        ) +
            theme_bw() +
            theme(legend.position = "none")
        return(res)
    }, .progress = TRUE)
length(detection_plots1)

cowplot::plot_grid(
    detection_plots1[[1]], detection_plots1[[2]],
    detection_plots1[[3]], detection_plots1[[4]],
    detection_plots1[[5]], detection_plots1[[6]],
    ncol = 3
)

detection_plots2 <- detecs_csong %>%
    split(., seq(nrow(.))) %>%
    purrr::map(., ~ {
        wav <- tuneR::readWave(
            filename = .x$soundscape_path, from = .x$detection_start, to = .x$detection_end, units = "seconds"
        )
        res <- fast_spectro(
            rec = wav, f = wav@samp.rate, wl = 1024, ovlp = 70,
            dyn_range = c(-102, -42), color_scale = "greyscale 1",
            freq_guide_interval = 0, time_guide_interval = 0,
            zoom_freq = c(
                .x$template_min_freq,
                .x$template_max_freq
            )
        ) +
            theme_bw() +
            theme(legend.position = "none")
        return(res)
    }, .progress = TRUE)
length(detection_plots2)

cowplot::plot_grid(
    detection_plots2[[1]], detection_plots2[[2]],
    detection_plots2[[3]], detection_plots2[[4]],
    detection_plots2[[5]], detection_plots2[[6]],
    detection_plots2[[7]], detection_plots2[[8]],
    detection_plots2[[9]], detection_plots2[[10]],
    detection_plots2[[11]], detection_plots2[[12]],
    detection_plots2[[13]],
    ncol = 5
)

# 30. Transformando as detec<U+00E7><U+00F5>es finais em tabelas de ROIs
dir.create("./final_detecs")
df_final <- rbind(detecs_csong, detecs_subC) %>% glimpse()
df_rois_final <- detecs_to_rois(
    df_detecs = df_final, username = "User",
    output_path = "./final_detecs/"
)
