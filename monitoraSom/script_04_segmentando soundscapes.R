################ Tutorial - monitoraSom - parte 04 #################
###################### Segmentação completa ########################
############### Gabriel L. M. Rosa UEL/ConservaSom #################

# Seja bem-vindo(a) ao tutorial do monitoraSom! Nessa quarta etapa, vamos
# aprender a segmentar soundscapes para uso posterior no treinamento e validação
# de processos de detecção de espécies. A segmentação é uma etapa fundamental
# que consiste em identificar e marcar manualmente os sinais sonoros de interesse
# nas gravações. Embora seja um processo que demanda tempo e atenção, os dados
# gerados são extremamente valiosos pois servem como referência para avaliar a
# precisão dos métodos automáticos de detecção.

library(monitoraSom)
library(dplyr)

# 22. Antes de tudo, vamos verificar se temos os arquivos necessários estão onde
#     devem estar.
list.files("./soundscapes/", full.names = TRUE)

# 23. Vamos usar o app de segmentação do monitoraSom para segmentar os
#     soundscapes, acessado pela função 'launch_segmentation_app', com os
#     settings otimizados que já definimos anteriormente (veja o passo 16).
launch_segmentation_app(
  user = "User", # Nome do usuário
  project_path = "./", # Caminho para a pasta do projeto
  preset_path = "./app_presets/", # Caminho para a pasta de presets
  soundscapes_path = "./soundscapes/", # Caminho onde ler as gravações
  roi_tables_path = "./roi_tables/", # Caminho para onde exportar as ROIs
  cuts_path = "./roi_cuts/", # Caminho para onde exportar cortes de audio
  dyn_range = c(-102, -42), # Ajuste do contraste do espectrograma
  wl = 1024, # Ajuste do comprimento da janela do fft (parametro espectral)
  ovlp = 50, # Ajuste da sobreposição do fft (parametro espectral)
  color_scale = "greyscale 1", # Ajuste da escala de cores do espectrograma
  play_norm = TRUE, # Ajuste da normalização do som para reprodução
  visible_bp = TRUE, # Ajuste da visibilidade do banco de frequências
  nav_autosave = TRUE # Auomtação de salvamento ao trocar de soundscape
)

# Diferentemente de quando segmentamos gravações para a extração de templates,
# agora nosso objetivo é identificar e registrar todos os sinais acústicos
# presentes nas gravações. Para manter nosso exemplo simples, vamos nos ater a
# demarcar somente cantos completos de Basileuterus culicivorus. Não vamos demarcar ROIs de outras espéces ou discriminar entre as subestruturas do canto de Basileuterus culicivorus.
# Não será necessário exportar as ROIs marcadas, exceto se desejarmos usar
# alguma delas como templates.
# 24. Na aba "User Setup", verifique os caminhos e clique em "Confirm Paths"
# 25. Ajuste a visualização:
#    - Oculte a barra lateral para ter mais espaço
#    - Use o zoom nos eixos X e Y para ver bem os sinais
#    - Ajuste o contraste se necessário
# 26. No menu "Available species names", selecione a espécie alvo Dica: Use
#    busca parcial (ex: "bas c" encontra "Basileuterus culicivorus").
# 27. Para cada sinal que você quer marcar como template:
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
#    - Desenhe a caixa de seleção (ROI) ao redor do sinal e pressione a tecla
#      "E" para registrar a ROI.
# 28. Depois de concluir a demarcação de todas as ROIs adequadas ao contexto do
#     seu projeto em uma gravação, avance para a próxima gravação pressionando a
#     tecla "Z" ou clicando no botão "Next" imediatamente abaixo do
#     spectrograma.

# Ovbservações inportantes sobre o comportamento do app de segmentação:
# - O app de segmentação possibilita a navegação e segmentação das gravações
#   presentes em um único diretório por vez e não faz a leitura de subdiretórios
#   de forma recursiva. Se o projeto envolve dados em multiplos dioretórios, a
#   segmentação de cada um deles deve ser feita em uma sessão separada.
# - Evite mover arquivos de seus locais de origem para evitar problemas de
#   leitura e escrita de arquivos. Ex.: Mover arquivos de uma pasta de tabelas
#   de ROIs fará com que o app não encontre as ROIs da repsetiva soundscapes em
#   uma nova sessão do app de segmentação, fazendo com que o usuário segmente
#   novamente a soundscape se não perceber o problema.
# - Ao avançar no processo de segmentação, verifique se as tabela de ROIs estão
#   sendo exportadas corretamente ao observar as pop-ups no canto inferior
#   direito da tela. Se não houver pop-ups, verifique se a caixa de seleção
#   "Auto save" no canto esquerdo inferior do painel do spectrograma está
#   marcada.
# - Para ganratir a integridade dos dados, recomendamos que ao fim de cada
#   sessão de segmentação o app seja encerrado por meio do botão "End session",
#   localizado no canto inferior da barra lateral.




