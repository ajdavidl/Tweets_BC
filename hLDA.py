import pandas as pd
import tomotopy as tp
import spacy
import re
import utils


Mystopwords = utils.mystopwords

df = pd.read_pickle('dados\\df_processado.pkl')
df = df[~df['sent_manual'].isin(['D'])] #remove tweets anotados com D (delete)
df = df[~df['usuario'].isin(['BancoCentralBR'])] #remove BancoCentralBR

#df.shape
df=df[df['tweet_limpo'].str.len()>10]
#df.shape

corpus = df['tweet_limpo'].tolist()

for i in range(0,len(corpus)):
    corpus[i]=corpus[i].lower()
    corpus[i] = re.sub('[0-9]+', '', corpus[i]) #remove numbers
    corpus[i] = re.sub(r'[^\w\s]','',corpus[i]) #remove punctuation
    corpus[i] = re.sub('\n','',corpus[i]) #remove \n - newline

    
#corrige expressões comuuns 
corpus = utils.altera_expressoes(corpus)



#REMOÇÃO DE STOP WORDS
for i in range(0,len(corpus)): # varre a lista de textos
    words=corpus[i].split(" ") # separa o texto em palavras
    words_new = [w for w in words if w not in Mystopwords] #remove as stop words
    corpus[i] = ' '.join(words_new) # concantena as palavras novamente

#LEMATIZAÇÃO
#carrega modelo pré-treinado para processar textos em português. Desabilita duas funções que não vamos usar
nlp = spacy.load('pt_core_news_lg', disable=['parser', 'ner'])

for i in range(0,len(corpus)): # varre a lista de textos
    doc = nlp(corpus[i]) # executa um processamento de texto
    corpus[i]=" ".join([token.lemma_ for token in doc]) # substitui o texto anterior por um texto contendo os lemas extraídos

#corrige palavras distorcidas pela lematização
corpus = utils.corrige_lema(corpus)


#REMOÇÃO DE STOP WORDS DE NOVO
for i in range(0,len(corpus)): # varre a lista de textos
    words=corpus[i].split(" ") # separa o texto em palavras
    words_new = [w for w in words if w not in Mystopwords] #remove as stop words
    corpus[i] = ' '.join(words_new) # concantena as palavras novamente

#corrige lemas de novo!
corpus = utils.corrige_lema(corpus)


df['tweet_limpo'] = corpus

#df.shape
df=df[df['tweet_limpo'].str.len()>2]
#df.shape


#corpus_hlda = tp.utils.Corpus(tokenizer=tp.utils.SimpleTokenizer(), stopwords=lambda x: len(x) <= 2 or x in Mystopwords)
#corpus_hlda = tp.utils.Corpus(tokenizer=tp.utils.SimpleTokenizer(), stopwords=Mystopwords)
corpus_hlda = tp.utils.Corpus(tokenizer=tp.utils.SimpleTokenizer())
# data_feeder yields a tuple of (raw string, user data) or a str (raw string)
corpus_hlda.process(df['tweet_limpo'])



mdl = tp.HLDAModel(tw=tp.TermWeight.ONE, 
                   min_cf=10, 
                   min_df=4, 
                   #rm_top=0, 
                   depth=4, 
                   #alpha=0.1, eta=0.01, gamma=0.1, seed=None, 
                   corpus=corpus_hlda, 
                   transform=None)


mdl.train(0)
print(len(mdl.used_vocabs))
if not (df.shape[0] == len(mdl.docs)):
    print('Shape do dataframe é diferente do número de docs do modelo hlda')
    print('Nr docs no df',df.shape[0])
    print('Nr docs no modelo hlda',len(mdl.docs))
    raise Exception("Shape do dataframe é diferente do número de docs do modelo hlda")

#print(len(mdl.used_vocabs))
with open('lista.txt', 'w') as f:
    for item in sorted(mdl.used_vocabs):
        f.write("%s\n" % item)

print('Num docs:', len(mdl.docs), ', Vocab size:', len(mdl.used_vocabs), ', Num words:', mdl.num_words)
print('Removed top words:', mdl.removed_top_words)
for i in range(0, 5000, 10):
    mdl.train(10, workers=6)
    print('Iteration: {}\tLog-likelihood: {}'.format(i, mdl.ll_per_word))
    
print(mdl.depth)

#Save model
mdl.save("models/hLDA.bin", True)

# #for k in range(20,40):
# for k in range(mdl.k):
#     if not mdl.is_live_topic(k): continue
#     print('Topic #{}'.format(k))
#     print('Level', mdl.level(k))
#     #print('Alive',mdl.is_live_topic(k))
#     print('Nr Docs:', mdl.num_docs_of_topic(k))
#     # print('Parent Topics:')
#     # print(mdl.parent_topic(k))
#     # print('Children Topics:')
#     # print(mdl.children_topics(k))
#     for word, prob in mdl.get_topic_words(k):
#         print('\t', word, prob, sep='\t')



#topic_dist, ll = mdl.infer(mdl.docs)

hlda_topics=[]
for i in range(len(mdl.docs)):
    hlda_topics.append(mdl.docs[i].path[-1])

df['hlda_topics'] = hlda_topics

df['hlda_topics'].to_pickle('dados\\df_hlda_topics_10k.pkl')



# for i in range(5000, 10000, 10):
#     mdl.train(10, workers=6)
#     print('Iteration: {}\tLog-likelihood: {}'.format(i, mdl.ll_per_word))
    
# mdl.save("models/hLDA_10k.bin", True)