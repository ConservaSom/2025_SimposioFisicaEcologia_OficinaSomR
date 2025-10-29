################ Tutorial - monitoraSom - parte 03 #################
############# Segmentação para extração de templates ###############
############### Gabriel L. M. Rosa UEL/ConservaSom #################

# Seja bem-vindo(a) ao tutorial do monitoraSom! Nessa terceira etapa, vamos
# aprender a extrair templates usando o app de segmentação.

library(monitoraSom)
library(dplyr)

# 15. Para detectar sons usando templates, precisamos extraí-los de gravações de
#     referência. Vamos verificar se temos os arquivos necessários - dois cantos
#     de pula-pula (Basileuterus culicivorus): "Bcu_1.wav" e "Bcu_2.wav".
list.files("./recordings/", full.names = TRUE)



# Agora que os diretórios estão configurados, vamos iniciar o app de segmentação
# com uma configuração mínima. Os parâmetros essenciais para iniciar o app são
# os caminhos para a pasta do projeto (`project_path`), o caminho para a pasta
# de paisagens sonoras (`soundscapes_path`), o caminho onde armazenar a pasta
# de tabelas ROI (`roi_tables_path`) e a identificação do usuário (neste caso
# definido como `user`). Você pode anotar suas configurações ideais e
# estabelecer os caminhos diretamente no `launch_segmentation_app()`. O app
# será iniciado executando o comando abaixo.


# 16. O app de segmentação é uma ferramenta multiuso que pode ser utilizada para
#     diversos objetivos. Serve como uma ferramenta rápida de visualização para
#     inspecionar gravações, listar espécies presentes em arquivos de som,
#     avaliar o repertório das espécies e medir aspectos comportamentais
#     específicos usando as vocalizações. Vamos usar o app de segmentação do
#     monitoraSom para extrair os templates, acessado pela função
#     'launch_segmentation_app', com settings otimizados. Note o importante
#     papel de preencher adequadamente os argumentos para que o app funcione
#     adequadamente. Existem outros argumentos que podem ser ajustados, mas
#     vamos nos ater aos essenciais neste exemplo.
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

# Agora vamos aprender a segmentar soundscapes usando o app de segmentação.
# Primeiro, precisamos marcar os sinais que queremos usar como templates. Para
# agilizar o processo, vamos usar templates já prontos nos dados de exemplo.
# Siga os passos 17-20 caso queira criar novos templates, ou pule para o passo
# 21 para usar os templates predefinidos.

# 17. Na aba "User Setup", verifique os caminhos e clique em "Confirm Paths"
# 18. Ajuste a visualização:
#    - Oculte a barra lateral para ter mais espaço
#    - Use o zoom nos eixos X e Y para ver bem os sinais
#    - Ajuste o contraste se necessário
# 19. No menu "Available species names", selecione a espécie alvo Dica: Use
#    busca parcial (ex: "bas c" encontra "Basileuterus culicivorus").
# 20. Para cada sinal que você quer marcar como template:
#    - Desenhe a caixa de seleção (ROI) ao redor do sinal
#    - Preencha os metadados:
#       - Nome da espécie
#       - Tipo de sinal (pode criar novos tipos digitando e clicando em
#         "Add...")
#       - Nível de certeza da identificação em "Id certainty"
#       - Se o sinal está completo ou não em "Complete"
#       - No campo "Comments", escreva informações úteis. Neste exemplo usaremos
#         "Substructure A/B/C" para cada parte do canto.
#       - Dica: Use o cadeado ao lado dos campos para manter os valores durante
#         a seleção de sucessivas ROIs.

# 21. Depois de marcar os sinais, você tem duas opções para exportar conforme as
# etapas abaixo:

# - Opção 1 - Exportação manual (recomendada para escolher "a dedo" uma pequena
# quantidade de ROIs)
#   - Na aba "ROI table", selecione as ROIs desejadas e clique em "Export audio
#   of selected ROI". Se não selecionar nada, todas as ROIs da gravação ativa
#   serão exportadas.
#   - Verifique se os arquivos foram exportados corretamente
list.files("./templates/", full.names = TRUE)

# - Opção 2 - Exportação via código (recomendada para exportar muitos templates
# de forma automatizada de forma guiada pelos metadados).
#   - Importe todas as ROIs marcadas
df_rois <- fetch_rois(rois_path = "./roi_tables/") %>% glimpse
#   - Filtre apenas as ROIs que você quer exportar. Neste exemplo, selecionamos
#     apenas as marcadas como "Substructure C"
df_rois_processed <- df_rois %>%
  filter(grepl("Substructure C", roi_comment)) %>%
  glimpse()
#   - Exporte as ROIs filtradas como arquivos de áudio
export_roi_cuts(
  df_rois = df_rois_processed, roi_cuts_path = "./templates/"
)
#   - Verifique se os arquivos foram exportados corretamente
list.files("./templates/", full.names = TRUE)
