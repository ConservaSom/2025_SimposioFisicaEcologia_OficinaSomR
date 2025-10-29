
### Tutorial - monitoraSom - parte 02 - Ambiente de trabalho ######
############### Gabriel L. M. Rosa UEL/ConservaSom ################

# Seja bem-vindo(a) ao tutorial do monitoraSom! Nessa segunda etapa, vamos
# configurar o ambiente de trabalho para o uso do monitoraSom.

library(monitoraSom)

# 10. Salve este script com o nome "script_02_ambiente.R" no diretório de
#     trabalho.

# 11. Defina o diretório de trabalho atual como o diretório de trabalho do R. O
#     comando abaixo irá detectar o diretório do script atual e definir como
#     diretório de trabalho de forma automática.
# - Atenção: Esse comando só funcionará se o script atual estiver aberto no
#   Rstudio e salvo no diretório de trabalho correto.
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# 12. Checar se o diretório de trabalho está correto.
getwd()

# 12. Usar `set_workspace` para construir o diretório de trabalho.
# - Atenção: Esse comando é recomendado para novos projetos. Evite executá-lo em
#   diretórios que já contenham dados de projetos em andamento. Isso poderá
#   resultar em perdas permanentes de dados.
# - Vamos salvar também o script atual no diretório de trabalho para que o
#   comando 'set_workspace' funcione adequadamente.
# - Principais argumentos do comando:
#   - project_path: caminho para o diretório de trabalho. Preecher com "./" é
#     uma forma de indicar que quer usar o diretório de trabalho atual.
#   - example_data: se TRUE, deposita os dados de exemplo do monitoraSom nas
#     pastas criadas.
# - No exemplo abaixo não definimos explicitamente o nome de cada uma das pastas
#   (usamos os nomes padrão ao omitir os argumentos), mas isso é possível.
#   Cheque a vignette de ajuda (?set_workspace) para mais informações sobre
#   quais são essas diretórios, qual é o conteúdo de cada um deles e quais são
#   os nomes padrão.
# - Observe o output do comando abaixo no console do R para informações sobre os
#   diretórios criados e o conteúdo de cada um deles.
# - Se tiver checado e estiver tudo certo, execute o comando abaixo:
set_workspace(project_path = "./", example_data = TRUE)

# 13. Vamos fazer uma checagem rápida para ver se os arquivos mais importantes
#     foram corretamente depositados no diretório de trabalho correto.
list.files("./soundscapes/", full.names = TRUE)

# 14. Note que além das pastas e arquivos, foi criado também um arquivo de
#     projeto do RStudio (.Rproj). Esse arquivo é importante para o RStudio
#     reconhecer o diretório de trabalho em sessões futuras.
# - A partir de agora é importante que todas as sessões do RStudio estejam
#   associadas a este projeto.
# - Para isso, basta abrir o arquivo .Rproj no diretório de trabalho, ou acessar
#   o menu "Project" no canto direito superior da interface do RStudio para
#   abrir o menu de projetos.
# - Se deu tudo certo, o nome do projeto aparecerá no canto direito superior da
#   interface do RStudio.
# - Atenção: Se essa etapa não for feita corretamente, o RStudio não irá ler e
#   exportar arquivos para os locais corretos, impossibilitando a execução dos
#   comandos subsequentes do fluxo de trabalho do monitoraSom.
