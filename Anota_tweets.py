
import pandas as pd
import numpy as np
import utils

df2 = pd.read_pickle('dados\\df_processado.pkl')


"""
###############################################################################
# ROTULACAO MANUAL USANDO A JANELA DE VISUALIZAÇÃO DE DADOS DO SPYDER
###############################################################################
"""
#PRIMEIRA VEZ

#df_rotulacao_manual = df[['id', 'usuario', 'data','tweet'] ].copy()
#df_rotulacao_manual.set_index('id', inplace=True)
#df_rotulacao_manual['sent_manual'] = df_rotulacao_manual['tweet'].apply(lambda x: 'nan')
#
##Em relação ao banco central:
## N - neutro
## E - elogio
## S - sugestão
## C - critica
## D - delete-me
## B - usuario é o BC
#
## PARA SALVAR
#df_rotulacao_manual = df_rotulacao_manual['sent_manual']
#df_rotulacao_manual  = df_rotulacao_manual[df_rotulacao_manual.str.contains('N|E|S|C|D|B')]
#df_rotulacao_manual.to_pickle('dados\\df_rotulacao_manual.pkl')


#carrega df_rotulacao_manual.pkl
df_rotulacao_manual_aux = pd.read_pickle('dados\\df_rotulacao_manual.pkl')
df_rotulacao_manual = df2[['usuario','tipo_usuario','description','seguidores', 'data','tweet'] ].copy()

df_rotulacao_manual = df_rotulacao_manual.merge(df_rotulacao_manual_aux, how='left', left_index=True, right_index=True)
df_rotulacao_manual['sent_manual'] = df_rotulacao_manual['sent_manual'].fillna('nan')
df_rotulacao_manual = df_rotulacao_manual.drop_duplicates()

#df_rotulacao_manual = df_rotulacao_manual[df_rotulacao_manual['data']<"2020-01-01"]
#df_rotulacao_manual = df_rotulacao_manual[df_rotulacao_manual['data']>"2018-12-31"]
df_rotulacao_manual = df_rotulacao_manual[df_rotulacao_manual['tweet'].str.contains('|'.join([' pqp',' tnc']))]
#df_rotulacao_manual = df_rotulacao_manual.sample(200)
df_rotulacao_manual  = df_rotulacao_manual[df_rotulacao_manual.sent_manual.str.contains('nan')]

#ROTULAR PELA JANELA DE VISUALIZAÇÃO DE DADOS DO SPYDER

df_rotulacao_manual = df_rotulacao_manual['sent_manual']
df_rotulacao_manual  = df_rotulacao_manual[df_rotulacao_manual.str.contains('N|E|S|C|D|B')]
if df_rotulacao_manual.index.dtype != np.int64:
    print('Tipo do id do dataframe df_rotulacao_manual é',df.id.dtype)
    raise Exception("Index do dataframe df_rotulacao_manual não é int64!!")

df_rotulacao_manual = pd.concat([df_rotulacao_manual_aux, df_rotulacao_manual])
df_rotulacao_manual.to_pickle('dados\\df_rotulacao_manual.pkl')

del df_rotulacao_manual_aux, df_rotulacao_manual


"""
###############################################################################
FUNÇÃO PARA ROTULAR USANDO O PROMPT DO PYTHON COM O ID DO TWEET
###############################################################################
"""



def anota_por_ID(id, sent): 
    df_rotulacao_manual = pd.read_pickle('dados\\df_rotulacao_manual.pkl')
    if id not in df_rotulacao_manual:
        s = pd.Series(sent, index=pd.Index([id]), name = 'sent_manual' )
        df_rotulacao_manual = pd.concat([df_rotulacao_manual, s])
        if df_rotulacao_manual.index.dtype != np.int64:
            print('Tipo do id do dataframe df_rotulacao_manual é',df.id.dtype)
            raise Exception("Index do dataframe df_rotulacao_manual não é int64!!")
        df_rotulacao_manual.to_pickle('dados\\df_rotulacao_manual.pkl')
        print('Salvo: ',id,sent)
    else:
        print(str(id)+" já está anotado na base como: "+df_rotulacao_manual[id])

#EXEMPLO        
#id = 10658204925038592
#sent_manual = 'N'
#anota_por_ID(id, sent_manual)
