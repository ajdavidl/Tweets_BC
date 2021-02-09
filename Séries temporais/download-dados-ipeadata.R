###############################
# DOWNLOAD DADOS DO IPEADATA  #
###############################

setwd("Tweets_BC")

library(lubridate) # pacote para manipulação de datas (funcao "today()")

# URL DA API
url <- "http://www.ipeadata.gov.br/api/odata4/Metadados('"

# LISTA DAS SERIES DESEJADAS
Lista_SERCODIGO <- c('JPM366_EMBI366','IGP12_IGPMG12','PRECOS12_INPCBR12','PRECOS12_IPCAG12',
                    'BM12_PIB12','GAC12_SALMINRE12','GM366_ERC366','GM366_ERV366','BM12_TJOVER12',
                    'BM366_TJOVER366','GM366_IBVSP366','PNADC12_TDESOC12','BMF12_SWAPDI18012',
                    'BMF12_SWAPDI36012')

# obtem a data atual ser utilizada no nome do arquivo e converte para string
data <- as.character(today())

#variável para controle 
i <- 1
tot <- length(Lista_SERCODIGO) 

# VARRE A LISTA DAS SERIES PARA BAIXAR ARQUIVOS JSON
for (SERCODIGO in Lista_SERCODIGO) {

  print(paste0("Baixando metadados de ",SERCODIGO," (",i,"/",tot,")"))
  
  # MONTA A QUERY PARA OBTER OS METADADOS DA SERIE  
  url_metadado <- paste0(url, SERCODIGO,"')")
 
  # CRIA O NOME DO ARQUIVO DE SAIDA
  nome_arquivo_metadado <- paste0(getwd(),"/dados/ipeadata/",SERCODIGO," - metadados [",data,"].json")
  
  # FAZ O DOWNLOAD DO ARQUIVO E SALVA NA PASTA DADOS  
  download.file(url = url_metadado, #url da query
                destfile = nome_arquivo_metadado)# nome do arquivo de destino

  # PAUSA O LOOP DO DOWNLOAD POR X SEGUNDOS PARA NAO SOBRECARREGAR O SERVIDOR 
  Sys.sleep(5)
  
  print(paste0("Baixando valores de ",SERCODIGO," (",i,"/",tot,")"))
  
  # MONTA A QUERY PARA OBTER OS VALORES DA SERIE  
  url_valores <- paste0(url_metadado,"/Valores")
  
  # CRIA O NOME DO ARQUIVO DE SAIDA
  nome_arquivo_valores <- paste0(getwd(),"/dados/ipeadata/",SERCODIGO," - valores [",data,"].json")
  
  # FAZ O DOWNLOAD DO ARQUIVO E SALVA NA PASTA DADOS  
  download.file(url = url_valores, #url da query
                destfile = nome_arquivo_valores)# nome do arquivo de destino
  
  # PAUSA O LOOP DO DOWNLOAD POR X SEGUNDOS PARA NAO SOBRECARREGAR O SERVIDOR 
  Sys.sleep(5)
  
  # atualiza variavel de controle
  i <- i + 1
}
