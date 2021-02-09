import pandas as pd
import sqlite3
import numpy as np

import sys
sys.path.insert(1, '..')
import utils

###############################################################################
## PEGA DADOS PROCESSADOS 
###############################################################################

df = pd.read_pickle('dados\\df_processado.pkl')
df = df[["data","usuario","tweet"]]
df.index = [str(i) for i in df.index.values]
df = df.reset_index() 
df.columns = df.columns
df = df.drop_duplicates()
df.tweet = df.tweet.str.lower()



###############################################################################
## SÉRIE DO TOTAL
###############################################################################

# a list of "1" to count the hashtags
ones = [1]*df['data'].shape[0]
# the index of the series
idx = pd.DatetimeIndex(df['data'])
# Resampling / bucketing
s_h = pd.Series(ones, index=idx).resample('H').sum().fillna(0)


###############################################################################
## SÉRIE DO COPOM
###############################################################################

df_copom = df[df['tweet'].str.contains('|'.join(['copom'])) ]

# a list of "1" to count the hashtags
ones = [1]*df_copom['data'].shape[0]
# the index of the series
idx = pd.DatetimeIndex(df_copom['data'])
# Resampling / bucketing
s_h_copom = pd.Series(ones, index=idx).resample('H').sum().fillna(0)

###############################################################################
## SÉRIE DE INCERTEZA
###############################################################################

lista_palavras_incerteza = ['incerteza', 'incerto', 'incerta', 'crise', 'recessão', 'dúvida', 'hesitação', 'imprecisão', 'indecisão', 'indefinição', 'indeterminação', 'insegurança', 'interrogação', 'inconsistência', 'desconfiança', 'piora']
df_incert = df[df.tweet.str.contains('|'.join(lista_palavras_incerteza))]

# a list of "1" to count the hashtags
ones = [1]*df_incert['data'].shape[0]
# the index of the series
idx = pd.DatetimeIndex(df_incert['data'])
# Resampling / bucketing
s_h_incert = pd.Series(ones, index=idx).resample('H').sum().fillna(0)


###############################################################################
## SÉRIE DE CREDIBILIDADE
###############################################################################

df_cred = df[df.tweet.str.contains('|'.join(['credibilidade']))]

# a list of "1" to count the hashtags
ones = [1]*df_cred['data'].shape[0]
# the index of the series
idx = pd.DatetimeIndex(df_cred['data'])
# Resampling / bucketing
s_h_cred = pd.Series(ones, index=idx).resample('H').sum().fillna(0)


###############################################################################
## SÉRIE DO FOCUS
###############################################################################

df_focus = df[df.tweet.str.contains('|'.join(['focus']))]

# a list of "1" to count the hashtags
ones = [1]*df_focus['data'].shape[0]
# the index of the series
idx = pd.DatetimeIndex(df_focus['data'])
# Resampling / bucketing
s_h_focus = pd.Series(ones, index=idx).resample('H').sum().fillna(0)

###############################################################################
## SÉRIE DE AUTONOMIA
###############################################################################

df_auto = df[df.tweet.str.contains('|'.join(['autonomia']))]

# a list of "1" to count the hashtags
ones = [1]*df_auto['data'].shape[0]
# the index of the series
idx = pd.DatetimeIndex(df_auto['data'])
# Resampling / bucketing
s_h_auto = pd.Series(ones, index=idx).resample('H').sum().fillna(0)


###############################################################################
## SÉRIE DE SENTIMENTO
###############################################################################

import joblib
import spacy
import re
import pickle
from sklearn.feature_extraction.text import TfidfVectorizer

corpus = df.tweet.to_list().copy()
#cleaning
for i in range(len(corpus)):
    corpus[i] = utils.corrige_ortografia(corpus[i])
    corpus[i]=corpus[i].lower()
    corpus[i] = re.sub(r'http\S+', ' ', corpus[i]) #urls (tem que ser antes dos outros)
    corpus[i] = re.sub('\n', ' ', corpus[i]) #newline
    corpus[i] = re.sub('[0-9]+', ' ', corpus[i]) #números
    corpus[i] = re.sub(r'[^\w\s]',' ',corpus[i]) #pontuação
    corpus[i] = re.sub('º','',corpus[i])
    corpus[i] = re.sub('ª','',corpus[i])
    corpus[i] = re.sub('@','',corpus[i])
    corpus[i] = re.sub('#','',corpus[i])
#lemmatization
nlp = spacy.load('pt_core_news_lg', disable=['parser', 'ner'])
for i in range(0,len(corpus)): # varre a lista de textos
    doc = nlp(corpus[i]) # executa um processamento de texto
    corpus[i]=" ".join([token.lemma_ for token in doc])

corpus = utils.altera_expressoes(corpus)
#stopwords
mystopwords=utils.mystopwords
for i in range(0,len(corpus)): # varre a lista de textos
    words=corpus[i].split(" ") # separa o texto em palavras
    words_new = [w for w in words if w not in mystopwords] #remove as stop words
    corpus[i] = ' '.join(words_new)

df['tweet_limpo'] = corpus
tfidf_vocab = pickle.load(open("dados\\tfidf-vocab-full", 'rb'))
tfidf_vect = TfidfVectorizer(analyzer='word', token_pattern=r'\w{1,}',binary=False, 
                              vocabulary=tfidf_vocab)
tfidf_vect.fit(df['tweet_limpo']) # treina o objeto nos textos processados
xvalid_tfidf = tfidf_vect.transform(df['tweet_limpo'])
classifier = joblib.load(open("dados\\class-SVM-tfidf-full", 'rb'))
probabilities = classifier.predict_proba(xvalid_tfidf)
df['prob_C'] = probabilities[:,0]
df['prob_N'] = probabilities[:,1]

idx = pd.DatetimeIndex(df['data'])
s_h_prob_C = df.prob_C
s_h_prob_C.index = idx
s_h_prob_C = s_h_prob_C.resample('H').mean().fillna(np.nan)

idx = pd.DatetimeIndex(df['data'])
s_h_prob_N = df.prob_N
s_h_prob_N.index = idx
s_h_prob_N = s_h_prob_N.resample('H').mean().fillna(np.nan)

# -----------------------------------------------------------------------------
predictions = classifier.predict(xvalid_tfidf)
df['SVM_tfidf'] = predictions
df['SVM_tfidf'] = df['SVM_tfidf'].apply(lambda x: "N" if x==1 else "C")

df_qtd_C = df[df.SVM_tfidf=='C']

# a list of "1" to count the hashtags
ones = [1]*df_qtd_C['data'].shape[0]
# the index of the series
idx = pd.DatetimeIndex(df_qtd_C['data'])
# Resampling / bucketing
s_h_qtd_C = pd.Series(ones, index=idx).resample('H').sum().fillna(0)


###############################################################################
## SALVA SÉRIES
###############################################################################

df_series = pd.DataFrame({'total' : s_h,
                          'copom' : s_h_copom,
                         'incerteza' : s_h_incert,
                         'credibilidade' : s_h_cred,
                         'focus' : s_h_focus,
                         'autonomia' : s_h_auto,
                         'prob_C': s_h_prob_C,
                         'prob_N': s_h_prob_N,
                         'qtd_C':s_h_qtd_C})

df_series.to_csv('dados\\series_temporais_tweets_v3.csv')