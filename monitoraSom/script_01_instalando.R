
######## Tutorial - monitoraSom - parte 01 - Instalação ###########
############### Gabriel L. M. Rosa UEL/ConservaSom ################

# Seja bem-vindo(a) ao tutorial do monitoraSom! Nessa primeira etapa, fazer os
# downloads e instalações necessárias para o uso do monitoraSom.

# 1. Baixar e instalar o R.

# - Verifique se já existe alguma versão instalada. Caso exista, verifique se é
#   adequada ao projeto. Se não for, desinstale a versão existente.
# - Ao fazer uma nova instalação, dê preferência para a versão mais recente.
#   Neste momento, a versão mais recente é a 4.5.1.
# - link para download: https://cran.r-project.org/bin/windows/base/

# 2. Baixar e instalar o Rstudio.
# - Após instalar o R, instale o Rstudio.
# - Atenção: se houver mais de uma versão do R instalada, certifique-se qual
# está sendo usada ao abrir o Rstudio.
# - link para download: https://posit.co/download/rstudio-desktop/

# 3. Instalar o Rtools (passo necessário apenas para usuários do Windows)
# - Rtools é necessário para compilar pacotes do R que foram instalados
#   a partir do GitHub.
# - Verifique se já existe alguma versão instalada. Caso exista, verifique se é
#   adequada ao projeto. Se não for, desinstale a versão existente.
# - Neste momento, a versão mais recente é a 4.5.
# - link para download: https://cran.r-project.org/bin/windows/Rtools/

# 4. Criar uma nova pasta para conter os arquivos usandos pelo monitoraSom.
# - Para usuários do Windows, recomendamos criar uma pasta para análises na raiz
#   do sistema, e dentro dela uma pasta para este projeto, por exemplo,
#   "C:/Analises/monitoraSom_tutorial". Dessa forma o caminho para os arquivos
#   será o mesmo mesmo que os arquivos sejam movidos para outro computador.

# 5. Instalar o devtools para poder instalar pacotes a partir do GitHub.
# - Esse comando deve ser executado no Rstudio após a instalação do Rtools.
install.packages("devtools")

# 6. Carregar o devtools para o ambiente de trabalho.
library(devtools)

# 7. Instalar o monitoraSom
# - O monitoraSom depende de outros pacotes do R para funcionar adequadamente.
# - Atenção 1: A isntalação poderá solicitar a confirmação de instalação das
#   dependências. Recomendamos que seja feita a instalação ou atualização de
#   todas as dependências respondendo '1' ("All").
# - Atenção 2: Pode ser solictada também a resposta sobre instalação de pacotes
#   de precisam de compilação. Nesse caso, responda 'Yes'.
# - Resolvendo possiveis problemas: Verifique o andamento da instalação no
#   console do Rstudio. É possivel que ocorram falhas na atualização de pacotes
#   que já foram instalados antes, a maior parte delas não resulta em problemas
#   para o monitoraSom. Observe se ao final do processo, apesar dos warnings, é
#   dada a mensagem "* DONE (monitoraSom)". Caso positivo, a instalação foi
#   concluída e podemos avançar para o próximo passo. Caso negativo, leia a
#   mensagem de erro, identifique os pacotes que estão causando o problema e
#   tente remove-los para fazer a instalação novamente.
# - Para casos em que a isntalação foi interrompida, é possivel que seja
#   necessário ir até o diretório onde arquivos dos pacotes instalados ficam
#   armazenados usando o navegador de arquivos (geralmente em "C:/Program
#   Files/R/R-4.5.1/library/") e removê-los manualmente juntamente com um
#   diretório de nome iniciado em "00-LOCK". Cerifique-se que o Rstudio está
#   fechado antes de fazer isso. Abra novamente o Rstudio e tente a instalação
#   novamente.
# Comando para instalar o monitoraSom:
install_github("ConservaSom/monitoraSom", dependencies = TRUE)

# 8. Carregar o monitoraSom no ambiente de trabalho do R para testar a
#    instalação.
library(monitoraSom)

# 9. Salvar esse script no diretório de trabalho conforme descrito no passo 4.
# - Priorize salvar com um nome informativo e que mantenha a sequência de passos
#   desse e dos tutoriais seguintes, por exemplo, "script_01_instalação.R".

