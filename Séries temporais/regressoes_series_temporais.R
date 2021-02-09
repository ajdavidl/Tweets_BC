library(dplyr)
library(lfe)
library(stargazer)
library(data.table)

setwd("Tweets_BC")

###############################################################################
# Carrega series -------------------------------------------------------------------
###############################################################################

df <- read.csv2("dados\\series_temporais_tweets_v3.csv", 
                sep=",", stringsAsFactors = FALSE)
df$total[df$total==''] <- NA
df$copom[df$copom==''] <- NA
df$incerteza[df$incerteza==''] <- NA
df$credibilidade[df$credibilidade==''] <- NA
df$focus[df$focus==''] <- NA
df$autonomia[df$autonomia==''] <- NA
df$prob_C[df$prob_C==''] <- NA
df$prob_N[df$prob_N==''] <- NA
df$qtd_C[df$qtd_C==''] <- NA


df$total <- as.integer(df$total)
df$copom <- as.integer(df$copom)
df$incerteza <- as.integer(df$incerteza)
df$credibilidade <- as.integer(df$credibilidade)
df$focus <- as.integer(df$focus)
df$autonomia <- as.integer(df$autonomia)
df$prob_C <- as.numeric(df$prob_C)
df$prob_N <- as.numeric(df$prob_N)
df$qtd_C <- as.integer(df$qtd_C)

colnames(df)<-c("DataHora","total","copom","incerteza","credibilidade","focus","autonomia","prob_C","prob_N","qtd_C")
df$DATA <- as.Date(df$DataHora, format = "%Y-%m-%d")

df <- df %>% select(DATA,total, copom, incerteza, credibilidade, focus, autonomia,prob_C,prob_N,qtd_C) %>% group_by(DATA) %>% 
  summarise(total = sum(total, na.rm = T),copom = sum(copom, na.rm = T), incerteza = sum(incerteza, na.rm = T),
            credibilidade = sum(credibilidade, na.rm = T), focus = sum(focus, na.rm = T), 
            autonomia = sum(autonomia, na.rm = T), prob_C = mean(prob_C, na.rm = T), 
            prob_N = mean(prob_N,na.rm=T), qtd_C = sum(qtd_C, na.rm=T))

base <- df


load(file = "dados\\Ipeadata_df.RData")
df <- df %>% filter(DATA >= min(base$DATA))


base <- left_join(base, df, by = c("DATA"))
rm(df)

df <- read.csv2("dados\\Brazil_Policy_Uncertainty_Data.csv", sep = "\t",dec = ",")
df$DATA <- paste0(df$year,"-",df$month,"-01")
df$DATA <- as.Date(df$DATA)
colnames(df) <- c("year","month","Brazil_News_Based_EPU","DATA" )
df <- df[,c("DATA","Brazil_News_Based_EPU")]
colnames(df) <- c("DATA","Uncertainty")
base <- left_join(base, df, by = c("DATA"))
rm(df)

df <- read.csv2("dados\\IIEBR-FGV.csv", sep = ",",dec = ".", header = F, stringsAsFactors = F)
colnames(df) <- c("DATA","IIEBR")
df$DATA <- as.Date(df$DATA, format = "%d/%m/%Y")
base <- left_join(base, df, by = c("DATA"))
rm(df)


base_d <- base %>% select(DATA,total, copom,incerteza,credibilidade,focus,autonomia,prob_C,prob_N,qtd_C,BM366_TJOVER366,
                          GM366_ERC366,GM366_ERV366,GM366_IBVSP366,JPM366_EMBI366)
colnames(base_d) <- c("DATA","total","copom","incerteza","credibilidade","focus","autonomia","prob_C","prob_N",
                      "qtd_C","selic_meta_aa", "dolarcompra","dolarvenda","ibovespa","embi")
base_d$Ano <- year(base_d$DATA)


base_m <- base
base_m$DATA <- lubridate::floor_date(base$DATA,"month")
base_m <- base_m %>% group_by(DATA) %>% 
  summarise(total = sum(total, na.rm = T),
            copom = sum(copom, na.rm = T),
            incerteza = sum(incerteza, na.rm = T),
            credibilidade = sum(credibilidade, na.rm = T),
            focus = sum(focus, na.rm = T),
            autonomia = sum(autonomia, na.rm = T),
            prob_C = mean(prob_C, na.rm = T),
            prob_N = mean(prob_N, na.rm = T),
            qtd_C = sum(qtd_C, na.rm = T),
            pib = mean(BM12_PIB12, na.rm = T),
            selic_over_am = mean(BM12_TJOVER12, na.rm = T),
            selic_meta_aa = mean(BM366_TJOVER366, na.rm = T),
            swapdi180 = mean(BMF12_SWAPDI18012, na.rm = T),
            swapdi360 = mean(BMF12_SWAPDI36012, na.rm = T),
            salminreal = mean(GAC12_SALMINRE12, na.rm = T),
            dolarcompra = mean(GM366_ERC366, na.rm = T),
            dolarvenda = mean(GM366_ERV366, na.rm = T),
            ibovespa = mean(GM366_IBVSP366, na.rm = T),
            igpm = mean(IGP12_IGPMG12, na.rm = T),
            embi = mean(JPM366_EMBI366, na.rm = T),
            desocupacao = mean(PNADC12_TDESOC12, na.rm = T),
            inpc = mean(PRECOS12_INPCBR12, na.rm = T),
            ipca = mean(PRECOS12_IPCAG12, na.rm = T),
            uncertainty = mean(Uncertainty, na.rm = T),
            iiebr = mean(IIEBR, na.rm = T))

base_m[base_m$DATA=="2016-02-01","selic_meta_aa"] <- base_m[base_m$DATA=="2016-01-01","selic_meta_aa"]
base_m$Ano <- year(base_m$DATA)


###############################################################################
## Pre-processamento -------------------------------------------------------------------
###############################################################################

base_d <- as.data.table(base_d)
base_m <- as.data.table(base_m)

base_d[,total_scaled := scale(total),]
base_d[,total_lag := shift(total, 1, "lag"),]
base_d[,total_log := log(total + 1),]
base_d[,total_lag_scaled := scale(total_lag),]
base_d[,total_lag_log := log(total_lag + 1),]
base_d[,total_dif := total-total_lag,]
base_d[,total_lag_dif := shift(total_dif, 1, "lag"),]
base_d[,copom_scaled := scale(copom),]
base_d[,copom_lag := shift(copom, 1, "lag"),]
base_d[,copom_log := log(copom + 1),]
base_d[,copom_lag_scaled := scale(copom_lag),]
base_d[,copom_lag_log := log(copom_lag + 1),]
base_d[,copom_dif := copom-copom_lag,]
base_d[,copom_lag_dif := shift(copom_dif, 1, "lag"),]
base_d[,incerteza_scaled := scale(incerteza),]
base_d[,incerteza_lag := shift(incerteza, 1, "lag"),]
base_d[,incerteza_log := log(incerteza + 1),]
base_d[,incerteza_lag_scaled := scale(incerteza_lag),]
base_d[,incerteza_lag_log := log(incerteza_lag + 1),]
base_d[,incerteza_dif := incerteza-incerteza_lag,]
base_d[,incerteza_lag_dif := shift(incerteza_dif, 1, "lag"),]
base_d[,credibilidade_scaled := scale(credibilidade),]
base_d[,credibilidade_lag := shift(credibilidade, 1, "lag"),]
base_d[,credibilidade_log := log(credibilidade + 1),]
base_d[,credibilidade_lag_scaled := scale(credibilidade_lag),]
base_d[,credibilidade_lag_log := log(credibilidade_lag + 1),]
base_d[,credibilidade_dif := credibilidade-credibilidade_lag,]
base_d[,credibilidade_lag_dif := shift(credibilidade_dif, 1, "lag"),]
base_d[,focus_scaled := scale(focus),]
base_d[,focus_lag := shift(focus, 1, "lag"),]
base_d[,focus_log := log(focus + 1),]
base_d[,focus_lag_scaled := scale(focus_lag),]
base_d[,focus_lag_log := log(focus_lag + 1),]
base_d[,focus_dif := focus-focus_lag,]
base_d[,focus_lag_dif := shift(focus_dif, 1, "lag"),]
base_d[,autonomia_scaled := scale(autonomia),]
base_d[,autonomia_lag := shift(autonomia, 1, "lag"),]
base_d[,autonomia_log := log(autonomia + 1),]
base_d[,autonomia_lag_scaled := scale(autonomia_lag),]
base_d[,autonomia_lag_log := log(autonomia_lag + 1),]
base_d[,autonomia_dif := autonomia-autonomia_lag,]
base_d[,autonomia_lag_dif := shift(autonomia_dif, 1, "lag"),]
base_d[,prob_C_scaled := scale(prob_C),]
base_d[,prob_C_lag := shift(prob_C, 1, "lag"),]
base_d[,prob_C_log := log(prob_C + 1),]
base_d[,prob_C_lag_scaled := scale(prob_C_lag),]
base_d[,prob_C_lag_log := log(prob_C_lag + 1),]
base_d[,prob_C_dif := prob_C-prob_C_lag,]
base_d[,prob_C_lag_dif := shift(prob_C_dif, 1, "lag"),]
base_d[,prob_N_scaled := scale(prob_N),]
base_d[,prob_N_lag := shift(prob_N, 1, "lag"),]
base_d[,prob_N_log := log(prob_N + 1),]
base_d[,prob_N_lag_scaled := scale(prob_N_lag),]
base_d[,prob_N_lag_log := log(prob_N_lag + 1),]
base_d[,prob_N_dif := prob_N-prob_N_lag,]
base_d[,prob_N_lag_dif := shift(prob_N_dif, 1, "lag"),]
base_d[,qtd_C_scaled := scale(qtd_C),]
base_d[,qtd_C_lag := shift(qtd_C, 1, "lag"),]
base_d[,qtd_C_log := log(qtd_C + 1),]
base_d[,qtd_C_lag_scaled := scale(qtd_C_lag),]
base_d[,qtd_C_lag_log := log(qtd_C_lag + 1),]
base_d[,qtd_C_dif := qtd_C-qtd_C_lag,]
base_d[,qtd_C_lag_dif := shift(qtd_C_dif, 1, "lag"),]

base_d[,incerteza_rel := incerteza/total,]
base_d[,incerteza_rel_lag := shift(incerteza_rel, 1, "lag"),]
base_d[,incerteza_rel_dif := incerteza_rel-incerteza_rel_lag,]

base_d[,selic_meta_aa_scaled := scale(selic_meta_aa),]
base_d[,selic_meta_aa_lag := shift(selic_meta_aa, 1, "lag"),]
base_d[,selic_meta_aa_log := log(selic_meta_aa + 1),]
base_d[,selic_meta_aa_lag_scaled := scale(selic_meta_aa_lag),]
base_d[,selic_meta_aa_lag_log := log(selic_meta_aa_lag + 1),]
base_d[,selic_meta_aa_dif := selic_meta_aa-selic_meta_aa_lag,]
base_d[,selic_meta_aa_lag_dif := shift(selic_meta_aa_dif, 1, "lag"),]
base_d[,dolarcompra_scaled := scale(dolarcompra),]
base_d[,dolarcompra_lag := shift(dolarcompra, 1, "lag"),]
base_d[,dolarcompra_log := log(dolarcompra + 1),]
base_d[,dolarcompra_lag_scaled := scale(dolarcompra_lag),]
base_d[,dolarcompra_lag_log := log(dolarcompra_lag + 1),]
base_d[,dolarcompra_dif := dolarcompra-dolarcompra_lag,]
base_d[,dolarcompra_lag_dif := shift(dolarcompra_dif, 1, "lag"),]
base_d[,dolarvenda_scaled := scale(dolarvenda),]
base_d[,dolarvenda_lag := shift(dolarvenda, 1, "lag"),]
base_d[,dolarvenda_log := log(dolarvenda + 1),]
base_d[,dolarvenda_lag_scaled := scale(dolarvenda_lag),]
base_d[,dolarvenda_lag_log := log(dolarvenda_lag + 1),]
base_d[,dolarvenda_dif := dolarvenda-dolarvenda_lag,]
base_d[,dolarvenda_lag_dif := shift(dolarvenda_dif, 1, "lag"),]
base_d[,ibovespa_scaled := scale(ibovespa),]
base_d[,ibovespa_lag := shift(ibovespa, 1, "lag"),]
base_d[,ibovespa_log := log(ibovespa + 1),]
base_d[,ibovespa_lag_scaled := scale(ibovespa_lag),]
base_d[,ibovespa_lag_log := log(ibovespa_lag + 1),]
base_d[,ibovespa_dif := ibovespa-ibovespa_lag,]
base_d[,ibovespa_lag_dif := shift(ibovespa_dif, 1, "lag"),]
base_d[,embi_scaled := scale(embi),]
base_d[,embi_lag := shift(embi, 1, "lag"),]
base_d[,embi_log := log(embi + 1),]
base_d[,embi_lag_scaled := scale(embi_lag),]
base_d[,embi_lag_log := log(embi_lag + 1),]
base_d[,embi_dif := embi-embi_lag,]
base_d[,embi_lag_dif := shift(embi_dif, 1, "lag"),]

base_d[DATA <= as.Date("2010-12-31") , presidente := "Meirelles" ]
base_d[DATA > as.Date("2010-12-31") & DATA <= as.Date("2016-06-09")  , presidente := "Tombini" ]
base_d[DATA > as.Date("2016-06-09") & DATA <= as.Date("2019-02-27")  , presidente := "Goldfajn" ]
base_d[DATA > as.Date("2019-02-27") , presidente := "Campos" ]

base_m[,total_scaled := scale(total),]
base_m[,total_lag := shift(total, 1, "lag"),]
base_m[,total_log := log(total + 1),]
base_m[,total_lag_scaled := scale(total_lag),]
base_m[,total_lag_log := log(total_lag + 1),]
base_m[,total_dif := total-total_lag,]
base_m[,total_lag_dif := shift(total_dif, 1, "lag"),]
base_m[,copom_scaled := scale(copom),]
base_m[,copom_lag := shift(copom, 1, "lag"),]
base_m[,copom_log := log(copom + 1),]
base_m[,copom_lag_scaled := scale(copom_lag),]
base_m[,copom_lag_log := log(copom_lag + 1),]
base_m[,copom_dif := copom-copom_lag,]
base_m[,copom_lag_dif := shift(copom_dif, 1, "lag"),]
base_m[,incerteza_scaled := scale(incerteza),]
base_m[,incerteza_lag := shift(incerteza, 1, "lag"),]
base_m[,incerteza_log := log(incerteza + 1),]
base_m[,incerteza_lag_scaled := scale(incerteza_lag),]
base_m[,incerteza_lag_log := log(incerteza_lag + 1),]
base_m[,incerteza_dif := incerteza-incerteza_lag,]
base_m[,incerteza_lag_dif := shift(incerteza_dif, 1, "lag"),]
base_m[,credibilidade_scaled := scale(credibilidade),]
base_m[,credibilidade_lag := shift(credibilidade, 1, "lag"),]
base_m[,credibilidade_log := log(credibilidade + 1),]
base_m[,credibilidade_lag_scaled := scale(credibilidade_lag),]
base_m[,credibilidade_lag_log := log(credibilidade_lag + 1),]
base_m[,credibilidade_dif := credibilidade-credibilidade_lag,]
base_m[,credibilidade_lag_dif := shift(credibilidade_dif, 1, "lag"),]
base_m[,focus_scaled := scale(focus),]
base_m[,focus_lag := shift(focus, 1, "lag"),]
base_m[,focus_log := log(focus + 1),]
base_m[,focus_lag_scaled := scale(focus_lag),]
base_m[,focus_lag_log := log(focus_lag + 1),]
base_m[,focus_dif := focus-focus_lag,]
base_m[,focus_lag_dif := shift(focus_dif, 1, "lag"),]
base_m[,autonomia_scaled := scale(autonomia),]
base_m[,autonomia_lag := shift(autonomia, 1, "lag"),]
base_m[,autonomia_log := log(autonomia + 1),]
base_m[,autonomia_lag_scaled := scale(autonomia_lag),]
base_m[,autonomia_lag_log := log(autonomia_lag + 1),]
base_m[,autonomia_dif := autonomia-autonomia_lag,]
base_m[,autonomia_lag_dif := shift(autonomia_dif, 1, "lag"),]
base_m[,prob_C_scaled := scale(prob_C),]
base_m[,prob_C_lag := shift(prob_C, 1, "lag"),]
base_m[,prob_C_log := log(prob_C + 1),]
base_m[,prob_C_lag_scaled := scale(prob_C_lag),]
base_m[,prob_C_lag_log := log(prob_C_lag + 1),]
base_m[,prob_C_dif := prob_C-prob_C_lag,]
base_m[,prob_C_lag_dif := shift(prob_C_dif, 1, "lag"),]
base_m[,prob_N_scaled := scale(prob_N),]
base_m[,prob_N_lag := shift(prob_N, 1, "lag"),]
base_m[,prob_N_log := log(prob_N + 1),]
base_m[,prob_N_lag_scaled := scale(prob_N_lag),]
base_m[,prob_N_lag_log := log(prob_N_lag + 1),]
base_m[,prob_N_dif := prob_N-prob_N_lag,]
base_m[,prob_N_lag_dif := shift(prob_N_dif, 1, "lag"),]
base_m[,qtd_C_scaled := scale(qtd_C),]
base_m[,qtd_C_lag := shift(qtd_C, 1, "lag"),]
base_m[,qtd_C_log := log(qtd_C + 1),]
base_m[,qtd_C_lag_scaled := scale(qtd_C_lag),]
base_m[,qtd_C_lag_log := log(qtd_C_lag + 1),]
base_m[,qtd_C_dif := qtd_C-qtd_C_lag,]
base_m[,qtd_C_lag_dif := shift(qtd_C_dif, 1, "lag"),]

base_m[,incerteza_rel := incerteza/total,]
base_m[,incerteza_rel_lag := shift(incerteza_rel, 1, "lag"),]
base_m[,incerteza_rel_dif := incerteza_rel-incerteza_rel_lag,]

base_m[,pib_scaled := scale(pib),]
base_m[,pib_lag := shift(pib, 1, "lag"),]
base_m[,pib_log := log(pib + 1),]
base_m[,pib_lag_scaled := scale(pib_lag),]
base_m[,pib_lag_log := log(pib_lag + 1),]
base_m[,pib_dif := pib-pib_lag,]
base_m[,pib_lag_dif := shift(pib_dif, 1, "lag"),]
base_m[,selic_over_am_scaled := scale(selic_over_am),]
base_m[,selic_over_am_lag := shift(selic_over_am, 1, "lag"),]
base_m[,selic_over_am_log := log(selic_over_am + 1),]
base_m[,selic_over_am_lag_scaled := scale(selic_over_am_lag),]
base_m[,selic_over_am_lag_log := log(selic_over_am_lag + 1),]
base_m[,selic_over_am_dif := selic_over_am-selic_over_am_lag,]
base_m[,selic_over_am_lag_dif := shift(selic_over_am_dif, 1, "lag"),]
base_m[,selic_meta_aa_scaled := scale(selic_meta_aa),]
base_m[,selic_meta_aa_lag := shift(selic_meta_aa, 1, "lag"),]
base_m[,selic_meta_aa_log := log(selic_meta_aa + 1),]
base_m[,selic_meta_aa_lag_scaled := scale(selic_meta_aa_lag),]
base_m[,selic_meta_aa_lag_log := log(selic_meta_aa_lag + 1),]
base_m[,selic_meta_aa_dif := selic_meta_aa-selic_meta_aa_lag,]
base_m[,selic_meta_aa_lag_dif := shift(selic_meta_aa_dif, 1, "lag"),]
base_m[,swapdi180_scaled := scale(swapdi180),]
base_m[,swapdi180_lag := shift(swapdi180, 1, "lag"),]
base_m[,swapdi180_log := log(swapdi180 + 1),]
base_m[,swapdi180_lag_scaled := scale(swapdi180_lag),]
base_m[,swapdi180_lag_log := log(swapdi180_lag + 1),]
base_m[,swapdi180_dif := swapdi180-swapdi180_lag,]
base_m[,swapdi180_lag_dif := shift(swapdi180_dif, 1, "lag"),]
base_m[,swapdi360_scaled := scale(swapdi360),]
base_m[,swapdi360_lag := shift(swapdi360, 1, "lag"),]
base_m[,swapdi360_log := log(swapdi360 + 1),]
base_m[,swapdi360_lag_scaled := scale(swapdi360_lag),]
base_m[,swapdi360_lag_log := log(swapdi360_lag + 1),]
base_m[,swapdi360_dif := swapdi360-swapdi360_lag,]
base_m[,swapdi360_lag_dif := shift(swapdi360_dif, 1, "lag"),]
base_m[,salminreal_scaled := scale(salminreal),]
base_m[,salminreal_lag := shift(salminreal, 1, "lag"),]
base_m[,salminreal_log := log(salminreal + 1),]
base_m[,salminreal_lag_scaled := scale(salminreal_lag),]
base_m[,salminreal_lag_log := log(salminreal_lag + 1),]
base_m[,salminreal_dif := salminreal-salminreal_lag,]
base_m[,salminreal_lag_dif := shift(salminreal_dif, 1, "lag"),]
base_m[,dolarcompra_scaled := scale(dolarcompra),]
base_m[,dolarcompra_lag := shift(dolarcompra, 1, "lag"),]
base_m[,dolarcompra_log := log(dolarcompra + 1),]
base_m[,dolarcompra_lag_scaled := scale(dolarcompra_lag),]
base_m[,dolarcompra_lag_log := log(dolarcompra_lag + 1),]
base_m[,dolarcompra_dif := dolarcompra-dolarcompra_lag,]
base_m[,dolarcompra_lag_dif := shift(dolarcompra_dif, 1, "lag"),]
base_m[,dolarvenda_scaled := scale(dolarvenda),]
base_m[,dolarvenda_lag := shift(dolarvenda, 1, "lag"),]
base_m[,dolarvenda_log := log(dolarvenda + 1),]
base_m[,dolarvenda_lag_scaled := scale(dolarvenda_lag),]
base_m[,dolarvenda_lag_log := log(dolarvenda_lag + 1),]
base_m[,dolarvenda_dif := dolarvenda-dolarvenda_lag,]
base_m[,dolarvenda_lag_dif := shift(dolarvenda_dif, 1, "lag"),]
base_m[,ibovespa_scaled := scale(ibovespa),]
base_m[,ibovespa_lag := shift(ibovespa, 1, "lag"),]
base_m[,ibovespa_log := log(ibovespa + 1),]
base_m[,ibovespa_lag_scaled := scale(ibovespa_lag),]
base_m[,ibovespa_lag_log := log(ibovespa_lag + 1),]
base_m[,ibovespa_dif := ibovespa-ibovespa_lag,]
base_m[,ibovespa_lag_dif := shift(ibovespa_dif, 1, "lag"),]
base_m[,igpm_scaled := scale(igpm),]
base_m[,igpm_lag := shift(igpm, 1, "lag"),]
base_m[,igpm_log := log(igpm + 1 + abs(min(base_m$igpm, na.rm = T))),]
base_m[,igpm_lag_scaled := scale(igpm_lag),]
base_m[,igpm_lag_log := log(igpm_lag + 1 + abs(min(base_m$igpm, na.rm = T))),]
base_m[,igpm_dif := igpm-igpm_lag,]
base_m[,igpm_lag_dif := shift(igpm_dif, 1, "lag"),]
base_m[,embi_scaled := scale(embi),]
base_m[,embi_lag := shift(embi, 1, "lag"),]
base_m[,embi_log := log(embi + 1),]
base_m[,embi_lag_scaled := scale(embi_lag),]
base_m[,embi_lag_log := log(embi_lag + 1),]
base_m[,embi_dif := embi-embi_lag,]
base_m[,embi_lag_dif := shift(embi_dif, 1, "lag"),]
base_m[,desocupacao_scaled := scale(desocupacao),]
base_m[,desocupacao_lag := shift(desocupacao, 1, "lag"),]
base_m[,desocupacao_log := log(desocupacao + 1),]
base_m[,desocupacao_lag_scaled := scale(desocupacao_lag),]
base_m[,desocupacao_lag_log := log(desocupacao_lag + 1),]
base_m[,desocupacao_dif := desocupacao-desocupacao_lag,]
base_m[,desocupacao_lag_dif := shift(desocupacao_dif, 1, "lag"),]
base_m[,inpc_scaled := scale(inpc),]
base_m[,inpc_lag := shift(inpc, 1, "lag"),]
base_m[,inpc_log := log(inpc + 1 + abs(min(base_m$inpc, na.rm = T))),]
base_m[,inpc_lag_scaled := scale(inpc_lag),]
base_m[,inpc_lag_log := log(inpc_lag + 1 + abs(min(base_m$inpc, na.rm = T))),]
base_m[,inpc_dif := inpc-inpc_lag,]
base_m[,inpc_lag_dif := shift(inpc_dif, 1, "lag"),]
base_m[,ipca_scaled := scale(ipca),]
base_m[,ipca_lag := shift(ipca, 1, "lag"),]
base_m[,ipca_log := log(ipca + 1 + abs(min(base_m$ipca, na.rm = T))),]
base_m[,ipca_lag_scaled := scale(ipca_lag),]
base_m[,ipca_lag_log := log(ipca_lag + 1 + abs(min(base_m$ipca, na.rm = T))),]
base_m[,ipca_dif := ipca-ipca_lag,]
base_m[,ipca_lag_dif := shift(ipca_dif, 1, "lag"),]
base_m[,uncertainty_scaled := scale(uncertainty),]
base_m[,uncertainty_lag := shift(uncertainty, 1, "lag"),]
base_m[,uncertainty_log := log(uncertainty + 1),]
base_m[,uncertainty_lag_scaled := scale(uncertainty_lag),]
base_m[,uncertainty_lag_log := log(uncertainty_lag + 1),]
base_m[,uncertainty_dif := uncertainty-uncertainty_lag,]
base_m[,uncertainty_lag_dif := shift(uncertainty_dif, 1, "lag"),]
base_m[,iiebr_scaled := scale(iiebr),]
base_m[,iiebr_lag := shift(iiebr, 1, "lag"),]
base_m[,iiebr_log := log(iiebr + 1),]
base_m[,iiebr_lag_scaled := scale(iiebr_lag),]
base_m[,iiebr_lag_log := log(iiebr_lag + 1),]
base_m[,iiebr_dif := iiebr-iiebr_lag,]
base_m[,iiebr_lag_dif := shift(iiebr_dif, 1, "lag"),]

base_m[DATA <= as.Date("2010-12-31") , presidente := "Meirelles" ]
base_m[DATA > as.Date("2010-12-31") & DATA <= as.Date("2016-06-09")  , presidente := "Tombini" ]
base_m[DATA > as.Date("2016-06-09") & DATA <= as.Date("2019-02-27")  , presidente := "Goldfajn" ]
base_m[DATA > as.Date("2019-02-27") , presidente := "Campos" ]

base_d <- base_d[DATA < as.Date("2020-12-01") ,  , ]
base_m <- base_m[DATA < as.Date("2020-12-01") ,  , ]

#stargazer(base_m[,c("incerteza_dif","dolarcompra_dif","pib_dif","ibovespa_dif","embi_dif","ipca_dif","uncertainty_dif","iiebr_dif"),],type="text", median = T)

base_m$pib_dif2 <- base_m$pib_dif/1e9
base_m$ibovespa_dif2 <- base_m$ibovespa_dif/1e3
base_d$ibovespa_dif2 <- base_d$ibovespa_dif/1e3

###############################################################################
## Funções -------------------------------------------------------------------
###############################################################################

printlm <- function(df, formula_){
  stargazer(
    felm(
      data = df,
      formula = formula_
      
    ),
    type = "text"
  )
}



# Teste augmented dickey fuller -------------------------------------------

library(tseries)
adf.test(base_m$incerteza_dif[-1], alternative = "stationary")
adf.test(base_m$dolarcompra_dif[-1], alternative = "stationary")
adf.test(base_m$pib_dif[3:(length(base_m$pib_dif)-1)], alternative = "stationary")
adf.test(base_m$ibovespa_dif[-1], alternative = "stationary")
adf.test(base_m$embi_dif[-1], alternative = "stationary")
adf.test(base_m$ipca_dif[-(1:2)], alternative = "stationary")
adf.test(base_m$uncertainty_dif[3:(length(base_m$uncertainty_dif)-1)], alternative = "stationary")
adf.test(base_m$iiebr_dif[3:(length(base_m$iiebr_dif)-1)], alternative = "stationary")

adf.test(base_d$incerteza_dif[-1], alternative = "stationary")
adf.test(na.remove(base_d$dolarcompra_dif), alternative = "stationary")
adf.test(na.remove(base_d$ibovespa_dif), alternative = "stationary")
adf.test(na.remove(base_d$embi_dif), alternative = "stationary")

###############################################################################
## Regressoes
###############################################################################


# EFEITO FIXO PRESIDENTE --------------------------------------------------



# total -------------------------------------------------------------------
# OK / NOK / ?


printlm(base_m, total_scaled ~ pib_scaled | factor(presidente))
printlm(base_m, total_scaled ~ pib_lag_scaled | factor(presidente))
printlm(base_m, total_log ~ pib_log | factor(presidente)) #***  NOK
printlm(base_m, total_log ~ pib_lag_log | factor(presidente)) #***  NOK
printlm(base_m, total_dif ~ pib_dif | factor(presidente))
printlm(base_m, total_dif ~ pib_lag_dif | factor(presidente)) #*nOK

printlm(base_m, total_scaled ~ dolarcompra_scaled | factor(presidente)) #** OK
printlm(base_m, total_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #** OK
printlm(base_m, total_log ~ dolarcompra_log | factor(presidente)) 
printlm(base_m, total_log ~ dolarcompra_lag_log | factor(presidente))
printlm(base_m, total_dif ~ dolarcompra_dif | factor(presidente)) #** OK
printlm(base_m, total_dif ~ dolarcompra_lag_dif | factor(presidente))

printlm(base_m, total_scaled ~ ibovespa_scaled | factor(presidente))
printlm(base_m, total_scaled ~ ibovespa_lag_scaled | factor(presidente))
printlm(base_m, total_log ~ ibovespa_log | factor(presidente))
printlm(base_m, total_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_m, total_dif ~ ibovespa_dif | factor(presidente))
printlm(base_m, total_dif ~ ibovespa_lag_dif | factor(presidente))

printlm(base_m, total_scaled ~ embi_scaled | factor(presidente))
printlm(base_m, total_scaled ~ embi_lag_scaled | factor(presidente))
printlm(base_m, total_log ~ embi_log | factor(presidente))
printlm(base_m, total_log ~ embi_lag_log | factor(presidente)) 
printlm(base_m, total_dif ~ embi_dif | factor(presidente))
printlm(base_m, total_dif ~ embi_lag_dif | factor(presidente))

printlm(base_m, total_scaled ~ igpm_scaled | factor(presidente)) #*** OK
printlm(base_m, total_scaled ~ igpm_lag_scaled | factor(presidente))
printlm(base_m, total_log ~ igpm_log | factor(presidente))
printlm(base_m, total_log ~ igpm_lag_log | factor(presidente)) 
printlm(base_m, total_dif ~ igpm_dif | factor(presidente))
printlm(base_m, total_dif ~ igpm_lag_dif | factor(presidente))

printlm(base_m, total_scaled ~ inpc_scaled | factor(presidente))
printlm(base_m, total_scaled ~ inpc_lag_scaled | factor(presidente)) #** NOK
printlm(base_m, total_log ~ inpc_log | factor(presidente))
printlm(base_m, total_log ~ inpc_lag_log | factor(presidente)) #* NOK
printlm(base_m, total_dif ~ inpc_dif | factor(presidente))
printlm(base_m, total_dif ~ inpc_lag_dif | factor(presidente)) #*** NOK

printlm(base_m, total_scaled ~ ipca_scaled | factor(presidente))
printlm(base_m, total_scaled ~ ipca_lag_scaled | factor(presidente)) #** NOK
printlm(base_m, total_log ~ ipca_log | factor(presidente))
printlm(base_m, total_log ~ ipca_lag_log | factor(presidente)) 
printlm(base_m, total_dif ~ ipca_dif | factor(presidente))
printlm(base_m, total_dif ~ ipca_lag_dif | factor(presidente)) #** NOK

printlm(base_m, total_scaled ~ uncertainty_scaled | factor(presidente))
printlm(base_m, total_scaled ~ uncertainty_lag_scaled | factor(presidente))
printlm(base_m, total_log ~ uncertainty_log | factor(presidente)) #* NOK
printlm(base_m, total_log ~ uncertainty_lag_log | factor(presidente)) 
printlm(base_m, total_dif ~ uncertainty_dif | factor(presidente))
printlm(base_m, total_dif ~ uncertainty_lag_dif | factor(presidente))

printlm(base_m, total_scaled ~ iiebr_scaled | factor(presidente)) #*** OK
printlm(base_m, total_scaled ~ iiebr_lag_scaled | factor(presidente)) #*** OK
printlm(base_m, total_log ~ iiebr_log | factor(presidente)) #** OK
printlm(base_m, total_log ~ iiebr_lag_log | factor(presidente)) #** OK
printlm(base_m, total_dif ~ iiebr_dif | factor(presidente))
printlm(base_m, total_dif ~ iiebr_lag_dif | factor(presidente)) #**

printlm(base_d, total_scaled ~ dolarcompra_scaled | factor(presidente)) #*** OK
printlm(base_d, total_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, total_log ~ dolarcompra_log | factor(presidente)) 
printlm(base_d, total_log ~ dolarcompra_lag_log | factor(presidente))
printlm(base_d, total_dif ~ dolarcompra_dif | factor(presidente))
printlm(base_d, total_dif ~ dolarcompra_lag_dif | factor(presidente))

printlm(base_d, total_scaled ~ ibovespa_scaled | factor(presidente)) #* OK
printlm(base_d, total_scaled ~ ibovespa_lag_scaled | factor(presidente)) #* OK
printlm(base_d, total_log ~ ibovespa_log | factor(presidente)) #*** NOK
printlm(base_d, total_log ~ ibovespa_lag_log | factor(presidente)) #*** NOK
printlm(base_d, total_dif ~ ibovespa_dif | factor(presidente))
printlm(base_d, total_dif ~ ibovespa_lag_dif | factor(presidente))

printlm(base_d, total_scaled ~ embi_scaled | factor(presidente)) #** OK
printlm(base_d, total_scaled ~ embi_lag_scaled | factor(presidente)) #** OK
printlm(base_d, total_log ~ embi_log | factor(presidente)) #** NOK
printlm(base_d, total_log ~ embi_lag_log | factor(presidente))
printlm(base_d, total_dif ~ embi_dif | factor(presidente))
printlm(base_d, total_dif ~ embi_lag_dif | factor(presidente))


# copom -------------------------------------------------------------------

printlm(base_m, copom_scaled ~ pib_scaled | factor(presidente)) #* OK
printlm(base_m, copom_scaled ~ pib_lag_scaled | factor(presidente)) #** OK
printlm(base_m, copom_log ~ pib_log | factor(presidente)) #***  NOK
printlm(base_m, copom_log ~ pib_lag_log | factor(presidente)) #**  NOK
printlm(base_m, copom_dif ~ pib_dif | factor(presidente))
printlm(base_m, copom_dif ~ pib_lag_dif | factor(presidente))

printlm(base_m, copom_scaled ~ dolarcompra_scaled | factor(presidente)) #** NOK
printlm(base_m, copom_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #** NOK
printlm(base_m, copom_log ~ dolarcompra_log | factor(presidente)) 
printlm(base_m, copom_log ~ dolarcompra_lag_log | factor(presidente))
printlm(base_m, copom_dif ~ dolarcompra_dif | factor(presidente))
printlm(base_m, copom_dif ~ dolarcompra_lag_dif | factor(presidente))

printlm(base_m, copom_scaled ~ ibovespa_scaled | factor(presidente))
printlm(base_m, copom_scaled ~ ibovespa_lag_scaled | factor(presidente))
printlm(base_m, copom_log ~ ibovespa_log | factor(presidente))
printlm(base_m, copom_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_m, copom_dif ~ ibovespa_dif | factor(presidente))
printlm(base_m, copom_dif ~ ibovespa_lag_dif | factor(presidente))

printlm(base_m, copom_scaled ~ embi_scaled | factor(presidente)) #* NOK
printlm(base_m, copom_scaled ~ embi_lag_scaled | factor(presidente))
printlm(base_m, copom_log ~ embi_log | factor(presidente))
printlm(base_m, copom_log ~ embi_lag_log | factor(presidente)) 
printlm(base_m, copom_dif ~ embi_dif | factor(presidente))
printlm(base_m, copom_dif ~ embi_lag_dif | factor(presidente))

printlm(base_m, copom_scaled ~ igpm_scaled | factor(presidente)) 
printlm(base_m, copom_scaled ~ igpm_lag_scaled | factor(presidente))
printlm(base_m, copom_log ~ igpm_log | factor(presidente))
printlm(base_m, copom_log ~ igpm_lag_log | factor(presidente)) 
printlm(base_m, copom_dif ~ igpm_dif | factor(presidente))
printlm(base_m, copom_dif ~ igpm_lag_dif | factor(presidente))

printlm(base_m, copom_scaled ~ inpc_scaled | factor(presidente))
printlm(base_m, copom_scaled ~ inpc_lag_scaled | factor(presidente)) #*** NOK
printlm(base_m, copom_log ~ inpc_log | factor(presidente))
printlm(base_m, copom_log ~ inpc_lag_log | factor(presidente)) #*** NOK
printlm(base_m, copom_dif ~ inpc_dif | factor(presidente)) #* OK
printlm(base_m, copom_dif ~ inpc_lag_dif | factor(presidente)) #***NOK

printlm(base_m, copom_scaled ~ ipca_scaled | factor(presidente))
printlm(base_m, copom_scaled ~ ipca_lag_scaled | factor(presidente)) #** NOK
printlm(base_m, copom_log ~ ipca_log | factor(presidente))
printlm(base_m, copom_log ~ ipca_lag_log | factor(presidente)) #*** NOK
printlm(base_m, copom_dif ~ ipca_dif | factor(presidente))
printlm(base_m, copom_dif ~ ipca_lag_dif | factor(presidente)) #*** NOK

printlm(base_m, copom_scaled ~ uncertainty_scaled | factor(presidente))
printlm(base_m, copom_scaled ~ uncertainty_lag_scaled | factor(presidente))
printlm(base_m, copom_log ~ uncertainty_log | factor(presidente)) 
printlm(base_m, copom_log ~ uncertainty_lag_log | factor(presidente)) 
printlm(base_m, copom_dif ~ uncertainty_dif | factor(presidente))
printlm(base_m, copom_dif ~ uncertainty_lag_dif | factor(presidente))

printlm(base_m, copom_scaled ~ iiebr_scaled | factor(presidente)) 
printlm(base_m, copom_scaled ~ iiebr_lag_scaled | factor(presidente)) 
printlm(base_m, copom_log ~ iiebr_log | factor(presidente)) 
printlm(base_m, copom_log ~ iiebr_lag_log | factor(presidente)) 
printlm(base_m, copom_dif ~ iiebr_dif | factor(presidente))
printlm(base_m, copom_dif ~ iiebr_lag_dif | factor(presidente))

printlm(base_d, copom_scaled ~ dolarcompra_scaled | factor(presidente)) #** NOK
printlm(base_d, copom_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #** NOK
printlm(base_d, copom_log ~ dolarcompra_log | factor(presidente)) #*** NOK
printlm(base_d, copom_log ~ dolarcompra_lag_log | factor(presidente)) #*** NOK
printlm(base_d, copom_dif ~ dolarcompra_dif | factor(presidente))
printlm(base_d, copom_dif ~ dolarcompra_lag_dif | factor(presidente))

printlm(base_d, copom_scaled ~ ibovespa_scaled | factor(presidente)) 
printlm(base_d, copom_scaled ~ ibovespa_lag_scaled | factor(presidente))
printlm(base_d, copom_log ~ ibovespa_log | factor(presidente)) #*** NOK
printlm(base_d, copom_log ~ ibovespa_lag_log | factor(presidente)) #*** NOK
printlm(base_d, copom_dif ~ ibovespa_dif | factor(presidente))
printlm(base_d, copom_dif ~ ibovespa_lag_dif | factor(presidente))

printlm(base_d, copom_scaled ~ embi_scaled | factor(presidente)) #* OK
printlm(base_d, copom_scaled ~ embi_lag_scaled | factor(presidente)) 
printlm(base_d, copom_log ~ embi_log | factor(presidente)) #*** NOK
printlm(base_d, copom_log ~ embi_lag_log | factor(presidente)) #*** NOK
printlm(base_d, copom_dif ~ embi_dif | factor(presidente))
printlm(base_d, copom_dif ~ embi_lag_dif | factor(presidente))


# incerteza ---------------------------------------------------------------

printlm(base_m, incerteza_scaled ~ pib_scaled | factor(presidente))
printlm(base_m, incerteza_scaled ~ pib_lag_scaled | factor(presidente))
printlm(base_m, incerteza_log ~ pib_log | factor(presidente)) #***  NOK
printlm(base_m, incerteza_log ~ pib_lag_log | factor(presidente)) #**  NOK
printlm(base_m, incerteza_dif ~ pib_dif | factor(presidente))
printlm(base_m, incerteza_dif ~ pib_lag_dif | factor(presidente)) #* nOK
printlm(base_m, incerteza_dif ~ pib_dif2 | factor(presidente))

printlm(base_m, incerteza_scaled ~ dolarcompra_scaled | factor(presidente)) #***
printlm(base_m, incerteza_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #***
printlm(base_m, incerteza_log ~ dolarcompra_log | factor(presidente)) #***
printlm(base_m, incerteza_log ~ dolarcompra_lag_log | factor(presidente)) #***
printlm(base_m, incerteza_dif ~ dolarcompra_dif | factor(presidente))#***
printlm(base_m, incerteza_dif ~ dolarcompra_lag_dif | factor(presidente))

printlm(base_m, incerteza_scaled ~ ibovespa_scaled | factor(presidente)) #***
printlm(base_m, incerteza_scaled ~ ibovespa_lag_scaled | factor(presidente)) #***
printlm(base_m, incerteza_log ~ ibovespa_log | factor(presidente)) #***
printlm(base_m, incerteza_log ~ ibovespa_lag_log | factor(presidente)) #**
printlm(base_m, incerteza_dif ~ ibovespa_dif | factor(presidente)) #***
printlm(base_m, incerteza_dif ~ ibovespa_lag_dif | factor(presidente))
printlm(base_m, incerteza_dif ~ ibovespa_dif2 | factor(presidente)) #***

printlm(base_m, incerteza_scaled ~ embi_scaled | factor(presidente)) #***
printlm(base_m, incerteza_scaled ~ embi_lag_scaled | factor(presidente)) #***
printlm(base_m, incerteza_log ~ embi_log | factor(presidente)) #***
printlm(base_m, incerteza_log ~ embi_lag_log | factor(presidente)) #***
printlm(base_m, incerteza_dif ~ embi_dif | factor(presidente)) #**
printlm(base_m, incerteza_dif ~ embi_lag_dif | factor(presidente))

printlm(base_m, incerteza_scaled ~ igpm_scaled | factor(presidente)) #* OK
printlm(base_m, incerteza_scaled ~ igpm_lag_scaled | factor(presidente))
printlm(base_m, incerteza_log ~ igpm_log | factor(presidente))
printlm(base_m, incerteza_log ~ igpm_lag_log | factor(presidente))
printlm(base_m, incerteza_dif ~ igpm_dif | factor(presidente))
printlm(base_m, incerteza_dif ~ igpm_lag_dif | factor(presidente))

printlm(base_m, incerteza_scaled ~ inpc_scaled | factor(presidente))
printlm(base_m, incerteza_scaled ~ inpc_lag_scaled | factor(presidente))
printlm(base_m, incerteza_log ~ inpc_log | factor(presidente))
printlm(base_m, incerteza_log ~ inpc_lag_log | factor(presidente)) 
printlm(base_m, incerteza_dif ~ inpc_dif | factor(presidente))
printlm(base_m, incerteza_dif ~ inpc_lag_dif | factor(presidente)) #** NOK

printlm(base_m, incerteza_scaled ~ ipca_scaled | factor(presidente))
printlm(base_m, incerteza_scaled ~ ipca_lag_scaled | factor(presidente))
printlm(base_m, incerteza_log ~ ipca_log | factor(presidente))
printlm(base_m, incerteza_log ~ ipca_lag_log | factor(presidente)) 
printlm(base_m, incerteza_dif ~ ipca_dif | factor(presidente))
printlm(base_m, incerteza_dif ~ ipca_lag_dif | factor(presidente))

printlm(base_m, incerteza_scaled ~ uncertainty_scaled | factor(presidente)) #***
printlm(base_m, incerteza_scaled ~ uncertainty_lag_scaled | factor(presidente)) #***
printlm(base_m, incerteza_log ~ uncertainty_log | factor(presidente)) #***
printlm(base_m, incerteza_log ~ uncertainty_lag_log | factor(presidente)) #*
printlm(base_m, incerteza_dif ~ uncertainty_dif | factor(presidente)) #**
printlm(base_m, incerteza_dif ~ uncertainty_lag_dif | factor(presidente)) #*

printlm(base_m, incerteza_scaled ~ iiebr_scaled | factor(presidente)) #*** OK
printlm(base_m, incerteza_scaled ~ iiebr_lag_scaled | factor(presidente)) #*** OK
printlm(base_m, incerteza_log ~ iiebr_log | factor(presidente)) #*** OK
printlm(base_m, incerteza_log ~ iiebr_lag_log | factor(presidente)) #*** OK
printlm(base_m, incerteza_dif ~ iiebr_dif | factor(presidente)) #**
printlm(base_m, incerteza_dif ~ iiebr_lag_dif | factor(presidente))#***


printlm(base_d, incerteza_scaled ~ dolarcompra_scaled | factor(presidente)) #*** OK
printlm(base_d, incerteza_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, incerteza_log ~ dolarcompra_log | factor(presidente)) #***
printlm(base_d, incerteza_log ~ dolarcompra_lag_log | factor(presidente)) #***
printlm(base_d, incerteza_dif ~ dolarcompra_dif | factor(presidente))#**
printlm(base_d, incerteza_dif ~ dolarcompra_lag_dif | factor(presidente))

printlm(base_d, incerteza_scaled ~ ibovespa_scaled | factor(presidente)) #*** OK
printlm(base_d, incerteza_scaled ~ ibovespa_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, incerteza_log ~ ibovespa_log | factor(presidente)) #*** OK
printlm(base_d, incerteza_log ~ ibovespa_lag_log | factor(presidente)) #*** OK
printlm(base_d, incerteza_dif ~ ibovespa_dif | factor(presidente))
printlm(base_d, incerteza_dif ~ ibovespa_lag_dif | factor(presidente))

printlm(base_d, incerteza_scaled ~ embi_scaled | factor(presidente)) #*** OK
printlm(base_d, incerteza_scaled ~ embi_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, incerteza_log ~ embi_log | factor(presidente)) #*** OK
printlm(base_d, incerteza_log ~ embi_lag_log | factor(presidente)) #***
printlm(base_d, incerteza_dif ~ embi_dif | factor(presidente))
printlm(base_d, incerteza_dif ~ embi_lag_dif | factor(presidente))

# credibilidade -----------------------------------------------------------

printlm(base_m, credibilidade_scaled ~ pib_scaled | factor(presidente))
printlm(base_m, credibilidade_scaled ~ pib_lag_scaled | factor(presidente))
printlm(base_m, credibilidade_log ~ pib_log | factor(presidente)) #***  NOK
printlm(base_m, credibilidade_log ~ pib_lag_log | factor(presidente)) #***  NOK
printlm(base_m, credibilidade_dif ~ pib_dif | factor(presidente))

printlm(base_m, credibilidade_scaled ~ dolarcompra_scaled | factor(presidente)) #*** OK
printlm(base_m, credibilidade_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #** OK
printlm(base_m, credibilidade_log ~ dolarcompra_log | factor(presidente)) #***
printlm(base_m, credibilidade_log ~ dolarcompra_lag_log | factor(presidente)) #**
printlm(base_m, credibilidade_dif ~ dolarcompra_dif | factor(presidente)) #*

printlm(base_m, credibilidade_scaled ~ ibovespa_scaled | factor(presidente)) #*
printlm(base_m, credibilidade_scaled ~ ibovespa_lag_scaled | factor(presidente))
printlm(base_m, credibilidade_log ~ ibovespa_log | factor(presidente))
printlm(base_m, credibilidade_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_m, credibilidade_dif ~ ibovespa_dif | factor(presidente))

printlm(base_m, credibilidade_scaled ~ embi_scaled | factor(presidente)) #***
printlm(base_m, credibilidade_scaled ~ embi_lag_scaled | factor(presidente)) #**
printlm(base_m, credibilidade_log ~ embi_log | factor(presidente))
printlm(base_m, credibilidade_log ~ embi_lag_log | factor(presidente)) 
printlm(base_m, credibilidade_dif ~ embi_dif | factor(presidente))

printlm(base_m, credibilidade_scaled ~ igpm_scaled | factor(presidente))
printlm(base_m, credibilidade_scaled ~ igpm_lag_scaled | factor(presidente))
printlm(base_m, credibilidade_log ~ igpm_log | factor(presidente))
printlm(base_m, credibilidade_log ~ igpm_lag_log | factor(presidente)) 
printlm(base_m, credibilidade_dif ~ igpm_dif | factor(presidente))

printlm(base_m, credibilidade_scaled ~ inpc_scaled | factor(presidente)) #*
printlm(base_m, credibilidade_scaled ~ inpc_lag_scaled | factor(presidente))
printlm(base_m, credibilidade_log ~ inpc_log | factor(presidente))
printlm(base_m, credibilidade_log ~ inpc_lag_log | factor(presidente)) 
printlm(base_m, credibilidade_dif ~ inpc_dif | factor(presidente))#***

printlm(base_m, credibilidade_scaled ~ ipca_scaled | factor(presidente))
printlm(base_m, credibilidade_scaled ~ ipca_lag_scaled | factor(presidente)) 
printlm(base_m, credibilidade_log ~ ipca_log | factor(presidente))
printlm(base_m, credibilidade_log ~ ipca_lag_log | factor(presidente)) 
printlm(base_m, credibilidade_dif ~ ipca_dif | factor(presidente))#**

printlm(base_m, credibilidade_scaled ~ uncertainty_scaled | factor(presidente))
printlm(base_m, credibilidade_scaled ~ uncertainty_lag_scaled | factor(presidente)) #*
printlm(base_m, credibilidade_log ~ uncertainty_log | factor(presidente)) 
printlm(base_m, credibilidade_log ~ uncertainty_lag_log | factor(presidente)) 
printlm(base_m, credibilidade_dif ~ uncertainty_dif | factor(presidente))

printlm(base_m, credibilidade_scaled ~ iiebr_scaled | factor(presidente)) #* OK
printlm(base_m, credibilidade_scaled ~ iiebr_lag_scaled | factor(presidente)) #* OK
printlm(base_m, credibilidade_log ~ iiebr_log | factor(presidente)) 
printlm(base_m, credibilidade_log ~ iiebr_lag_log | factor(presidente)) 
printlm(base_m, credibilidade_dif ~ iiebr_dif | factor(presidente))

printlm(base_d, credibilidade_scaled ~ dolarcompra_scaled | factor(presidente)) #*** OK
printlm(base_d, credibilidade_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, credibilidade_log ~ dolarcompra_log | factor(presidente)) #***
printlm(base_d, credibilidade_log ~ dolarcompra_lag_log | factor(presidente)) #***
printlm(base_d, credibilidade_dif ~ dolarcompra_dif | factor(presidente))

printlm(base_d, credibilidade_scaled ~ ibovespa_scaled | factor(presidente)) #*** OK
printlm(base_d, credibilidade_scaled ~ ibovespa_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, credibilidade_log ~ ibovespa_log | factor(presidente)) #* OK
printlm(base_d, credibilidade_log ~ ibovespa_lag_log | factor(presidente)) #* OK
printlm(base_d, credibilidade_dif ~ ibovespa_dif | factor(presidente))

printlm(base_d, credibilidade_scaled ~ embi_scaled | factor(presidente)) #*** OK
printlm(base_d, credibilidade_scaled ~ embi_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, credibilidade_log ~ embi_log | factor(presidente)) #*** OK
printlm(base_d, credibilidade_log ~ embi_lag_log | factor(presidente)) #***
printlm(base_d, credibilidade_dif ~ embi_dif | factor(presidente))

# focus -------------------------------------------------------------------

printlm(base_m, focus_scaled ~ pib_scaled | factor(presidente))
printlm(base_m, focus_scaled ~ pib_lag_scaled | factor(presidente))
printlm(base_m, focus_log ~ pib_log | factor(presidente)) #***  NOK
printlm(base_m, focus_log ~ pib_lag_log | factor(presidente)) #***  NOK
printlm(base_m, focus_dif ~ pib_dif | factor(presidente))

printlm(base_m, focus_scaled ~ dolarcompra_scaled | factor(presidente)) 
printlm(base_m, focus_scaled ~ dolarcompra_lag_scaled | factor(presidente)) 
printlm(base_m, focus_log ~ dolarcompra_log | factor(presidente)) 
printlm(base_m, focus_log ~ dolarcompra_lag_log | factor(presidente))
printlm(base_m, focus_dif ~ dolarcompra_dif | factor(presidente))

printlm(base_m, focus_scaled ~ ibovespa_scaled | factor(presidente))
printlm(base_m, focus_scaled ~ ibovespa_lag_scaled | factor(presidente))
printlm(base_m, focus_log ~ ibovespa_log | factor(presidente)) #* NOK
printlm(base_m, focus_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_m, focus_dif ~ ibovespa_dif | factor(presidente))

printlm(base_m, focus_scaled ~ embi_scaled | factor(presidente))
printlm(base_m, focus_scaled ~ embi_lag_scaled | factor(presidente))
printlm(base_m, focus_log ~ embi_log | factor(presidente))
printlm(base_m, focus_log ~ embi_lag_log | factor(presidente)) 
printlm(base_m, focus_dif ~ embi_dif | factor(presidente))

printlm(base_m, focus_scaled ~ igpm_scaled | factor(presidente)) 
printlm(base_m, focus_scaled ~ igpm_lag_scaled | factor(presidente))
printlm(base_m, focus_log ~ igpm_log | factor(presidente))
printlm(base_m, focus_log ~ igpm_lag_log | factor(presidente)) 
printlm(base_m, focus_dif ~ igpm_dif | factor(presidente))

printlm(base_m, focus_scaled ~ inpc_scaled | factor(presidente))
printlm(base_m, focus_scaled ~ inpc_lag_scaled | factor(presidente))
printlm(base_m, focus_log ~ inpc_log | factor(presidente))
printlm(base_m, focus_log ~ inpc_lag_log | factor(presidente)) 
printlm(base_m, focus_dif ~ inpc_dif | factor(presidente))

printlm(base_m, focus_scaled ~ ipca_scaled | factor(presidente))
printlm(base_m, focus_scaled ~ ipca_lag_scaled | factor(presidente)) 
printlm(base_m, focus_log ~ ipca_log | factor(presidente))
printlm(base_m, focus_log ~ ipca_lag_log | factor(presidente)) 
printlm(base_m, focus_dif ~ ipca_dif | factor(presidente))

printlm(base_m, focus_scaled ~ uncertainty_scaled | factor(presidente)) #**
printlm(base_m, focus_scaled ~ uncertainty_lag_scaled | factor(presidente)) #**
printlm(base_m, focus_log ~ uncertainty_log | factor(presidente)) #** NOK
printlm(base_m, focus_log ~ uncertainty_lag_log | factor(presidente)) 
printlm(base_m, focus_dif ~ uncertainty_dif | factor(presidente))

printlm(base_m, focus_scaled ~ iiebr_scaled | factor(presidente)) #*** OK
printlm(base_m, focus_scaled ~ iiebr_lag_scaled | factor(presidente)) #*** OK
printlm(base_m, focus_log ~ iiebr_log | factor(presidente)) #* OK
printlm(base_m, focus_log ~ iiebr_lag_log | factor(presidente)) #* OK
printlm(base_m, focus_dif ~ iiebr_dif | factor(presidente))


printlm(base_d, focus_scaled ~ dolarcompra_scaled | factor(presidente)) 
printlm(base_d, focus_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, focus_log ~ dolarcompra_log | factor(presidente)) 
printlm(base_d, focus_log ~ dolarcompra_lag_log | factor(presidente)) #***
printlm(base_d, focus_dif ~ dolarcompra_dif | factor(presidente))

printlm(base_d, focus_scaled ~ ibovespa_scaled | factor(presidente)) 
printlm(base_d, focus_scaled ~ ibovespa_lag_scaled | factor(presidente)) 
printlm(base_d, focus_log ~ ibovespa_log | factor(presidente)) 
printlm(base_d, focus_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_d, focus_dif ~ ibovespa_dif | factor(presidente))

printlm(base_d, focus_scaled ~ embi_scaled | factor(presidente)) 
printlm(base_d, focus_scaled ~ embi_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, focus_log ~ embi_log | factor(presidente)) 
printlm(base_d, focus_log ~ embi_lag_log | factor(presidente)) #**
printlm(base_d, focus_dif ~ embi_dif | factor(presidente))

# autonomia ---------------------------------------------------------------

printlm(base_m, autonomia_scaled ~ pib_scaled | factor(presidente))
printlm(base_m, autonomia_scaled ~ pib_lag_scaled | factor(presidente))
printlm(base_m, autonomia_log ~ pib_log | factor(presidente)) #*  NOK
printlm(base_m, autonomia_log ~ pib_lag_log | factor(presidente)) #**  NOK
printlm(base_m, autonomia_dif ~ pib_dif | factor(presidente)) #*** NOK

printlm(base_m, autonomia_scaled ~ dolarcompra_scaled | factor(presidente)) #*** OK
printlm(base_m, autonomia_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #*** OK
printlm(base_m, autonomia_log ~ dolarcompra_log | factor(presidente)) #*
printlm(base_m, autonomia_log ~ dolarcompra_lag_log | factor(presidente))
printlm(base_m, autonomia_dif ~ dolarcompra_dif | factor(presidente)) #**

printlm(base_m, autonomia_scaled ~ ibovespa_scaled | factor(presidente)) #**
printlm(base_m, autonomia_scaled ~ ibovespa_lag_scaled | factor(presidente)) #**
printlm(base_m, autonomia_log ~ ibovespa_log | factor(presidente))
printlm(base_m, autonomia_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_m, autonomia_dif ~ ibovespa_dif | factor(presidente))

printlm(base_m, autonomia_scaled ~ embi_scaled | factor(presidente)) #***
printlm(base_m, autonomia_scaled ~ embi_lag_scaled | factor(presidente)) #***
printlm(base_m, autonomia_log ~ embi_log | factor(presidente))
printlm(base_m, autonomia_log ~ embi_lag_log | factor(presidente)) 
printlm(base_m, autonomia_dif ~ embi_dif | factor(presidente))

printlm(base_m, autonomia_scaled ~ igpm_scaled | factor(presidente)) #*** OK
printlm(base_m, autonomia_scaled ~ igpm_lag_scaled | factor(presidente))
printlm(base_m, autonomia_log ~ igpm_log | factor(presidente)) #**
printlm(base_m, autonomia_log ~ igpm_lag_log | factor(presidente)) 
printlm(base_m, autonomia_dif ~ igpm_dif | factor(presidente))

printlm(base_m, autonomia_scaled ~ inpc_scaled | factor(presidente))
printlm(base_m, autonomia_scaled ~ inpc_lag_scaled | factor(presidente)) 
printlm(base_m, autonomia_log ~ inpc_log | factor(presidente))
printlm(base_m, autonomia_log ~ inpc_lag_log | factor(presidente)) 
printlm(base_m, autonomia_dif ~ inpc_dif | factor(presidente))

printlm(base_m, autonomia_scaled ~ ipca_scaled | factor(presidente))
printlm(base_m, autonomia_scaled ~ ipca_lag_scaled | factor(presidente)) #** NOK
printlm(base_m, autonomia_log ~ ipca_log | factor(presidente))
printlm(base_m, autonomia_log ~ ipca_lag_log | factor(presidente)) 
printlm(base_m, autonomia_dif ~ ipca_dif | factor(presidente))

printlm(base_m, autonomia_scaled ~ uncertainty_scaled | factor(presidente))
printlm(base_m, autonomia_scaled ~ uncertainty_lag_scaled | factor(presidente)) #*
printlm(base_m, autonomia_log ~ uncertainty_log | factor(presidente)) 
printlm(base_m, autonomia_log ~ uncertainty_lag_log | factor(presidente)) 
printlm(base_m, autonomia_dif ~ uncertainty_dif | factor(presidente))

printlm(base_m, autonomia_scaled ~ iiebr_scaled | factor(presidente)) #*** OK
printlm(base_m, autonomia_scaled ~ iiebr_lag_scaled | factor(presidente)) #*** OK
printlm(base_m, autonomia_log ~ iiebr_log | factor(presidente)) #*** OK
printlm(base_m, autonomia_log ~ iiebr_lag_log | factor(presidente)) #*** OK
printlm(base_m, autonomia_dif ~ iiebr_dif | factor(presidente))#**

printlm(base_d, autonomia_scaled ~ dolarcompra_scaled | factor(presidente)) #*** OK
printlm(base_d, autonomia_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, autonomia_log ~ dolarcompra_log | factor(presidente)) #***
printlm(base_d, autonomia_log ~ dolarcompra_lag_log | factor(presidente)) #***
printlm(base_d, autonomia_dif ~ dolarcompra_dif | factor(presidente))

printlm(base_d, autonomia_scaled ~ ibovespa_scaled | factor(presidente)) #*** OK
printlm(base_d, autonomia_scaled ~ ibovespa_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, autonomia_log ~ ibovespa_log | factor(presidente)) 
printlm(base_d, autonomia_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_d, autonomia_dif ~ ibovespa_dif | factor(presidente))

printlm(base_d, autonomia_scaled ~ embi_scaled | factor(presidente)) #*** OK
printlm(base_d, autonomia_scaled ~ embi_lag_scaled | factor(presidente)) #*** OK
printlm(base_d, autonomia_log ~ embi_log | factor(presidente)) #*** OK
printlm(base_d, autonomia_log ~ embi_lag_log | factor(presidente))#***
printlm(base_d, autonomia_dif ~ embi_dif | factor(presidente))

# prob_N ------------------------------------------------------------------

printlm(base_m, prob_N_scaled ~ pib_scaled | factor(presidente)) #*** NOK
printlm(base_m, prob_N_scaled ~ pib_lag_scaled | factor(presidente)) #*** NOK
printlm(base_m, prob_N_log ~ pib_log | factor(presidente)) #*** NOK
printlm(base_m, prob_N_log ~ pib_lag_log | factor(presidente)) # *** NOK
printlm(base_m, prob_N_dif ~ pib_dif | factor(presidente))

printlm(base_m, prob_N_scaled ~ dolarcompra_scaled | factor(presidente)) #*** OK
printlm(base_m, prob_N_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #*** OK
printlm(base_m, prob_N_log ~ dolarcompra_log | factor(presidente)) #*** OK
printlm(base_m, prob_N_log ~ dolarcompra_lag_log | factor(presidente)) #*** OK
printlm(base_m, prob_N_dif ~ dolarcompra_dif | factor(presidente))

printlm(base_m, prob_N_scaled ~ ibovespa_scaled | factor(presidente))
printlm(base_m, prob_N_scaled ~ ibovespa_lag_scaled | factor(presidente))
printlm(base_m, prob_N_log ~ ibovespa_log | factor(presidente))
printlm(base_m, prob_N_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_m, prob_N_dif ~ ibovespa_dif | factor(presidente))#** NOK

printlm(base_m, prob_N_scaled ~ embi_scaled | factor(presidente)) #** OK
printlm(base_m, prob_N_scaled ~ embi_lag_scaled | factor(presidente)) #** OK
printlm(base_m, prob_N_log ~ embi_log | factor(presidente)) #** OK
printlm(base_m, prob_N_log ~ embi_lag_log | factor(presidente)) #** OK
printlm(base_m, prob_N_dif ~ embi_dif | factor(presidente))

printlm(base_m, prob_N_scaled ~ igpm_scaled | factor(presidente))  #* OK
printlm(base_m, prob_N_scaled ~ igpm_lag_scaled | factor(presidente)) #** OK
printlm(base_m, prob_N_log ~ igpm_log | factor(presidente)) #* OK
printlm(base_m, prob_N_log ~ igpm_lag_log | factor(presidente)) #* OK
printlm(base_m, prob_N_dif ~ igpm_dif | factor(presidente))

printlm(base_m, prob_N_scaled ~ inpc_scaled | factor(presidente)) #*
printlm(base_m, prob_N_scaled ~ inpc_lag_scaled | factor(presidente)) #**
printlm(base_m, prob_N_log ~ inpc_log | factor(presidente))
printlm(base_m, prob_N_log ~ inpc_lag_log | factor(presidente)) #**
printlm(base_m, prob_N_dif ~ inpc_dif | factor(presidente))

printlm(base_m, prob_N_scaled ~ ipca_scaled | factor(presidente)) #*
printlm(base_m, prob_N_scaled ~ ipca_lag_scaled | factor(presidente)) #**
printlm(base_m, prob_N_log ~ ipca_log | factor(presidente)) #*
printlm(base_m, prob_N_log ~ ipca_lag_log | factor(presidente)) #*
printlm(base_m, prob_N_dif ~ ipca_dif | factor(presidente))

printlm(base_m, prob_N_scaled ~ uncertainty_scaled | factor(presidente))
printlm(base_m, prob_N_scaled ~ uncertainty_lag_scaled | factor(presidente))
printlm(base_m, prob_N_log ~ uncertainty_log | factor(presidente)) 
printlm(base_m, prob_N_log ~ uncertainty_lag_log | factor(presidente)) 
printlm(base_m, prob_N_dif ~ uncertainty_dif | factor(presidente))

printlm(base_m, prob_N_scaled ~ iiebr_scaled | factor(presidente)) 
printlm(base_m, prob_N_scaled ~ iiebr_lag_scaled | factor(presidente)) #*
printlm(base_m, prob_N_log ~ iiebr_log | factor(presidente)) 
printlm(base_m, prob_N_log ~ iiebr_lag_log | factor(presidente)) #*
printlm(base_m, prob_N_dif ~ iiebr_dif | factor(presidente))

printlm(base_d, prob_N_scaled ~ dolarcompra_scaled | factor(presidente)) #***
printlm(base_d, prob_N_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #***
printlm(base_d, prob_N_log ~ dolarcompra_log | factor(presidente)) #***
printlm(base_d, prob_N_log ~ dolarcompra_lag_log | factor(presidente)) #***
printlm(base_d, prob_N_dif ~ dolarcompra_dif | factor(presidente))

printlm(base_d, prob_N_scaled ~ ibovespa_scaled | factor(presidente)) 
printlm(base_d, prob_N_scaled ~ ibovespa_lag_scaled | factor(presidente)) #** NOK
printlm(base_d, prob_N_log ~ ibovespa_log | factor(presidente)) 
printlm(base_d, prob_N_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_d, prob_N_dif ~ ibovespa_dif | factor(presidente)) #*** OK

printlm(base_d, prob_N_scaled ~ embi_scaled | factor(presidente)) #***
printlm(base_d, prob_N_scaled ~ embi_lag_scaled | factor(presidente)) #***
printlm(base_d, prob_N_log ~ embi_log | factor(presidente)) #***
printlm(base_d, prob_N_log ~ embi_lag_log | factor(presidente)) #***
printlm(base_d, prob_N_dif ~ embi_dif | factor(presidente))#*

# prob_C ------------------------------------------------------------------

printlm(base_m, prob_C_scaled ~ pib_scaled | factor(presidente)) #*** NOK
printlm(base_m, prob_C_scaled ~ pib_lag_scaled | factor(presidente)) #*** NOK
printlm(base_m, prob_C_log ~ pib_log | factor(presidente)) #*** NOK
printlm(base_m, prob_C_log ~ pib_lag_log | factor(presidente)) # *** NOK
printlm(base_m, prob_C_dif ~ pib_dif | factor(presidente))

printlm(base_m, prob_C_scaled ~ dolarcompra_scaled | factor(presidente)) #*** OK
printlm(base_m, prob_C_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #***
printlm(base_m, prob_C_log ~ dolarcompra_log | factor(presidente)) #***
printlm(base_m, prob_C_log ~ dolarcompra_lag_log | factor(presidente)) #***
printlm(base_m, prob_C_dif ~ dolarcompra_dif | factor(presidente))

printlm(base_m, prob_C_scaled ~ ibovespa_scaled | factor(presidente))
printlm(base_m, prob_C_scaled ~ ibovespa_lag_scaled | factor(presidente))
printlm(base_m, prob_C_log ~ ibovespa_log | factor(presidente))
printlm(base_m, prob_C_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_m, prob_C_dif ~ ibovespa_dif | factor(presidente)) #** NOK

printlm(base_m, prob_C_scaled ~ embi_scaled | factor(presidente)) #**
printlm(base_m, prob_C_scaled ~ embi_lag_scaled | factor(presidente)) #**
printlm(base_m, prob_C_log ~ embi_log | factor(presidente)) #**
printlm(base_m, prob_C_log ~ embi_lag_log | factor(presidente)) #**
printlm(base_m, prob_C_dif ~ embi_dif | factor(presidente))

printlm(base_m, prob_C_scaled ~ igpm_scaled | factor(presidente)) #*
printlm(base_m, prob_C_scaled ~ igpm_lag_scaled | factor(presidente)) #**
printlm(base_m, prob_C_log ~ igpm_log | factor(presidente))
printlm(base_m, prob_C_log ~ igpm_lag_log | factor(presidente)) #*
printlm(base_m, prob_C_dif ~ igpm_dif | factor(presidente))

printlm(base_m, prob_C_scaled ~ inpc_scaled | factor(presidente)) #*
printlm(base_m, prob_C_scaled ~ inpc_lag_scaled | factor(presidente)) #**
printlm(base_m, prob_C_log ~ inpc_log | factor(presidente)) #*
printlm(base_m, prob_C_log ~ inpc_lag_log | factor(presidente)) #**
printlm(base_m, prob_C_dif ~ inpc_dif | factor(presidente))

printlm(base_m, prob_C_scaled ~ ipca_scaled | factor(presidente)) #*
printlm(base_m, prob_C_scaled ~ ipca_lag_scaled | factor(presidente)) #**
printlm(base_m, prob_C_log ~ ipca_log | factor(presidente)) #*
printlm(base_m, prob_C_log ~ ipca_lag_log | factor(presidente)) #*
printlm(base_m, prob_C_dif ~ ipca_dif | factor(presidente))

printlm(base_m, prob_C_scaled ~ uncertainty_scaled | factor(presidente))
printlm(base_m, prob_C_scaled ~ uncertainty_lag_scaled | factor(presidente))
printlm(base_m, prob_C_log ~ uncertainty_log | factor(presidente)) 
printlm(base_m, prob_C_log ~ uncertainty_lag_log | factor(presidente)) 
printlm(base_m, prob_C_dif ~ uncertainty_dif | factor(presidente))

printlm(base_m, prob_C_scaled ~ iiebr_scaled | factor(presidente)) 
printlm(base_m, prob_C_scaled ~ iiebr_lag_scaled | factor(presidente)) #*
printlm(base_m, prob_C_log ~ iiebr_log | factor(presidente)) 
printlm(base_m, prob_C_log ~ iiebr_lag_log | factor(presidente)) 
printlm(base_m, prob_C_dif ~ iiebr_dif | factor(presidente))

printlm(base_d, prob_C_scaled ~ dolarcompra_scaled | factor(presidente)) #***
printlm(base_d, prob_C_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #***
printlm(base_d, prob_C_log ~ dolarcompra_log | factor(presidente)) #***
printlm(base_d, prob_C_log ~ dolarcompra_lag_log | factor(presidente)) #***
printlm(base_d, prob_C_dif ~ dolarcompra_dif | factor(presidente))

printlm(base_d, prob_C_scaled ~ ibovespa_scaled | factor(presidente)) 
printlm(base_d, prob_C_scaled ~ ibovespa_lag_scaled | factor(presidente)) #** NOK
printlm(base_d, prob_C_log ~ ibovespa_log | factor(presidente)) 
printlm(base_d, prob_C_log ~ ibovespa_lag_log | factor(presidente)) #* NOK
printlm(base_d, prob_C_dif ~ ibovespa_dif | factor(presidente))#***

printlm(base_d, prob_C_scaled ~ embi_scaled | factor(presidente)) #***
printlm(base_d, prob_C_scaled ~ embi_lag_scaled | factor(presidente)) #***
printlm(base_d, prob_C_log ~ embi_log | factor(presidente)) #***
printlm(base_d, prob_C_log ~ embi_lag_log | factor(presidente)) #***
printlm(base_d, prob_C_dif ~ embi_dif | factor(presidente))#*


# qtd_C -------------------------------------------------------------------

printlm(base_m, qtd_C_scaled ~ pib_scaled | factor(presidente)) 
printlm(base_m, qtd_C_scaled ~ pib_lag_scaled | factor(presidente)) 
printlm(base_m, qtd_C_log ~ pib_log | factor(presidente)) #*** NOK
printlm(base_m, qtd_C_log ~ pib_lag_log | factor(presidente)) # *** NOK
printlm(base_m, qtd_C_dif ~ pib_dif | factor(presidente)) #*** NOK

printlm(base_m, qtd_C_scaled ~ dolarcompra_scaled | factor(presidente)) #*** OK
printlm(base_m, qtd_C_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #***
printlm(base_m, qtd_C_log ~ dolarcompra_log | factor(presidente)) #*
printlm(base_m, qtd_C_log ~ dolarcompra_lag_log | factor(presidente)) #*
printlm(base_m, qtd_C_dif ~ dolarcompra_dif | factor(presidente)) #***

printlm(base_m, qtd_C_scaled ~ ibovespa_scaled | factor(presidente)) #*
printlm(base_m, qtd_C_scaled ~ ibovespa_lag_scaled | factor(presidente)) #**
printlm(base_m, qtd_C_log ~ ibovespa_log | factor(presidente)) #* NOK
printlm(base_m, qtd_C_log ~ ibovespa_lag_log | factor(presidente)) #* NOK
printlm(base_m, qtd_C_dif ~ ibovespa_dif | factor(presidente))

printlm(base_m, qtd_C_scaled ~ embi_scaled | factor(presidente)) #***
printlm(base_m, qtd_C_scaled ~ embi_lag_scaled | factor(presidente)) #***
printlm(base_m, qtd_C_log ~ embi_log | factor(presidente)) 
printlm(base_m, qtd_C_log ~ embi_lag_log | factor(presidente)) 
printlm(base_m, qtd_C_dif ~ embi_dif | factor(presidente)) #**

printlm(base_m, qtd_C_scaled ~ igpm_scaled | factor(presidente)) #***
printlm(base_m, qtd_C_scaled ~ igpm_lag_scaled | factor(presidente)) #***
printlm(base_m, qtd_C_log ~ igpm_log | factor(presidente)) #**
printlm(base_m, qtd_C_log ~ igpm_lag_log | factor(presidente)) 
printlm(base_m, qtd_C_dif ~ igpm_dif | factor(presidente))

printlm(base_m, qtd_C_scaled ~ inpc_scaled | factor(presidente)) 
printlm(base_m, qtd_C_scaled ~ inpc_lag_scaled | factor(presidente)) 
printlm(base_m, qtd_C_log ~ inpc_log | factor(presidente)) 
printlm(base_m, qtd_C_log ~ inpc_lag_log | factor(presidente)) 
printlm(base_m, qtd_C_dif ~ inpc_dif | factor(presidente))

printlm(base_m, qtd_C_scaled ~ ipca_scaled | factor(presidente)) 
printlm(base_m, qtd_C_scaled ~ ipca_lag_scaled | factor(presidente)) #* NOK
printlm(base_m, qtd_C_log ~ ipca_log | factor(presidente)) 
printlm(base_m, qtd_C_log ~ ipca_lag_log | factor(presidente))
printlm(base_m, qtd_C_dif ~ ipca_dif | factor(presidente))#* NOK

printlm(base_m, qtd_C_scaled ~ uncertainty_scaled | factor(presidente))
printlm(base_m, qtd_C_scaled ~ uncertainty_lag_scaled | factor(presidente)) #**
printlm(base_m, qtd_C_log ~ uncertainty_log | factor(presidente)) #* NOK
printlm(base_m, qtd_C_log ~ uncertainty_lag_log | factor(presidente)) 
printlm(base_m, qtd_C_dif ~ uncertainty_dif | factor(presidente))

printlm(base_m, qtd_C_scaled ~ iiebr_scaled | factor(presidente)) #***
printlm(base_m, qtd_C_scaled ~ iiebr_lag_scaled | factor(presidente)) #***
printlm(base_m, qtd_C_log ~ iiebr_log | factor(presidente)) #**
printlm(base_m, qtd_C_log ~ iiebr_lag_log | factor(presidente)) #***
printlm(base_m, qtd_C_dif ~ iiebr_dif | factor(presidente))#*

printlm(base_d, qtd_C_scaled ~ dolarcompra_scaled | factor(presidente)) #***
printlm(base_d, qtd_C_scaled ~ dolarcompra_lag_scaled | factor(presidente)) #***
printlm(base_d, qtd_C_log ~ dolarcompra_log | factor(presidente)) #***
printlm(base_d, qtd_C_log ~ dolarcompra_lag_log | factor(presidente)) #***
printlm(base_d, qtd_C_dif ~ dolarcompra_dif | factor(presidente))

printlm(base_d, qtd_C_scaled ~ ibovespa_scaled | factor(presidente)) #***
printlm(base_d, qtd_C_scaled ~ ibovespa_lag_scaled | factor(presidente)) #***
printlm(base_d, qtd_C_log ~ ibovespa_log | factor(presidente)) 
printlm(base_d, qtd_C_log ~ ibovespa_lag_log | factor(presidente)) 
printlm(base_d, qtd_C_dif ~ ibovespa_dif | factor(presidente))

printlm(base_d, qtd_C_scaled ~ embi_scaled | factor(presidente)) #***
printlm(base_d, qtd_C_scaled ~ embi_lag_scaled | factor(presidente)) #***
printlm(base_d, qtd_C_log ~ embi_log | factor(presidente)) #***
printlm(base_d, qtd_C_log ~ embi_lag_log | factor(presidente)) #***
printlm(base_d, qtd_C_dif ~ embi_dif | factor(presidente))



# incerteza relativa ---------------------------------------------------------------

printlm(base_m, incerteza_rel_dif ~ pib_dif | factor(presidente))
printlm(base_m, incerteza_rel_dif ~ pib_lag_dif | factor(presidente))

printlm(base_m, incerteza_rel_dif ~ dolarcompra_dif | factor(presidente))#***
printlm(base_m, incerteza_rel_dif ~ dolarcompra_lag_dif | factor(presidente))

printlm(base_m, incerteza_rel_dif ~ ibovespa_dif | factor(presidente)) #*** mas beta muito pequeno
printlm(base_m, incerteza_rel_dif ~ ibovespa_lag_dif | factor(presidente))

printlm(base_m, incerteza_rel_dif ~ embi_dif | factor(presidente)) #**
printlm(base_m, incerteza_rel_dif ~ embi_lag_dif | factor(presidente))

printlm(base_m, incerteza_rel_dif ~ igpm_dif | factor(presidente)) #**
printlm(base_m, incerteza_rel_dif ~ igpm_lag_dif | factor(presidente))

printlm(base_m, incerteza_rel_dif ~ inpc_dif | factor(presidente))
printlm(base_m, incerteza_rel_dif ~ inpc_lag_dif | factor(presidente))

printlm(base_m, incerteza_rel_dif ~ ipca_dif | factor(presidente))
printlm(base_m, incerteza_rel_dif ~ ipca_lag_dif | factor(presidente))

printlm(base_m, incerteza_rel_dif ~ uncertainty_dif | factor(presidente)) #**
printlm(base_m, incerteza_rel_dif ~ uncertainty_lag_dif | factor(presidente))

printlm(base_m, incerteza_rel_dif ~ iiebr_dif | factor(presidente)) #**
printlm(base_m, incerteza_rel_dif ~ iiebr_lag_dif | factor(presidente))


printlm(base_d, incerteza_rel_dif ~ dolarcompra_dif | factor(presidente))
printlm(base_d, incerteza_rel_dif ~ dolarcompra_lag_dif | factor(presidente))#**

printlm(base_d, incerteza_rel_dif ~ ibovespa_dif | factor(presidente))
printlm(base_d, incerteza_rel_dif ~ ibovespa_lag_dif | factor(presidente))

printlm(base_d, incerteza_rel_dif ~ embi_dif | factor(presidente))
printlm(base_d, incerteza_rel_dif ~ embi_lag_dif | factor(presidente))


# incerteza ate 2019 ---------------------------------------------------------------

printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ pib_dif | factor(presidente))
printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ pib_lag_dif | factor(presidente))

printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ dolarcompra_dif | factor(presidente))#***
printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ dolarcompra_lag_dif | factor(presidente))

printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ ibovespa_dif | factor(presidente)) 
printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ ibovespa_lag_dif | factor(presidente))

printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ embi_dif | factor(presidente))
printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ embi_lag_dif | factor(presidente))

printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ igpm_dif | factor(presidente))
printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ igpm_lag_dif | factor(presidente))

printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ inpc_dif | factor(presidente))
printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ inpc_lag_dif | factor(presidente))#* NOK

printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ ipca_dif | factor(presidente))
printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ ipca_lag_dif | factor(presidente)) 

printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ uncertainty_dif | factor(presidente)) #*
printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ uncertainty_lag_dif | factor(presidente))

printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ iiebr_dif | factor(presidente))
printlm(base_m[base_m$DATA<"2020-01-01",], incerteza_dif ~ iiebr_lag_dif | factor(presidente))


printlm(base_d[base_d$DATA<"2020-01-01",], incerteza_dif ~ dolarcompra_dif | factor(presidente)) #**
printlm(base_d[base_d$DATA<"2020-01-01",], incerteza_dif ~ dolarcompra_lag_dif | factor(presidente))

printlm(base_d[base_d$DATA<"2020-01-01",], incerteza_dif ~ ibovespa_dif | factor(presidente))
printlm(base_d[base_d$DATA<"2020-01-01",], incerteza_dif ~ ibovespa_lag_dif | factor(presidente))

printlm(base_d[base_d$DATA<"2020-01-01",], incerteza_dif ~ embi_dif | factor(presidente))
printlm(base_d[base_d$DATA<"2020-01-01",], incerteza_dif ~ embi_lag_dif | factor(presidente))



# EFEITO FIXO ANO ---------------------------------------------------------



# total -------------------------------------------------------------------
# OK / NOK / ?


printlm(base_m, total_scaled ~ pib_scaled | factor(Ano))
printlm(base_m, total_scaled ~ pib_lag_scaled | factor(Ano)) #**
printlm(base_m, total_log ~ pib_log | factor(Ano)) #***  NOK
printlm(base_m, total_log ~ pib_lag_log | factor(Ano)) #***  NOK
printlm(base_m, total_dif ~ pib_dif | factor(Ano))

printlm(base_m, total_scaled ~ dolarcompra_scaled | factor(Ano)) #*** OK
printlm(base_m, total_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #*** OK
printlm(base_m, total_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_m, total_log ~ dolarcompra_lag_log | factor(Ano))
printlm(base_m, total_dif ~ dolarcompra_dif | factor(Ano)) #***

printlm(base_m, total_scaled ~ ibovespa_scaled | factor(Ano))
printlm(base_m, total_scaled ~ ibovespa_lag_scaled | factor(Ano)) #**
printlm(base_m, total_log ~ ibovespa_log | factor(Ano))
printlm(base_m, total_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_m, total_dif ~ ibovespa_dif | factor(Ano))

printlm(base_m, total_scaled ~ embi_scaled | factor(Ano)) #*
printlm(base_m, total_scaled ~ embi_lag_scaled | factor(Ano)) #**
printlm(base_m, total_log ~ embi_log | factor(Ano))
printlm(base_m, total_log ~ embi_lag_log | factor(Ano)) 
printlm(base_m, total_dif ~ embi_dif | factor(Ano))

printlm(base_m, total_scaled ~ igpm_scaled | factor(Ano)) #** OK
printlm(base_m, total_scaled ~ igpm_lag_scaled | factor(Ano))
printlm(base_m, total_log ~ igpm_log | factor(Ano))
printlm(base_m, total_log ~ igpm_lag_log | factor(Ano)) 
printlm(base_m, total_dif ~ igpm_dif | factor(Ano))

printlm(base_m, total_scaled ~ inpc_scaled | factor(Ano))
printlm(base_m, total_scaled ~ inpc_lag_scaled | factor(Ano)) #* NOK
printlm(base_m, total_log ~ inpc_log | factor(Ano))
printlm(base_m, total_log ~ inpc_lag_log | factor(Ano)) #** NOK
printlm(base_m, total_dif ~ inpc_dif | factor(Ano))

printlm(base_m, total_scaled ~ ipca_scaled | factor(Ano))
printlm(base_m, total_scaled ~ ipca_lag_scaled | factor(Ano)) #** NOK
printlm(base_m, total_log ~ ipca_log | factor(Ano))
printlm(base_m, total_log ~ ipca_lag_log | factor(Ano)) #* NOK
printlm(base_m, total_dif ~ ipca_dif | factor(Ano))

printlm(base_m, total_scaled ~ uncertainty_scaled | factor(Ano))
printlm(base_m, total_scaled ~ uncertainty_lag_scaled | factor(Ano))
printlm(base_m, total_log ~ uncertainty_log | factor(Ano)) 
printlm(base_m, total_log ~ uncertainty_lag_log | factor(Ano)) 
printlm(base_m, total_dif ~ uncertainty_dif | factor(Ano))

printlm(base_m, total_scaled ~ iiebr_scaled | factor(Ano)) #*** OK
printlm(base_m, total_scaled ~ iiebr_lag_scaled | factor(Ano)) #*** OK
printlm(base_m, total_log ~ iiebr_log | factor(Ano)) 
printlm(base_m, total_log ~ iiebr_lag_log | factor(Ano)) #* OK
printlm(base_m, total_dif ~ iiebr_dif | factor(Ano))


printlm(base_d, total_scaled ~ dolarcompra_scaled | factor(Ano)) #*** OK
printlm(base_d, total_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, total_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_d, total_log ~ dolarcompra_lag_log | factor(Ano))
printlm(base_d, total_dif ~ dolarcompra_dif | factor(Ano)) 

printlm(base_d, total_scaled ~ ibovespa_scaled | factor(Ano)) #* OK
printlm(base_d, total_scaled ~ ibovespa_lag_scaled | factor(Ano)) #* OK
printlm(base_d, total_log ~ ibovespa_log | factor(Ano)) 
printlm(base_d, total_log ~ ibovespa_lag_log | factor(Ano))
printlm(base_d, total_dif ~ ibovespa_dif | factor(Ano))

printlm(base_d, total_scaled ~ embi_scaled | factor(Ano)) #*** OK
printlm(base_d, total_scaled ~ embi_lag_scaled | factor(Ano)) #** OK
printlm(base_d, total_log ~ embi_log | factor(Ano)) 
printlm(base_d, total_log ~ embi_lag_log | factor(Ano))
printlm(base_d, total_dif ~ embi_dif | factor(Ano))


# copom -------------------------------------------------------------------

printlm(base_m, copom_scaled ~ pib_scaled | factor(Ano)) 
printlm(base_m, copom_scaled ~ pib_lag_scaled | factor(Ano)) 
printlm(base_m, copom_log ~ pib_log | factor(Ano)) #***  NOK
printlm(base_m, copom_log ~ pib_lag_log | factor(Ano)) 
printlm(base_m, copom_dif ~ pib_dif | factor(Ano))

printlm(base_m, copom_scaled ~ dolarcompra_scaled | factor(Ano)) 
printlm(base_m, copom_scaled ~ dolarcompra_lag_scaled | factor(Ano)) 
printlm(base_m, copom_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_m, copom_log ~ dolarcompra_lag_log | factor(Ano))
printlm(base_m, copom_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_m, copom_scaled ~ ibovespa_scaled | factor(Ano))
printlm(base_m, copom_scaled ~ ibovespa_lag_scaled | factor(Ano))
printlm(base_m, copom_log ~ ibovespa_log | factor(Ano))
printlm(base_m, copom_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_m, copom_dif ~ ibovespa_dif | factor(Ano))

printlm(base_m, copom_scaled ~ embi_scaled | factor(Ano)) 
printlm(base_m, copom_scaled ~ embi_lag_scaled | factor(Ano))
printlm(base_m, copom_log ~ embi_log | factor(Ano))
printlm(base_m, copom_log ~ embi_lag_log | factor(Ano)) 
printlm(base_m, copom_dif ~ embi_dif | factor(Ano))

printlm(base_m, copom_scaled ~ igpm_scaled | factor(Ano)) 
printlm(base_m, copom_scaled ~ igpm_lag_scaled | factor(Ano))
printlm(base_m, copom_log ~ igpm_log | factor(Ano))
printlm(base_m, copom_log ~ igpm_lag_log | factor(Ano)) 
printlm(base_m, copom_dif ~ igpm_dif | factor(Ano))

printlm(base_m, copom_scaled ~ inpc_scaled | factor(Ano))
printlm(base_m, copom_scaled ~ inpc_lag_scaled | factor(Ano)) #* NOK
printlm(base_m, copom_log ~ inpc_log | factor(Ano))
printlm(base_m, copom_log ~ inpc_lag_log | factor(Ano)) #*** NOK
printlm(base_m, copom_dif ~ inpc_dif | factor(Ano))#*

printlm(base_m, copom_scaled ~ ipca_scaled | factor(Ano))
printlm(base_m, copom_scaled ~ ipca_lag_scaled | factor(Ano))
printlm(base_m, copom_log ~ ipca_log | factor(Ano))
printlm(base_m, copom_log ~ ipca_lag_log | factor(Ano)) #*** NOK
printlm(base_m, copom_dif ~ ipca_dif | factor(Ano))

printlm(base_m, copom_scaled ~ uncertainty_scaled | factor(Ano))
printlm(base_m, copom_scaled ~ uncertainty_lag_scaled | factor(Ano))
printlm(base_m, copom_log ~ uncertainty_log | factor(Ano)) 
printlm(base_m, copom_log ~ uncertainty_lag_log | factor(Ano)) 
printlm(base_m, copom_dif ~ uncertainty_dif | factor(Ano))

printlm(base_m, copom_scaled ~ iiebr_scaled | factor(Ano)) 
printlm(base_m, copom_scaled ~ iiebr_lag_scaled | factor(Ano)) 
printlm(base_m, copom_log ~ iiebr_log | factor(Ano)) 
printlm(base_m, copom_log ~ iiebr_lag_log | factor(Ano)) 
printlm(base_m, copom_dif ~ iiebr_dif | factor(Ano))

printlm(base_d, copom_scaled ~ dolarcompra_scaled | factor(Ano))
printlm(base_d, copom_scaled ~ dolarcompra_lag_scaled | factor(Ano))
printlm(base_d, copom_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_d, copom_log ~ dolarcompra_lag_log | factor(Ano))
printlm(base_d, copom_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_d, copom_scaled ~ ibovespa_scaled | factor(Ano)) 
printlm(base_d, copom_scaled ~ ibovespa_lag_scaled | factor(Ano))
printlm(base_d, copom_log ~ ibovespa_log | factor(Ano)) 
printlm(base_d, copom_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_d, copom_dif ~ ibovespa_dif | factor(Ano))

printlm(base_d, copom_scaled ~ embi_scaled | factor(Ano))
printlm(base_d, copom_scaled ~ embi_lag_scaled | factor(Ano)) 
printlm(base_d, copom_log ~ embi_log | factor(Ano))
printlm(base_d, copom_log ~ embi_lag_log | factor(Ano))
printlm(base_d, copom_dif ~ embi_dif | factor(Ano))


# incerteza ---------------------------------------------------------------

printlm(base_m, incerteza_scaled ~ pib_scaled | factor(Ano))
printlm(base_m, incerteza_scaled ~ pib_lag_scaled | factor(Ano)) #**
printlm(base_m, incerteza_log ~ pib_log | factor(Ano)) 
printlm(base_m, incerteza_log ~ pib_lag_log | factor(Ano)) 
printlm(base_m, incerteza_dif ~ pib_dif | factor(Ano))

printlm(base_m, incerteza_scaled ~ dolarcompra_scaled | factor(Ano)) #***
printlm(base_m, incerteza_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #***
printlm(base_m, incerteza_log ~ dolarcompra_log | factor(Ano)) #***
printlm(base_m, incerteza_log ~ dolarcompra_lag_log | factor(Ano)) #*
printlm(base_m, incerteza_dif ~ dolarcompra_dif | factor(Ano)) #***

printlm(base_m, incerteza_scaled ~ ibovespa_scaled | factor(Ano)) #***
printlm(base_m, incerteza_scaled ~ ibovespa_lag_scaled | factor(Ano)) #***
printlm(base_m, incerteza_log ~ ibovespa_log | factor(Ano)) #***
printlm(base_m, incerteza_log ~ ibovespa_lag_log | factor(Ano)) #**
printlm(base_m, incerteza_dif ~ ibovespa_dif | factor(Ano))#***

printlm(base_m, incerteza_scaled ~ embi_scaled | factor(Ano)) #***
printlm(base_m, incerteza_scaled ~ embi_lag_scaled | factor(Ano)) #***
printlm(base_m, incerteza_log ~ embi_log | factor(Ano)) #***
printlm(base_m, incerteza_log ~ embi_lag_log | factor(Ano))
printlm(base_m, incerteza_dif ~ embi_dif | factor(Ano))#***

printlm(base_m, incerteza_scaled ~ igpm_scaled | factor(Ano)) 
printlm(base_m, incerteza_scaled ~ igpm_lag_scaled | factor(Ano))
printlm(base_m, incerteza_log ~ igpm_log | factor(Ano))
printlm(base_m, incerteza_log ~ igpm_lag_log | factor(Ano))
printlm(base_m, incerteza_dif ~ igpm_dif | factor(Ano))

printlm(base_m, incerteza_scaled ~ inpc_scaled | factor(Ano))
printlm(base_m, incerteza_scaled ~ inpc_lag_scaled | factor(Ano))
printlm(base_m, incerteza_log ~ inpc_log | factor(Ano))
printlm(base_m, incerteza_log ~ inpc_lag_log | factor(Ano)) 
printlm(base_m, incerteza_dif ~ inpc_dif | factor(Ano))

printlm(base_m, incerteza_scaled ~ ipca_scaled | factor(Ano))
printlm(base_m, incerteza_scaled ~ ipca_lag_scaled | factor(Ano))
printlm(base_m, incerteza_log ~ ipca_log | factor(Ano))
printlm(base_m, incerteza_log ~ ipca_lag_log | factor(Ano)) 
printlm(base_m, incerteza_dif ~ ipca_dif | factor(Ano))

printlm(base_m, incerteza_scaled ~ uncertainty_scaled | factor(Ano)) #**
printlm(base_m, incerteza_scaled ~ uncertainty_lag_scaled | factor(Ano)) #***
printlm(base_m, incerteza_log ~ uncertainty_log | factor(Ano)) #**
printlm(base_m, incerteza_log ~ uncertainty_lag_log | factor(Ano))
printlm(base_m, incerteza_dif ~ uncertainty_dif | factor(Ano))#**

printlm(base_m, incerteza_scaled ~ iiebr_scaled | factor(Ano)) #*** OK
printlm(base_m, incerteza_scaled ~ iiebr_lag_scaled | factor(Ano)) #*** OK
printlm(base_m, incerteza_log ~ iiebr_log | factor(Ano)) #*** OK
printlm(base_m, incerteza_log ~ iiebr_lag_log | factor(Ano)) #*** OK
printlm(base_m, incerteza_dif ~ iiebr_dif | factor(Ano))#**


printlm(base_d, incerteza_scaled ~ dolarcompra_scaled | factor(Ano)) #*** OK
printlm(base_d, incerteza_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, incerteza_log ~ dolarcompra_log | factor(Ano)) #***
printlm(base_d, incerteza_log ~ dolarcompra_lag_log | factor(Ano)) #***
printlm(base_d, incerteza_dif ~ dolarcompra_dif | factor(Ano)) #**

printlm(base_d, incerteza_scaled ~ ibovespa_scaled | factor(Ano)) #*** OK
printlm(base_d, incerteza_scaled ~ ibovespa_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, incerteza_log ~ ibovespa_log | factor(Ano)) #*** OK
printlm(base_d, incerteza_log ~ ibovespa_lag_log | factor(Ano)) #*** OK
printlm(base_d, incerteza_dif ~ ibovespa_dif | factor(Ano)) 

printlm(base_d, incerteza_scaled ~ embi_scaled | factor(Ano)) #*** OK
printlm(base_d, incerteza_scaled ~ embi_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, incerteza_log ~ embi_log | factor(Ano)) #*** OK
printlm(base_d, incerteza_log ~ embi_lag_log | factor(Ano)) #***
printlm(base_d, incerteza_dif ~ embi_dif | factor(Ano))

# credibilidade -----------------------------------------------------------

printlm(base_m, credibilidade_scaled ~ pib_scaled | factor(Ano))
printlm(base_m, credibilidade_scaled ~ pib_lag_scaled | factor(Ano))
printlm(base_m, credibilidade_log ~ pib_log | factor(Ano)) 
printlm(base_m, credibilidade_log ~ pib_lag_log | factor(Ano))
printlm(base_m, credibilidade_dif ~ pib_dif | factor(Ano))

printlm(base_m, credibilidade_scaled ~ dolarcompra_scaled | factor(Ano)) #** OK
printlm(base_m, credibilidade_scaled ~ dolarcompra_lag_scaled | factor(Ano))
printlm(base_m, credibilidade_log ~ dolarcompra_log | factor(Ano))
printlm(base_m, credibilidade_log ~ dolarcompra_lag_log | factor(Ano))
printlm(base_m, credibilidade_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_m, credibilidade_scaled ~ ibovespa_scaled | factor(Ano)) #** 
printlm(base_m, credibilidade_scaled ~ ibovespa_lag_scaled | factor(Ano))
printlm(base_m, credibilidade_log ~ ibovespa_log | factor(Ano))
printlm(base_m, credibilidade_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_m, credibilidade_dif ~ ibovespa_dif | factor(Ano))

printlm(base_m, credibilidade_scaled ~ embi_scaled | factor(Ano)) #**
printlm(base_m, credibilidade_scaled ~ embi_lag_scaled | factor(Ano))
printlm(base_m, credibilidade_log ~ embi_log | factor(Ano))
printlm(base_m, credibilidade_log ~ embi_lag_log | factor(Ano)) 
printlm(base_m, credibilidade_dif ~ embi_dif | factor(Ano))

printlm(base_m, credibilidade_scaled ~ igpm_scaled | factor(Ano))
printlm(base_m, credibilidade_scaled ~ igpm_lag_scaled | factor(Ano))
printlm(base_m, credibilidade_log ~ igpm_log | factor(Ano))
printlm(base_m, credibilidade_log ~ igpm_lag_log | factor(Ano)) 
printlm(base_m, credibilidade_dif ~ igpm_dif | factor(Ano))

printlm(base_m, credibilidade_scaled ~ inpc_scaled | factor(Ano)) #**
printlm(base_m, credibilidade_scaled ~ inpc_lag_scaled | factor(Ano))
printlm(base_m, credibilidade_log ~ inpc_log | factor(Ano))
printlm(base_m, credibilidade_log ~ inpc_lag_log | factor(Ano)) 
printlm(base_m, credibilidade_dif ~ inpc_dif | factor(Ano)) #***

printlm(base_m, credibilidade_scaled ~ ipca_scaled | factor(Ano)) #**
printlm(base_m, credibilidade_scaled ~ ipca_lag_scaled | factor(Ano)) 
printlm(base_m, credibilidade_log ~ ipca_log | factor(Ano))
printlm(base_m, credibilidade_log ~ ipca_lag_log | factor(Ano)) 
printlm(base_m, credibilidade_dif ~ ipca_dif | factor(Ano)) #**

printlm(base_m, credibilidade_scaled ~ uncertainty_scaled | factor(Ano))
printlm(base_m, credibilidade_scaled ~ uncertainty_lag_scaled | factor(Ano))
printlm(base_m, credibilidade_log ~ uncertainty_log | factor(Ano)) 
printlm(base_m, credibilidade_log ~ uncertainty_lag_log | factor(Ano)) 
printlm(base_m, credibilidade_dif ~ uncertainty_dif | factor(Ano))

printlm(base_m, credibilidade_scaled ~ iiebr_scaled | factor(Ano)) 
printlm(base_m, credibilidade_scaled ~ iiebr_lag_scaled | factor(Ano))
printlm(base_m, credibilidade_log ~ iiebr_log | factor(Ano)) 
printlm(base_m, credibilidade_log ~ iiebr_lag_log | factor(Ano)) 
printlm(base_m, credibilidade_dif ~ iiebr_dif | factor(Ano))

printlm(base_d, credibilidade_scaled ~ dolarcompra_scaled | factor(Ano)) #*** OK
printlm(base_d, credibilidade_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, credibilidade_log ~ dolarcompra_log | factor(Ano)) #***
printlm(base_d, credibilidade_log ~ dolarcompra_lag_log | factor(Ano)) #***
printlm(base_d, credibilidade_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_d, credibilidade_scaled ~ ibovespa_scaled | factor(Ano)) #*** OK
printlm(base_d, credibilidade_scaled ~ ibovespa_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, credibilidade_log ~ ibovespa_log | factor(Ano)) #** OK
printlm(base_d, credibilidade_log ~ ibovespa_lag_log | factor(Ano)) #*** OK
printlm(base_d, credibilidade_dif ~ ibovespa_dif | factor(Ano))

printlm(base_d, credibilidade_scaled ~ embi_scaled | factor(Ano)) #*** OK
printlm(base_d, credibilidade_scaled ~ embi_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, credibilidade_log ~ embi_log | factor(Ano)) #*** OK
printlm(base_d, credibilidade_log ~ embi_lag_log | factor(Ano)) #***
printlm(base_d, credibilidade_dif ~ embi_dif | factor(Ano))

# focus -------------------------------------------------------------------

printlm(base_m, focus_scaled ~ pib_scaled | factor(Ano))
printlm(base_m, focus_scaled ~ pib_lag_scaled | factor(Ano))
printlm(base_m, focus_log ~ pib_log | factor(Ano)) #***  NOK
printlm(base_m, focus_log ~ pib_lag_log | factor(Ano)) #***  NOK
printlm(base_m, focus_dif ~ pib_dif | factor(Ano))

printlm(base_m, focus_scaled ~ dolarcompra_scaled | factor(Ano)) 
printlm(base_m, focus_scaled ~ dolarcompra_lag_scaled | factor(Ano)) 
printlm(base_m, focus_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_m, focus_log ~ dolarcompra_lag_log | factor(Ano)) #* NOK
printlm(base_m, focus_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_m, focus_scaled ~ ibovespa_scaled | factor(Ano))
printlm(base_m, focus_scaled ~ ibovespa_lag_scaled | factor(Ano)) #*
printlm(base_m, focus_log ~ ibovespa_log | factor(Ano)) 
printlm(base_m, focus_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_m, focus_dif ~ ibovespa_dif | factor(Ano))

printlm(base_m, focus_scaled ~ embi_scaled | factor(Ano))
printlm(base_m, focus_scaled ~ embi_lag_scaled | factor(Ano)) #*
printlm(base_m, focus_log ~ embi_log | factor(Ano)) #* NOK
printlm(base_m, focus_log ~ embi_lag_log | factor(Ano)) 
printlm(base_m, focus_dif ~ embi_dif | factor(Ano))

printlm(base_m, focus_scaled ~ igpm_scaled | factor(Ano)) 
printlm(base_m, focus_scaled ~ igpm_lag_scaled | factor(Ano))
printlm(base_m, focus_log ~ igpm_log | factor(Ano))
printlm(base_m, focus_log ~ igpm_lag_log | factor(Ano)) 
printlm(base_m, focus_dif ~ igpm_dif | factor(Ano))

printlm(base_m, focus_scaled ~ inpc_scaled | factor(Ano))
printlm(base_m, focus_scaled ~ inpc_lag_scaled | factor(Ano))
printlm(base_m, focus_log ~ inpc_log | factor(Ano))
printlm(base_m, focus_log ~ inpc_lag_log | factor(Ano)) 
printlm(base_m, focus_dif ~ inpc_dif | factor(Ano))

printlm(base_m, focus_scaled ~ ipca_scaled | factor(Ano))
printlm(base_m, focus_scaled ~ ipca_lag_scaled | factor(Ano)) 
printlm(base_m, focus_log ~ ipca_log | factor(Ano))
printlm(base_m, focus_log ~ ipca_lag_log | factor(Ano)) 
printlm(base_m, focus_dif ~ ipca_dif | factor(Ano))

printlm(base_m, focus_scaled ~ uncertainty_scaled | factor(Ano))
printlm(base_m, focus_scaled ~ uncertainty_lag_scaled | factor(Ano)) 
printlm(base_m, focus_log ~ uncertainty_log | factor(Ano)) #* NOK
printlm(base_m, focus_log ~ uncertainty_lag_log | factor(Ano)) 
printlm(base_m, focus_dif ~ uncertainty_dif | factor(Ano))

printlm(base_m, focus_scaled ~ iiebr_scaled | factor(Ano)) #* OK
printlm(base_m, focus_scaled ~ iiebr_lag_scaled | factor(Ano)) #* OK
printlm(base_m, focus_log ~ iiebr_log | factor(Ano))
printlm(base_m, focus_log ~ iiebr_lag_log | factor(Ano))
printlm(base_m, focus_dif ~ iiebr_dif | factor(Ano))

printlm(base_d, focus_scaled ~ dolarcompra_scaled | factor(Ano)) 
printlm(base_d, focus_scaled ~ dolarcompra_lag_scaled | factor(Ano))
printlm(base_d, focus_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_d, focus_log ~ dolarcompra_lag_log | factor(Ano))
printlm(base_d, focus_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_d, focus_scaled ~ ibovespa_scaled | factor(Ano)) 
printlm(base_d, focus_scaled ~ ibovespa_lag_scaled | factor(Ano)) 
printlm(base_d, focus_log ~ ibovespa_log | factor(Ano)) 
printlm(base_d, focus_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_d, focus_dif ~ ibovespa_dif | factor(Ano))

printlm(base_d, focus_scaled ~ embi_scaled | factor(Ano)) 
printlm(base_d, focus_scaled ~ embi_lag_scaled | factor(Ano))
printlm(base_d, focus_log ~ embi_log | factor(Ano)) 
printlm(base_d, focus_log ~ embi_lag_log | factor(Ano))
printlm(base_d, focus_dif ~ embi_dif | factor(Ano))

# autonomia ---------------------------------------------------------------

printlm(base_m, autonomia_scaled ~ pib_scaled | factor(Ano))
printlm(base_m, autonomia_scaled ~ pib_lag_scaled | factor(Ano)) #**
printlm(base_m, autonomia_log ~ pib_log | factor(Ano)) 
printlm(base_m, autonomia_log ~ pib_lag_log | factor(Ano)) 
printlm(base_m, autonomia_dif ~ pib_dif | factor(Ano)) # ** NOK

printlm(base_m, autonomia_scaled ~ dolarcompra_scaled | factor(Ano)) #*** OK
printlm(base_m, autonomia_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #*** OK
printlm(base_m, autonomia_log ~ dolarcompra_log | factor(Ano))
printlm(base_m, autonomia_log ~ dolarcompra_lag_log | factor(Ano))
printlm(base_m, autonomia_dif ~ dolarcompra_dif | factor(Ano)) #*

printlm(base_m, autonomia_scaled ~ ibovespa_scaled | factor(Ano)) #**
printlm(base_m, autonomia_scaled ~ ibovespa_lag_scaled | factor(Ano)) #***
printlm(base_m, autonomia_log ~ ibovespa_log | factor(Ano))
printlm(base_m, autonomia_log ~ ibovespa_lag_log | factor(Ano))
printlm(base_m, autonomia_dif ~ ibovespa_dif | factor(Ano))

printlm(base_m, autonomia_scaled ~ embi_scaled | factor(Ano)) #**
printlm(base_m, autonomia_scaled ~ embi_lag_scaled | factor(Ano)) #***
printlm(base_m, autonomia_log ~ embi_log | factor(Ano))
printlm(base_m, autonomia_log ~ embi_lag_log | factor(Ano)) 
printlm(base_m, autonomia_dif ~ embi_dif | factor(Ano))

printlm(base_m, autonomia_scaled ~ igpm_scaled | factor(Ano)) #* OK
printlm(base_m, autonomia_scaled ~ igpm_lag_scaled | factor(Ano))
printlm(base_m, autonomia_log ~ igpm_log | factor(Ano))
printlm(base_m, autonomia_log ~ igpm_lag_log | factor(Ano)) 
printlm(base_m, autonomia_dif ~ igpm_dif | factor(Ano))

printlm(base_m, autonomia_scaled ~ inpc_scaled | factor(Ano))
printlm(base_m, autonomia_scaled ~ inpc_lag_scaled | factor(Ano)) 
printlm(base_m, autonomia_log ~ inpc_log | factor(Ano))
printlm(base_m, autonomia_log ~ inpc_lag_log | factor(Ano)) 
printlm(base_m, autonomia_dif ~ inpc_dif | factor(Ano))

printlm(base_m, autonomia_scaled ~ ipca_scaled | factor(Ano))
printlm(base_m, autonomia_scaled ~ ipca_lag_scaled | factor(Ano)) #** NOK
printlm(base_m, autonomia_log ~ ipca_log | factor(Ano))
printlm(base_m, autonomia_log ~ ipca_lag_log | factor(Ano)) 
printlm(base_m, autonomia_dif ~ ipca_dif | factor(Ano))

printlm(base_m, autonomia_scaled ~ uncertainty_scaled | factor(Ano))
printlm(base_m, autonomia_scaled ~ uncertainty_lag_scaled | factor(Ano)) #*
printlm(base_m, autonomia_log ~ uncertainty_log | factor(Ano)) 
printlm(base_m, autonomia_log ~ uncertainty_lag_log | factor(Ano)) 
printlm(base_m, autonomia_dif ~ uncertainty_dif | factor(Ano))

printlm(base_m, autonomia_scaled ~ iiebr_scaled | factor(Ano)) #*** OK
printlm(base_m, autonomia_scaled ~ iiebr_lag_scaled | factor(Ano)) #*** OK
printlm(base_m, autonomia_log ~ iiebr_log | factor(Ano)) #* OK
printlm(base_m, autonomia_log ~ iiebr_lag_log | factor(Ano)) #** OK
printlm(base_m, autonomia_dif ~ iiebr_dif | factor(Ano)) #*

printlm(base_d, autonomia_scaled ~ dolarcompra_scaled | factor(Ano)) #*** OK
printlm(base_d, autonomia_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, autonomia_log ~ dolarcompra_log | factor(Ano)) #***
printlm(base_d, autonomia_log ~ dolarcompra_lag_log | factor(Ano)) #***
printlm(base_d, autonomia_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_d, autonomia_scaled ~ ibovespa_scaled | factor(Ano)) #** OK
printlm(base_d, autonomia_scaled ~ ibovespa_lag_scaled | factor(Ano)) #** OK
printlm(base_d, autonomia_log ~ ibovespa_log | factor(Ano)) 
printlm(base_d, autonomia_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_m, autonomia_dif ~ ibovespa_dif | factor(Ano))

printlm(base_d, autonomia_scaled ~ embi_scaled | factor(Ano)) #*** OK
printlm(base_d, autonomia_scaled ~ embi_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, autonomia_log ~ embi_log | factor(Ano)) #*** OK
printlm(base_d, autonomia_log ~ embi_lag_log | factor(Ano))#***
printlm(base_m, autonomia_dif ~ embi_dif | factor(Ano))

# prob_N ------------------------------------------------------------------

printlm(base_m, prob_N_scaled ~ pib_scaled | factor(Ano)) 
printlm(base_m, prob_N_scaled ~ pib_lag_scaled | factor(Ano)) 
printlm(base_m, prob_N_log ~ pib_log | factor(Ano)) 
printlm(base_m, prob_N_log ~ pib_lag_log | factor(Ano)) 
printlm(base_m, prob_N_dif ~ pib_dif | factor(Ano))

printlm(base_m, prob_N_scaled ~ dolarcompra_scaled | factor(Ano)) 
printlm(base_m, prob_N_scaled ~ dolarcompra_lag_scaled | factor(Ano)) 
printlm(base_m, prob_N_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_m, prob_N_log ~ dolarcompra_lag_log | factor(Ano)) 
printlm(base_m, prob_N_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_m, prob_N_scaled ~ ibovespa_scaled | factor(Ano)) #** NOK
printlm(base_m, prob_N_scaled ~ ibovespa_lag_scaled | factor(Ano))
printlm(base_m, prob_N_log ~ ibovespa_log | factor(Ano)) #** NOK
printlm(base_m, prob_N_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_m, prob_N_dif ~ ibovespa_dif | factor(Ano)) #**NOK

printlm(base_m, prob_N_scaled ~ embi_scaled | factor(Ano)) 
printlm(base_m, prob_N_scaled ~ embi_lag_scaled | factor(Ano)) 
printlm(base_m, prob_N_log ~ embi_log | factor(Ano)) 
printlm(base_m, prob_N_log ~ embi_lag_log | factor(Ano))
printlm(base_m, prob_N_dif ~ embi_dif | factor(Ano))

printlm(base_m, prob_N_scaled ~ igpm_scaled | factor(Ano))  
printlm(base_m, prob_N_scaled ~ igpm_lag_scaled | factor(Ano)) 
printlm(base_m, prob_N_log ~ igpm_log | factor(Ano)) 
printlm(base_m, prob_N_log ~ igpm_lag_log | factor(Ano))
printlm(base_m, prob_N_dif ~ igpm_dif | factor(Ano))

printlm(base_m, prob_N_scaled ~ inpc_scaled | factor(Ano))
printlm(base_m, prob_N_scaled ~ inpc_lag_scaled | factor(Ano))
printlm(base_m, prob_N_log ~ inpc_log | factor(Ano))
printlm(base_m, prob_N_log ~ inpc_lag_log | factor(Ano))
printlm(base_m, prob_N_dif ~ inpc_dif | factor(Ano))

printlm(base_m, prob_N_scaled ~ ipca_scaled | factor(Ano)) 
printlm(base_m, prob_N_scaled ~ ipca_lag_scaled | factor(Ano)) 
printlm(base_m, prob_N_log ~ ipca_log | factor(Ano)) 
printlm(base_m, prob_N_log ~ ipca_lag_log | factor(Ano)) 
printlm(base_m, prob_N_dif ~ ipca_dif | factor(Ano))

printlm(base_m, prob_N_scaled ~ uncertainty_scaled | factor(Ano))
printlm(base_m, prob_N_scaled ~ uncertainty_lag_scaled | factor(Ano))
printlm(base_m, prob_N_log ~ uncertainty_log | factor(Ano)) 
printlm(base_m, prob_N_log ~ uncertainty_lag_log | factor(Ano)) 
printlm(base_m, prob_N_dif ~ uncertainty_dif | factor(Ano))

printlm(base_m, prob_N_scaled ~ iiebr_scaled | factor(Ano)) 
printlm(base_m, prob_N_scaled ~ iiebr_lag_scaled | factor(Ano)) #*
printlm(base_m, prob_N_log ~ iiebr_log | factor(Ano)) 
printlm(base_m, prob_N_log ~ iiebr_lag_log | factor(Ano)) #*
printlm(base_m, prob_N_dif ~ iiebr_dif | factor(Ano))

printlm(base_d, prob_N_scaled ~ dolarcompra_scaled | factor(Ano)) #**
printlm(base_d, prob_N_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #**
printlm(base_d, prob_N_log ~ dolarcompra_log | factor(Ano)) #*
printlm(base_d, prob_N_log ~ dolarcompra_lag_log | factor(Ano))
printlm(base_d, prob_N_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_d, prob_N_scaled ~ ibovespa_scaled | factor(Ano)) #*** NOK
printlm(base_d, prob_N_scaled ~ ibovespa_lag_scaled | factor(Ano)) #*** NOK
printlm(base_d, prob_N_log ~ ibovespa_log | factor(Ano)) #*** NOK
printlm(base_d, prob_N_log ~ ibovespa_lag_log | factor(Ano)) #*** NOK
printlm(base_d, prob_N_dif ~ ibovespa_dif | factor(Ano))#*** 

printlm(base_d, prob_N_scaled ~ embi_scaled | factor(Ano)) 
printlm(base_d, prob_N_scaled ~ embi_lag_scaled | factor(Ano)) 
printlm(base_d, prob_N_log ~ embi_log | factor(Ano)) 
printlm(base_d, prob_N_log ~ embi_lag_log | factor(Ano)) 
printlm(base_d, prob_N_dif ~ embi_dif | factor(Ano)) #*

# prob_C ------------------------------------------------------------------

printlm(base_m, prob_C_scaled ~ pib_scaled | factor(Ano)) 
printlm(base_m, prob_C_scaled ~ pib_lag_scaled | factor(Ano)) 
printlm(base_m, prob_C_log ~ pib_log | factor(Ano)) 
printlm(base_m, prob_C_log ~ pib_lag_log | factor(Ano)) 
printlm(base_m, prob_C_dif ~ pib_dif | factor(Ano))

printlm(base_m, prob_C_scaled ~ dolarcompra_scaled | factor(Ano)) 
printlm(base_m, prob_C_scaled ~ dolarcompra_lag_scaled | factor(Ano))
printlm(base_m, prob_C_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_m, prob_C_log ~ dolarcompra_lag_log | factor(Ano)) 
printlm(base_m, prob_C_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_m, prob_C_scaled ~ ibovespa_scaled | factor(Ano)) #** NOK
printlm(base_m, prob_C_scaled ~ ibovespa_lag_scaled | factor(Ano))
printlm(base_m, prob_C_log ~ ibovespa_log | factor(Ano)) #** NOK
printlm(base_m, prob_C_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_m, prob_C_dif ~ ibovespa_dif | factor(Ano)) #** NOK

printlm(base_m, prob_C_scaled ~ embi_scaled | factor(Ano)) 
printlm(base_m, prob_C_scaled ~ embi_lag_scaled | factor(Ano)) 
printlm(base_m, prob_C_log ~ embi_log | factor(Ano)) 
printlm(base_m, prob_C_log ~ embi_lag_log | factor(Ano)) 
printlm(base_m, prob_C_dif ~ embi_dif | factor(Ano))

printlm(base_m, prob_C_scaled ~ igpm_scaled | factor(Ano)) 
printlm(base_m, prob_C_scaled ~ igpm_lag_scaled | factor(Ano)) 
printlm(base_m, prob_C_log ~ igpm_log | factor(Ano))
printlm(base_m, prob_C_log ~ igpm_lag_log | factor(Ano)) 
printlm(base_m, prob_C_dif ~ igpm_dif | factor(Ano))

printlm(base_m, prob_C_scaled ~ inpc_scaled | factor(Ano)) 
printlm(base_m, prob_C_scaled ~ inpc_lag_scaled | factor(Ano)) 
printlm(base_m, prob_C_log ~ inpc_log | factor(Ano)) 
printlm(base_m, prob_C_log ~ inpc_lag_log | factor(Ano))
printlm(base_m, prob_C_dif ~ inpc_dif | factor(Ano))

printlm(base_m, prob_C_scaled ~ ipca_scaled | factor(Ano)) 
printlm(base_m, prob_C_scaled ~ ipca_lag_scaled | factor(Ano)) 
printlm(base_m, prob_C_log ~ ipca_log | factor(Ano)) 
printlm(base_m, prob_C_log ~ ipca_lag_log | factor(Ano)) 
printlm(base_m, prob_C_dif ~ ipca_dif | factor(Ano))

printlm(base_m, prob_C_scaled ~ uncertainty_scaled | factor(Ano))
printlm(base_m, prob_C_scaled ~ uncertainty_lag_scaled | factor(Ano))
printlm(base_m, prob_C_log ~ uncertainty_log | factor(Ano)) 
printlm(base_m, prob_C_log ~ uncertainty_lag_log | factor(Ano)) 
printlm(base_m, prob_C_dif ~ uncertainty_dif | factor(Ano))

printlm(base_m, prob_C_scaled ~ iiebr_scaled | factor(Ano)) 
printlm(base_m, prob_C_scaled ~ iiebr_lag_scaled | factor(Ano)) 
printlm(base_m, prob_C_log ~ iiebr_log | factor(Ano)) 
printlm(base_m, prob_C_log ~ iiebr_lag_log | factor(Ano)) 
printlm(base_m, prob_C_dif ~ iiebr_dif | factor(Ano))

printlm(base_d, prob_C_scaled ~ dolarcompra_scaled | factor(Ano)) #**
printlm(base_d, prob_C_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #**
printlm(base_d, prob_C_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_d, prob_C_log ~ dolarcompra_lag_log | factor(Ano)) 
printlm(base_d, prob_C_dif ~ dolarcompra_dif | factor(Ano))

printlm(base_d, prob_C_scaled ~ ibovespa_scaled | factor(Ano)) #*** NOK
printlm(base_d, prob_C_scaled ~ ibovespa_lag_scaled | factor(Ano)) #*** NOK
printlm(base_d, prob_C_log ~ ibovespa_log | factor(Ano)) #*** NOK
printlm(base_d, prob_C_log ~ ibovespa_lag_log | factor(Ano)) #*** NOK
printlm(base_d, prob_C_dif ~ ibovespa_dif | factor(Ano)) #*** OK

printlm(base_d, prob_C_scaled ~ embi_scaled | factor(Ano)) 
printlm(base_d, prob_C_scaled ~ embi_lag_scaled | factor(Ano)) 
printlm(base_d, prob_C_log ~ embi_log | factor(Ano)) 
printlm(base_d, prob_C_log ~ embi_lag_log | factor(Ano)) 
printlm(base_d, prob_C_dif ~ embi_dif | factor(Ano)) #*


# qtd_C -------------------------------------------------------------------

printlm(base_m, qtd_C_scaled ~ pib_scaled | factor(Ano)) 
printlm(base_m, qtd_C_scaled ~ pib_lag_scaled | factor(Ano)) 
printlm(base_m, qtd_C_log ~ pib_log | factor(Ano)) #*** NOK
printlm(base_m, qtd_C_log ~ pib_lag_log | factor(Ano)) # * NOK
printlm(base_m, qtd_C_dif ~ pib_dif | factor(Ano)) #** nOK

printlm(base_m, qtd_C_scaled ~ dolarcompra_scaled | factor(Ano)) #*** OK
printlm(base_m, qtd_C_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #***
printlm(base_m, qtd_C_log ~ dolarcompra_log | factor(Ano)) 
printlm(base_m, qtd_C_log ~ dolarcompra_lag_log | factor(Ano)) 
printlm(base_m, qtd_C_dif ~ dolarcompra_dif | factor(Ano)) #***

printlm(base_m, qtd_C_scaled ~ ibovespa_scaled | factor(Ano)) 
printlm(base_m, qtd_C_scaled ~ ibovespa_lag_scaled | factor(Ano)) #*** 
printlm(base_m, qtd_C_log ~ ibovespa_log | factor(Ano)) 
printlm(base_m, qtd_C_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_m, qtd_C_dif ~ ibovespa_dif | factor(Ano))

printlm(base_m, qtd_C_scaled ~ embi_scaled | factor(Ano)) #***
printlm(base_m, qtd_C_scaled ~ embi_lag_scaled | factor(Ano)) #***
printlm(base_m, qtd_C_log ~ embi_log | factor(Ano)) 
printlm(base_m, qtd_C_log ~ embi_lag_log | factor(Ano)) 
printlm(base_m, qtd_C_dif ~ embi_dif | factor(Ano)) #**

printlm(base_m, qtd_C_scaled ~ igpm_scaled | factor(Ano)) #***
printlm(base_m, qtd_C_scaled ~ igpm_lag_scaled | factor(Ano))
printlm(base_m, qtd_C_log ~ igpm_log | factor(Ano)) #*
printlm(base_m, qtd_C_log ~ igpm_lag_log | factor(Ano)) #*
printlm(base_m, qtd_C_dif ~ igpm_dif | factor(Ano))

printlm(base_m, qtd_C_scaled ~ inpc_scaled | factor(Ano)) 
printlm(base_m, qtd_C_scaled ~ inpc_lag_scaled | factor(Ano)) #* NOK
printlm(base_m, qtd_C_log ~ inpc_log | factor(Ano)) 
printlm(base_m, qtd_C_log ~ inpc_lag_log | factor(Ano)) 
printlm(base_m, qtd_C_dif ~ inpc_dif | factor(Ano))

printlm(base_m, qtd_C_scaled ~ ipca_scaled | factor(Ano)) 
printlm(base_m, qtd_C_scaled ~ ipca_lag_scaled | factor(Ano)) #** NOK
printlm(base_m, qtd_C_log ~ ipca_log | factor(Ano)) 
printlm(base_m, qtd_C_log ~ ipca_lag_log | factor(Ano))
printlm(base_m, qtd_C_dif ~ ipca_dif | factor(Ano))

printlm(base_m, qtd_C_scaled ~ uncertainty_scaled | factor(Ano))
printlm(base_m, qtd_C_scaled ~ uncertainty_lag_scaled | factor(Ano))
printlm(base_m, qtd_C_log ~ uncertainty_log | factor(Ano)) #* NOK
printlm(base_m, qtd_C_log ~ uncertainty_lag_log | factor(Ano)) 
printlm(base_m, qtd_C_dif ~ uncertainty_dif | factor(Ano))

printlm(base_m, qtd_C_scaled ~ iiebr_scaled | factor(Ano)) #***
printlm(base_m, qtd_C_scaled ~ iiebr_lag_scaled | factor(Ano)) #***
printlm(base_m, qtd_C_log ~ iiebr_log | factor(Ano)) 
printlm(base_m, qtd_C_log ~ iiebr_lag_log | factor(Ano)) #**
printlm(base_m, qtd_C_dif ~ iiebr_dif | factor(Ano)) #*

printlm(base_d, qtd_C_scaled ~ dolarcompra_scaled | factor(Ano)) #***
printlm(base_d, qtd_C_scaled ~ dolarcompra_lag_scaled | factor(Ano)) #***
printlm(base_d, qtd_C_log ~ dolarcompra_log | factor(Ano)) #***
printlm(base_d, qtd_C_log ~ dolarcompra_lag_log | factor(Ano)) #***
printlm(base_d, qtd_C_dif ~ dolarcompra_dif | factor(Ano)) 

printlm(base_d, qtd_C_scaled ~ ibovespa_scaled | factor(Ano)) 
printlm(base_d, qtd_C_scaled ~ ibovespa_lag_scaled | factor(Ano)) #* 
printlm(base_d, qtd_C_log ~ ibovespa_log | factor(Ano)) 
printlm(base_d, qtd_C_log ~ ibovespa_lag_log | factor(Ano)) 
printlm(base_d, qtd_C_dif ~ ibovespa_dif | factor(Ano))

printlm(base_d, qtd_C_scaled ~ embi_scaled | factor(Ano)) #***
printlm(base_d, qtd_C_scaled ~ embi_lag_scaled | factor(Ano)) #***
printlm(base_d, qtd_C_log ~ embi_log | factor(Ano)) #*
printlm(base_d, qtd_C_log ~ embi_lag_log | factor(Ano)) #*
printlm(base_d, qtd_C_dif ~ embi_dif | factor(Ano)) #**


# EFEITO FIXO ANO E PRESIDENTE --------------------------------------------



# total -------------------------------------------------------------------
# OK / NOK / ?


printlm(base_m, total_scaled ~ pib_scaled | factor(Ano):factor(presidente))
printlm(base_m, total_scaled ~ pib_lag_scaled | factor(Ano):factor(presidente)) #*
printlm(base_m, total_log ~ pib_log | factor(Ano):factor(presidente)) #***  NOK
printlm(base_m, total_log ~ pib_lag_log | factor(Ano):factor(presidente)) #***  NOK
printlm(base_m, total_dif ~ pib_dif | factor(Ano):factor(presidente))

printlm(base_m, total_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, total_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, total_log ~ dolarcompra_log | factor(Ano):factor(presidente)) 
printlm(base_m, total_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente))
printlm(base_m, total_dif ~ dolarcompra_dif | factor(Ano):factor(presidente)) #***

printlm(base_m, total_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente))
printlm(base_m, total_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #*
printlm(base_m, total_log ~ ibovespa_log | factor(Ano):factor(presidente))
printlm(base_m, total_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, total_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_m, total_scaled ~ embi_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, total_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) #*
printlm(base_m, total_log ~ embi_log | factor(Ano):factor(presidente))
printlm(base_m, total_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, total_dif ~ embi_dif | factor(Ano):factor(presidente))

printlm(base_m, total_scaled ~ igpm_scaled | factor(Ano):factor(presidente)) #* OK
printlm(base_m, total_scaled ~ igpm_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, total_log ~ igpm_log | factor(Ano):factor(presidente))
printlm(base_m, total_log ~ igpm_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, total_dif ~ igpm_dif | factor(Ano):factor(presidente))

printlm(base_m, total_scaled ~ inpc_scaled | factor(Ano):factor(presidente))
printlm(base_m, total_scaled ~ inpc_lag_scaled | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, total_log ~ inpc_log | factor(Ano):factor(presidente))
printlm(base_m, total_log ~ inpc_lag_log | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, total_dif ~ inpc_dif | factor(Ano):factor(presidente))

printlm(base_m, total_scaled ~ ipca_scaled | factor(Ano):factor(presidente))
printlm(base_m, total_scaled ~ ipca_lag_scaled | factor(Ano):factor(presidente)) #*** NOK
printlm(base_m, total_log ~ ipca_log | factor(Ano):factor(presidente))
printlm(base_m, total_log ~ ipca_lag_log | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, total_dif ~ ipca_dif | factor(Ano):factor(presidente))

printlm(base_m, total_scaled ~ uncertainty_scaled | factor(Ano):factor(presidente))
printlm(base_m, total_scaled ~ uncertainty_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, total_log ~ uncertainty_log | factor(Ano):factor(presidente)) 
printlm(base_m, total_log ~ uncertainty_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, total_dif ~ uncertainty_dif | factor(Ano):factor(presidente)) #*

printlm(base_m, total_scaled ~ iiebr_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, total_scaled ~ iiebr_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, total_log ~ iiebr_log | factor(Ano):factor(presidente)) 
printlm(base_m, total_log ~ iiebr_lag_log | factor(Ano):factor(presidente))
printlm(base_m, total_dif ~ iiebr_dif | factor(Ano):factor(presidente))

printlm(base_d, total_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, total_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, total_log ~ dolarcompra_log | factor(Ano):factor(presidente)) 
printlm(base_d, total_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente))
printlm(base_d, total_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_d, total_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente))
printlm(base_d, total_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente))
printlm(base_d, total_log ~ ibovespa_log | factor(Ano):factor(presidente)) 
printlm(base_d, total_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_d, total_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_d, total_scaled ~ embi_scaled | factor(Ano):factor(presidente)) #** OK
printlm(base_d, total_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) #** OK
printlm(base_d, total_log ~ embi_log | factor(Ano):factor(presidente)) 
printlm(base_d, total_log ~ embi_lag_log | factor(Ano):factor(presidente))
printlm(base_d, total_dif ~ embi_dif | factor(Ano):factor(presidente))

# copom -------------------------------------------------------------------

printlm(base_m, copom_scaled ~ pib_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, copom_scaled ~ pib_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, copom_log ~ pib_log | factor(Ano):factor(presidente)) #***  NOK
printlm(base_m, copom_log ~ pib_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, copom_dif ~ pib_dif | factor(Ano):factor(presidente))

printlm(base_m, copom_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, copom_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, copom_log ~ dolarcompra_log | factor(Ano):factor(presidente)) 
printlm(base_m, copom_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente))
printlm(base_m, copom_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_m, copom_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente))
printlm(base_m, copom_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, copom_log ~ ibovespa_log | factor(Ano):factor(presidente))
printlm(base_m, copom_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, copom_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_m, copom_scaled ~ embi_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, copom_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, copom_log ~ embi_log | factor(Ano):factor(presidente))
printlm(base_m, copom_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, copom_dif ~ embi_dif | factor(Ano):factor(presidente))

printlm(base_m, copom_scaled ~ igpm_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, copom_scaled ~ igpm_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, copom_log ~ igpm_log | factor(Ano):factor(presidente))
printlm(base_m, copom_log ~ igpm_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, copom_dif ~ igpm_dif | factor(Ano):factor(presidente))

printlm(base_m, copom_scaled ~ inpc_scaled | factor(Ano):factor(presidente))
printlm(base_m, copom_scaled ~ inpc_lag_scaled | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, copom_log ~ inpc_log | factor(Ano):factor(presidente))
printlm(base_m, copom_log ~ inpc_lag_log | factor(Ano):factor(presidente)) #*** NOK
printlm(base_m, copom_dif ~ inpc_dif | factor(Ano):factor(presidente)) #*

printlm(base_m, copom_scaled ~ ipca_scaled | factor(Ano):factor(presidente))
printlm(base_m, copom_scaled ~ ipca_lag_scaled | factor(Ano):factor(presidente)) #* NOK
printlm(base_m, copom_log ~ ipca_log | factor(Ano):factor(presidente))
printlm(base_m, copom_log ~ ipca_lag_log | factor(Ano):factor(presidente)) #*** NOK
printlm(base_m, copom_dif ~ ipca_dif | factor(Ano):factor(presidente))

printlm(base_m, copom_scaled ~ uncertainty_scaled | factor(Ano):factor(presidente))
printlm(base_m, copom_scaled ~ uncertainty_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, copom_log ~ uncertainty_log | factor(Ano):factor(presidente)) 
printlm(base_m, copom_log ~ uncertainty_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, copom_dif ~ uncertainty_dif | factor(Ano):factor(presidente))

printlm(base_m, copom_scaled ~ iiebr_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, copom_scaled ~ iiebr_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, copom_log ~ iiebr_log | factor(Ano):factor(presidente)) 
printlm(base_m, copom_log ~ iiebr_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, copom_dif ~ iiebr_dif | factor(Ano):factor(presidente))

printlm(base_d, copom_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente))
printlm(base_d, copom_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente))
printlm(base_d, copom_log ~ dolarcompra_log | factor(Ano):factor(presidente)) 
printlm(base_d, copom_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente))
printlm(base_d, copom_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_d, copom_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, copom_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente))
printlm(base_d, copom_log ~ ibovespa_log | factor(Ano):factor(presidente)) 
printlm(base_d, copom_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_d, copom_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_d, copom_scaled ~ embi_scaled | factor(Ano):factor(presidente))
printlm(base_d, copom_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, copom_log ~ embi_log | factor(Ano):factor(presidente))
printlm(base_d, copom_log ~ embi_lag_log | factor(Ano):factor(presidente))
printlm(base_d, copom_dif ~ embi_dif | factor(Ano):factor(presidente))


# incerteza ---------------------------------------------------------------

printlm(base_m, incerteza_scaled ~ pib_scaled | factor(Ano):factor(presidente))
printlm(base_m, incerteza_scaled ~ pib_lag_scaled | factor(Ano):factor(presidente)) #*
printlm(base_m, incerteza_log ~ pib_log | factor(Ano):factor(presidente)) 
printlm(base_m, incerteza_log ~ pib_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, incerteza_dif ~ pib_dif | factor(Ano):factor(presidente))

printlm(base_m, incerteza_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, incerteza_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #**
printlm(base_m, incerteza_log ~ dolarcompra_log | factor(Ano):factor(presidente)) #***
printlm(base_m, incerteza_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, incerteza_dif ~ dolarcompra_dif | factor(Ano):factor(presidente)) #***

printlm(base_m, incerteza_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, incerteza_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, incerteza_log ~ ibovespa_log | factor(Ano):factor(presidente)) #***
printlm(base_m, incerteza_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) #*
printlm(base_m, incerteza_dif ~ ibovespa_dif | factor(Ano):factor(presidente)) #***

printlm(base_m, incerteza_scaled ~ embi_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, incerteza_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) #*
printlm(base_m, incerteza_log ~ embi_log | factor(Ano):factor(presidente)) #**
printlm(base_m, incerteza_log ~ embi_lag_log | factor(Ano):factor(presidente))
printlm(base_m, incerteza_dif ~ embi_dif | factor(Ano):factor(presidente)) #**

printlm(base_m, incerteza_scaled ~ igpm_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, incerteza_scaled ~ igpm_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, incerteza_log ~ igpm_log | factor(Ano):factor(presidente))
printlm(base_m, incerteza_log ~ igpm_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, incerteza_dif ~ igpm_dif | factor(Ano):factor(presidente))

printlm(base_m, incerteza_scaled ~ inpc_scaled | factor(Ano):factor(presidente))
printlm(base_m, incerteza_scaled ~ inpc_lag_scaled | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, incerteza_log ~ inpc_log | factor(Ano):factor(presidente))
printlm(base_m, incerteza_log ~ inpc_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, incerteza_dif ~ inpc_dif | factor(Ano):factor(presidente))

printlm(base_m, incerteza_scaled ~ ipca_scaled | factor(Ano):factor(presidente))
printlm(base_m, incerteza_scaled ~ ipca_lag_scaled | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, incerteza_log ~ ipca_log | factor(Ano):factor(presidente))
printlm(base_m, incerteza_log ~ ipca_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, incerteza_dif ~ ipca_dif | factor(Ano):factor(presidente))

printlm(base_m, incerteza_scaled ~ uncertainty_scaled | factor(Ano):factor(presidente)) #**
printlm(base_m, incerteza_scaled ~ uncertainty_lag_scaled | factor(Ano):factor(presidente)) #**
printlm(base_m, incerteza_log ~ uncertainty_log | factor(Ano):factor(presidente)) #**
printlm(base_m, incerteza_log ~ uncertainty_lag_log | factor(Ano):factor(presidente))
printlm(base_m, incerteza_dif ~ uncertainty_dif | factor(Ano):factor(presidente)) #**

printlm(base_m, incerteza_scaled ~ iiebr_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, incerteza_scaled ~ iiebr_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, incerteza_log ~ iiebr_log | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, incerteza_log ~ iiebr_lag_log | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, incerteza_dif ~ iiebr_dif | factor(Ano):factor(presidente)) #**

printlm(base_d, incerteza_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, incerteza_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, incerteza_log ~ dolarcompra_log | factor(Ano):factor(presidente)) #***
printlm(base_d, incerteza_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) #***
printlm(base_d, incerteza_dif ~ dolarcompra_dif | factor(Ano):factor(presidente)) #**

printlm(base_d, incerteza_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, incerteza_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, incerteza_log ~ ibovespa_log | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, incerteza_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, incerteza_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_d, incerteza_scaled ~ embi_scaled | factor(Ano)) #*** OK
printlm(base_d, incerteza_scaled ~ embi_lag_scaled | factor(Ano)) #*** OK
printlm(base_d, incerteza_log ~ embi_log | factor(Ano)) #*** OK
printlm(base_d, incerteza_log ~ embi_lag_log | factor(Ano)) #***
printlm(base_d, incerteza_dif ~ embi_dif | factor(Ano):factor(presidente))

# credibilidade -----------------------------------------------------------

printlm(base_m, credibilidade_scaled ~ pib_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_scaled ~ pib_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ pib_log | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_log ~ pib_lag_log | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_dif ~ pib_dif | factor(Ano):factor(presidente))

printlm(base_m, credibilidade_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ dolarcompra_log | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_m, credibilidade_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ ibovespa_log | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_m, credibilidade_scaled ~ embi_scaled | factor(Ano):factor(presidente)) #*
printlm(base_m, credibilidade_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ embi_log | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_dif ~ embi_dif | factor(Ano):factor(presidente))

printlm(base_m, credibilidade_scaled ~ igpm_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_scaled ~ igpm_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ igpm_log | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ igpm_lag_log | factor(Ano):factor(presidente)) #* NOK
printlm(base_m, credibilidade_dif ~ igpm_dif | factor(Ano):factor(presidente))

printlm(base_m, credibilidade_scaled ~ inpc_scaled | factor(Ano):factor(presidente)) #*
printlm(base_m, credibilidade_scaled ~ inpc_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ inpc_log | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ inpc_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_dif ~ inpc_dif | factor(Ano):factor(presidente)) #***

printlm(base_m, credibilidade_scaled ~ ipca_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_scaled ~ ipca_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_log ~ ipca_log | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ ipca_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_dif ~ ipca_dif | factor(Ano):factor(presidente)) #**

printlm(base_m, credibilidade_scaled ~ uncertainty_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_scaled ~ uncertainty_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ uncertainty_log | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_log ~ uncertainty_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_dif ~ uncertainty_dif | factor(Ano):factor(presidente))

printlm(base_m, credibilidade_scaled ~ iiebr_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_scaled ~ iiebr_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, credibilidade_log ~ iiebr_log | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_log ~ iiebr_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, credibilidade_dif ~ iiebr_dif | factor(Ano):factor(presidente))

printlm(base_d, credibilidade_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #** OK
printlm(base_d, credibilidade_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #** OK
printlm(base_d, credibilidade_log ~ dolarcompra_log | factor(Ano):factor(presidente)) #**
printlm(base_d, credibilidade_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) #**
printlm(base_d, credibilidade_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_d, credibilidade_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #** OK
printlm(base_d, credibilidade_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #** OK
printlm(base_d, credibilidade_log ~ ibovespa_log | factor(Ano):factor(presidente)) 
printlm(base_d, credibilidade_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) #* OK
printlm(base_d, credibilidade_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_d, credibilidade_scaled ~ embi_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, credibilidade_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, credibilidade_log ~ embi_log | factor(Ano):factor(presidente)) #** OK
printlm(base_d, credibilidade_log ~ embi_lag_log | factor(Ano):factor(presidente)) #**
printlm(base_d, credibilidade_dif ~ embi_dif | factor(Ano):factor(presidente))

# focus -------------------------------------------------------------------

printlm(base_m, focus_scaled ~ pib_scaled | factor(Ano):factor(presidente))
printlm(base_m, focus_scaled ~ pib_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, focus_log ~ pib_log | factor(Ano):factor(presidente)) #***  NOK
printlm(base_m, focus_log ~ pib_lag_log | factor(Ano):factor(presidente)) #***  NOK
printlm(base_m, focus_dif ~ pib_dif | factor(Ano):factor(presidente))

printlm(base_m, focus_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, focus_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, focus_log ~ dolarcompra_log | factor(Ano):factor(presidente)) #* NOK
printlm(base_m, focus_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, focus_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_m, focus_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente))
printlm(base_m, focus_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, focus_log ~ ibovespa_log | factor(Ano):factor(presidente)) #* NOK
printlm(base_m, focus_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) #* NOK
printlm(base_m, focus_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_m, focus_scaled ~ embi_scaled | factor(Ano):factor(presidente))
printlm(base_m, focus_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, focus_log ~ embi_log | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, focus_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, focus_dif ~ embi_dif | factor(Ano):factor(presidente))

printlm(base_m, focus_scaled ~ igpm_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, focus_scaled ~ igpm_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, focus_log ~ igpm_log | factor(Ano):factor(presidente))
printlm(base_m, focus_log ~ igpm_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, focus_dif ~ igpm_dif | factor(Ano):factor(presidente))

printlm(base_m, focus_scaled ~ inpc_scaled | factor(Ano):factor(presidente))
printlm(base_m, focus_scaled ~ inpc_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, focus_log ~ inpc_log | factor(Ano):factor(presidente))
printlm(base_m, focus_log ~ inpc_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, focus_dif ~ inpc_dif | factor(Ano):factor(presidente))

printlm(base_m, focus_scaled ~ ipca_scaled | factor(Ano):factor(presidente))
printlm(base_m, focus_scaled ~ ipca_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, focus_log ~ ipca_log | factor(Ano):factor(presidente))
printlm(base_m, focus_log ~ ipca_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, focus_dif ~ ipca_dif | factor(Ano):factor(presidente))

printlm(base_m, focus_scaled ~ uncertainty_scaled | factor(Ano):factor(presidente))
printlm(base_m, focus_scaled ~ uncertainty_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, focus_log ~ uncertainty_log | factor(Ano):factor(presidente)) #* NOK
printlm(base_m, focus_log ~ uncertainty_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, focus_dif ~ uncertainty_dif | factor(Ano):factor(presidente))

printlm(base_m, focus_scaled ~ iiebr_scaled | factor(Ano):factor(presidente)) #* OK
printlm(base_m, focus_scaled ~ iiebr_lag_scaled | factor(Ano):factor(presidente)) #* OK
printlm(base_m, focus_log ~ iiebr_log | factor(Ano):factor(presidente))
printlm(base_m, focus_log ~ iiebr_lag_log | factor(Ano):factor(presidente))
printlm(base_m, focus_dif ~ iiebr_dif | factor(Ano):factor(presidente))

printlm(base_d, focus_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, focus_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente))
printlm(base_d, focus_log ~ dolarcompra_log | factor(Ano):factor(presidente)) 
printlm(base_d, focus_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente))
printlm(base_d, focus_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_d, focus_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, focus_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, focus_log ~ ibovespa_log | factor(Ano):factor(presidente)) 
printlm(base_d, focus_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_d, focus_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_d, focus_scaled ~ embi_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, focus_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente))
printlm(base_d, focus_log ~ embi_log | factor(Ano):factor(presidente)) 
printlm(base_d, focus_log ~ embi_lag_log | factor(Ano):factor(presidente))
printlm(base_d, focus_dif ~ embi_dif | factor(Ano):factor(presidente))

# autonomia ---------------------------------------------------------------

printlm(base_m, autonomia_scaled ~ pib_scaled | factor(Ano):factor(presidente))
printlm(base_m, autonomia_scaled ~ pib_lag_scaled | factor(Ano):factor(presidente)) #**
printlm(base_m, autonomia_log ~ pib_log | factor(Ano):factor(presidente)) 
printlm(base_m, autonomia_log ~ pib_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, autonomia_dif ~ pib_dif | factor(Ano):factor(presidente)) #** NOK

printlm(base_m, autonomia_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, autonomia_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, autonomia_log ~ dolarcompra_log | factor(Ano):factor(presidente))
printlm(base_m, autonomia_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente))
printlm(base_m, autonomia_dif ~ dolarcompra_dif | factor(Ano):factor(presidente)) #*

printlm(base_m, autonomia_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #**
printlm(base_m, autonomia_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, autonomia_log ~ ibovespa_log | factor(Ano):factor(presidente))
printlm(base_m, autonomia_log ~ ibovespa_lag_log | factor(Ano):factor(presidente))
printlm(base_m, autonomia_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_m, autonomia_scaled ~ embi_scaled | factor(Ano):factor(presidente)) #**
printlm(base_m, autonomia_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, autonomia_log ~ embi_log | factor(Ano):factor(presidente))
printlm(base_m, autonomia_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, autonomia_dif ~ embi_dif | factor(Ano):factor(presidente))

printlm(base_m, autonomia_scaled ~ igpm_scaled | factor(Ano):factor(presidente)) #* OK
printlm(base_m, autonomia_scaled ~ igpm_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, autonomia_log ~ igpm_log | factor(Ano):factor(presidente))
printlm(base_m, autonomia_log ~ igpm_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, autonomia_dif ~ igpm_dif | factor(Ano):factor(presidente))

printlm(base_m, autonomia_scaled ~ inpc_scaled | factor(Ano):factor(presidente))
printlm(base_m, autonomia_scaled ~ inpc_lag_scaled | factor(Ano):factor(presidente)) #*
printlm(base_m, autonomia_log ~ inpc_log | factor(Ano):factor(presidente))
printlm(base_m, autonomia_log ~ inpc_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, autonomia_dif ~ inpc_dif | factor(Ano):factor(presidente))

printlm(base_m, autonomia_scaled ~ ipca_scaled | factor(Ano):factor(presidente))
printlm(base_m, autonomia_scaled ~ ipca_lag_scaled | factor(Ano):factor(presidente)) #*** NOK
printlm(base_m, autonomia_log ~ ipca_log | factor(Ano):factor(presidente))
printlm(base_m, autonomia_log ~ ipca_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, autonomia_dif ~ ipca_dif | factor(Ano):factor(presidente))

printlm(base_m, autonomia_scaled ~ uncertainty_scaled | factor(Ano):factor(presidente))
printlm(base_m, autonomia_scaled ~ uncertainty_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, autonomia_log ~ uncertainty_log | factor(Ano):factor(presidente)) 
printlm(base_m, autonomia_log ~ uncertainty_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, autonomia_dif ~ uncertainty_dif | factor(Ano):factor(presidente))

printlm(base_m, autonomia_scaled ~ iiebr_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, autonomia_scaled ~ iiebr_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, autonomia_log ~ iiebr_log | factor(Ano):factor(presidente)) #* OK
printlm(base_m, autonomia_log ~ iiebr_lag_log | factor(Ano):factor(presidente)) #** OK
printlm(base_m, autonomia_dif ~ iiebr_dif | factor(Ano):factor(presidente)) #*

printlm(base_d, autonomia_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, autonomia_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, autonomia_log ~ dolarcompra_log | factor(Ano):factor(presidente)) #***
printlm(base_d, autonomia_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) #***
printlm(base_d, autonomia_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_d, autonomia_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #** OK
printlm(base_d, autonomia_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #** OK
printlm(base_d, autonomia_log ~ ibovespa_log | factor(Ano):factor(presidente)) 
printlm(base_d, autonomia_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_d, autonomia_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_d, autonomia_scaled ~ embi_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, autonomia_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, autonomia_log ~ embi_log | factor(Ano):factor(presidente)) #*** OK
printlm(base_d, autonomia_log ~ embi_lag_log | factor(Ano):factor(presidente))#***
printlm(base_m, autonomia_dif ~ embi_dif | factor(Ano):factor(presidente))

# prob_N ------------------------------------------------------------------

printlm(base_m, prob_N_scaled ~ pib_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_scaled ~ pib_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ pib_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ pib_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_dif ~ pib_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_N_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #**
printlm(base_m, prob_N_log ~ dolarcompra_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_N_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, prob_N_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, prob_N_log ~ ibovespa_log | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, prob_N_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_dif ~ ibovespa_dif | factor(Ano):factor(presidente)) #NOK

printlm(base_m, prob_N_scaled ~ embi_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ embi_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_dif ~ embi_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_N_scaled ~ igpm_scaled | factor(Ano):factor(presidente))  
printlm(base_m, prob_N_scaled ~ igpm_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ igpm_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ igpm_lag_log | factor(Ano):factor(presidente))
printlm(base_m, prob_N_dif ~ igpm_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_N_scaled ~ inpc_scaled | factor(Ano):factor(presidente))
printlm(base_m, prob_N_scaled ~ inpc_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, prob_N_log ~ inpc_log | factor(Ano):factor(presidente))
printlm(base_m, prob_N_log ~ inpc_lag_log | factor(Ano):factor(presidente))
printlm(base_m, prob_N_dif ~ inpc_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_N_scaled ~ ipca_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_scaled ~ ipca_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ ipca_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ ipca_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_dif ~ ipca_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_N_scaled ~ uncertainty_scaled | factor(Ano):factor(presidente))
printlm(base_m, prob_N_scaled ~ uncertainty_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, prob_N_log ~ uncertainty_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ uncertainty_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_dif ~ uncertainty_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_N_scaled ~ iiebr_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_scaled ~ iiebr_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ iiebr_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_log ~ iiebr_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_N_dif ~ iiebr_dif | factor(Ano):factor(presidente))

printlm(base_d, prob_N_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #***
printlm(base_d, prob_N_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #**
printlm(base_d, prob_N_log ~ dolarcompra_log | factor(Ano):factor(presidente)) #**
printlm(base_d, prob_N_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) #**
printlm(base_d, prob_N_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_d, prob_N_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #*** NOK
printlm(base_d, prob_N_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #*** NOK
printlm(base_d, prob_N_log ~ ibovespa_log | factor(Ano):factor(presidente)) #*** NOK
printlm(base_d, prob_N_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) #*** NOK
printlm(base_d, prob_N_dif ~ ibovespa_dif | factor(Ano):factor(presidente)) #***

printlm(base_d, prob_N_scaled ~ embi_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, prob_N_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, prob_N_log ~ embi_log | factor(Ano):factor(presidente)) 
printlm(base_d, prob_N_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_d, prob_N_dif ~ embi_dif | factor(Ano):factor(presidente)) #*

# prob_C ------------------------------------------------------------------

printlm(base_m, prob_C_scaled ~ pib_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_scaled ~ pib_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ pib_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ pib_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_dif ~ pib_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_C_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #**
printlm(base_m, prob_C_log ~ dolarcompra_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_C_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, prob_C_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, prob_C_log ~ ibovespa_log | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, prob_C_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_dif ~ ibovespa_dif | factor(Ano):factor(presidente)) # ** NOK

printlm(base_m, prob_C_scaled ~ embi_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ embi_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_dif ~ embi_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_C_scaled ~ igpm_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_scaled ~ igpm_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ igpm_log | factor(Ano):factor(presidente))
printlm(base_m, prob_C_log ~ igpm_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_dif ~ igpm_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_C_scaled ~ inpc_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_scaled ~ inpc_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ inpc_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ inpc_lag_log | factor(Ano):factor(presidente))
printlm(base_m, prob_C_dif ~ inpc_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_C_scaled ~ ipca_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_scaled ~ ipca_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ ipca_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ ipca_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_dif ~ ipca_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_C_scaled ~ uncertainty_scaled | factor(Ano):factor(presidente))
printlm(base_m, prob_C_scaled ~ uncertainty_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, prob_C_log ~ uncertainty_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ uncertainty_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_dif ~ uncertainty_dif | factor(Ano):factor(presidente))

printlm(base_m, prob_C_scaled ~ iiebr_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_scaled ~ iiebr_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ iiebr_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_log ~ iiebr_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, prob_C_dif ~ iiebr_dif | factor(Ano):factor(presidente))

printlm(base_d, prob_C_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #***
printlm(base_d, prob_C_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #***
printlm(base_d, prob_C_log ~ dolarcompra_log | factor(Ano):factor(presidente)) #**
printlm(base_d, prob_C_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) #*
printlm(base_d, prob_C_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_d, prob_C_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #*** NOK
printlm(base_d, prob_C_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #*** NOK
printlm(base_d, prob_C_log ~ ibovespa_log | factor(Ano):factor(presidente)) #*** NOK
printlm(base_d, prob_C_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) #*** NOK
printlm(base_d, prob_C_dif ~ ibovespa_dif | factor(Ano):factor(presidente)) #***

printlm(base_d, prob_C_scaled ~ embi_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, prob_C_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_d, prob_C_log ~ embi_log | factor(Ano):factor(presidente)) 
printlm(base_d, prob_C_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_d, prob_C_dif ~ embi_dif | factor(Ano):factor(presidente)) #*


# qtd_C -------------------------------------------------------------------

printlm(base_m, qtd_C_scaled ~ pib_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_scaled ~ pib_lag_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_log ~ pib_log | factor(Ano):factor(presidente)) #*** NOK
printlm(base_m, qtd_C_log ~ pib_lag_log | factor(Ano):factor(presidente))
printlm(base_m, qtd_C_dif ~ pib_dif | factor(Ano):factor(presidente)) #*** Nok

printlm(base_m, qtd_C_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #*** OK
printlm(base_m, qtd_C_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, qtd_C_log ~ dolarcompra_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_dif ~ dolarcompra_dif | factor(Ano):factor(presidente)) #***

printlm(base_m, qtd_C_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #*** 
printlm(base_m, qtd_C_log ~ ibovespa_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_m, qtd_C_scaled ~ embi_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, qtd_C_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, qtd_C_log ~ embi_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_log ~ embi_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_dif ~ embi_dif | factor(Ano):factor(presidente)) #**

printlm(base_m, qtd_C_scaled ~ igpm_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, qtd_C_scaled ~ igpm_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, qtd_C_log ~ igpm_log | factor(Ano):factor(presidente)) #**
printlm(base_m, qtd_C_log ~ igpm_lag_log | factor(Ano):factor(presidente))
printlm(base_m, qtd_C_dif ~ igpm_dif | factor(Ano):factor(presidente))

printlm(base_m, qtd_C_scaled ~ inpc_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_scaled ~ inpc_lag_scaled | factor(Ano):factor(presidente)) #* NOK
printlm(base_m, qtd_C_log ~ inpc_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_log ~ inpc_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_dif ~ inpc_dif | factor(Ano):factor(presidente))

printlm(base_m, qtd_C_scaled ~ ipca_scaled | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_scaled ~ ipca_lag_scaled | factor(Ano):factor(presidente)) #** NOK
printlm(base_m, qtd_C_log ~ ipca_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_log ~ ipca_lag_log | factor(Ano):factor(presidente))
printlm(base_m, qtd_C_dif ~ ipca_dif | factor(Ano):factor(presidente))

printlm(base_m, qtd_C_scaled ~ uncertainty_scaled | factor(Ano):factor(presidente))
printlm(base_m, qtd_C_scaled ~ uncertainty_lag_scaled | factor(Ano):factor(presidente))
printlm(base_m, qtd_C_log ~ uncertainty_log | factor(Ano):factor(presidente)) #* NOK
printlm(base_m, qtd_C_log ~ uncertainty_lag_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_dif ~ uncertainty_dif | factor(Ano):factor(presidente))

printlm(base_m, qtd_C_scaled ~ iiebr_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, qtd_C_scaled ~ iiebr_lag_scaled | factor(Ano):factor(presidente)) #***
printlm(base_m, qtd_C_log ~ iiebr_log | factor(Ano):factor(presidente)) 
printlm(base_m, qtd_C_log ~ iiebr_lag_log | factor(Ano):factor(presidente)) #**
printlm(base_m, qtd_C_dif ~ iiebr_dif | factor(Ano):factor(presidente)) #*

printlm(base_d, qtd_C_scaled ~ dolarcompra_scaled | factor(Ano):factor(presidente)) #***
printlm(base_d, qtd_C_scaled ~ dolarcompra_lag_scaled | factor(Ano):factor(presidente)) #***
printlm(base_d, qtd_C_log ~ dolarcompra_log | factor(Ano):factor(presidente)) #***
printlm(base_d, qtd_C_log ~ dolarcompra_lag_log | factor(Ano):factor(presidente)) #***
printlm(base_d, qtd_C_dif ~ dolarcompra_dif | factor(Ano):factor(presidente))

printlm(base_d, qtd_C_scaled ~ ibovespa_scaled | factor(Ano):factor(presidente)) #*
printlm(base_d, qtd_C_scaled ~ ibovespa_lag_scaled | factor(Ano):factor(presidente)) #* 
printlm(base_d, qtd_C_log ~ ibovespa_log | factor(Ano):factor(presidente)) 
printlm(base_d, qtd_C_log ~ ibovespa_lag_log | factor(Ano):factor(presidente)) 
printlm(base_d, qtd_C_dif ~ ibovespa_dif | factor(Ano):factor(presidente))

printlm(base_d, qtd_C_scaled ~ embi_scaled | factor(Ano):factor(presidente)) #***
printlm(base_d, qtd_C_scaled ~ embi_lag_scaled | factor(Ano):factor(presidente)) #***
printlm(base_d, qtd_C_log ~ embi_log | factor(Ano):factor(presidente)) #**
printlm(base_d, qtd_C_log ~ embi_lag_log | factor(Ano):factor(presidente)) #**
printlm(base_d, qtd_C_dif ~ embi_dif | factor(Ano):factor(presidente))


# testes ------------------------------------------------------------------

model <- lm(data = base_m,
  formula = incerteza_scaled ~ iiebr_scaled + factor(Ano) 
  
)

e <- model$residuals
pacf(e)


# VAR ---------------------------------------------------------------------

library(vars)

df_incerteza = base_m[3:(length(base_m$DATA)-1) ,c("incerteza_dif","dolarcompra_dif","pib_dif2","ibovespa_dif2","embi_dif","ipca_dif","uncertainty_dif","iiebr_dif"),]
#df_incerteza = base_m[3:(length(base_m$DATA)-1) ,c("incerteza_dif","dolarcompra_dif","ibovespa_dif2","embi_dif","uncertainty_dif","iiebr_dif"),]
v = VAR(df_incerteza, p = 12, type = "const")

stargazer(v$varresult$incerteza, type = "text")

stargazer(VAR(df_incerteza, p = 1, type = "const")$varresult$incerteza, type = "text")
stargazer(VAR(df_incerteza, p = 1, type = "const")$varresult$incerteza, type = "latex")
stargazer(VAR(df_incerteza, p = 2, type = "const")$varresult$incerteza, type = "text")
stargazer(VAR(df_incerteza, p = 3, type = "const")$varresult$incerteza, type = "text")
stargazer(VAR(df_incerteza, p = 4, type = "const")$varresult$incerteza, type = "text")
stargazer(VAR(df_incerteza, p = 6, type = "const")$varresult$incerteza, type = "text")
stargazer(VAR(df_incerteza, p = 12, type = "const")$varresult$incerteza, type = "text")

#df_incerteza2 = base_m[3:(length(base_m$DATA)-1) ,c("incerteza_dif","dolarcompra_dif","pib_dif","ibovespa_dif","embi_dif","ipca_dif","uncertainty_dif","iiebr_dif","presidente"),]
#df_incerteza2$presidente <- as.factor(df_incerteza2$presidente)
#stargazer(VAR(df_incerteza2, p = 1, type = "const")$varresult$incerteza, type = "text")


# incerteza_ponderada -----------------------------------------------------


base_m[,incerteza_pond := incerteza/total,]
base_m[,incerteza_lag_pond := shift(incerteza_pond, 1, "lag"),]
base_m[,incerteza_pond_dif := incerteza_pond-incerteza_lag_pond,]
printlm(base_m, incerteza_pond_dif ~ dolarcompra_dif | factor(presidente))#***
printlm(base_m, incerteza_pond_dif ~ pib_dif | factor(presidente))
printlm(base_m, incerteza_pond_dif ~ ibovespa_dif | factor(presidente))#***
printlm(base_m, incerteza_pond_dif ~ embi_dif | factor(presidente))#**
printlm(base_m, incerteza_pond_dif ~ ipca_dif | factor(presidente))
printlm(base_m, incerteza_pond_dif ~ uncertainty_dif | factor(presidente))#**
printlm(base_m, incerteza_pond_dif ~ iiebr_dif | factor(presidente))#**

base_d[,incerteza_pond := incerteza/total,]
base_d[,incerteza_lag_pond := shift(incerteza_pond, 1, "lag"),]
base_d[,incerteza_pond_dif := incerteza_pond-incerteza_lag_pond,]
printlm(base_d, incerteza_pond_dif ~ dolarcompra_dif | factor(presidente))
printlm(base_d, incerteza_pond_dif ~ ibovespa_dif | factor(presidente))
printlm(base_d, incerteza_pond_dif ~ embi_dif | factor(presidente))



df_incerteza_rel = base_m[3:(length(base_m$DATA)-1) ,c("incerteza_rel_dif","dolarcompra_dif","pib_dif","ibovespa_dif","embi_dif","ipca_dif","uncertainty_dif","iiebr_dif"),]

stargazer(VAR(df_incerteza_rel, p = 1, type = "const")$varresult$incerteza, type = "text")
