library(tokenizers)
library(dplyr)
library(tidytext)

afinn = get_sentiments("afinn")

setwd("Tweets_BC")

df <- read.csv2("dados/df_tweet_ingles_limpo.csv", sep = ',', encoding = 'UTF-8',colClasses=c('character'), stringsAsFactors = FALSE)


sent_afinn <- c()

list_tweets <- df$tweet_ingles_limpo
pol = 0

for (tweet in list_tweets) {
  pol = 0
  if(tweet != ""){
    tweet <- paste(tweet," ")
    tweet_token = tokenize_tweets(tweet, simplify = T,lowercase = T)
    
    for (w in tweet_token) {
      if (w %in% afinn$word){
        pol = pol + afinn[afinn$word == w, 2]
      }
    }
  }
  sent_afinn = c(sent_afinn, pol/length(tweet_token))
}

df$R_sent_afinn <- unlist(sent_afinn)



# bing --------------------------------------------------------------------

bing = get_sentiments("bing")

sent_bing <- c()


pol = 0

for (tweet in list_tweets) {
  pol = 0
  if(tweet != ""){
    tweet <- paste(tweet," ")
    tweet_token = tokenize_tweets(tweet, simplify = T,lowercase = T)
    
    for (w in tweet_token) {
      if (w %in% bing$word){
        if(bing[bing$word == w, 2] == "negative"){
          pol = pol - 1
        }
        else if(bing[bing$word == w, 2] == "positive"){
          pol = pol + 1
        }
      }
    }
  }
  sent_bing = c(sent_bing, pol/length(tweet_token))
}

df$R_sent_bing <- unlist(sent_bing)



# loughran ----------------------------------------------------------------



#Name: Loughran-McDonald Sentiment lexicon 
#URL: https://sraf.nd.edu/textual-analysis/resources/ 
#License: License required for commercial use. Please contact tloughra@nd.edu. 
loughran <- get_sentiments("loughran")

sent_loughran <- c()

pol = 0

for (tweet in list_tweets) {
  pol = 0
  if(tweet != ""){
    tweet <- paste(tweet," ")
    tweet_token = tokenize_tweets(tweet, simplify = T,lowercase = T)
    
    for (w in tweet_token) {
      if (w %in% loughran$word){
        if(loughran[loughran$word == w, 2] == "negative"){
          pol = pol - 1
        }
        else if(loughran[loughran$word == w, 2] == "positive"){
          pol = pol + 1
        }
      }
    }
  }
  sent_loughran = c(sent_loughran, pol/length(tweet_token))
}

df$R_sent_loughrang <- unlist(sent_loughran)



# nrc ---------------------------------------------------------------------

# Name: NRC Word-Emotion Association Lexicon 
# URL: http://saifmohammad.com/WebPages/lexicons.html 
# License: License required for commercial use. Please contact Saif M. Mohammad (saif.mohammad@nrc-cnrc.gc.ca). 
# Size: 22.8 MB (cleaned 424 KB) 
# Download mechanism: http 
# Citation info:
#   
#   This dataset was published in Saif M. Mohammad and Peter Turney. (2013), ``Crowdsourcing a Word-Emotion Association Lexicon.'' Computational Intelligence, 29(3): 436-465.
# 
# article{mohammad13,
#   author = {Mohammad, Saif M. and Turney, Peter D.},
#   title = {Crowdsourcing a Word-Emotion Association Lexicon},
#   journal = {Computational Intelligence},
#   volume = {29},
#   number = {3},
#   pages = {436-465},
#   doi = {10.1111/j.1467-8640.2012.00460.x},
#   url = {https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1467-8640.2012.00460.x},
#   eprint = {https://onlinelibrary.wiley.com/doi/pdf/10.1111/j.1467-8640.2012.00460.x},
#   year = {2013}
# }

nrc <- get_sentiments("nrc")

nrc <- nrc %>% filter(sentiment %in% c("positive","negative"))

sent_nrc <- c()

pol = 0

for (tweet in list_tweets) {
  pol = 0
  if(tweet != ""){
    tweet <- paste(tweet," ")
    tweet_token = tokenize_tweets(tweet, simplify = T,lowercase = T)
    
    for (w in tweet_token) {
      if (w %in% nrc$word){
        if(nrc[nrc$word == w, 2] == "negative"){
          pol = pol - 1
        }
        else if(nrc[nrc$word == w, 2] == "positive"){
          pol = pol + 1
        }
      }
    }
  }
  sent_nrc = c(sent_nrc, pol/length(tweet_token))
}

df$R_sent_nrc <- unlist(sent_nrc)



# SentimentAnalysis library -----------------------------------------------

#citation("SentimentAnalysis")

library(SentimentAnalysis)

#https://cran.r-project.org/web/packages/SentimentAnalysis/vignettes/SentimentAnalysis.html

#list_tweets <- df$tweet_ingles_limpo

#limpa caracteres estranhos que dão problema na função analyzeSentiment

list_tweets <- stringr::str_extract(list_tweets,"[[:alpha:] ]+")

sentiment <- analyzeSentiment(list_tweets)

#GI = Dictionary with opinionated words from the Harvard-IV dictionary as used in the General Inquirer software
#HE = Dictionary with opinionated words from Henry's Financial dictionary
#LM = Dictionary with opinionated words from Loughran-McDonald Financial dictionary
#QDAP = QDAP dictionary from the package qdapDictionaries

colnames(sentiment) <- c("WordCount","R_Sent_HarvardIV","R_Neg_HarvardIV","R_Pos_HarvardIV",
                         "R_Sent_Henry","R_Neg_Henry","R_Pos_Henry",
                         "R_Sent_Loughran2","R_Neg_Loughran2","R_Pos_Loughran2","R_Uncertainty_Loughran2", 
                         "R_Sent_QDAP","R_Neg_QDAP","R_Pos_QDAP")

sentiment$WordCount <- NULL

df$tweet_ingles_limpo <- NULL
df <- cbind.data.frame(df, sentiment)

write.csv2(x = df, file = "dados/df_tweet_R_sentiments.csv", fileEncoding = 'UTF-8')
