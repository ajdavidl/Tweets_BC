library(rjson)
library(dplyr)

setwd("Tweets_BC")

lista_arquivos<-list.files(path = paste0(getwd(),"/dados/ipeadata"))

lista_arquivos <- lista_arquivos[!grepl("old", lista_arquivos)]

metadados <- fromJSON(file = paste0(getwd(),"/dados/ipeadata/",lista_arquivos[1]))
valores <- fromJSON(file = paste0(getwd(),"/dados/ipeadata/",lista_arquivos[2]))

if(is.null(metadados$value[[1]]$MULNOME)){
  multiplicador = 1
} else if(metadados$value[[1]]$MULNOME == "mil"){
  multiplicador = 1000
} else if (metadados$value[[1]]$MULNOME == "milhões" | metadados$value[[1]]$MULNOME == "milh\u00f5es") {
  multiplicador = 1000000
} else multiplicador = 1

df <- data.frame(X1 = valores$value[[1]]$VALDATA[1],
                 X2 = valores$value[[1]]$VALVALOR[1]*multiplicador,
                 stringsAsFactors = FALSE)

for (i in 2:length(valores$value)) {
  if(is.null(valores$value[[i]]$VALVALOR[1])){
    valor = NA
  } else{
    valor = valores$value[[i]]$VALVALOR[1]
  }
  aux <- data.frame(X1 = valores$value[[i]]$VALDATA[1],
                   X2 = valor*multiplicador,
                   stringsAsFactors = FALSE)
  
  df <- rbind.data.frame(df, aux)
}

colnames(df) <- c("DATA", valores$value[[1]]$SERCODIGO)
df$DATA <- as.Date(df$DATA, format = "%Y-%m-%d")

for (j in 2:(length(lista_arquivos)/2)) {
  
  metadados <- fromJSON(file = paste0(getwd(),"/dados/ipeadata/",lista_arquivos[2*j-1]))
  valores <- fromJSON(file = paste0(getwd(),"/dados/ipeadata/",lista_arquivos[2*j]))
  
  if(is.null(metadados$value[[1]]$MULNOME)){
    multiplicador = 1
  } else if(metadados$value[[1]]$MULNOME == "mil"){
    multiplicador = 1000
  } else if (metadados$value[[1]]$MULNOME == "milhões" | metadados$value[[1]]$MULNOME == "milh\u00f5es") {
    multiplicador = 1000000
  } else multiplicador = 1
  
  aux <- data.frame(X1 = valores$value[[1]]$VALDATA[1],
                   X2 = valores$value[[1]]$VALVALOR[1]*multiplicador,
                   stringsAsFactors = FALSE)
  
  for (i in 2:length(valores$value)) {
    if(is.null(valores$value[[i]]$VALVALOR[1])){
      valor = NA
    } else{
      valor = valores$value[[i]]$VALVALOR[1]
    }
    aux2 <- data.frame(X1 = valores$value[[i]]$VALDATA[1],
                      X2 = valor*multiplicador,
                      stringsAsFactors = FALSE)
    
    aux <- rbind.data.frame(aux, aux2)
  }
  
  colnames(aux) <- c("DATA", valores$value[[1]]$SERCODIGO)
  aux$DATA <- as.Date(aux$DATA, format = "%Y-%m-%d")
  
  df <- df %>% full_join(y = aux,by = "DATA") %>% arrange(DATA)
  #df <- merge(x = df, y = aux, by = "DATA", All = TRUE)
  
}
save(df, file = "dados/Ipeadata_df.RData")
write.csv2(x = df, file =  "dados/Ipeadata_df.csv", fileEncoding = "UTF-8")

