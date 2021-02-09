"""

Baixa os tweets antigos usando o parâmetro max_id

"""

import tweepy
import pandas as pd
import pickle
from datetime import datetime
import time



#intervalo em minutos
intervalo = 10/60

# Twitter Api Credentials
consumerKey = 'XXXXXXXXXXXXX'
consumerSecret = 'XXXXXXXXXXXXX'
accessToken = 'XXXXXXXXXXXXX'
accessTokenSecret = 'XXXXXXXXXXXXX'

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
lista_queries = ["bc lang:pt filter:verified","bacen lang:pt filter:verified",
                 "banco central lang:pt filter:verified", "bcb lang:pt",
                 "#bancocentral lang:pt", "#bcb lang:pt", "#bc lang:pt",
                 "#bacen lang:pt filter:verified","BancoCentralBR",
                 "Conselho Monetário Nacional",
                 "copom lang:pt", "#copom lang:pt" ,"#BancocentraldoBrasil"#,
                 ]

# Baixa a base de tweets 
df = pd.read_pickle('dados\\df_tweet_completo.pkl')



for user in lista_usuarios:
    oldest = df[df['usuario']==user[1:]].id.min()-1
    nr_posts = 1
    while nr_posts>0:
    
        try:
            dateTimeObj = datetime.now()
            timestampStr = dateTimeObj.strftime("%Y-%m-%d-%H-%M-%S")
            print(user + ' - ' + timestampStr)
            posts = api.user_timeline(screen_name=user, count = 100, lang ="pt", 
                                  tweet_mode="extended",max_id = oldest)
            
            nr_posts = len(posts)
            oldest = posts[-1].id - 1
            print(nr_posts)
            
            with open('dados\\tweets\\tweets-'+timestampStr+'.pickle', 'wb') as f:
                pickle.dump(posts, f)
            f.close()
            print('ok')
        except Exception as e:
            print(e)
            print("continuing...")
        time.sleep(intervalo*60)



tipo_resultado = 'recent'
for query in lista_queries:
    
    try:
        dateTimeObj = datetime.now()
        timestampStr = dateTimeObj.strftime("%Y-%m-%d-%H-%M-%S")
        print(query + ' - ' + timestampStr)
        posts = api.search(q=query, count = 100, lang ="pt", result_type = tipo_resultado,
                          tweet_mode="extended")
        
        nr_posts = len(posts)
        oldest = posts[-1].id - 1
        print(nr_posts)
        
        with open('dados\\tweets\\tweets-'+timestampStr+'.pickle', 'wb') as f:
            pickle.dump(posts, f)
        f.close()
        print('ok')
    except Exception as e:
        print(e)
        print("continuing...")
    time.sleep(intervalo*60)
    
    
    while nr_posts>0:
    
        try:
            dateTimeObj = datetime.now()
            timestampStr = dateTimeObj.strftime("%Y-%m-%d-%H-%M-%S")
            print(query + ' - ' + timestampStr)
            posts = api.search(q=query, count = 100, lang ="pt", result_type = tipo_resultado,
                              tweet_mode="extended",max_id = oldest)
            
            nr_posts = len(posts)
            oldest = posts[-1].id - 1
            print(nr_posts)
            
            with open('dados\\tweets\\tweets-'+timestampStr+'.pickle', 'wb') as f:
                pickle.dump(posts, f)
            f.close()
            print('ok')
        except Exception as e:
            print(e)
            print("continuing...")
        time.sleep(intervalo*60)