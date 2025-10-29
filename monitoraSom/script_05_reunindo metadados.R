################ Tutorial - monitoraSom - parte 05 #################
###################### Reunindo metadados #########################
############### Gabriel L. M. Rosa UEL/ConservaSom #################

# Seja bem-vindo(a) ao tutorial do monitoraSom! Nessa quinta etapa, vamos
# aprender a reunir os metadados das ROIs marcadas nas gravações.

library(monitoraSom)
library(dplyr)
library(tidyr)
library(lubridate)
library(hms)

# 29. Antes de tudo, vamos verificar se temos os arquivos necessários estão onde
#     devem estar.
list.files("./roi_tables/", full.names = TRUE) # tabelas de ROIs
list.files("./soundscapes/", full.names = TRUE) # soundscapes
list.files("./templates/", full.names = TRUE) # templates

# 30. Vamos importar a tabela de ROIs e remover as ROIs das gravações focais de
#     Basileuterus culicivorus, de onde extraímos os templates, já que não vamos
#     usar elas para detecção.
df_rois <- fetch_rois(rois_path = "./roi_tables/") %>%
    # Aqui negamos todas as linhas que contém "Bcu" no nome do arquivo da
    # soundscape para manter somente as ROIs das soundscapes.
    filter(!grepl("Bcu", soundscape_file)) %>%
    # Inspecionamos o resultado
    glimpse()

# Vamos fazer mais algumas checagens para verificar se os dados estão corretos.
count(df_rois, soundscape_file) # quantas ROIs temos para cada soundscape

# 31. Agora seguimos o processo importando os metadados das soundscapes.
#     Chamaremos de soundscapes todas as gravações de paisagens acústicas,
#     geralmente obtidas em campo por meio de gravadores autônomos em grandes
#     quantidades com o proposito de registrar ocorrências de espécies alvo do
#     monitoramento acústico passivo. 0s resultados apresentam as especificações
#     dos arquivos WAV que são essenciais para garantir a compatibilidade com os
#     templates durante o processo de detecção. Como o processamento de muitas
#     soundscapes pode ser demorado será conveniente usar o processamento
#     paralelo e o salvamento automático do arquivo com os metadados. Portanto,
#     essa função também realiza o salvamento automático do arquivo
#     com os metadados, processamento paralelo, e pulo de arquivos já
#     registrados nos metadados. Veja a vignette de ajuda
#     (?fetch_soundscape_metadata) para mais informações.
df_soundscapes <- fetch_soundscape_metadata(
    soundscapes_path = "./soundscapes", # caminho para as soundscapes
    recursive = TRUE, # se TRUE, lê subdiretórios de forma recursiva
    # caminho para onde exportar o arquivo de metadados
    output_file = "./soundscapes_metadata/df_soundscapes.csv",
    ncores = 4, # quantidade de núcleos para processamento paralelo
    # se TRUE, pula o processamento de arquivos já registrados nos metadados
    skip_processed = TRUE
)
glimpse(df_soundscapes) # Inspecionando o resultado

# 32. Os metadados dos templates são importados de forma
#     similar aos demais tipos de metadados. Como a
#     quantidade de e o tamanho dos arquivos de templates
#     dificilmente será grande, a função não realiza o
#     processamento paralelo nem salvamento automático do
#     arquivo com os metadados. Precisamos juntar os
#     metadados das soundscapes e #     dos templates em uma
#     unica tabela e fazer checagens para garantir que o
#     template matching ocorra segundo planejado. O
#     resultado dessa combinção é o que podemos chamar de
#     grade de busca. As função que produz essa grade faz
#     mais do que produzir uma combinação par a par entre
#     todas as soundscapes e templates, ela também faz
#     checagens de compatibilidade entre os arquivos. Uma
#     dessas checagens, por exemplo, garante que a taxa de
#     amostragem das soundscapes seja compatível com a taxa
#     de amostragem dos templates. Casos de
#     incompatibilidade são automaticamente omitidos e
#     retornam alertas para o usuário.
df_grid <- monitoraSom::fetch_match_grid(
    soundscape_data = df_soundscapes, template_data = df_templates
)
glimpse(df_grid)


unique(df_grid$template_name)
unique(df_grid$soundscape_file)

# Conteúdo bonus: trabalhando com os metadados de tempo e espaço.
df_gridB <- df_grid %>%
    separate(
        soundscape_file,
        into = c("coords", "date", "time"), remove = FALSE
    ) %>%
    mutate(
        longitude = -as.numeric(substr(coords, 2, 6)) / 1000,
        latitude = -as.numeric(substr(coords, 8, 13)) / 1000,
        date_time = as.POSIXct(
            paste0(
                substr(date, 1, 4), "-", substr(date, 5, 6), "-",
                substr(date, 7, 8), " ", substr(time, 1, 2), ":",
                substr(time, 3, 4), ":", substr(time, 5, 6)
            ),
            format = "%Y-%m-%d %H:%M:%S"
        )
    ) %>%
    mutate(
        Year = date_time %>% format("%Y") %>% as.numeric(),
        Month = date_time %>% format("%m") %>% as.numeric(),
        Month_ref = lubridate::floor_date(date_time, "month"),
        Day = date_time %>% format("%d") %>% as.numeric(),
        Day_ref = lubridate::floor_date(date_time, "day"),
        Day_seq = lubridate::yday(date_time),
        Time = hms::as_hms(date_time),
        Hour = date_time %>% format("%H") %>% as.numeric(),
        Minute = date_time %>% format("%M") %>% as.numeric()
    ) %>%
    select(-coords, -date, -time) %>%
    glimpse()


