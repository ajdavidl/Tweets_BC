import tweepy
import pickle
from datetime import datetime
import time



#intervalo em minutos
intervalo = 5/60

# Twitter Api Credentials
consumerKey = 'XXXXXXXXXX'
consumerSecret = 'XXXXXXXXXX'
accessToken = 'XXXXXXXXXX'
accessTokenSecret = 'XXXXXXXXXX'

# Create the authentication object
authenticate = tweepy.OAuthHandler(consumerKey, consumerSecret)
# Set the access token and access token secret
authenticate.set_access_token(accessToken, accessTokenSecret)
# Creating the API object while passing in auth information
api = tweepy.API(authenticate, wait_on_rate_limit = True)

lista_usuarios = ["@UOLEconomia","@valoreconomico","@exame","@infomoney","@BloombergBrasil",
                  "@OGlobo_Economia","@folha_mercado","@EstadaoEconomia","@CNNBrBusiness",
                  "@empiricus","@FGVIBRE","@epocanegocios","@leiamoneytimes","@MinEconomia",
                  "@BancoCentralBR"]

lista_queries = ["bc lang:pt","bacen lang:pt",
                 "banco central lang:pt", "bcb lang:pt",
                 "#bancocentral lang:pt", "#bcb lang:pt", "#bc lang:pt",
                 "#bacen lang:pt","BancoCentralBR", "selic","autonomia bc",
                 "autonomia banco central","pix bc lang:pt",
                 "Conselho Monetário Nacional","política monetária lang:pt",
                 "copom lang:pt", "#copom lang:pt" ,"#BancocentraldoBrasil",
                 "estabilidade financeira","crédito bancário","regulação prudencial",
                 "sistema financeiro","comef lang:pt","redesconto","reservas internacionais"]


# Baixa os tweets com base nas queries com o critério de mais populares
for query in lista_queries:
    try:
        dateTimeObj = datetime.now()
        timestampStr = dateTimeObj.strftime("%Y-%m-%d-%H-%M-%S")
        print(query + ' - ' + timestampStr)
        posts = api.search(q=query, count = 100, lang ="pt", result_type = "popular",
                              tweet_mode="extended")
        print(len(posts))
        if len(posts)>0:
            with open('dados\\tweets\\tweets-'+timestampStr+'.pickle', 'wb') as f:
                pickle.dump(posts, f)
        
            f.close()
        print('ok')
    except Exception as e:
        print(e)
        print("continuing...")
    time.sleep(intervalo*60)
    
# Baixa os tweets com base nas queries com o critério de mais recentes
for query in lista_queries:
    try:
        dateTimeObj = datetime.now()
        timestampStr = dateTimeObj.strftime("%Y-%m-%d-%H-%M-%S")
        print(query + ' - ' + timestampStr)
        posts = api.search(q=query, count = 100, lang ="pt", result_type = "recent",
                              tweet_mode="extended")
        print(len(posts))
        if len(posts)>0:
            with open('dados\\tweets\\tweets-'+timestampStr+'.pickle', 'wb') as f:
                pickle.dump(posts, f)
        
            f.close()
        print('ok')
    except Exception as e:
        print(e)
        print("continuing...")
    time.sleep(intervalo*60)

# Baixa os tweets com base nos usuários listados
for user in lista_usuarios:
    try:
        dateTimeObj = datetime.now()
        timestampStr = dateTimeObj.strftime("%Y-%m-%d-%H-%M-%S")
        print(user + ' - ' + timestampStr)
        posts = api.user_timeline(screen_name=user, count = 100, lang ="pt", 
                              tweet_mode="extended")
        print(len(posts))
        with open('dados\\tweets\\tweets-'+timestampStr+'.pickle', 'wb') as f:
            pickle.dump(posts, f)
        f.close()
        print('ok')
    except Exception as e:
        print(e)
        print("continuing...")
    time.sleep(intervalo*60)
    
