
print("Carregando pacotes!")
import os
import pickle
import pandas as pd
import numpy as np

from datetime import datetime
#import numpy as np

from textblob import TextBlob
import time
from datetime import timedelta
#from pattern.en import sentiment
import networkx as nx
import sqlite3

import utils

print("Carrega arquivos!")

path = "dados\\tweets"

# USAR ESSE CÓDIGO QUANDO RODAR PELA PRIMEIRA VEZ
# lista_arquivos = os.listdir(path)
# with open('dados\\lista_arquivos_lidos.pickle','wb') as f:
#     pickle.dump(lista_arquivos, f)
# df, df_g = utils.le_arquivos(path, lista_arquivos)
# df = df.drop_duplicates(subset = ['id'],keep = 'last')
# df['data'] =  pd.to_datetime(df['data'])
# df['data'] = df['data'].apply(lambda x: x - timedelta(hours=3))
# df = df.sort_values(by='data')
# df.to_pickle('dados\\df_tweet_completo.pkl')
# df_g = df_g.drop_duplicates()
# df_g.to_pickle('dados\\df_tweet_grafo_completo.pkl')

#USAR ESSE CÓDIGO QUANDO FOR RODAR AS DEMAIS VEZES
pickle_in = open("dados\\lista_arquivos_lidos.pickle","rb")
lista_arquivos_lidos = pickle.load(pickle_in)
lista_arquivos = os.listdir(path)


df = pd.read_pickle('dados\\df_tweet_completo.pkl')
df_g = pd.read_pickle('dados\\df_tweet_grafo_completo.pkl')

lista_arquivos = utils.Diff(lista_arquivos,lista_arquivos_lidos)

print(len(lista_arquivos),"arquivos novos")

if len(lista_arquivos)>0:
    # LE ARQUIVOS
    df_aux, df_g_aux = utils.le_arquivos(path, lista_arquivos)
    
    print(df_aux.shape[0], "novos tweets")
    
    # CONCATENA DATA FRAMES
    df_aux = df_aux.drop_duplicates(subset = ['id'],keep = 'last')
    df_aux['data'] =  pd.to_datetime(df_aux['data'])
    df_aux['data'] = df_aux['data'].apply(lambda x: x - timedelta(hours=3))
    df_aux = df_aux.sort_values(by='data')
    
    df = pd.concat([df, df_aux])
    df = df.drop_duplicates(subset = ['id'],keep = 'last')
    
    if df.id.dtype != np.int64:
        print('Tipo do id do dataframe df é',df.id.dtype)
        raise Exception("Coluna id do dataframe df não é int64!!")
    
    if df.retwitted.dtype != bool:
        print('Tipo da coluna retwitted do dataframe df é',df.retwitted.dtype)
        raise Exception("Coluna retwitted do dataframe df não é do tipo bool!!")
    
    
    df.to_pickle('dados\\df_tweet_completo.pkl')
    #df = pd.read_pickle('dados\\df_tweet_completo.pkl')
    del df_aux
    
    
    df_g_aux = df_g_aux.drop_duplicates()
    df_g = pd.concat([df_g, df_g_aux])
    df_g = df_g.drop_duplicates()
    df_g = df_g.reset_index()
    del df_g['index']
    
    if df_g.id.dtype != np.int64:
        print('Tipo do id do dataframe df é',df.id.dtype)
        raise Exception("Coluna id do dataframe df não é int64!!")
        
    
    df_g.to_pickle('dados\\df_tweet_grafo_completo.pkl')
    
    del df_g_aux
    
    # salva a lista de arquivos lidos
    lista_arquivos_lidos = lista_arquivos_lidos + lista_arquivos
    with open('dados\\lista_arquivos_lidos.pickle','wb') as f:
        pickle.dump(lista_arquivos_lidos, f)

print("Filtra tweets!")

#limpa usuários 
lista_negra_usuarios = utils.retorna_lista_negra_usuarios()

df = df[~df['usuario'].isin(lista_negra_usuarios)]


palavras_chave = [' BC ','BCs',' bc ','BCB ','bcb ','bacen ','Bacen ', 'BC#'
                  'banco central','Banco Central','Banco central','bancocentral',
                  '@BancoCentralBR'
                  #'Dólar','dólar',
                  #'pib','PIB',
                  'Conselho Monetário Nacional','conselho monetário nacional','conselho monetario nacional',
                  'depósito compulsório','deposito compulsorio',
                  'política monetária','Política Monetária', 'Política monetária','politica monetaria',
                  'política cambial','Política Cambial','Política cambial','politica cambial',
                  'Relatório de Inflação','relatório de inflação',
                  'Relatório Trimestral de Inflação','relatório trimestral de inflação',
                  'Relatório de Estabilidade Financeira','relatório de estabilidade financeira',' REF ',
                  'lift','LIFT','autonomia','pix',
                  #'credibilidade', #credibilidade trouxe muito lixo em tweets com muitos likes
                  'reservas','comef','COMEF','Comef',#'estabilidade financeira',
                  'crédito bancário','regulação prudencial', 
                  'Focus ','focus ','Copom','copom','selic','Selic']
df = df[df['tweet'].str.contains('|'.join(palavras_chave))]


#remove tweets
lista_negra_expressoes = utils.retorna_lista_negra_expressoes()

df = df[~df['tweet'].str.contains('|'.join(lista_negra_expressoes)) ]


df['tipo_usuario'] = df['usuario'].apply(utils.retorna_tipo_usuario)
df['tweet_limpo'] = df['tweet'].apply(utils.remove_url)
df['tweet_limpo'] = df['tweet_limpo'].apply(utils.corrige_ortografia)
df['tweet_para_traducao'] = df['tweet_limpo']
df['tweet_limpo'] = df['tweet_limpo'].apply(utils.strip_all_entities)
df['tweet_limpo'] = df['tweet_limpo'].apply(utils.remove_numeros)
df['source'] = df['source'].apply(utils.strip_html_tags)
df['localidade'] = df['localidade'].apply(utils.compila_localidade)

df2 = df[~df['retwitted']]
df2 = df2.drop(columns=['retwitted'])
#df2.set_index('data', inplace=True)
df2.set_index('id', inplace=True)
df2 = df2.sort_index()


"""
###############################################################################
# BANCO DE DADOS
###############################################################################
"""
print("Lendo banco de dados sqlite")
#Index(['usuario', 'localidade', 'description', 'seguidores', 'amigos',
#       'favoritos', 'listado', 'nr_tweets', 'data', 'likes', 'retweets',
#       'replies', 'tweet', 'source', 'tipo_usuario', 'tweet_limpo',
#       'tweet_para_traducao'],
#      dtype='object')

conn = sqlite3.connect('base_sqlite3\\tweets.db')
query = "SELECT * FROM tweet;"
df_banco = pd.read_sql_query(query,conn)
conn.close()

df_banco.id = np.int64(df_banco.id)
df_banco.set_index(keys = "id", inplace = True)
df_banco.columns = ['author_id', 'date', 'likes', 'data', 'geo', 'hashtags',
       'mentions', 'permalink', 'replies', 'retweets', 'tweet', 'urls',
       'usuario']

print("Ajustando colunas")
# cria coluna vazias para concatenar com a base da api
df_banco["localidade"] = ["Não disponível" for i in range(df_banco.shape[0])]
df_banco["description"] = [" " for i in range(df_banco.shape[0])]
df_banco["seguidores"] = [np.nan for i in range(df_banco.shape[0])]
df_banco["amigos"] = [np.nan for i in range(df_banco.shape[0])]
df_banco["favoritos"] = [np.nan for i in range(df_banco.shape[0])]
df_banco["listado"] = [np.nan for i in range(df_banco.shape[0])]
df_banco["nr_tweets"] = [np.nan for i in range(df_banco.shape[0])]
df_banco["source"] = ["nan" for i in range(df_banco.shape[0])]

df_banco["data_str"] = df_banco.data
df_banco.data = pd.to_datetime(df_banco.data)

df_banco['tipo_usuario'] = df_banco['usuario'].apply(utils.retorna_tipo_usuario)
df_banco['tweet_limpo'] = df_banco['tweet'].apply(utils.remove_url)
df_banco['tweet_limpo'] = df_banco['tweet_limpo'].apply(utils.corrige_ortografia)
df_banco['tweet_para_traducao'] = df_banco['tweet_limpo']
df_banco['tweet_limpo'] = df_banco['tweet_limpo'].apply(utils.strip_all_entities)
df_banco['tweet_limpo'] = df_banco['tweet_limpo'].apply(utils.remove_numeros)

print("filtrando tweets")
#lista_negra_usuarios = utils.retorna_lista_negra_usuarios()
df_banco = df_banco[~df_banco['usuario'].isin(lista_negra_usuarios)]

df_banco = df_banco[df_banco['tweet'].str.contains('|'.join(palavras_chave))]
#lista_negra_expressoes = utils.retorna_lista_negra_expressoes()
df_banco = df_banco[~df_banco['tweet'].str.contains('|'.join(lista_negra_expressoes)) ]

df_banco.data = df_banco.data + np.timedelta64(-3,'h') # corrige o fuso horário

df_banco2 = df_banco[['usuario', 'localidade', 'description', 'seguidores', 'amigos',
       'favoritos', 'listado', 'nr_tweets', 'data', 'likes', 'retweets',
       'replies', 'tweet', 'source', 'tipo_usuario', 'tweet_limpo',
       'tweet_para_traducao']]

df_banco2 = df_banco2[~df_banco2.index.isin(df2.index.values.tolist())]

df2 = pd.concat([df2,df_banco2])
df2 = df2.drop_duplicates()

print("criando base da rede de usuários")
g_ids = []
g_datas = []
g_usuario1 = []
g_usuario2 = []
g_likes = []
g_retweets = []
g_tipo_link = []

#lista_index = df_g.id.unique().tolist()

for i in df_banco.index:
#    if i not in lista_index:
    hashtag = df_banco.hashtags[i]
    if hashtag != '':
        for h in hashtag.split(' '):
            g_ids.append(i)
            g_datas.append(df_banco.data_str[i])
            g_usuario1.append(df_banco.usuario[i])
            g_usuario2.append(h[1:])
            g_likes.append(df_banco.likes[i])
            g_retweets.append(df_banco.retweets[i])
            g_tipo_link.append("hashtag")

for i in df_banco.index:
#    if i not in lista_index:
    mention = df_banco.mentions[i]
    if mention != '':
        for m in mention.split(' '):
            g_ids.append(i)
            g_datas.append(df_banco.data_str[i])
            g_usuario1.append(df_banco.usuario[i])
            g_usuario2.append(m[1:])
            g_likes.append(df_banco.likes[i])
            g_retweets.append(df_banco.retweets[i])
            g_tipo_link.append("menção")

df_g_aux = pd.DataFrame({'id':g_ids, 
                   'usuario1':g_usuario1,
                   'usuario2':g_usuario2,
                   'likes':g_likes,
                   'retweets':g_retweets,
                   'data':g_datas,
                   'tipo':g_tipo_link})

df_g_aux = df_g_aux.drop_duplicates()
df_g = pd.concat([df_g, df_g_aux])
df_g = df_g.drop_duplicates()
df_g = df_g.reset_index()
del df_g['index']
    
if df_g.id.dtype != np.int64:
    print('Tipo do id do dataframe df é',df.id.dtype)
    raise Exception("Coluna id do dataframe df não é int64!!")
            
del df_g_aux #, lista_index


"""
###############################################################################
# BLOCO LÉXICO
###############################################################################
"""
#print("Bloco Léxico PT")

#df2['P_oplexicon3'] = df2['tweet_limpo'].apply(utils.oplexicon3_P)
#df2['N_oplexicon3'] = df2['tweet_limpo'].apply(utils.oplexicon3_N)
#df2['sent_oplexicon3_ABP'] = df2['tweet_limpo'].apply(utils.oplexicon3_Absolute_Proportional_Difference)
#df2['sent_oplexicon3_RPD'] = df2['tweet_limpo'].apply(utils.oplexicon3_Relative_Proportional_Difference)
#df2['sent_oplexicon3_Log'] = df2['tweet_limpo'].apply(utils.oplexicon3_Logit_scale)

#df2['tweet_lema'] = df2['tweet_para_traducao'].apply(utils.retorna_lemas)

#df2['P_wordnetaffectbr'] = df2['tweet_lema'].apply(utils.wordnetaffectbr_P)
#df2['N_wordnetaffectbr'] = df2['tweet_lema'].apply(utils.wordnetaffectbr_N)
#df2['sent_wordnetaffectbr_ABP'] = df2['tweet_lema'].apply(utils.wordnetaffectbr_Absolute_Proportional_Difference)
#df2['sent_wordnetaffectbr_RPD'] = df2['tweet_lema'].apply(utils.wordnetaffectbr_Relative_Proportional_Difference)
#df2['sent_wordnetaffectbr_Log'] = df2['tweet_lema'].apply(utils.wordnetaffectbr_Logit_scale)


#df2['P_LIWC'] = df2['tweet_limpo'].apply(utils.LIWC_P)
#df2['N_LIWC'] = df2['tweet_limpo'].apply(utils.LIWC_N)
#df2['sent_LIWC_ABP'] = df2['tweet_limpo'].apply(utils.LIWC_Absolute_Proportional_Difference)
#df2['sent_LIWC_RPD'] = df2['tweet_limpo'].apply(utils.LIWC_Relative_Proportional_Difference)
#df2['sent_LIWC_Log'] = df2['tweet_limpo'].apply(utils.LIWC_Logit_scale)

#df2['P_SentiLex'] = df2['tweet_limpo'].apply(utils.SentiLex_P)
#df2['N_SentiLex'] = df2['tweet_limpo'].apply(utils.SentiLex_N)
#df2['sent_SentiLex_ABP'] = df2['tweet_limpo'].apply(utils.SentiLex_Absolute_Proportional_Difference)
#df2['sent_SentiLex_RPD'] = df2['tweet_limpo'].apply(utils.SentiLex_Relative_Proportional_Difference)
#df2['sent_SentiLex_Log'] = df2['tweet_limpo'].apply(utils.SentiLex_Logit_scale)


#df2['Formality'] = df2['tweet_para_traducao'].apply(utils.retorna_formality)
#df2['Lexical_density'] = df2['tweet_para_traducao'].apply(utils.retorna_lexical_density)
#df2['Lexical_diversity'] = df2['tweet_para_traducao'].apply(utils.lexical_diversity)
#df2['ARI'] = df2['tweet_para_traducao'].apply(utils.ARI)
#df2['CLI'] = df2['tweet_para_traducao'].apply(utils.CLI)

"""
###############################################################################
# TRADUCAO
###############################################################################
"""

print("Tradução!")

# USAR ESSE CÓDIGO QUANDO RODAR DA PRIMEIRA VEZ

#tweet_ingles = []
#textblob_polarity = []
#textblob_subjectivity = []
#
#for tweet in df2['tweet_para_traducao'].to_list()[:5]:
#    blob = TextBlob(tweet).translate(to='en')
#    tweet_ingles.append(str(blob))
#    textblob_polarity.append(blob.polarity)
#    textblob_subjectivity.append(blob.subjectivity)
#    time.sleep(10)
#
#df_tweet_ingles = pd.DataFrame({'tweet_ingles':tweet_ingles, 
#                                'textblob_polarity':textblob_polarity,
#                                'textblob_subjectivity':textblob_subjectivity},
#                                index = df2.index[:5])
#
#df_tweet_ingles.to_pickle('dados\\df_tweet_ingles.pkl')

#USAR ESSE CÓDIGO NAS DEMAIS VEZES

df_tweet_ingles = pd.read_pickle('dados\\df_tweet_ingles.pkl')

df3 = df2.merge(df_tweet_ingles, how='left', left_index=True, right_index=True)

df_aux = df3[df3.isnull().any(axis=1)]
df_aux = df_aux.drop(columns=['tweet_ingles','textblob_polarity','textblob_subjectivity'])
df_aux = df_aux.drop_duplicates()

df_aux = df_aux[df_aux['data']>"2020-10-01 00:00:00+00:00"]

tweet_ingles = []
textblob_polarity = []
textblob_subjectivity = []

print(df_aux.shape[0]," novos tweets")

for tweet in df_aux['tweet_para_traducao'].to_list():
    try:
        blob = TextBlob(tweet).translate(to='en')
        tweet_ingles.append(str(blob))
        textblob_polarity.append(blob.polarity)
        textblob_subjectivity.append(blob.subjectivity)
        time.sleep(9)
    except Exception as e:
        print(e)
        print(tweet)
        continue

df_tweet_ingles_aux = pd.DataFrame({'tweet_ingles':tweet_ingles, 
                                'textblob_polarity':textblob_polarity,
                                'textblob_subjectivity':textblob_subjectivity},
                                index = df_aux.index[:len(tweet_ingles)])

df_tweet_ingles = pd.concat([df_tweet_ingles , df_tweet_ingles_aux ])

if df_tweet_ingles.index.dtype != np.int64:
    print('Tipo do id do dataframe df_tweet_ingles é',df.id.dtype)
    raise Exception("Index do dataframe df_tweet_ingles não é int64!!")


df_tweet_ingles.to_pickle('dados\\df_tweet_ingles.pkl')
del df_aux, df_tweet_ingles_aux

df3 = df2.merge(df_tweet_ingles, how='left', left_index=True, right_index=True)
df3 = df3.drop_duplicates()


"""
###############################################################################
# BLOCO LÉXICO INGLÊS
###############################################################################
"""

#print("Bloco Léxico EN")

# salva csv para calcular sentimentos no R
#df3['tweet_ingles_limpo'] = df3['tweet_ingles'].apply(utils.remove_url)
#df3['tweet_ingles_limpo'] = df3['tweet_ingles_limpo'].apply(utils.strip_all_entities)
#df3['tweet_ingles_limpo'] = df3['tweet_ingles_limpo'].apply(utils.remove_numeros) 
#df3['tweet_ingles_limpo'].to_frame().to_csv('dados\\df_tweet_ingles_limpo.csv', index = True)

# RODAR O SCRIPT DO R (R_sentiment_analysis.R) PARA CALCULAR OS SENTIMENTOS DOS DEMAIS DICIONÁRIOS



#df3['vader_neg'] = df3['tweet_ingles'].apply(utils.vader_polarity_neg)
#df3['vader_neu'] = df3['tweet_ingles'].apply(utils.vader_polarity_neu)
#df3['vader_pos'] = df3['tweet_ingles'].apply(utils.vader_polarity_pos)
#df3['vader_compound'] = df3['tweet_ingles'].apply(utils.vader_polarity_compound)

#df3['Formality_en'] = df3['tweet_ingles'].apply(utils.retorna_formality_en)
#df3['Lexical_density_en'] = df3['tweet_ingles'].apply(utils.retorna_lexical_density_en)
#df3['ARI_en'] = df3['tweet_ingles'].apply(utils.ARI)
#df3['CLI_en'] = df3['tweet_ingles'].apply(utils.CLI)

#df3['pattern_sentiment'] = df3['tweet_ingles'].apply(lambda x: sentiment(x)[0])
#df3['pattern_subjectivity'] = df3['tweet_ingles'].apply(lambda x: sentiment(x)[1])


#"""
#Importa sentimentos calculados no R
#"""

#df_R = pd.read_csv("dados\\df_tweet_R_sentiments.csv", sep = ";", 
#                   dtype={'Unnamed: 0':np.int32, 'id':np.int64, 'R_sent_afinn':np.float64, 
#                          'R_sent_bing':np.float64, 'R_sent_loughrang':np.float64,
#                          'R_sent_nrc':np.float64, 'R_Sent_HarvardIV':np.float64, 
#                          'R_Neg_HarvardIV':np.float64, 'R_Pos_HarvardIV':np.float64,
#                          'R_Sent_Henry':np.float64, 'R_Neg_Henry':np.float64, 
#                          'R_Pos_Henry':np.float64, 'R_Sent_Loughran2':np.float64,
#                          'R_Neg_Loughran2':np.float64, 'R_Pos_Loughran2':np.float64, 
#                          'R_Uncertainty_Loughran2':np.float64,'R_Sent_QDAP':np.float64, 
#                          'R_Neg_QDAP':np.float64, 'R_Pos_QDAP':np.float64},
#                   decimal = b",")
#df_R.set_index('id',inplace=True)
#del df_R['Unnamed: 0']
#
#
#df3 = df3.merge(df_R, how='left', left_index=True, right_index=True)
#df3 = df3.drop_duplicates()

"""
## INCLUI COLUNA DE ROTULACAO MANUAL
"""

df_rotulacao_manual_aux = pd.read_pickle('dados\\df_rotulacao_manual.pkl')

df3 = df3.merge(df_rotulacao_manual_aux , how='left', left_index=True, right_index=True)

df3 = df3.drop_duplicates()
df3 = df3[~df3['sent_manual'].isin(['D'])] #remove tweets marcadaos com D
df3.to_pickle('dados\\df_processado.pkl')

#df inclui os tweets com retweet e df nao tem o id como index
df_g2 = df_g[df_g['id'].isin(df['id']) ].copy()

df_g2['tipo_usuario1'] = df_g2['usuario1'].apply(utils.retorna_tipo_usuario)
df_g2['tipo_usuario2'] = df_g2['usuario2'].apply(utils.retorna_tipo_usuario)

df_g2.to_pickle('dados\\df_tweet_grafo.pkl')

df4 = df3[['usuario', 'localidade', 'seguidores', 'data', 'source','likes', 'retweets',
       'tweet','tweet_limpo', 'tipo_usuario', #'sent_oplexicon3_ABP',
       #'sent_wordnetaffectbr_ABP', 
       #'sent_LIWC_ABP', 
       #'sent_SentiLex_ABP', 'textblob_polarity', 
       #'vader_compound', #'pattern_sentiment', 'R_sent_afinn',
       #'R_sent_bing', 'R_sent_loughrang', 'R_sent_nrc', 'R_Sent_HarvardIV',
       #'R_Sent_Henry', 'R_Sent_Loughran2', 'R_Sent_QDAP', 
       'sent_manual']].copy()

df4 = df4.drop_duplicates()
df4.to_pickle('dados\\df_processado_simplificado.pkl')


"""
###############################################################################
# TRATAMENTO DE LINKS
###############################################################################
"""
print("Tratamento de Links")

import requests

#df = pd.read_pickle('dados\\df_tweet_completo.pkl')
#df = pd.read_pickle('dados\\df_processado.pkl')

# PRIMEIRA VEZ
# dict_url = {}
# shorturl = 'http://bit.ly/SQo4Y'
# r0 = requests.get(shorturl, verify=True)
# dict_url[shorturl] = r0.url
# with open('dados\\dict_url.pickle','wb') as f:
#     pickle.dump(dict_url, f)

# DEMAIS VEZES
pickle_in = open("dados\\dict_url.pickle","rb")
dict_url = pickle.load(pickle_in)

lista_urls = df.tweet.str.extractall(r'(http\S+)')[0].values.tolist()
lista_urls = list(set(lista_urls))
lista_urls = utils.Diff(lista_urls,list(dict_url.keys()))
print(len(lista_urls),'urls para ler.')
print(len(dict_url),'urls cadastradas.')


for shorturl in lista_urls:
    if shorturl not in dict_url.keys():
        try:
            r0 = requests.get(shorturl, verify=True)
            dict_url[shorturl] = r0.url
            time.sleep(1)
        except Exception as e:
            print(shorturl)
            print(e)
            dict_url[shorturl] = "NA"
            continue

with open('dados\\dict_url.pickle','wb') as f:
    pickle.dump(dict_url, f)

print("Número de urls cadastradas:", len(dict_url))

print("Fim do processamento de dados!")
print("Número de Tweets: ",df3.shape[0])
dateTimeObj = datetime.now()
timestampStr = dateTimeObj.strftime("%Y-%m-%d-%H-%M-%S-%f")
print(timestampStr)
