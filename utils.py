import re
import string
import pickle
import pandas as pd
import numpy as np
from nltk.tokenize import sent_tokenize
from nltk import word_tokenize, corpus
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from collections import Counter
import spacy

nlp = spacy.load('pt_core_news_sm')
nlp_en = spacy.load('en_core_web_sm')

def remove_url(string):
    if type(string)!=str:
        return(string)
    return(re.sub(r'http\S+', '', string))

def corrige_ortografia(string):
    string = re.sub('alem', 'além', string)
    string = re.sub('akguma', 'alguma', string)
    string = re.sub('aestá','está', string)
    string = re.sub(' asegurar ',' assegurar ', string)
    string = re.sub('babaquisse','babaquice', string)
    string = re.sub(' BCB ',' Banco Central do Brasil ', string)
    string = re.sub(' bcb ',' Banco Central do Brasil ', string)
    string = re.sub(' bancocentralbr ',' Banco Central do Brasil ', string)
    string = re.sub(' BancoCentralBR ',' Banco Central do Brasil ', string)
    string = re.sub(' bancodobrasil ',' Banco do Brasil ', string)
    string = re.sub(' BC ',' Banco Central ', string)
    string = re.sub(' bc ',' Banco Central ', string)
    string = re.sub(' bco ',' banco ', string)
    string = re.sub(' bcos ',' bancos ', string)
    string = re.sub(' Bco ',' Banco ', string)
    string = re.sub(' Bcos ',' Bancos ', string)
    string = re.sub(' bilião ',' bilhão ', string)
    string = re.sub(' BR ',' Brasil ', string)
    string = re.sub(' blz ',' beleza ', string)
    string = re.sub('Campos Neto ', 'Roberto Campos Neto ', string)
    string = re.sub('camposneto ', 'Roberto Campos Neto ', string)
    string = re.sub('kapaz','capaz', string)
    string = re.sub('coloucou','colocou', string)
    string = re.sub('comite','comitê', string)
    string = re.sub('comité','comitê', string)
    string = re.sub('compulsorio','compulsório', string)
    string = re.sub('coravírus','coronavírus',string) 
    string = re.sub('coronaviros','coronavírus',string)
    string = re.sub('coronavirus','coronavírus',string)
    string = re.sub('crecer','crescer', string)
    string = re.sub('crescim ', 'crescimento ', string)
    string = re.sub('crescime ', 'crescimento ', string)
    string = re.sub('crescimen ', 'crescimento ', string)
    string = re.sub('cresimento ', 'crescimento ', string)
    string = re.sub(' crédit ', ' crédito ', string)
    string = re.sub(' credito', ' crédito', string)
    string = re.sub('ctz', 'certeza', string)
    string = re.sub('cãmbio', 'câmbio', string)
    string = re.sub('c/ ', 'com ', string)
    string = re.sub(' cto ', ' curto ', string)
    string = re.sub(' d+ ', ' demais ', string)
    string = re.sub('desvalorizacao', 'desvalorização', string)
    string = re.sub('decisao', 'decisão', string)
    string = re.sub(' deficit ', ' déficit ', string)
    string = re.sub('dificil', 'difícil', string)
    string = re.sub('digitos', 'dígitos', string)
    string = re.sub('disserám', 'disseram', string)
    string = re.sub('divulação', 'divulgação', string)
    string = re.sub('dmais', 'demais', string)
    string = re.sub('dolar', 'dólar', string)
    string = re.sub('dóla ', 'dólar ', string)
    string = re.sub('dólarbrl', 'dólar', string)
    string = re.sub('dolares', 'dólares', string)
    string = re.sub('dollar', 'dólar', string)
    string = re.sub('dove ', 'dovish ', string)
    string = re.sub('dp', 'depois', string)
    string = re.sub('dps', 'depois', string)
    string = re.sub('eh ','é ', string)
    string = re.sub('Eh ','É ', string)
    string = re.sub('Enqto ','Enquanto ', string)
    string = re.sub('enqto ','enquanto ', string)
    string = re.sub('esestá','está', string)
    string = re.sub('Esestá','Está', string)
    string = re.sub('ecobomistas','economistas', string)
    string = re.sub('economico','econômico', string)
    string = re.sub('económico','econômico', string)
    string = re.sub('econômia','economia', string)
    string = re.sub('eletrobras','eletrobrás', string)
    string = re.sub('empossar','empoçar', string)
    string = re.sub('emprestimo','empréstimo', string)
    string = re.sub('emprestimos','empréstimos', string)
    string = re.sub('epoca','época', string)
    string = re.sub('espaco','espaço', string)
    string = re.sub('espresso','expresso', string)
    string = re.sub('estavel','estável', string)
    string = re.sub('expectativ ','expectativa ', string)
    string = re.sub('facil ', 'fácil ', string)
    string = re.sub('factor ', 'fator ', string)
    string = re.sub('gde ', 'grande ', string)
    string = re.sub('grafico ', 'gráfico ', string)
    string = re.sub('gratis ', 'grátis ', string)
    string = re.sub('gnt ', 'gente ', string)
    string = re.sub('hawk ', 'hawkish ', string)
    string = re.sub('hj','hoje', string)
    string = re.sub('Hj','Hoje', string)
    string = re.sub('HJ','HOJE', string)
    string = re.sub('ibov ','ibovespa ', string)
    string = re.sub('idéia','ideia', string)
    string = re.sub('imobiliár ','imobiliária ', string)
    string = re.sub('imoveis','imóveis', string)
    string = re.sub('independencia','independência', string)
    string = re.sub('indice','índice', string)
    string = re.sub('inflacao','inflação', string)
    string = re.sub('inflacão','inflação', string)
    string = re.sub('inflaçao','inflação', string)
    string = re.sub('inflaç ','inflação ', string)
    string = re.sub('inflaçã ','inflação ', string)
    string = re.sub('jairbolsonaro','Bolsonaro', string)
    string = re.sub('jmais','jamais', string)
    string = re.sub('juridico','jurídico', string)
    string = re.sub(' linguage ',' linguagem ', string)
    string = re.sub('liquides','liquidez',string) 
    string = re.sub(' msm ',' mesmo ', string)
    string = re.sub(' midia ',' mídia ', string)
    string = re.sub(' manha ',' manhã ', string)
    string = re.sub(' manteu ',' manteve ', string)
    string = re.sub(' mao ',' mão ', string)
    string = re.sub(' maõs ',' mãos ', string)
    string = re.sub(' materia ',' matéria ', string)
    string = re.sub(' midia ',' mídia ', string)
    string = re.sub(' milhoes ',' milhões ', string)
    string = re.sub(' minima ',' mínima ', string)
    string = re.sub(' minimo ',' mínimo ', string)
    string = re.sub(' monetario ',' monetário ', string)
    string = re.sub(' monetaria ',' monetária ', string)
    string = re.sub(' monetári ',' monetário ', string)
    string = re.sub(' msg ',' mensagem ', string)
    string = re.sub(' msm ',' mesmo ', string)
    string = re.sub(' mt ',' muito ', string)
    string = re.sub(' mta ',' muita ', string)
    string = re.sub(' mtas ',' muitas ', string)
    string = re.sub(' mto ',' muito ', string)
    string = re.sub(' mtos ',' muitos ', string)
    string = re.sub(' nao ',' não ', string)
    string = re.sub(' necessario ',' necessário ', string)
    string = re.sub('ngm','ninguém', string)
    string = re.sub('ninguem','ninguém',string) 
    string = re.sub('nivel','nível', string)
    string = re.sub('numero','número', string)
    string = re.sub(' né ',' não é ', string)
    string = re.sub(' Né ',' Não é ', string)
    string = re.sub(' NÉ ',' não é ', string)
    string = re.sub(' nomeaçõ ',' nomeação ', string)
    string = re.sub(' obg ', ' obrigado ', string)
    string = re.sub(' op. ', ' operações ', string)
    string = re.sub(' op. comp. ', ' operações compromissadas ', string)
    string = re.sub('Oq ', 'O que ', string)
    string = re.sub('oq ', 'o que ', string)
    string = re.sub('otimo ', 'ótimo ', string)
    string = re.sub('papeis', 'papéis', string)
    string = re.sub('parabém', 'parabéns', string)
    string = re.sub('parabens', 'parabéns', string)
    string = re.sub('percentu ', 'percentual ', string)
    string = re.sub('petrobras', 'petrobrás', string)
    string = re.sub('pgto', 'pagamento', string)
    string = re.sub('polít ', 'política ', string)
    string = re.sub('políti ', 'política ', string)
    string = re.sub('polític ', 'política ', string)
    string = re.sub('possivel', 'possível', string)
    string = re.sub('precificarr ', 'precificar ', string)
    string = re.sub('precificarção', 'precificação', string)
    string = re.sub('preco', 'preço', string)
    string = re.sub('premio', 'prêmio', string)
    string = re.sub('pressao', 'pressão', string)
    string = re.sub('preve ', 'prevê ', string)
    string = re.sub('previsao', 'previsão', string)
    string = re.sub('preç ', 'preço ', string)
    string = re.sub('projecao ', 'projeção ', string)
    string = re.sub('projeç ', 'projeção ', string)
    string = re.sub('projeçã ', 'projeção ', string)
    string = re.sub(' proprio ', ' próprio ', string)
    string = re.sub(' proxima ', ' próxima ', string)
    string = re.sub(' proximo ', ' próximo ', string)
    string = re.sub(' publico', ' público', string)
    string = re.sub(' plo ', ' pelo ', string)
    string = re.sub(' poupanca ', ' poupança ', string)
    string = re.sub(' pra ',' para ', string)
    string = re.sub(' Pra ',' Para ', string)
    string = re.sub(' pzo ', ' prazo ', string)
    string = re.sub(' p/ ',' para ', string)
    string = re.sub(' p ',' para ', string)
    string = re.sub(' pro ',' para o ', string)
    string = re.sub(' Pro ',' Para o ', string)
    string = re.sub('pq ','por que ', string)
    string = re.sub('pqp ','puta que pariu ', string)
    string = re.sub('pqq ','por que que ', string)
    string = re.sub('qd ','quando ',string)
    string = re.sub('qdo ','quando ',string)
    string = re.sub('Qdo ','Quando ',string)
    string = re.sub('qdo ','quando ',string)
    string = re.sub('qnd ','quando ',string)
    string = re.sub('qndo ','quando ',string)
    string = re.sub(' q ', ' que ', string)
    string = re.sub(' qo ', ' que o ', string)
    string = re.sub('qlqr ', 'qualquer ', string)
    string = re.sub('qm ', 'quem ', string)
    string = re.sub('qq ', 'qualquer ', string)
    string = re.sub('Qq ', 'Qualquer ', string)
    string = re.sub('qqer ', 'qualquer ', string)
    string = re.sub('Qto ','Quanto ',string)
    string = re.sub('qto ','quanto ',string)
    string = re.sub('qria ','queria ',string)
    string = re.sub('RCN ', 'Roberto Campos Neto ', string)
    string = re.sub('RC Neto ', 'Roberto Campos Neto ', string)
    string = re.sub('reducao', 'redução', string)
    string = re.sub('reduçã ', 'redução ', string)
    string = re.sub('relativamen ', 'relativamente ', string)
    string = re.sub('relatorio', 'relatório', string)
    string = re.sub('relatóri ', 'relatório ', string)
    string = re.sub('relatóro ', 'relatório ', string)
    string = re.sub('repercussao ', 'repercussão ', string)
    string = re.sub('reporter ', 'repórter ', string)
    string = re.sub('repórt ', 'repórter ', string)
    string = re.sub('repórte ', 'repórter ', string)
    string = re.sub(' responsavel ', 'responsável ', string)
    string = re.sub(' reu ', ' réu ', string)
    string = re.sub(' reuniao ', ' reunião ', string)
    string = re.sub(' reuniã ', ' reunião ', string)
    string = re.sub('saida ', 'saída ', string)
    string = re.sub('SQN ', 'só que não ', string)
    string = re.sub('sqn ', 'só que não ', string)
    string = re.sub('superavit ', 'superávit ', string)
    string = re.sub('tambem ', 'também ', string)
    string = re.sub('també ', 'também ', string)
    string = re.sub(' tamo ', ' estamos ', string)
    string = re.sub(' tava ', ' estava ', string)
    string = re.sub('tít púb', 'títulos públicos', string)
    string = re.sub('TN ','Tesouro Nacional ', string)
    string = re.sub(' cê ',' você ', string)
    string = re.sub('vc ','você ', string)
    string = re.sub('Vc ','Você ', string)
    string = re.sub('vcs ','vocês ', string)
    string = re.sub('vctos ','vencimentos ', string)
    string = re.sub('vcto ','vencimento ', string)
    string = re.sub(' ñ ',' não ',string)
    string = re.sub(' n ',' não ',string)
    string = re.sub('td ','tudo ',string)
    string = re.sub('tô ','estou ',string)
    string = re.sub('Tô ','Estou ',string)
    string = re.sub(' tá ',' está ',string)
    string = re.sub(' ta ',' está ',string)
    string = re.sub(' Tá ',' Está ',string)
    string = re.sub('tb ','também ', string)
    string = re.sub('tbm ','também ', string)
    string = re.sub('tbém ','também ', string)
    string = re.sub('tbem ','também ', string)
    string = re.sub('tendencia ','tendência ', string)
    string = re.sub('titulo','título', string)
    string = re.sub('tombar','tombo', string)
    string = re.sub('trilhao','trilhão', string)
    string = re.sub('trilhoes','trilhões', string)
    string = re.sub('ultimo','último', string)
    string = re.sub('unica','única', string)
    string = re.sub('varios','vários', string)
    string = re.sub('veem','ver', string)
    string = re.sub('video','vídeo', string)
    string = re.sub('vies','viés', string)
    string = re.sub('voce','você', string)
    string = re.sub('nao','não', string)
    string = re.sub('Nao','Não', string)
    string = re.sub('kct','cacete', string)
    string = re.sub(' pota ',' puta ', string)
    string = re.sub('forca','força',string)
    string = re.sub('dolar','dólar',string)
    string = re.sub('dolares','dólares',string)
    string = re.sub('sera','será',string)
    string = re.sub('meestá','me está',string)
    string = re.sub('loco','louco',string)
    string = re.sub('Sdds','Saudades',string)
    string = re.sub('sdds','saudades',string)
    string = re.sub('mineconomia','ministério da economia',string) 
    string = re.sub('politica','política',string) 
    string = re.sub('monetaria','monetária',string) 
    string = re.sub('economica','econômica',string) 
    return(string)


def strip_all_entities(text):
    if type(text)!=str:
        return(text)
    text = re.sub('“','',text)
    text = re.sub('”','',text)
    text = re.sub('"','',text)
    entity_prefixes = ['@','#']
    for separator in  string.punctuation:
        if separator not in entity_prefixes :
            text = text.replace(separator,' ')
    words = []
    for word in text.split():
        word = word.strip()
        if word:
            if word[0] not in entity_prefixes:
                words.append(word)
    return ' '.join(words)

def strip_html_tags(text):
    p = re.compile(r'<.*?>')
    return p.sub('', text)

def remove_numeros(string):
    if type(string)!=str:
        return(string)
    string = re.sub('[0-9]+','',string)
    return(string)

def retorna_tipo_usuario(usuario):
    lista_jornais = ['BandJornalismo','BloombergBrasil','Estadao','EstadaoEconomia','FolhaPainel','folha_poder',
                     'ForbesBR','GloboNews','Globo_Rural','JornalOGlobo','JovemPanNews','OGlobo_Economia',
                     'ReutersLatam','UOL','UOLEconomia','VEJA','correio','epocanegocios','exame','recordtvoficial',
                     'folha','folha_mercado','g1','g1economia','infomoney','jornal_cultura','ReutersBrasil',
                     'jornalnacional','jornalodia','opaisonline','portaldaband','radiobandnewsfm','jornaldarecord',
                     'valoreconomico','valorinveste','OGloboAnalitico','rodaviva','portalR7','CNNBrBusiness',
                     'DiarioPE','elpais_brasil','CNNBrasil','jc_pe','UOLNoticias','CBNoficial','istoe_dinheiro',
                     'dw_brasil','sbtjornalismo','SBTonline','RevistaISTOE','sbtnointerior','cbnrecife','recordnews']

    #'OMITIDO POR CAUSA DAS REGRAS DE PRIVACIDADE DO TWITTER.'
    lista_blogs_jornais_menores = ["?"]

    #'OMITIDO POR CAUSA DAS REGRAS DE PRIVACIDADE DO TWITTER.'
    lista_jornalistas = ["??"] 

    #'OMITIDO POR CAUSA DAS REGRAS DE PRIVACIDADE DO TWITTER.'
    lista_economistas = ["???"] 

    lista_governo = ['BancoCentralBR','SenadoFederal','TesouroNacional','agenciabrasil',
                     'avozdobrasil','govbr','proconspoficial','tvbrasilgov','tvcamara',
                     'tvsenado','planalto','IFIBrasil','IphanGovBr','RadioSenado','GovernoMA',
                     'camaradeputados','MinEconomia','RadioJustica','casadamoedabr','TRE_RS',
                     'Mapa_Brasil','casacivilbr','justicafederal','secomvc','EconomiaSepec']

    #'OMITIDO POR CAUSA DAS REGRAS DE PRIVACIDADE DO TWITTER.'
    lista_consultorias = ['????']
    
    lista_bancos_corretoras_bolsa = ['ADVFNBrasil','BTGPDigital','FEBRABAN','genialinveste',
                                     'itaucorretora','modalmais','personnalite','xpinvestimentos','itau',
                                     'picpay','BancodoBrasil','Bancointer','unicredrs','ativacorretora',
                                     'Caixa','meuBMG','nubank','SICOOB_oficial','cresoloficial','ricocomvc',
                                     'MeuTimaoBMG','SumUp_BR','Easynvest']

    #'OMITIDO POR CAUSA DAS REGRAS DE PRIVACIDADE DO TWITTER.'
    lista_políticos = ['?????']

    #'OMITIDO POR CAUSA DAS REGRAS DE PRIVACIDADE DO TWITTER.'
    lista_instituicoes = ['??????']
    if usuario in lista_jornais:
        return("jornal")
    elif usuario in lista_blogs_jornais_menores:
        return("jornal2")
    elif usuario in lista_economistas:
        return("economista")
    elif usuario in lista_jornalistas:
        return("jornalista")
    elif usuario in lista_governo:
        return("governo")
    elif usuario in lista_consultorias:
        return("consultoria")
    elif usuario in lista_bancos_corretoras_bolsa:
        return("banco")
    elif usuario in lista_políticos:
        return("politico")
    elif usuario in lista_instituicoes:
        return("instituicao")
    else:
        return("cidadao")

def compila_localidade(text):
    if type(text)!=str:
        return(text)
    if bool(re.search('(S|s)(ã|a)o (P|p)aulo', text)):
        return("São Paulo")
    elif bool(re.search('SP', text)):
        return("São Paulo")
    elif bool(re.search('(R|r)io de (J|j)aneiro', text)):
        return("Rio de Janeiro")
    elif bool(re.search('RJ', text)):
        return("Rio de Janeiro")
    elif text == "Rio":
        return("Rio de Janeiro")
    elif bool(re.search('(B|b)ras(í|i)lia', text)):
        return("Brasília")
    elif bool(re.search('(R|r)(e|é)cife', text)):
        return("Recife")
    elif bool(re.search('(P|p)orto (A|a)legre', text)):
        return("Porto Alegre")
    elif bool(re.search('(B|b)elo (H|h)orizonte', text)):
        return("Belo Horizonte")        
    elif bool(re.search('(M|m)anaus', text)):
        return("Manaus")
    elif bool(re.search('(F|f)ortaleza', text)):
        return("Fortaleza")
    elif bool(re.search('(C|c)uritiba', text)):
        return("Curitiba")
    elif bool(re.search('(B|b)el(é|e)m', text)):
        return("Belém")
    elif bool(re.search('Praia Grande', text)):
        return("Praia Grande")
    elif bool(re.search('Minas Gerais', text)):
        return("Minas Gerais")
    elif bool(re.search('Ourinhos', text)):
        return("Ourinhos")
    elif bool(re.search('(B|b)ra(s|z)il', text)):
        return("Brasil")
    elif bool(re.search('(N|n)ew (Y|y)ork', text)):
        return("Nova Iorque")
    elif bool(re.search('(W|w)ashington', text)):
        return("Washington")
    elif bool(re.search('mises', text)):
        return("Brasil")
    elif bool(re.search('Conde de Linhares', text)):
        return("Belo Horizonte")
    elif bool(re.search('Pessoa', text)):
        return("João Pessoa")
    elif bool(re.search('Contagem', text)):
        return("Contagem")
    elif bool(re.search('São João de Meriti', text)):
        return("São João de Meriti")
    elif bool(re.search('Lisbon', text)):
        return("Lisboa")
    elif bool(re.search('Chicago', text)):
        return("Chicago")
    elif bool(re.search('Franconia', text)):
        return("Franconia")
    elif bool(re.search('Lewsiburg', text)):
        return("Lewsiburg")
    elif bool(re.search('Cambridge', text)):
        return("Cambridge")
    elif bool(re.search('Miami', text)):
        return("Miami")
    elif bool(re.search('Salvador', text)):
        return("Salvador")
    elif bool(re.search('Vitória', text)):
        return("Vitória")
    elif bool(re.search('Finanças', text)):
        return("")
    elif bool(re.search('Rua da Assembl', text)):
        return("Rio de Janeiro")
    elif bool(re.search('London', text)):
        return("Londres")
    elif bool(re.search('Campo Grande', text)):
        return("Campo Grande")
    elif bool(re.search("Lat. 05º 05' Long. 42º 48'", text)):
        return("Teresina")
    elif bool(re.search('Laconia', text)):
        return("Laconia")
    elif bool(re.search('(G|g)oi(â|a)nia', text)):
        return("Goiânia")
    elif bool(re.search('Marte', text)):
        return("Não disponível")
    elif text=='' :
        return("Não disponível")
    elif text==' ' :
        return("Não disponível")
    else:
        return(text)
        
def Diff(li1, li2): 
    """
    Difference between two lists
    In this method we convert the lists into sets explicitly and then simply 
    reduce one from the other using the subtract operator. 
    https://www.geeksforgeeks.org/python-difference-two-lists/
    """
    return (list(set(li1) - set(li2))) 



"""
Opinion Lexicon
"""

df_oplexicon3 = pd.read_csv('dados\\dicionarios\\oplexicon_v3.0\\lexico_v3.0.txt',
                            header=None)
df_oplexicon3.columns = ["palavra", "tag", "polaridade", "c"]
df_oplexicon3 = df_oplexicon3.drop(columns=['tag','c'])
df_oplexicon3.set_index('palavra', inplace=True)
dic_oplexicon3 = df_oplexicon3.to_dict()
dic_oplexicon3 = dic_oplexicon3['polaridade']


dic_oplexicon3['torrados'] = -1
dic_oplexicon3['afinar'] = [0, 0]
dic_oplexicon3['inútil'] = -1
dic_oplexicon3['queda'] = -1
dic_oplexicon3['caem'] = -1
dic_oplexicon3['cagada'] = -1
dic_oplexicon3['pqp'] = -1
dic_oplexicon3['parabéns'] = 1


def retorna_polaridade(dic_lex, palavra):
    """
    dic_lex é o dicionário contendo as polaridades
    """
    try:
        pol = dic_lex[palavra]
        if type(pol) == pd.core.series.Series: #tem palavras com mais de uma ocorrência, nesse caso o retorno é uma serie
            return(pol[0]) 
        else:
            return(pol)
    except:
        return(0)

def oplexicon3_retorna_polaridade(palavra):
    """
    dic_lex é o dicionário contendo as polaridades
    """
    dic_lex =  dic_oplexicon3
    try:
        pol = dic_lex[palavra]
        if type(pol) == pd.core.series.Series: #tem palavras com mais de uma ocorrência, nesse caso o retorno é uma serie
            return(pol[0]) 
        else:
            return(pol)
    except:
        return(0)


#https://stackoverflow.com/questions/33543446/what-is-the-formula-of-sentiment-calculation
def oplexicon3_Absolute_Proportional_Difference(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    O = len(string)
    for w in string:
        pol = retorna_polaridade(dic_oplexicon3,w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    if O == 0:
        sent = 0
    else:
        sent = (P - N)/O
    return(sent)
    
def oplexicon3_Relative_Proportional_Difference(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    for w in string:
        pol = retorna_polaridade(dic_oplexicon3,w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    if P+N == 0:
        sent = 0;
    else:
        sent = (P - N)/(P + N)
    return(sent)

def oplexicon3_Logit_scale(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    for w in string:
        pol = retorna_polaridade(dic_oplexicon3,w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    sent = np.log(P + 0.5) - np.log(N + 0.5)
    return(sent)

def oplexicon3_N(string):
    """
    retorna o número de palavras negativas de uma string com base no oplexicon3
    """
    string = word_tokenize(string.lower(), language='portuguese')
    N = 0;
    for w in string:
        pol = retorna_polaridade(dic_oplexicon3,w)
        if pol == -1:
            N = N + 1
    return(N)

def oplexicon3_P(string):
    """
    retorna o número de palavras positivas de uma string com base no oplexicon3
    """
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    for w in string:
        pol = retorna_polaridade(dic_oplexicon3,w)
        if pol == 1:
            P = P + 1
    return(P)


"""
WordnetAffectBr
"""

def retorna_lemas(string):
    doc = nlp(string)
    string=" ".join([token.lemma_ for token in doc])
    return(string)

df_wordnetaffectbr = pd.read_csv('dados\\dicionarios\\wordnetaffectbr_valencia.csv',
                            sep=';',encoding='ANSI')
df_wordnetaffectbr.columns = ['palavra','polaridade']
df_wordnetaffectbr.set_index('palavra', inplace=True)
dic_wordnetaffectbr = df_wordnetaffectbr.to_dict()
dic_wordnetaffectbr = dic_wordnetaffectbr['polaridade']

dic_wordnetaffectbr['torrado'] = '-'
dic_wordnetaffectbr['torrar'] = '-'
#dic_wordnetaffectbr['afinar'] = 0
dic_wordnetaffectbr['inútil'] = '-'
dic_wordnetaffectbr['queda'] = '-'
dic_wordnetaffectbr['cair'] = '-'
dic_wordnetaffectbr['cagada'] = '-'
dic_wordnetaffectbr['cagado'] = '-'
dic_wordnetaffectbr['cagar'] = '-'
dic_wordnetaffectbr['pqp'] = '-'
dic_wordnetaffectbr['parabéns'] = '+'

def wordnetaffectbr_retorna_polaridade(palavra):
    """
    retorna polaridades de wordnetaffectbr
    """
    try:
        pol = dic_wordnetaffectbr[palavra]
        if type(pol) == pd.core.series.Series: #tem palavras com mais de uma ocorrência, nesse caso o retorno é uma serie
            return(pol[0]) 
        else:
            return(pol)
    except:
        return(0)


def wordnetaffectbr_Absolute_Proportional_Difference(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    O = len(string)
    for w in string:
        pol = wordnetaffectbr_retorna_polaridade(w)
        if pol == '+':
            P = P + 1
        elif pol == '-':
            N = N + 1
    if O == 0:
        sent = 0
    else:
        sent = (P - N)/O
    return(sent)
    
def wordnetaffectbr_Relative_Proportional_Difference(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    for w in string:
        pol = wordnetaffectbr_retorna_polaridade(w)
        if pol == '+':
            P = P + 1
        elif pol == '-':
            N = N + 1
    if P+N == 0:
        sent = 0;
    else:
        sent = (P - N)/(P + N)
    return(sent)

def wordnetaffectbr_Logit_scale(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    for w in string:
        pol = wordnetaffectbr_retorna_polaridade(w)
        if pol == '+':
            P = P + 1
        elif pol == '-':
            N = N + 1
    sent = np.log(P + 0.5) - np.log(N + 0.5)
    return(sent)

def wordnetaffectbr_N(string):
    """
    retorna o número de palavras negativas de uma string com base no wordnetaffectbr
    """
    string = word_tokenize(string.lower(), language='portuguese')
    N = 0;
    for w in string:
        pol = wordnetaffectbr_retorna_polaridade(w)
        if pol == '-':
            N = N + 1
    return(N)

def wordnetaffectbr_P(string):
    """
    retorna o número de palavras positivas de uma string com base no wordnetaffectbr
    """
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    for w in string:
        pol = wordnetaffectbr_retorna_polaridade(w)
        if pol == '+':
            P = P + 1
    return(P)


"""
#LIWC - Linguistic Inquiry and Word Count - PORTUGUES
"""

f = open('dados\\dicionarios\\LIWC2007_Portugues_win.dic.txt', 'r') 
Lines = f.readlines() 

dic_LIWC = {}
# Strips the newline character 
for line in Lines[66:]: 
    line = re.sub('\t',' ',line)
    line = re.sub('\n','',line)
    lista = line.split()
    key = lista[0]
    if '127' in lista: #negemod
        value = -1 
    elif '126' in lista: #posemod
        value = 1
    else:
        value = 0
    dic_LIWC[key] = value

f.close()
del Lines, line 
    
def LIWC_retorna_polaridade(palavra):
    """
    retorna polaridades de LIWC
    """
    try:
        pol = dic_LIWC[palavra]
        if type(pol) == pd.core.series.Series: #tem palavras com mais de uma ocorrência, nesse caso o retorno é uma serie
            return(pol[0]) 
        else:
            return(pol)
    except:
        return(0)


def LIWC_Absolute_Proportional_Difference(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    O = len(string)
    for w in string:
        pol = LIWC_retorna_polaridade(w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    if O == 0:
        sent = 0
    else:
        sent = (P - N)/O
    return(sent)
    
def LIWC_Relative_Proportional_Difference(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    for w in string:
        pol = LIWC_retorna_polaridade(w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    if P+N == 0:
        sent = 0;
    else:
        sent = (P - N)/(P + N)
    return(sent)

def LIWC_Logit_scale(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    for w in string:
        pol = LIWC_retorna_polaridade(w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    sent = np.log(P + 0.5) - np.log(N + 0.5)
    return(sent)

def LIWC_N(string):
    """
    retorna o número de palavras negativas de uma string com base no LIWC
    """
    string = word_tokenize(string.lower(), language='portuguese')
    N = 0;
    for w in string:
        pol = LIWC_retorna_polaridade(w)
        if pol == -1:
            N = N + 1
    return(N)

def LIWC_P(string):
    """
    retorna o número de palavras positivas de uma string com base no LIWC
    """
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    for w in string:
        pol = LIWC_retorna_polaridade(w)
        if pol == 1:
            P = P + 1
    return(P)



"""
#SentiLex - PORTUGUES
"""

f = open('dados\\dicionarios\\SentiLex-flex-PT02.txt', 'r') 
Lines = f.readlines() 

dic_SentiLex = {}
# Strips the newline character 
for line in Lines[66:]: 
    line = re.sub(',',' ',line)
    line = re.sub('\n','',line)
    lista = line.split()
    key = lista[0]
    if 'POL:N0=-1' in line: #negativo
        value = -1 
    elif 'POL:N0=1' in line: #positivo
        value = 1
    else:
        value = 0
    dic_SentiLex[key] = value

f.close()
del Lines, line 
    
def SentiLex_retorna_polaridade(palavra):
    """
    retorna polaridades de SentiLex
    """
    try:
        pol = dic_SentiLex[palavra]
        if type(pol) == pd.core.series.Series: #tem palavras com mais de uma ocorrência, nesse caso o retorno é uma serie
            return(pol[0]) 
        else:
            return(pol)
    except:
        return(0)


def SentiLex_Absolute_Proportional_Difference(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    O = len(string)
    for w in string:
        pol = SentiLex_retorna_polaridade(w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    if O == 0:
        sent = 0
    else:
        sent = (P - N)/O
    return(sent)
    
def SentiLex_Relative_Proportional_Difference(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    for w in string:
        pol = SentiLex_retorna_polaridade(w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    if P+N == 0:
        sent = 0;
    else:
        sent = (P - N)/(P + N)
    return(sent)

def SentiLex_Logit_scale(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    for w in string:
        pol = SentiLex_retorna_polaridade(w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    sent = np.log(P + 0.5) - np.log(N + 0.5)
    return(sent)

def SentiLex_N(string):
    """
    retorna o número de palavras negativas de uma string com base no SentiLex
    """
    string = word_tokenize(string.lower(), language='portuguese')
    N = 0;
    for w in string:
        pol = SentiLex_retorna_polaridade(w)
        if pol == -1:
            N = N + 1
    return(N)

def SentiLex_P(string):
    """
    retorna o número de palavras positivas de uma string com base no SentiLex
    """
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    for w in string:
        pol = SentiLex_retorna_polaridade(w)
        if pol == 1:
            P = P + 1
    return(P)


"""
#FORMALITY
"""

def retorna_formality(text):
    doc = nlp(text)
    ADJ = ADP = ADV = AUX = CONJ = CCONJ = DET = INTJ = NOUN = NUM = PART = 0
    PRON = PROPN = PUNCT = SCONJ = SYM = VERB = X = SPACE = 0
    
    for token in doc:
        pos = token.pos_
        if pos == 'NOUN':
            NOUN = NOUN + 1
        elif pos == 'ADP':
            ADP = ADP + 1
        elif pos == 'PUNCT':
            PUNCT = PUNCT + 1
        elif pos == 'DET':
            DET = DET + 1
        elif pos == 'VERB':
            VERB = VERB + 1
        elif pos == 'ADJ':
            ADJ = ADJ +1
        elif pos == 'PROPN':
            PROPN = PROPN + 1
        elif pos == 'NUM':
            NUM = NUM + 1
        elif pos == 'PRON':
            PRON = PRON + 1
        elif pos == 'ADV':
            ADV = ADV +1
        elif pos == 'AUX':
            AUX = AUX + 1
        elif pos == 'CONJ':
            CONJ = CONJ + 1
        elif pos == 'CCONJ':
            CCONJ = CCONJ + 1
        elif pos == 'INTJ':
            INTJ = INTJ + 1
        elif pos == 'PART':
            PART = PART + 1
        elif pos == 'SCONJ':
            SCONJ = SCONJ + 1
        elif pos == 'SYM':
            SYM = SYM + 1
        elif pos == 'X':
            X = X + 1
        elif pos == 'SPACE':
            SPACE = SPACE + 1
    F = NOUN + PROPN + ADJ + DET
    C = PRON + ADV + VERB + AUX + INTJ
    N = F + C + CONJ + CCONJ + SCONJ
    if N == 0:
        return (0)
    else:
        formality = 50 * ((F - C)/N + 1)
        return(formality)

def retorna_lexical_density(text):
    doc = nlp(text)
    ADJ = ADP = ADV = AUX = CONJ = CCONJ = DET = INTJ = NOUN = NUM = PART = 0
    PRON = PROPN = PUNCT = SCONJ = SYM = VERB = X = SPACE = 0
    
    for token in doc:
        pos = token.pos_
        if pos == 'NOUN':
            NOUN = NOUN + 1
        elif pos == 'ADP':
            ADP = ADP + 1
        elif pos == 'PUNCT':
            PUNCT = PUNCT + 1
        elif pos == 'DET':
            DET = DET + 1
        elif pos == 'VERB':
            VERB = VERB + 1
        elif pos == 'ADJ':
            ADJ = ADJ +1
        elif pos == 'PROPN':
            PROPN = PROPN + 1
        elif pos == 'NUM':
            NUM = NUM + 1
        elif pos == 'PRON':
            PRON = PRON + 1
        elif pos == 'ADV':
            ADV = ADV +1
        elif pos == 'AUX':
            AUX = AUX + 1
        elif pos == 'CONJ':
            CONJ = CONJ + 1
        elif pos == 'CCONJ':
            CCONJ = CCONJ + 1
        elif pos == 'INTJ':
            INTJ = INTJ + 1
        elif pos == 'PART':
            PART = PART + 1
        elif pos == 'SCONJ':
            SCONJ = SCONJ + 1
        elif pos == 'SYM':
            SYM = SYM + 1
        elif pos == 'X':
            X = X + 1
        elif pos == 'SPACE':
            SPACE = SPACE + 1
    N = ADJ + ADP + ADV + AUX + CONJ + CCONJ + DET + INTJ + NOUN + NUM + PART + PRON + PROPN + SCONJ + VERB
    if N == 0:
        return (0)
    else:
        lex_den = (NOUN + PROPN + ADJ + ADV + VERB + AUX)/N
        return(lex_den)

def lexical_diversity(text):
    """
        #Número de palavras únicas dividido pelo total de palavras
    """
    if type(text) != type('string'):
        return(np.nan)
    tokens = text.split()
    return len(set(tokens))/len(tokens) 

def ARI(text):
    """
        #Automated Readability Index
        #ARI <- 4.71*(Nr_caracteres_limpos/Nr_palavras)+0.5*Nr_palavras/Nr_frases-21.43
    """
    if type(text) != type('string'):
        return(np.nan)
    text_clean = re.sub(r'[^\w\s]','',text)
    n_char = len(text_clean)
    n_word = len(word_tokenize(text))
    n_sent = len(sent_tokenize(text))
    if n_word == 0:
        n_word = 1
    if n_sent == 0:
        n_sent = 1
    ARI = 4.71 * n_char / n_word + 0.5 * n_word / n_sent - 21.43
    return(ARI)

def CLI(text):
    if type(text) != type('string'):
        return(np.nan)
    """
        #Coleman-Liau index
        #"4-Pre-escolar, 5->9 Elementary school, 10->15 Middle school, 16->18 High school CF/88 = 30.24"
        #CLI<-0.0588*Nr_caracteres_limpos/Nr_palavras*100 - 0.296*Nr_frases/Nr_palavras*100
    """
    text_clean = re.sub(r'[^\w\s]','',text)
    n_char = len(text_clean)
    n_word = len(word_tokenize(text))
    n_sent = len(sent_tokenize(text))
    if n_word == 0:
        n_word = 1
    if n_sent == 0:
        n_sent = 1
    CLI = 0.0588 * n_char / n_word * 100 - 0.296 * n_sent / n_word * 100
    return(CLI)

vds = SentimentIntensityAnalyzer()

def vader_polarity_neg(text):
    if type(text) != type('string'):
        return(np.nan)
    score = vds.polarity_scores(text)['neg']
    return(score)

def vader_polarity_neu(text):
    if type(text) != type('string'):
        return(np.nan)
    score = vds.polarity_scores(text)['neu']
    return(score)

def vader_polarity_pos(text):
    if type(text) != type('string'):
        return(np.nan)
    score = vds.polarity_scores(text)['pos']
    return(score)

def vader_polarity_compound(text):
    if type(text) != type('string'):
        return(np.nan)
    score = vds.polarity_scores(text)['compound']
    return(score)

def retorna_formality_en(text):
    if type(text) != type('string'):
        return(np.nan)
    doc = nlp_en(text)
    ADJ = ADP = ADV = AUX = CONJ = CCONJ = DET = INTJ = NOUN = NUM = PART = 0
    PRON = PROPN = PUNCT = SCONJ = SYM = VERB = X = SPACE = 0
    
    for token in doc:
        pos = token.pos_
        if pos == 'NOUN':
            NOUN = NOUN + 1
        elif pos == 'ADP':
            ADP = ADP + 1
        elif pos == 'PUNCT':
            PUNCT = PUNCT + 1
        elif pos == 'DET':
            DET = DET + 1
        elif pos == 'VERB':
            VERB = VERB + 1
        elif pos == 'ADJ':
            ADJ = ADJ +1
        elif pos == 'PROPN':
            PROPN = PROPN + 1
        elif pos == 'NUM':
            NUM = NUM + 1
        elif pos == 'PRON':
            PRON = PRON + 1
        elif pos == 'ADV':
            ADV = ADV +1
        elif pos == 'AUX':
            AUX = AUX + 1
        elif pos == 'CONJ':
            CONJ = CONJ + 1
        elif pos == 'CCONJ':
            CCONJ = CCONJ + 1
        elif pos == 'INTJ':
            INTJ = INTJ + 1
        elif pos == 'PART':
            PART = PART + 1
        elif pos == 'SCONJ':
            SCONJ = SCONJ + 1
        elif pos == 'SYM':
            SYM = SYM + 1
        elif pos == 'X':
            X = X + 1
        elif pos == 'SPACE':
            SPACE = SPACE + 1
    F = NOUN + PROPN + ADJ + DET
    C = PRON + ADV + VERB + AUX + INTJ
    N = F + C + CONJ + CCONJ + SCONJ
    if N == 0:
        return (0)
    else:
        formality = 50 * ((F - C)/N + 1)
        return(formality)

def retorna_lexical_density_en(text):
    if type(text) != type('string'):
        return(np.nan)
    doc = nlp_en(text)
    ADJ = ADP = ADV = AUX = CONJ = CCONJ = DET = INTJ = NOUN = NUM = PART = 0
    PRON = PROPN = PUNCT = SCONJ = SYM = VERB = X = SPACE = 0
    
    for token in doc:
        pos = token.pos_
        if pos == 'NOUN':
            NOUN = NOUN + 1
        elif pos == 'ADP':
            ADP = ADP + 1
        elif pos == 'PUNCT':
            PUNCT = PUNCT + 1
        elif pos == 'DET':
            DET = DET + 1
        elif pos == 'VERB':
            VERB = VERB + 1
        elif pos == 'ADJ':
            ADJ = ADJ +1
        elif pos == 'PROPN':
            PROPN = PROPN + 1
        elif pos == 'NUM':
            NUM = NUM + 1
        elif pos == 'PRON':
            PRON = PRON + 1
        elif pos == 'ADV':
            ADV = ADV +1
        elif pos == 'AUX':
            AUX = AUX + 1
        elif pos == 'CONJ':
            CONJ = CONJ + 1
        elif pos == 'CCONJ':
            CCONJ = CCONJ + 1
        elif pos == 'INTJ':
            INTJ = INTJ + 1
        elif pos == 'PART':
            PART = PART + 1
        elif pos == 'SCONJ':
            SCONJ = SCONJ + 1
        elif pos == 'SYM':
            SYM = SYM + 1
        elif pos == 'X':
            X = X + 1
        elif pos == 'SPACE':
            SPACE = SPACE + 1
    N = ADJ + ADP + ADV + AUX + CONJ + CCONJ + DET + INTJ + NOUN + NUM + PART + PRON + PROPN + SCONJ + VERB
    if N == 0:
        return (0)
    else:
        lex_den = (NOUN + PROPN + ADJ + ADV + VERB + AUX)/N
        return(lex_den)


def retorna_polaridade_dicionario_conjunta(palavra):
    """
    retorna a polaridade considerando os dicionários oplexicon, sentiwordnetbr, liwc e sentilex de forma conjunta
    
    """
    if palavra in dic_wordnetaffectbr.keys():
        try:
            pol = dic_wordnetaffectbr[palavra]
            if type(pol) == pd.core.series.Series: #tem palavras com mais de uma ocorrência, nesse caso o retorno é uma serie
                if pol[0] == '+':
                    return(1) 
                elif pol[0] == '-':
                    return(-1)
            else:
                if pol == '+':
                    return(1) 
                elif pol == '-':
                    return(-1)
        except:
            e=True
			
			
    if palavra in dic_oplexicon3.keys():
        try:
            pol = dic_oplexicon3[palavra]
            if type(pol) == pd.core.series.Series: #tem palavras com mais de uma ocorrência, nesse caso o retorno é uma serie
                return(pol[0]) 
            else:
                return(pol)
        except:
            e = True


    if palavra in dic_SentiLex.keys():
        try:
            pol = dic_SentiLex[palavra]
            if type(pol) == pd.core.series.Series: #tem palavras com mais de uma ocorrência, nesse caso o retorno é uma serie
                return(pol[0]) 
            else:
                return(pol)
        except:
            e = True

    if palavra in dic_LIWC.keys():
        try:
            pol = dic_LIWC[palavra]
            if type(pol) == pd.core.series.Series: #tem palavras com mais de uma ocorrência, nesse caso o retorno é uma serie
                return(pol[0]) 
            else:
                return(pol)
        except:
            e = True

    return(0)

def Dicionario_conjunto_Absolute_Proportional_Difference(string):
    string = word_tokenize(string.lower(), language='portuguese')
    P = 0;
    N = 0;
    O = len(string)
    for w in string:
        pol = retorna_polaridade_dicionario_conjunta(w)
        if pol == 1:
            P = P + 1
        elif pol == -1:
            N = N + 1
    if O == 0:
        sent = 0
    else:
        sent = (P - N)/O
    return(sent)

def polaridade(valor):
    """
    Classifica a polaridade em três níves: positivo, negativo e neutro.
    Positivo retorna E (elogio)
    Negativo retorna C (crítica)
    Neutro retorna N.
    """
    if valor>0.02:
        return("E") #positivo
    elif valor<-0.02:
        return("C") #negativo
    else:
        return("N") # neutro

def polaridade2(valor):
    """
    Classifica a polaridade em DOIS NÍVEIS: positivo, negativo e neutro.
    Negativo retorna C (crítica)
    Neutro retorna N (Não-crítica).
    """
    if valor>=0:
        return("N") #Não-crítica (positivo e neutro)
    else:
        return("C") # crítica (negativo)



def ensemble_portugues(string):
    
    D = {}
    aux = oplexicon3_Absolute_Proportional_Difference(string)
    D['oplexicon3'] = polaridade(aux)
    aux = SentiLex_Absolute_Proportional_Difference(string)
    D['sentilex'] = polaridade(aux)
    aux = LIWC_Absolute_Proportional_Difference(string)
    D['LIWC'] = polaridade(aux)
    aux = wordnetaffectbr_Absolute_Proportional_Difference(string)
    D['wordnetaffectbr'] = polaridade(aux)
    c = Counter(D.values())
    # são 4 dicionários
    if c.most_common(1)[0][1] == 4 or c.most_common(1)[0][1] == 3: #significa que houve um vencedor
        return(c.most_common(1)[0][0])
    else: #siginifica que houve empate 2 a 2, entao escolhe-se o wordnetaffectbr
        return(D['wordnetaffectbr'])

def retorna_lista_negra_usuarios():
    #'OMITIDO POR CAUSA DAS REGRAS DE PRIVACIDADE DO TWITTER.'
    lista_negra_usuarios = ["???"]
    
    return lista_negra_usuarios

def retorna_lista_negra_expressoes():
    #'OMITIDO POR CAUSA DAS REGRAS DE PRIVACIDADE DO TWITTER. CONTÉM MENÇÕES A NOMES DE USUÁRIOS.'
    lista_negra_expressoes = ['?????']
    return lista_negra_expressoes


def le_arquivos(path, lista_arquivos):
        
    usuarios = []
    locations = []
    descriptions = []
    followers = []
    friends = []
    favourites = []
    listed = []
    statuses = []
    tweets = []
    datas = []
    retwitted =[]
    ids = []
    likes = []
    retweets = []
    sources = []
    reply = []
    
    g_ids = []
    g_datas = []
    g_usuario1 = []
    g_usuario2 = []
    g_likes = []
    g_retweets = []
    g_tipo_link = []
    
    for i in range(len(lista_arquivos)):
    
        if lista_arquivos[i][:2] == "tw":
        
            pickle_in = open(path+'\\'+lista_arquivos[i],"rb")
            posts = pickle.load(pickle_in)
            
            json_data = [p._json for p in posts]
            
            for dic in json_data:
                # Caso não seja um retweet
                if dic['full_text'][:4] != "RT @":
                    usuarios.append(dic['user']['screen_name'])
                    locations.append(dic['user']['location'])
                    descriptions.append(dic['user']['description'])
                    followers.append(dic['user']['followers_count'])
                    friends.append(dic['user']['friends_count'])
                    favourites.append(dic['user']['favourites_count'])
                    listed.append(dic['user']['listed_count'])
                    statuses.append(dic['user']['statuses_count'])
                    datas.append(dic['created_at'])
                    tweets.append(dic['full_text'])
                    ids.append(dic['id'])
                    likes.append(dic['favorite_count'])
                    retweets.append(dic['retweet_count'])
                    sources.append(dic['source'])
                    retwitted.append(False)
                    if 'reply_count' in dic.keys():
                        reply.append(dic['reply_count'])
                    else:
                        reply.append(0)
                # Caso seja um retweet
                else:
                    usuarios.append(dic['user']['screen_name'])
                    locations.append(dic['user']['location'])
                    descriptions.append(dic['user']['description'])
                    followers.append(dic['user']['followers_count'])
                    friends.append(dic['user']['friends_count'])
                    favourites.append(dic['user']['favourites_count'])
                    listed.append(dic['user']['listed_count'])
                    statuses.append(dic['user']['statuses_count'])
                    datas.append(dic['created_at'])
                    tweets.append(dic['full_text'])
                    ids.append(dic['id'])
                    likes.append(dic['favorite_count'])
                    retweets.append(dic['retweet_count'])
                    sources.append(dic['source'])
                    retwitted.append(True)
                    if 'reply_count' in dic.keys():
                        reply.append(dic['reply_count'])
                    else:
                        reply.append(0)
                    if 'retweeted_status' in dic.keys():
                        usuarios.append(dic['retweeted_status']['user']['screen_name'])
                        locations.append(dic['retweeted_status']['user']['location'])
                        descriptions.append(dic['retweeted_status']['user']['description'])
                        followers.append(dic['retweeted_status']['user']['followers_count'])
                        friends.append(dic['retweeted_status']['user']['friends_count'])
                        favourites.append(dic['retweeted_status']['user']['favourites_count'])
                        listed.append(dic['retweeted_status']['user']['listed_count'])
                        statuses.append(dic['retweeted_status']['user']['statuses_count'])
                        datas.append(dic['retweeted_status']['created_at'])
                        tweets.append(dic['retweeted_status']['full_text'])
                        ids.append(dic['retweeted_status']['id'])
                        likes.append(dic['retweeted_status']['favorite_count'])
                        retweets.append(dic['retweeted_status']['retweet_count'])
                        sources.append(dic['retweeted_status']['source'])
                        retwitted.append(False)
                        if 'reply_count' in dic['retweeted_status'].keys():
                            reply.append(dic['retweeted_status']['reply_count'])
                        else:
                            reply.append(0)
                        
                if len(dic['entities']['user_mentions'])>0:
                    for i in range(len(dic['entities']['user_mentions'])):
                        g_usuario1.append(dic['user']['screen_name'])
                        g_usuario2.append(dic['entities']['user_mentions'][i]['screen_name'])
                        g_ids.append(dic['id'])
                        g_likes.append(dic['favorite_count'])
                        g_retweets.append(dic['retweet_count'])
                        g_datas.append(dic['created_at'])
                        g_tipo_link.append('menção')
                
                if len(dic['entities']['hashtags'])>0:
                    for i in range(len(dic['entities']['hashtags'])):
                        g_usuario1.append(dic['user']['screen_name'])
                        g_usuario2.append(dic['entities']['hashtags'][i]['text'])
                        g_ids.append(dic['id'])
                        g_likes.append(dic['favorite_count'])
                        g_retweets.append(dic['retweet_count'])
                        g_datas.append(dic['created_at'])
                        g_tipo_link.append('hashtag')
                        
                
                if 'retweeted_status' in dic:
                    g_usuario1.append(dic['user']['screen_name'])
                    g_usuario2.append(dic['retweeted_status']['user']['screen_name'])
                    g_ids.append(dic['id'])
                    g_likes.append(dic['favorite_count'])
                    g_retweets.append(dic['retweet_count'])
                    g_datas.append(dic['created_at'])
                    g_tipo_link.append('retweet')
                
                if dic['in_reply_to_screen_name']!=None:
                    g_usuario1.append(dic['user']['screen_name'])
                    g_usuario2.append(dic['in_reply_to_screen_name'])
                    g_ids.append(dic['id'])
                    g_likes.append(dic['favorite_count'])
                    g_retweets.append(dic['retweet_count'])
                    g_datas.append(dic['created_at'])
                    g_tipo_link.append('resposta')
        
        elif lista_arquivos[i][:2] == "st":
            pickle_in = open(path+'\\'+lista_arquivos[i],"rb")
            dic = pickle.load(pickle_in)
            if dic['text'][:4] != "RT @":
                usuarios.append(dic['user']['screen_name'])
                locations.append(dic['user']['location'])
                descriptions.append(dic['user']['description'])
                followers.append(dic['user']['followers_count'])
                friends.append(dic['user']['friends_count'])
                favourites.append(dic['user']['favourites_count'])
                listed.append(dic['user']['listed_count'])
                statuses.append(dic['user']['statuses_count'])
                datas.append(dic['created_at'])
                tweets.append(dic['text'])
                ids.append(dic['id'])
                likes.append(dic['favorite_count'])
                retweets.append(dic['retweet_count'])
                sources.append(dic['source'])
                retwitted.append(False)
                if 'reply_count' in dic.keys():
                    reply.append(dic['reply_count'])
                else:
                    reply.append(0)
            else:
                usuarios.append(dic['user']['screen_name'])
                locations.append(dic['user']['location'])
                descriptions.append(dic['user']['description'])
                followers.append(dic['user']['followers_count'])
                friends.append(dic['user']['friends_count'])
                favourites.append(dic['user']['favourites_count'])
                listed.append(dic['user']['listed_count'])
                statuses.append(dic['user']['statuses_count'])
                datas.append(dic['created_at'])
                tweets.append(dic['text'])
                ids.append(dic['id'])
                likes.append(dic['favorite_count'])
                retweets.append(dic['retweet_count'])
                sources.append(dic['source'])
                retwitted.append(True)
                if 'reply_count' in dic.keys():
                    reply.append(dic['reply_count'])
                else:
                    reply.append(0)
                if 'retweeted_status' in dic.keys():
                    usuarios.append(dic['retweeted_status']['user']['screen_name'])
                    locations.append(dic['retweeted_status']['user']['location'])
                    descriptions.append(dic['retweeted_status']['user']['description'])
                    followers.append(dic['retweeted_status']['user']['followers_count'])
                    friends.append(dic['retweeted_status']['user']['friends_count'])
                    favourites.append(dic['retweeted_status']['user']['favourites_count'])
                    listed.append(dic['retweeted_status']['user']['listed_count'])
                    statuses.append(dic['retweeted_status']['user']['statuses_count'])
                    datas.append(dic['retweeted_status']['created_at'])
                    tweets.append(dic['retweeted_status']['text'])
                    ids.append(dic['retweeted_status']['id'])
                    likes.append(dic['retweeted_status']['favorite_count'])
                    retweets.append(dic['retweeted_status']['retweet_count'])
                    sources.append(dic['retweeted_status']['source'])
                    retwitted.append(False)
                    if 'reply_count' in dic['retweeted_status'].keys():
                        reply.append(dic['retweeted_status']['reply_count'])
                    else:
                        reply.append(0)
                    
            if len(dic['entities']['user_mentions'])>0:
                for i in range(len(dic['entities']['user_mentions'])):
                    g_usuario1.append(dic['user']['screen_name'])
                    g_usuario2.append(dic['entities']['user_mentions'][i]['screen_name'])
                    g_ids.append(dic['id'])
                    g_likes.append(dic['favorite_count'])
                    g_retweets.append(dic['retweet_count'])
                    g_datas.append(dic['created_at'])
                    g_tipo_link.append('menção')
            
            if len(dic['entities']['hashtags'])>0:
                for i in range(len(dic['entities']['hashtags'])):
                    g_usuario1.append(dic['user']['screen_name'])
                    g_usuario2.append(dic['entities']['hashtags'][i]['text'])
                    g_ids.append(dic['id'])
                    g_likes.append(dic['favorite_count'])
                    g_retweets.append(dic['retweet_count'])
                    g_datas.append(dic['created_at'])
                    g_tipo_link.append('hashtag')
            
            if 'retweeted_status' in dic:
                g_usuario1.append(dic['user']['screen_name'])
                g_usuario2.append(dic['retweeted_status']['user']['screen_name'])
                g_ids.append(dic['id'])
                g_likes.append(dic['favorite_count'])
                g_retweets.append(dic['retweet_count'])
                g_datas.append(dic['created_at'])
                g_tipo_link.append('retweet')
            
            if dic['in_reply_to_screen_name']!=None:
                g_usuario1.append(dic['user']['screen_name'])
                g_usuario2.append(dic['in_reply_to_screen_name'])
                g_ids.append(dic['id'])
                g_likes.append(dic['favorite_count'])
                g_retweets.append(dic['retweet_count'])
                g_datas.append(dic['created_at'])
                g_tipo_link.append('resposta')
    
    
    df_aux = pd.DataFrame({'id':ids, 
                       'usuario':usuarios,
                       'localidade':locations,
                       'description':descriptions,
                       'seguidores':followers,
                       'amigos':friends,
                       'favoritos':favourites,
                       'listado':listed,
                       'nr_tweets':statuses,
                       'data':datas,
                       'likes':likes,
                       'retweets':retweets,
                       'replies':reply, 
                       'tweet':tweets,
                       'retwitted':retwitted,
                       'source':sources})
    
    df_g_aux = pd.DataFrame({'id':g_ids, 
                   'usuario1':g_usuario1,
                   'usuario2':g_usuario2,
                   'likes':g_likes,
                   'retweets':g_retweets,
                   'data':g_datas,
                   'tipo':g_tipo_link})
    
    return df_aux, df_g_aux





mystopwords = ['é','sobre','ainda','banco central','banco_central','bcb','bc','banco','central','bacen','brasil','presidente','bancocentralbr',
                 #'política','monetária','inflação','juros','selic','taxa','juro','ipca','dólar','dolar','dólares','dolares','copom','câmbio','pib',
                 'economia','mercado','mercados','brasileiro','brasileiros','brasileira','brasileiras','bancos', 'hoje',
                 'dinheiro','governo','encaminhada','encaminhadas','podem','ser','vai','confira','pode','saiba','assista','veja','diz',
                 'fazer','quer','pode','agora','r','dia','dados','divulgados','momento','espera','reunião','entrevista','porque',
                 'destaques','novo','h','após','faça','através','feira','ano','anos','deve','desde','durante','aqui','ter','via','notícia','ig','gn',
                 'notícias','acho','artigo','artigos','ontem','faz','tão','assim','enquanto','da','para','ab',
                 'neste','nestes','nesta','nestas','nisto','nesse','nesses','nessa','nessas','nisso',
                 'deste','destes','desta','destas','disto','desse','desses','dessa','dessas','disso',
                 'pelo','pela','pelos','pelas','fl','lol','lt','segundo','ainda','desda','desde','muita','muitas','muito','muitos',
                 'janeiro','fevereiro','março','abril','maio','junho','julho','agosto','setembro','outubro','novembro','dezembro',
                 'jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez',
                 'segunda','terça','quarta','quinta','sexta','feira','sábado','domingo',
                 'segunda-feira','terça-feira','quarta-feira','quinta-feira','sexta-feira','feira',
                 'meses','mes','mês','outro','outros','outra','outras','p','relator','dar','meio','bcs','semana','º','dessar','know', 'how',
                 'parte','apenas','aí','sendo','segue','ponto','próxima','dj','gt','site','link','g','blog','c','onde','sim','não','quedo','então','parir',
                 'nhonho','pelar','pontar','link', 'blog','att','per', 'si', 'á','new', 'post', 'pt', 'carioca','bs','ps','dj', 'zap', 'áudio', 'live',
                 'fernando','antes','depois','uso','hora','sim','onde','está','parir','comer','\xa0','pelar','casar','antar','estar','horar','mercar','umar',
                 'ba','mlk','sono','ª','conforme', 'group', 'farsul', 'baderneiro','dt', 'min', 'screenshots','ceilândia', 'arredores','torre', 'babel','colouco',
                 'gt','bps','dias','tempo','cenário','evitar','presidente','acesse','site','texto','telefone','precisa','registre','ouvindo','tudo','todo',
                 'crl','cmb','bfs','clickbait','pfv','ynwa','gente', 'vídeo','cavalo','ei','log','goiaba', 'starks', 'mekieh', 'cantora', 'nu', 'heavy','nois','serto',
                 'cultura','bfilho', 'tiko', 'gostoso', 'magra','magro','feia','feio','risa', 'pongo', 'cosas', 'max', 'le', 'gado', 'shounen', 'hi','tv',
                 'cristo','qulquer','miseri','gt','bps','dias','tempo','cenário','evitar','acesse','site','texto','telefone','precisa',
                 'registre','ouvindo'
                 'pirocar','god','tília','hortelã','camomila','melissa','org','tatashi','edir','petê','gomz','mig','érika','feshow','sputnik','co',
                 'clichê', 'vibe', 'sanju', 'not', 'love', 'filha', 'lucas', 'aro', 'conhecido', 'balãozinho', 'neném', 'holland', 'chinela', 'kk','fds','carai','obg','nao','depoiss','afazer',
                 'boca', 'totó', 'ibre',  'entrevistado', 'ar', 'entrevistas', 'roda', 'youtube', 'reveja', 'convite', 'guerreira',
                 'buse',  'uam', 'tenao', 'dormi', 'mandano', 'ezsas', 'palhacada', 'balela', 'peté', 'caraca', 'kkkkk', 'encheção', 'fulano','crescime','expectativ','meno','fdepois','empresaial','dóla',
                 'plantão', 'gay', 'jusiciario', 'legisla',  'molusco', 'modelod', 'fácimmmm',  'odeio', 'pergunte', 'guru', 
                 'quantos', 'comento', 'instituído', 'produtivos','jpeg', 'gêmeas', 'filosofia', 'justus', 'aprendiz', 'franklin', 'serrano', 'citando',
                  'summa', 'review', 'keynesian', 'stonks',  'babaca', 'endometriose', 'sintomas', 'diagnóstico', 'acidente', 'laparoscopia','administrativoitir','estáv','admini','linguage',
                 'ignorada', 'ridicularizada', 'infinito', 'represálias', 'fadiga', 'crónica', 'intolerâncias', 'ansiedade', 'insuficiência', 'renal','filhinho','maneiro','mim',
                 'tadow','euuuuu','animaisssss','baby','tristrza','cru','linde','bhara','gabiru','choppa','bandicoot','linkedin',
                 'abc', 'linda', 'amigão',  'von', 'keynesianos', 'mumnuca', 'geladeira', 'vazia','adooooooro', 'mulê', 'elator', 'opa',
                 'π', 'y', 'φ', 'kkk', 'blouco', 'yag', 'anjo','carr','viri', 'vila', 'verde', 'bancada', 'barato', 'stanley',
                 'pauzao','loqestoyviendo','bombdia','fu','hoja','chup','hirata','goertek','panasonic','hikvision','macri','coppola','alexribeir','francisco','phillips','infinity','nomeaçõ',
                 'misericórdia','chegass','condomínio','esquerdalha','hmin','maddxn','pump','fods','moço','caverna','obrigandoseus','by','zâmbia','hollywood','administrativostrativoi','letônia','polít',
                 'desgraçaaaaaaaa','gutierry','white','subiiirrr','gtana','carrapato','furdunço', 'namora', 'tre','agabii','chroar','chataaaaaaaaaaaa','portalrubemgonzaleznotíciash','voce','ipiranga',
                 'levy','paulo','joão', 'borges','emerson','ciro','daniel','biden','powell', 'lcmb','david', 'luiz','tony', 'volpon','lula', 'dilma','mourão','coelho','guedes','raphael',
                 'bráulio', 'nilson', 'teixeira', 'meirelles','geddel', 'vieira', 'lima', 'monica','barbooosa','wilson','helio', 'beltrão', 'alcolumbre','simão','levi','oliveir','funchal','isabel',
                 'weintraub','moro','fernando','márcio', 'camargo', 'armínio', 'fraga','carlos', 'johnny','samy','silva', 'mendes', 'bruno', 'igor', 'erica','nehme','brizola','otaviano','mesquita',
                 'natália','renato', 'andrade','alexandre', 'schwartsman','zé', 'luan','dr','susana', 'alexandregon','vinícius', 'heleno','eduarda','sarkozy','yami','antoniocostapm','loen','regazzini',
                 'thalesnogueira','mônica','bolle','haddad','queiroz','gabriela','borba','bacano','totonho','barros','nelson','pérsio','alan','nassif','xavi','kalev','canuto','pedro','naercio','menezes','jessé','souza','nery','augustin','leonardo','monasterio','ferraz','andrea','calabi','ricardo','paes','rodrigo','zeidan','manteiga','paulo','gala','gustavo','franco','gianetti','beluzzo',
                 'flavinho','magalhães','tombini','ilan','goldfajn','ricardo','gabizinha','marcelo', 'tavares','arminio','camila','ludwig','abrao','senador','cal','evo','ecobomistas',
                 'plínio','deputado','ranieri','kfoury', 'mantega','luciano','friedman', 'hommel', 'serjão','craques', 'marco', 'bonomo', 'marcio', 'garcia','mohamed','chacra','alexschwartsman','bianchini','pedro','tarcísio',
                 'pt','psdb','pros','pmdb','psl','dem','psol','pco','pdt',
                 'rt','cartacapital','folha','infomoney','reuters','moodys','globonews', 'gnt','globo','istoédinheiro',
                 'btg','citi','ubs','modalmais','morgan','bamerindus','nado','ct','tmb','sm','morréu',
                 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
                 'kkkkkkkkkkkkkki','widnwkdjekske','ksksksksks','twinsanity','kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk','yoy','hein','kkkkkkkkkkkkkkkkk', 'kkkkkkkkk','hauahauahauahauahauahauahaauahauhaauahauahauah','kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk','heinnnn','kkkkkkkkkkkkkkkk','uhummm','kkkk', 'porra','fudeu','kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk','kkkkkkkkkkkkkk','kkkkkkkkkkkkkkkkkkkk','₂₀₁₆', '₀₅', '₀₂', '₁₈', '₀₃','oooooou', 'aa', 'cuuuuuuuuuuuuuuuuuuuuu','fudidos','kkkkkkkkkkkkk','kkkkkkkkkk','rsrsrs','ú','kkkkkkk','hahahahahakaka','caralho','kakkakkkkk','kskskss','hahahaha','siiiiiiimmmmmm',  'kkkkkkkk',  'pg','pau','foda','pras', 'picas','hahahahahaha','cuuuuuuuuu','kskskssjsb','hahahahahahha','kdjsksjskj','kkkkkk','cu','kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk','kkkkkkkeu','kkkkkkjkkj','ueheuheuheuheuheu','kkkk','kkkkkkkkkkkkkkkkkkkkkkkkkkk','ksmdkmskwmsksmqkmakamwmam','grrrrrrrrr','pipipipopopo','porraaaaaaaaaaa','kkkkkkkkkkk','kkkkkkkkkkkkkkkkkkkkkk','iif',
                 'um','dois','três','quatro','cinco','seis','sete','oito','nove','dez','onze','doze','treze','catorze','quinze',
                 'dezesseis','dezessete','dezoito','dezenove','vinte','trinta','quarenta','cinquenta','sessenta','setenta','oitenta',
                 'noventa','cem','duzentos','trezentos','quatrocentos','quinhentos','seiscentos','setecentos','oitocentos','novecentos',
                 'primeiro','primeira','segundo','terceiro','terceira','quarto','quinto','sexto','sétimo','sétima','oitavo','oitava',
                 'nono','nona','décimo','vigésimo','trigésimo','décima','vigésima','trigésima',
                 'ii','iii','iv','vi','vii','viii','ix','xi','xii','xiii','xiv','xv','xvi','xvii','xviii','xix','xx','xxi','xxii',
                 'xxiii','xxiv','xxv','xxvi','xxvii','xxviii','xxix','xxx','xxxi','xxxii','xxxiii','xxxiv','xxxv','xxxvi','xxxvii',
                 'ab','abacaxi','abad','abar','abdib','abraçar','abraço','abreu','abs','ac','academiar','acim','acr','acsp','ad','ademais','adeus','adin','adir','adorar','adversar','advfn','ae','af','aff','affonso','afim','afir','afp','afundir','ag','agr','agê','agên','agênc','ah','ai','ain','aind','aires','al','alagoa','alar','alberto','alckmin','ald','aldo','alemanha','alencar','alessandro','alex','alexa','alexan','alexand','alexandr','alfredo','algo','alguem','algum','alguém','alheio','ali','aliás','almeida','almeidense','almo','almoçar','alonso','alt','altamir','altamiro','alvaro','alves','além','alémão','alô','am','amador','amanhar','amanhecer','amanhã','amapá','amar','amarelar','amarelo','amazona','amazônia','ambev','ambos','america','americano','amigo','amo','amoedar','amor','amp','amém','américa','an','ana','anal','anali','anastasia','anatel','anbima','ancap','and','andrada','andre','andré','aneel','anefac','anfavea','angola','animador','animal','animar','antagonista','anti','antonio','antônio','anun','anunc','anunci','anunciad','aonde','ap','ape','aper','apesar','api','apo','apont','app','apple','apps','apr','aproximadamente','aq','arar','araújo','argentino','arida','armí','art','asiático','aspx','assis','at','ata','ater','ating','ativ','atro','au','audi','audio','august','augusto','aum','aume','aumen','aument','aurélio','austin','australiano','austrália','austríaco','autorid','ava','avô','awazu','axe','ayres','ayresbrasília','azevedo','azul','aécio','bacana','bahamas','bahia','bai','bailar','baita','baix','baldar','balir','ban','bananeiro','banc','banca','bancar','band','bandar','bandeiro','bandnews','barbosa','barboza','barclays','barrir','barulhar','bas','bastante','batista','bba','bbc','bbva','bce','bdm','be','beber','bege','beijar','beirar','beleza','belo','bem','berlim','bernanke','bernardo','berriel','bes','besi','bezerro','bh','bi','bid','big','bil','bis','bit','bla','black','blk','blogs','bloomberg','blz','blá','bm','bmf','bmg','bndes','bnds','bnp','bo','boe','bofar','boi','boiar','bol','bolsar','bolsonaro','bom','bonito','book','boom','bora','borgeso','bostar','boston','boto','boulos','bound','bovespa','box','bozo','bp','br','bra','bradesco','braga','branco','bras','brasi','brasilia','brasilo','brasilpara','brasí','brasília','breno','brexit','broadcast','brpontos','bsb','buenos','bull','bunda','buracar','bz','bá','bás','bási','básic','ca','cabeça','cacete','cada','cade','cadê','cae','café','cagar','caged','calgary','campar','campeão','campo','canal','candiota','capitar','car','caracas','cardoso','carl','carnaval','caro','carolino','carro','carry','carstens','carvalho','caseb','caut','cb','cbdc','cbn','ccj','cdb','cdbs','cdc','cdi','cdl','cds','ce','cef','celic','celso','cem','cen','cena','cent','centr','centrar','ceo','certar','cesar','cf','cgtb','ch','che','chicago','chico','chile','chileno','chino','chinês','chipre','chorar','chororô','chupar','ci','ciar','cielo','ciesp','cin','cincar','cingapura','cir','classific','claudia','claudio','clicar','clipping','cm','cn','cni','cnn','code','coeuré','cointelegraph','coitar','collor','colômbio','colônia','comeca','comerc','coming','comit','complac','compom','comuni','con','confi','confor','cons','consec','cont','conti','contin','contábeis','cop','copar','cor','corar','cordo','coreia','corner','correa','correar','corrêa','coutinho','cp','cr','cre','credit','cres','cresc','cristiano','cristina','cristovam','cré','créd','crédi','csn','cubar','cucolo','cueca','cujo','cury','cut','cux','cv','cá','cássio','câm','cê','damaso','danar','dantas','dantes','daoud','daquela','daquele','daqueles','daqui','data','datafolha','davos','day','daí','dbgg','dci','debaixo','dec','deci','decid','decl','def','deigmar','del','delfim','demais','denise','dentre','dentro','dep','deputar','der','des','desd','destac','deus','deutsche','dev','devir','df','diabo','dian','diante','diariamente','dif','dir','dirceu','dire','dis','disney','div','divu','divul','divulg','diário','dm','dnv','doc','dog','dol','donald','dopovo','doria','dornelles','douglas','draghi','dromenezes','duarte','duartesã','duartesão','dênio','dório','ebc','ec','eco','econ','econo','econom','economi','econô','econôm','econômic','ecosport','edson','edu','eduardo','edunews','efe','egito','egt','eh','eis','eita','el','elev','eliomar','elmor','elt','ema','embaixo','embora','emendar','empiricus','en','enavant','encontr','enfim','enganir','ent','entanto','entao','entr','entretanto','er','es','escapo','esfo','esp','espanha','essenc','est','estadao','estadão','estao','esteirar','estevar','estimati','etc','eua','eur','europ','europa','europeu','evê','ewz','ex','exigênc','exp','expe','expec','expect','expectat','explod','expressi','fa','fabio','falcão','falém','fatorelli','fattorelli','fdp','fe','fecomercio','fecomerciosp','fecomércio','fed','federar','federowski','federowskisão','feed','fei','feir','felipe','feriar','fernanda','fernandes','fero','fgv','fhc','fiergs','fiesp','fiesta','figueiredo','filadélfia','fin','financ','finance','financei','financiera','finar','flamengo','flor','florianópolis','flávio','fm','fmi','fo','focu','foder','folhapoder','follow','fomc','ford','fornir','fortalezar','foward','fr','frag','frankfurt','frança','freitas','frutar','fsp','ft','fuder','furlan','fut','futconnect','futebol','fábio','fã','féria','gabriel','galar','garotar','garoto','gata','gazeta','gaúcho','geconomia','george','giants','gilberto','gl','gleisi','glo','global','gmt','go','goiá','goiânia','google','gov','govern','granir','graziane','grazie','graça','grec','grego','grécia','guedes','guido','guimarães','gustavo','ha','haha','hahaha','hahahah','hahahahaha','ham','hamilton','haruhiko','hatch','hd','he','hehe','hehehe','heim','henrique','hermes','hillary','hj','ho','hoj','hojee','home','hrs','hs','hsbc','hum','humildar','ibc','ibef','idear','idec','ied','iene','if','ifi','igps','il','im','imo','imp','impressor','in','inc','ind','indi','indic','inf','infl','inflacio','info','inform','insper','inst','instituiç','inter','intervir','invistaativa','ip','ipa','iriar','irã','is','isaac','iso','istoé','it','itamar','itau','itaú','itub','itália','iv','ja','jair','jaja','japonês','japão','jb','jbfm','jc','jean','jeito','jesus','jmc','jn','joao','joaquim','joca','joesley','jordano','jorge','jornaldobrasil','jose','josias','josé','jp','jpmorgan','jr','ju','jud','juliano','julio','july','jumento','june','jur','júlio','ka','kanczuk','kassio','kayros','kd','kelly','kennedy','keynes','keynesiano','kia','kihara','kit','kliass','km','kroll','kuntz','kupfer','kuroda','lacerda','lagarde','lara','latif','lato','laura','leandro','legar','leika','leiloar','leitão','lenir','leo','librar','light','lindar','lise','lives','llx','lopes','lp','ltesouro','lu','lua','lucia','luciana','luis','lupi','luzir','luís','ly','lá','lírio','lúcia','ma','macedo','maciel','maisassine','makavelijones','malan','malparar','man','mandetta','maniero','manifes','manir','mansueto','mant','mantar','marcel','marcela','maria','marinhar','marino','mario','marita','marília','mastercard','mauro','may','mc','mcm','mdb','mds','mecado','med','medeiro','mei','meireles','meirelle','menezes','menino','mer','merc','mercad','merda','mero','mesa','mf','mg','mi','miami','michel','midiaconcopom','migar','miguel','ming','miriam','miriamleitaocom','mises','mj','mkt','mmt','mmx','mo','mobilar','mon','mone','monet','monetary','monetá','monetár','money','montezano','moody','moraes','moreira','mornar','mos','most','mostr','mov','movime','mp','ms','msn','mt','mto','mud','mv','mário','méxico','míriam','naquela','naquele','nath','natura','navalhar','nd','ne','nece','nechio','neh','nela','nele','nes','nest','net','neto','netto','news','newsletter','next','ngm','nigéria','ninguém','noblat','noel','nogueira','nomura','nono','nordeste','norte','nortear','novelar','nowotny','nubank','nuconta','nunes','ny','nº','nã','né','ní','nóbrega','oba','obama','obrar','obs','ocar','ocb','octavio','odebrecht','oesp','oeste','of','oglobo','oh','oi','oitavar','oitavo','oito','ok','oliv','olive','oliveira','oliveirarepórter','olá','on','onze','op','open','opopular','opovo','ops','oq','ordin','otavio','otoni','otonisão','otário','otávio','ourar','ovar','pa','pablo','pablotimbeta','pac','padilha','page','pagseguro','paix','palancar','palmar','palocci','pan','panar','papar','paper','paraná','paraíba','paribas','paridade','pariz','part','partici','pass','pat','patam','patama','patrício','paul','paula','paulinho','paulista','paulistano','paulo_guedes','paulocomitê','pay','paypal','paz','pb','pc','pdf','pe','pegn','pego','pegt','pel','peno','pequim','pera','perc','perce','percen','percent','pereira','perm','pernambuco','perspec','perspect','peru','pesq','pesquis','petista','petistas','petr','petro','photo','pi','pibs','pic','picchetti','picpay','pif','pig','piketty','pimentel','pinn','pixabay','player','players','please','pls','pm','pmi','pmis','pmpp','po','pochmann','podcast','poer','pois','pol','polibio','policy','polí','pon','pont','porquê','porrada','portanto','portugal','portuguesar','português','porém','pos','posi','posts','posturar','potiguar','powered','powershift','poxa','ppi','pq','pqp','pr','pra','pre','preju','pres','presentar','presid','president','prev','previs','princi','principa','pro','procautela','prod','prof','professorar','progre','proj','proje','prol','prox','prá','pró','prós','próx','próxi','pto','pts','pudim','puta','puto','putz','qndo','qr','qse','qto','qu','qua','qualquer','quantiar','quanto','quantum','quart','quase','qui','quin','quint','quot','quão','quê','ra','rafael','rafaela','rba','rcampos','rcn','re','rea','readout','reaj','real','reali','rec','recadar','recebilhões','recen','recife','record','red','redar','redepeabirus','redu','reduce','reduç','reinaldo','rel','relar','relat','renan','repicar','repór','repúblico','requião','res','research','resende','retorn','retweeted','reun','reut','reute','reuter','reuterspresidente','revelir','rf','rh','ribeiro','ribeirorepórter','ribeirão','riogs','ripple','riscala','rit','rj','rn','roberto','roberto_campos_neto','rocha','rodrigar','rogério','rolf','romero','rosar','rosenberg','rossi','roto','roubini','roupar','rousseff','rp','rs','rsrs','rti','rtuolnoticias','rtvalor','rtveja','rubem','russo','rá','rússia','sa','sabatino','safatle','safra','sal','salariar','salvador','sambar','samuel','santana','santander','santo','sanya','sao','sardenberg','sarney','sc','schahin','score','scoring','scr','script','seabra','sedan','seg','segu','seguid','segund','sel','seli','sema','seman','sempre','sen','send','senna','senão','sera','sergio','serrar','setubal','share','sharing','show','sicoob','sidnei','sidney','silvaebooks','silvio','simepar','sinali','sinalizaante','sino','sist','skaf','so','sob','sobr','soer','soh','som','soto','souza','sp','spx','spyer','sr','st','statement','status','stop','stênio','su','sudeste','suisse','sul','sumio','sunitrac','suplicy','surpreend','sus','suíço','sá','sérgio','ta','tal','talvez','tam','tamb','tanto','tao','tasa','tava','tax','taylor','taí','tb','tbem','tbm','tbolsa','tbrasil','tc','tcom','td','tde','tdiretor','tdis','tds','tdólar','tech','tecnoblog','ted','tel','telhar','temer','terca','tercer','tereza','terç','tesar','testo','thadeu','the','thiago','thread','ti','tiago','tim','timbeta','times','timing','tio','tn','to','toar','tocantim','toledo','tom','tomador','tomar','tomb','tombi','tombin','top','torós','tpresidente','tr','tra','trabal','trabucar','transferwise','través','trepercussão','trichet','trim','trump','tsistema','ttaxas','ttombini','tucano','tulio','turbar','turco','turquia','tvonlinefilmes','tweet','twitter','tá','túlio','uai','ue','ufa','ugt','uinstante','ulrich','ultimoinstante','undefined','undefineda','unibanco','uol','up','update','uruguai','us','usiminas','ué','va','valdo','valém','valéria','vao','var','varga','vaticano','vb','vc','vcs','vdd','ve','vei','venezuela','vero','vezar','viana','vicente','vidar','vigilan','vinicius','viomundo','vitor','vitória','vivian','vixe','viçar','vol','votorantim','vs','vía','wagner','waldery','washington','watch','way','web','webinar','wellton','werlang','wh','with','workshop','worldwide','www','xavier','xeque','xiii','xp','xvii','yahoo','yellen','yes','yield','york','zeina','zelândia','zlb','ªf','áfrico','álvaro','árabe','ásia','áustria','ão','è','índ','índi','índio','ñ','ó','ô','úl','últim','abar','abréu','adir','alagoa','alar','algum','amoedar','apo','arar','argentino','asiático','ateneu','ater','atro','austríaco','b','balir','bandar','barrir','basto','beijar','belo','bezerro','bofar','boletiom','bolsonarista','bom','bostar','boto','c','capitar','carolino','chino','chinês','ciar','coitar','colômbio','comigo','compassar','conceição','contudo','cordo','cruciar','deus','dp','comúnicado','comúnicar','comúnicação','consecutiv','consumid','imobiliár','inflaç','inflaçã','inflacao','preve','preç','recessãop','reduçã','també']
stopwords = corpus.stopwords.words('portuguese')
mystopwords = mystopwords + stopwords
del stopwords

def altera_expressoes(corpus):
    """
    Esta função é utilizada para reduzir a dimensionalidade de tokens no corpus.
    Une strings de expressões comuns com underscore '_'; ou
    Transforma expressões comuns em siglas; ou
    Transforma siglas em palavras
    """
    for i in range(0,len(corpus)):
        #corrige expressões comuns
        corpus[i] = re.sub('paulo guedes','paulo_guedes',corpus[i]) 
        corpus[i] = re.sub('política monetária','política_monetária',corpus[i]) 
        corpus[i] = re.sub('política econômica','política_econômica',corpus[i]) 
        corpus[i] = re.sub('política cambial','política_cambial',corpus[i]) 
        corpus[i] = re.sub('roberto campos neto','roberto_campos_neto',corpus[i]) 
        corpus[i] = re.sub('reservas internacionais','reservas_internacionais',corpus[i]) 
        corpus[i] = re.sub('produto interno bruto','pib',corpus[i]) 
        corpus[i] = re.sub('instituição financeira','if',corpus[i]) 
        corpus[i] = re.sub('instituições financeiras','if',corpus[i]) 
        corpus[i] = re.sub('operação compromissada','operação_compromissada',corpus[i]) 
        corpus[i] = re.sub('operações compromissadas','operação_compromissada',corpus[i]) 
        corpus[i] = re.sub('relatório trimestral de inflação','rti',corpus[i]) 
        corpus[i] = re.sub('relatório de inflação','rti',corpus[i]) 
        corpus[i] = re.sub('orçamento de guerra','orçamento_de_guerra',corpus[i]) 
        corpus[i] = re.sub('bi ','bilhões ',corpus[i]) 
        corpus[i] = re.sub('tri ','trilhões ',corpus[i]) 
        corpus[i] = re.sub('reunião do copom','copom',corpus[i]) 
        corpus[i] = re.sub('cheque especial','cheque_especial',corpus[i]) 
        corpus[i] = re.sub('conselho monetário nacional','cmn',corpus[i]) 
        corpus[i] = re.sub('relatório focus','focus',corpus[i]) 
        corpus[i] = re.sub('boletim focus','focus',corpus[i]) 
        corpus[i] = re.sub('reclamações','reclamação',corpus[i]) 
        corpus[i] = re.sub('estabilidade financeira','estabilidade_financeira',corpus[i]) 
        corpus[i] = re.sub('ministério da economia','ministério_da_economia',corpus[i]) 
        corpus[i] = re.sub('banco central do brasil','bcb',corpus[i]) 
        corpus[i] = re.sub('banco central','bc',corpus[i])
        corpus[i] = re.sub('déficit primário','déficit_primário',corpus[i]) 
        corpus[i] = re.sub('estabilidade financeira','estabilidade_financeira',corpus[i]) 
        corpus[i] = re.sub('estados unidos','eua',corpus[i]) 
        corpus[i] = re.sub('mercado financeiro','mercado_financeiro',corpus[i]) 
        corpus[i] = re.sub('taxa de juros','taxa_de_juros',corpus[i]) 
        corpus[i] = re.sub('taxa básica de juros','taxa_de_juros',corpus[i]) 
        corpus[i] = re.sub('taxa selic','taxa_selic',corpus[i]) 
        corpus[i] = re.sub('política monetária','política_monetária',corpus[i]) 
        corpus[i] = re.sub('depressso','depressão',corpus[i]) 
        corpus[i] = re.sub('curto prazo','curto_prazo',corpus[i]) 
        corpus[i] = re.sub('longo prazo','longo_prazo',corpus[i]) 
        corpus[i] = re.sub('médio prazo','médio_prazo',corpus[i]) 
        corpus[i] = re.sub('quantitative easing','quantitative_easing',corpus[i]) 
        corpus[i] = re.sub('qualitative easing','qualitative_easing',corpus[i]) 
        corpus[i] = re.sub('estados unidos','eua',corpus[i]) 
        corpus[i] = re.sub('dólares','dólar',corpus[i]) 
        corpus[i] = re.sub('dolares','dólar',corpus[i]) 
        corpus[i] = re.sub('usd','dólar',corpus[i]) 
        corpus[i] = re.sub('incertezas','incerteza',corpus[i]) 
        corpus[i] = re.sub('fake news','fake_news',corpus[i]) 
        corpus[i] = re.sub('circuit braker','circuit_braker',corpus[i]) 
        corpus[i] = re.sub('pass through','pass_through',corpus[i]) 
        corpus[i] = re.sub('pessoa física','pessoa_física',corpus[i]) 
        corpus[i] = re.sub('pessoa jurídica','pessoa_jurídica',corpus[i]) 
        corpus[i] = re.sub('jairbolsonaro','jair_bolsonaro',corpus[i]) 
        corpus[i] = re.sub('valores mobiliários','valores_mobiliários',corpus[i]) 
        corpus[i] = re.sub('valor mobiliário','valores_mobiliários',corpus[i]) 
    return corpus



def corrige_lema(corpus):
    """
    Corrige os lemas gerados pelo lematizador do Spacy.
    """
    for i in range(0,len(corpus)): # varre a lista de textos
        corpus[i] = re.sub('abismar', 'abismo', corpus[i])
        corpus[i] = re.sub('academiar', 'academia', corpus[i])
        corpus[i] = re.sub('acata ', 'acatar ', corpus[i])
        corpus[i] = re.sub('achata ', 'achatar ', corpus[i])
        corpus[i] = re.sub('aciona ', 'acionar ', corpus[i])
        corpus[i] = re.sub('acionistas ', 'acionista ', corpus[i])
        corpus[i] = re.sub('adm ', 'administrativo ', corpus[i])
        corpus[i] = re.sub('adivinho ', 'adivinhar ', corpus[i])
        corpus[i] = re.sub('admini ', 'administrativo ', corpus[i])
        corpus[i] = re.sub('administro ', 'administrar ', corpus[i])
        corpus[i] = re.sub(' adota ', ' adotar ', corpus[i])
        corpus[i] = re.sub(' adotada ', ' adotar ', corpus[i])
        corpus[i] = re.sub(' adotadas ', ' adotar ', corpus[i])
        corpus[i] = re.sub(' adotado ', ' adotar ', corpus[i])
        corpus[i] = re.sub(' adotaram ', ' adotar ', corpus[i])
        corpus[i] = re.sub(' adotará ', ' adotar ', corpus[i])
        corpus[i] = re.sub(' adotou ', ' adotar ', corpus[i])
        corpus[i] = re.sub(' afeta ', ' afetar ', corpus[i])
        corpus[i] = re.sub(' afetada ', ' afetar ', corpus[i])
        corpus[i] = re.sub(' afetado ', ' afetar ', corpus[i])
        corpus[i] = re.sub(' afetados ', ' afetar ', corpus[i])
        corpus[i] = re.sub(' afetando ', ' afetar ', corpus[i])
        corpus[i] = re.sub(' afetará ', ' afetar ', corpus[i])
        corpus[i] = re.sub(' afetou ', ' afetar ', corpus[i])
        corpus[i] = re.sub(' aposto ', ' apostar ', corpus[i])
        corpus[i] = re.sub(' aprofundo ', ' aprofundar ', corpus[i])
        corpus[i] = re.sub(' asegurar ', ' assegurar ', corpus[i])
        corpus[i] = re.sub(' atar ', ' ata ', corpus[i])
        corpus[i] = re.sub(' ativos ', ' ativo ', corpus[i])
        corpus[i] = re.sub(' atos ', ' ato ', corpus[i])
        corpus[i] = re.sub(' atua ', ' atuar ', corpus[i])
        corpus[i] = re.sub(' atuam ', ' atuar ', corpus[i])
        corpus[i] = re.sub(' atuando ', ' atuar ', corpus[i])
        corpus[i] = re.sub(' atuações ', ' atuação ', corpus[i])
        corpus[i] = re.sub(' atuado ', ' atuar ', corpus[i])
        corpus[i] = re.sub(' atuais ', ' atual ', corpus[i])
        corpus[i] = re.sub(' atualiza ', ' atualizar ', corpus[i])
        corpus[i] = re.sub(' atualizada ', ' atualizar ', corpus[i])
        corpus[i] = re.sub(' atualizadas ', ' atualizar ', corpus[i])
        corpus[i] = re.sub(' atualizado ', ' atualizar ', corpus[i])
        corpus[i] = re.sub(' atualizando ', ' atualizar ', corpus[i])
        corpus[i] = re.sub(' atualizou ', ' atualizar ', corpus[i])
        corpus[i] = re.sub('atividades', 'atividade', corpus[i])
        corpus[i] = re.sub('atrativos', 'atrativo', corpus[i])
        corpus[i] = re.sub('autônoma', 'autônomo', corpus[i])
        corpus[i] = re.sub('autônomos', 'autônomo', corpus[i])
        corpus[i] = re.sub('atualizações', 'atualização', corpus[i])
        corpus[i] = re.sub(' ações ', ' ação ', corpus[i])
        corpus[i] = re.sub('bancaria', 'bancário', corpus[i])
        corpus[i] = re.sub('bancario', 'bancário', corpus[i])
        corpus[i] = re.sub('bancões', 'bancão', corpus[i])
        corpus[i] = re.sub('bandar', 'banda', corpus[i])
        corpus[i] = re.sub('bandeiro', 'bandeira', corpus[i])
        corpus[i] = re.sub('basica', 'básico', corpus[i])
        corpus[i] = re.sub('básica', 'básico', corpus[i])
        corpus[i] = re.sub('bilhões', 'bilhão', corpus[i])
        corpus[i] = re.sub('bilhoes', 'bilhão', corpus[i])
        corpus[i] = re.sub('bilião', 'bilhão', corpus[i])
        corpus[i] = re.sub('bilionário', 'bilhionário', corpus[i])
        corpus[i] = re.sub('bloguear', 'blog', corpus[i])
        corpus[i] = re.sub('bolhar', 'bolha', corpus[i])
        corpus[i] = re.sub('bolsar', 'bolsa', corpus[i])
        corpus[i] = re.sub('buracar', 'buraco', corpus[i])
        corpus[i] = re.sub('cairam', 'cair', corpus[i])
        corpus[i] = re.sub('calculador', 'calculado', corpus[i])
        corpus[i] = re.sub(' calmar ', ' calmo ', corpus[i])
        corpus[i] = re.sub('camara', 'câmara', corpus[i])
        corpus[i] = re.sub('cambiar', 'câmbio', corpus[i])
        corpus[i] = re.sub('candidata ', 'candidato ', corpus[i])
        corpus[i] = re.sub('cartao', 'cartão', corpus[i])
        corpus[i] = re.sub('cartoes', 'cartão', corpus[i])
        corpus[i] = re.sub('cenario', 'cenário', corpus[i])
        corpus[i] = re.sub('cartar', 'carta', corpus[i])
        corpus[i] = re.sub('centrar', 'centro', corpus[i])
        corpus[i] = re.sub('certar', 'certo', corpus[i])
        corpus[i] = re.sub('chapar', 'chapa', corpus[i])
        corpus[i] = re.sub('cincar', 'cinco', corpus[i])
        corpus[i] = re.sub('cinzar', 'cinza', corpus[i])
        corpus[i] = re.sub('colegiada ', 'colegiado ', corpus[i])
        corpus[i] = re.sub('colegiados ', 'colegiado ', corpus[i])
        corpus[i] = re.sub('colecionadores', 'colecionador', corpus[i])
        corpus[i] = re.sub('coloucou', 'colocar', corpus[i])
        corpus[i] = re.sub('comite', 'comitê', corpus[i])
        corpus[i] = re.sub('comité', 'comitê', corpus[i])
        corpus[i] = re.sub('compromissadas', 'compromissada', corpus[i])
        corpus[i] = re.sub(' comprometa ', ' comprometer ', corpus[i])
        corpus[i] = re.sub(' comúnica ', ' comunicar ', corpus[i])
        corpus[i] = re.sub(' comúnicado ', ' comunicado ', corpus[i])
        corpus[i] = re.sub(' comúnicados ', ' comunicado ', corpus[i])
        corpus[i] = re.sub(' comúnicar ', ' comunicar ', corpus[i])
        corpus[i] = re.sub(' comúnicação ', ' comunicação ', corpus[i])
        corpus[i] = re.sub(' comúnicações ', ' comunicação ', corpus[i])
        corpus[i] = re.sub(' concursados ', ' concursado ', corpus[i])
        corpus[i] = re.sub(' consecutiv ', ' consecutivo ', corpus[i])
        corpus[i] = re.sub('conjuntar', 'conjunto', corpus[i])
        corpus[i] = re.sub('consecutiv ', 'consecutivo ', corpus[i])
        corpus[i] = re.sub('consulto ', 'consultar ', corpus[i])
        corpus[i] = re.sub('contrata ', 'contratar ', corpus[i])
        corpus[i] = re.sub(' constata ', ' constatar ', corpus[i])
        corpus[i] = re.sub(' consumid ', ' consumidor ', corpus[i])
        corpus[i] = re.sub(' contido ', ' conter ', corpus[i])
        corpus[i] = re.sub('controlo ', 'controlar ', corpus[i])
        corpus[i] = re.sub('copar ', 'copa ', corpus[i])
        corpus[i] = re.sub('consumid ', 'consumidor ', corpus[i])
        corpus[i] = re.sub('contábeis', 'contábil', corpus[i])
        corpus[i] = re.sub('correntistas', 'correntista', corpus[i])
        corpus[i] = re.sub('corretar', 'correto', corpus[i])
        corpus[i] = re.sub(' contrata ', ' contratar ', corpus[i])
        corpus[i] = re.sub(' corona ', ' coronavírus ', corpus[i])
        corpus[i] = re.sub(' correções ', ' correção ', corpus[i])
        corpus[i] = re.sub(' crescim ', ' crescimento ', corpus[i])
        corpus[i] = re.sub(' crescimen ', ' crescimento ', corpus[i])
        corpus[i] = re.sub(' crédit ', ' crédito ', corpus[i])
        corpus[i] = re.sub(' curvar ', ' curva ', corpus[i])
        corpus[i] = re.sub('criptomoedas', 'criptomoeda', corpus[i])
        corpus[i] = re.sub(' datar ', ' data ', corpus[i])
        corpus[i] = re.sub(' debêntures ', ' debênture ', corpus[i])
        corpus[i] = re.sub('defasada', 'defasado', corpus[i])
        corpus[i] = re.sub('defasados', 'defasado', corpus[i])
        corpus[i] = re.sub(' depoiss ', ' depois ', corpus[i])
        corpus[i] = re.sub(' desarrumo ', ' desarrumar ', corpus[i])
        corpus[i] = re.sub(' descarta ', ' descartar ', corpus[i])
        corpus[i] = re.sub(' desestimula ', ' desestimular ', corpus[i])
        corpus[i] = re.sub(' desfechar ', ' desfecho ', corpus[i])
        corpus[i] = re.sub(' desidrata ', ' desidratar ', corpus[i])
        corpus[i] = re.sub('desinflacionários', 'desinflacionário', corpus[i])
        corpus[i] = re.sub('desonestar', 'desonesto', corpus[i])
        corpus[i] = re.sub('defasagens', 'defasagem', corpus[i])
        corpus[i] = re.sub(' devido ', ' dever ', corpus[i])
        corpus[i] = re.sub('diferençar', 'diferença', corpus[i])
        corpus[i] = re.sub(' direcionados ', ' direcionar ', corpus[i])
        corpus[i] = re.sub(' direcionado ', ' direcionar ', corpus[i])
        corpus[i] = re.sub(' direcionada ', ' direcionar ', corpus[i])
        corpus[i] = re.sub('diretora', 'diretor', corpus[i])
        corpus[i] = re.sub('diretores', 'diretor', corpus[i])
        corpus[i] = re.sub('diretrizes', 'diretriz', corpus[i])
        corpus[i] = re.sub('direções', 'direção', corpus[i])
        corpus[i] = re.sub(' disserám ', ' dizer ', corpus[i])
        corpus[i] = re.sub('doleiros', 'doleiro', corpus[i])
        corpus[i] = re.sub(' dolar ', ' dólar ', corpus[i])
        corpus[i] = re.sub(' dóla ', ' dólar ', corpus[i])
        corpus[i] = re.sub(' dólarbrl ', ' dólar ', corpus[i])
        corpus[i] = re.sub(' dove ', ' dovish ', corpus[i])
        corpus[i] = re.sub('drogar ', 'droga ', corpus[i])
        corpus[i] = re.sub('déficits', 'déficit', corpus[i])
        corpus[i] = re.sub(' econômica ', ' econômico ', corpus[i])
        corpus[i] = re.sub(' econômicas ', ' econômico ', corpus[i])
        corpus[i] = re.sub(' economico ', ' econômico ', corpus[i])
        corpus[i] = re.sub(' económico ', ' econômico ', corpus[i])
        corpus[i] = re.sub(' econômicos ', ' econômico ', corpus[i])
        corpus[i] = re.sub('eletrônica', 'eletrônico', corpus[i])
        corpus[i] = re.sub('eletrônicos', 'eletrônico', corpus[i])
        corpus[i] = re.sub(' eletrobras ', ' eletrobrás ', corpus[i])
        corpus[i] = re.sub('emergenciais', 'emergencial', corpus[i])
        corpus[i] = re.sub('empresar', 'empresa', corpus[i])
        corpus[i] = re.sub('entrelinhar', 'entrelinha', corpus[i])
        corpus[i] = re.sub('espectativa', 'expectativa', corpus[i])
        corpus[i] = re.sub('esperançar', 'esperança', corpus[i])
        corpus[i] = re.sub('espertar', 'esperto', corpus[i])
        corpus[i] = re.sub('estimativo', 'estimativa', corpus[i])
        corpus[i] = re.sub('estimulativa', 'estimulativo', corpus[i])
        corpus[i] = re.sub('estimulativos', 'estimulativo', corpus[i])
        corpus[i] = re.sub('estrangeirar', 'estrangeiro', corpus[i])
        corpus[i] = re.sub(' estratosféricos ', ' estratosférico ', corpus[i])
        corpus[i] = re.sub(' estratoférico ', ' estratosférico ', corpus[i])
        corpus[i] = re.sub(' estratoféricos ', ' estratosférico ', corpus[i])
        corpus[i] = re.sub('estressa', 'estresse', corpus[i])
        corpus[i] = re.sub('eternar', 'eterno', corpus[i])
        corpus[i] = re.sub('extremar', 'extremo', corpus[i])
        corpus[i] = re.sub('faixar', 'faixa', corpus[i])
        corpus[i] = re.sub('falsar', 'falso', corpus[i])
        corpus[i] = re.sub(' faturam ', ' faturar ', corpus[i])
        corpus[i] = re.sub(' faturas ', ' fatura ', corpus[i])
        corpus[i] = re.sub('feirar', 'feira', corpus[i])
        corpus[i] = re.sub('filhar', 'filho', corpus[i])
        corpus[i] = re.sub(' fiis ', ' fii ', corpus[i])
        corpus[i] = re.sub('fintechs', 'fintech', corpus[i])
        corpus[i] = re.sub(' fracionárias ', ' fracionária ', corpus[i])
        corpus[i] = re.sub(' freia ', ' frear ', corpus[i])
        corpus[i] = re.sub('futurar', 'futuro', corpus[i])
        corpus[i] = re.sub('grupar', 'grupo', corpus[i])
        corpus[i] = re.sub('gênios', 'gênio', corpus[i])
        corpus[i] = re.sub(' goelar ', ' goela ', corpus[i])
        corpus[i] = re.sub(' ibov ', ' ibovespa ', corpus[i])
        corpus[i] = re.sub(' indice ', ' índice ', corpus[i])
        corpus[i] = re.sub('inflacionária', 'inflacionário', corpus[i])
        corpus[i] = re.sub('inflacionárias', 'inflacionário', corpus[i])
        corpus[i] = re.sub('inflacionários', 'inflacionário', corpus[i])
        corpus[i] = re.sub(' inflacao ', ' inflação ', corpus[i])
        corpus[i] = re.sub(' inflation ', ' inflação ', corpus[i])
        corpus[i] = re.sub(' inflaç ', ' inflação ', corpus[i])
        corpus[i] = re.sub(' inflaçã ', ' inflação ', corpus[i])
        corpus[i] = re.sub('injeções', 'injeção', corpus[i])
        corpus[i] = re.sub('intervalar', 'intervalo', corpus[i])
        corpus[i] = re.sub('interviu', 'intervir', corpus[i])
        corpus[i] = re.sub('judiciar', 'judiciário', corpus[i])
        corpus[i] = re.sub(' juro ', ' juros ', corpus[i])
        corpus[i] = re.sub('justiçar', 'justiça', corpus[i])
        corpus[i] = re.sub('jurar', 'juro', corpus[i])
        corpus[i] = re.sub('leigar', 'leigo', corpus[i])
        corpus[i] = re.sub('lentar', 'lento', corpus[i])
        corpus[i] = re.sub('lfts', 'lft', corpus[i])
        corpus[i] = re.sub('macroeconomias', 'macroeconomia', corpus[i])
        corpus[i] = re.sub('macroeconômica', 'macroeconomia', corpus[i])
        corpus[i] = re.sub('macroeconômicas', 'macroeconomia', corpus[i])
        corpus[i] = re.sub('macroeconômico', 'macroeconomia', corpus[i])
        corpus[i] = re.sub('macroeconômicos', 'macroeconomia', corpus[i])
        corpus[i] = re.sub('macroprudenciais', 'macroprudencial', corpus[i])
        corpus[i] = re.sub(' mail ', ' email ', corpus[i])
        corpus[i] = re.sub('malucar', 'maluco', corpus[i])
        corpus[i] = re.sub(' manteu ', ' manter ', corpus[i])
        corpus[i] = re.sub(' maquininhas', ' maquininha ', corpus[i])
        corpus[i] = re.sub('maõs', 'mão', corpus[i])
        corpus[i] = re.sub('maravilhar', 'maravilha', corpus[i])
        corpus[i] = re.sub(' mear ', ' meio ', corpus[i])
        corpus[i] = re.sub(' medio ', ' médio ', corpus[i])
        corpus[i] = re.sub(' meter ', ' meta ', corpus[i])
        corpus[i] = re.sub(' midia ', 'mídia ', corpus[i])
        corpus[i] = re.sub(' milionário ', 'milhionário ', corpus[i])
        corpus[i] = re.sub(' milionario ', 'milhionário ', corpus[i])
        corpus[i] = re.sub('mínima', 'mínimo', corpus[i])
        corpus[i] = re.sub('ministrar', 'ministro', corpus[i])
        corpus[i] = re.sub('minutar', 'minuta', corpus[i])
        corpus[i] = re.sub('mercar', 'mercado', corpus[i])
        corpus[i] = re.sub('monetári ', 'monetário ', corpus[i])
        corpus[i] = re.sub('monetaria ', 'monetário ', corpus[i])
        corpus[i] = re.sub(' odio ', ' ódio ', corpus[i])
        corpus[i] = re.sub(' orçamentar ', ' orçamento ', corpus[i])
        corpus[i] = re.sub('orçamentária ', 'orçamentário ', corpus[i])
        corpus[i] = re.sub('orçamentários ', 'orçamentário ', corpus[i])
        corpus[i] = re.sub('otimistas', 'otimista', corpus[i])
        corpus[i] = re.sub(' parabens ', ' parabéns ', corpus[i])
        corpus[i] = re.sub(' parabém ', ' parabéns ', corpus[i])
        corpus[i] = re.sub('passivar', 'passivo', corpus[i])
        corpus[i] = re.sub('pedrar', 'pedra', corpus[i])
        corpus[i] = re.sub('planeja', 'planejar', corpus[i])
        corpus[i] = re.sub('planejam', 'planejar', corpus[i])
        corpus[i] = re.sub('planejarm', 'planejar', corpus[i])
        corpus[i] = re.sub('plautonomia', 'pl autonomia', corpus[i])
        corpus[i] = re.sub('perigar', 'perigo', corpus[i])
        corpus[i] = re.sub(' periodo ', ' período ', corpus[i])
        corpus[i] = re.sub(' petrobras ', ' petrobrás ', corpus[i])
        corpus[i] = re.sub(' pmes ', ' pme ', corpus[i])
        corpus[i] = re.sub(' polêmico ', ' polêmica ', corpus[i])
        corpus[i] = re.sub('politicar', 'política', corpus[i])
        corpus[i] = re.sub(' políti ', ' política ', corpus[i])
        corpus[i] = re.sub(' polític ', ' política ', corpus[i])
        corpus[i] = re.sub('porcentuais', 'porcentual', corpus[i])
        corpus[i] = re.sub('precifica ', 'precificar ', corpus[i])
        corpus[i] = re.sub('precificada ', 'precificar ', corpus[i])
        corpus[i] = re.sub('precificado ', 'precificar ', corpus[i])
        corpus[i] = re.sub('precificando ', 'precificar ', corpus[i])
        corpus[i] = re.sub('precificou ', 'precificar ', corpus[i])
        corpus[i] = re.sub(' prejuizo ', ' prejuízo ', corpus[i])
        corpus[i] = re.sub(' preç ', ' preço ', corpus[i])
        corpus[i] = re.sub(' presar ', ' preso ', corpus[i])
        corpus[i] = re.sub(' preservas ', ' preservar ', corpus[i])
        corpus[i] = re.sub(' presto ', ' prestar ', corpus[i])
        corpus[i] = re.sub('pretextar', 'pretexto', corpus[i])
        corpus[i] = re.sub('previsao ', 'previsão ', corpus[i])
        corpus[i] = re.sub('previsõe ', 'previsão ', corpus[i])
        corpus[i] = re.sub(' quedo ', ' queda ', corpus[i])
        corpus[i] = re.sub(' profundar ', ' profundo ', corpus[i])
        corpus[i] = re.sub(' projeç ', ' projeção ', corpus[i])
        corpus[i] = re.sub(' projeçã ', ' projeção ', corpus[i])
        corpus[i] = re.sub(' projeções', ' projeção', corpus[i])
        corpus[i] = re.sub(' próxima ', ' próximo ', corpus[i])
        corpus[i] = re.sub(' próxim ', ' próximo ', corpus[i])
        corpus[i] = re.sub('prêmios', 'prêmio', corpus[i])
        corpus[i] = re.sub(' publicou ', ' publicar ', corpus[i])
        corpus[i] = re.sub(' quadrar ', ' quadro ', corpus[i])
        corpus[i] = re.sub('quarentenar ', 'quarentena ', corpus[i])
        corpus[i] = re.sub('quartar ', 'quarto ', corpus[i])
        corpus[i] = re.sub('quentar ', 'quente ', corpus[i])
        corpus[i] = re.sub(' quintar ', ' quinta ', corpus[i])
        corpus[i] = re.sub('raivar ', 'raiva ', corpus[i])
        corpus[i] = re.sub('raposar ', 'raposar ', corpus[i])
        corpus[i] = re.sub('reações ', 'reação ', corpus[i])
        corpus[i] = re.sub(' realimenta ', ' realimentar ', corpus[i])
        corpus[i] = re.sub('recebido ', 'receber ', corpus[i])
        corpus[i] = re.sub(' recessãop ', ' recessão ', corpus[i])
        corpus[i] = re.sub(' reduçã ', ' redução ', corpus[i])
        corpus[i] = re.sub('reflete ', 'refletir ', corpus[i])
        corpus[i] = re.sub('refletem ', 'refletir ', corpus[i])
        corpus[i] = re.sub('refletindo ', 'refletir ', corpus[i])
        corpus[i] = re.sub('refletiu ', 'refletir ', corpus[i])
        corpus[i] = re.sub(' regrar ', ' regra ', corpus[i])
        corpus[i] = re.sub(' relata ', ' relatar ', corpus[i])
        corpus[i] = re.sub(' relativamen ', ' relativamente ', corpus[i])
        corpus[i] = re.sub(' relatorio ', ' relatório ', corpus[i])
        corpus[i] = re.sub(' relatóri ', ' relatório ', corpus[i])
        corpus[i] = re.sub(' relatóro ', ' relatório ', corpus[i])
        corpus[i] = re.sub(' rentistas ', ' rentista ', corpus[i])
        corpus[i] = re.sub(' reporter ', ' repórter ', corpus[i])
        corpus[i] = re.sub(' repórt ', ' repórter ', corpus[i])
        corpus[i] = re.sub(' repórte ', ' repórter ', corpus[i])
        corpus[i] = re.sub('rotativar', 'rotativo', corpus[i])
        corpus[i] = re.sub('respostar', 'resposta', corpus[i])
        corpus[i] = re.sub('reservar', 'reservas', corpus[i])
        corpus[i] = re.sub('reune', 'reunir', corpus[i])
        corpus[i] = re.sub('reversar', 'reverso', corpus[i])
        corpus[i] = re.sub('ritmar', 'ritmo', corpus[i])
        corpus[i] = re.sub('riscar', 'risco', corpus[i])
        corpus[i] = re.sub('rumar', 'rumo', corpus[i])
        corpus[i] = re.sub('segredar', 'segredo', corpus[i])
        corpus[i] = re.sub(' semestr ', ' semestre ', corpus[i])
        corpus[i] = re.sub('setores ', 'setor ', corpus[i])
        corpus[i] = re.sub('sigilar ', 'sigilo ', corpus[i])
        corpus[i] = re.sub('spreads ', 'spread ', corpus[i])
        corpus[i] = re.sub('startups ', 'startup ', corpus[i])
        corpus[i] = re.sub(' submeta ', ' submeter ', corpus[i])
        corpus[i] = re.sub('sujeitar ', 'sujeito ', corpus[i])
        corpus[i] = re.sub('surpresar ', 'surpreso ', corpus[i])
        corpus[i] = re.sub('swaps ', 'swap ', corpus[i])
        corpus[i] = re.sub(' també ', ' também ', corpus[i])
        corpus[i] = re.sub('tardar ', 'tarde ', corpus[i])
        corpus[i] = re.sub('tarefar ', 'tarefa ', corpus[i])
        corpus[i] = re.sub('taxar ', 'taxa ', corpus[i])
        corpus[i] = re.sub('terceirar ', 'terceiro ', corpus[i])
        corpus[i] = re.sub('terçar ', 'terça ', corpus[i])
        corpus[i] = re.sub('tesourar ', 'tesouro ', corpus[i])
        corpus[i] = re.sub('traders ', 'trader ', corpus[i])
        corpus[i] = re.sub('trades ', 'trade ', corpus[i])
        corpus[i] = re.sub('swaps ', 'swap ', corpus[i])
        corpus[i] = re.sub(' trata ', ' tratar ', corpus[i])
        corpus[i] = re.sub(' trazido ', ' trazer ', corpus[i])
        corpus[i] = re.sub(' tx ', ' taxa ', corpus[i])
        corpus[i] = re.sub(' txt ', ' texto ', corpus[i])
        corpus[i] = re.sub(' unico ', ' único ', corpus[i])
        corpus[i] = re.sub(' usurar ', ' usura ', corpus[i])
        corpus[i] = re.sub(' vacar ', ' vaca ', corpus[i])
        corpus[i] = re.sub(' varejar ', ' varejo ', corpus[i])
        corpus[i] = re.sub('varejistas ', 'varejista ', corpus[i])
        corpus[i] = re.sub(' vaziar ', ' vazio ', corpus[i])
        corpus[i] = re.sub(' vermelhar ', ' vermelho ', corpus[i])
        corpus[i] = re.sub('vidrar ', 'vidro ', corpus[i])
        corpus[i] = re.sub(' vigent ', ' vigente ', corpus[i])
        corpus[i] = re.sub(' volumar ', ' volume ', corpus[i])
        corpus[i] = re.sub('vário ', 'vários ', corpus[i])
        corpus[i] = re.sub('seriar', 'ser', corpus[i])
        corpus[i] = re.sub('zera ', 'zerar ', corpus[i])
        corpus[i] = re.sub('ótima ', 'ótimo ', corpus[i])
        corpus[i] = re.sub('ótimos ', 'ótimo ', corpus[i])
        corpus[i] = re.sub('últim ', 'último ', corpus[i])
        corpus[i] = re.sub('deputados','deputado',corpus[i]) 
        corpus[i] = re.sub('moedas','moeda',corpus[i]) 
        corpus[i] = re.sub('empréstimos','empréstimo',corpus[i]) 
        corpus[i] = re.sub('empresaial','empresarial',corpus[i]) 
        corpus[i] = re.sub('financiamentos','financiamento',corpus[i]) 
        corpus[i] = re.sub('presidentes','presidente',corpus[i]) 
        corpus[i] = re.sub('corretoras','corretora',corpus[i]) 
        corpus[i] = re.sub('atividades','atividade',corpus[i]) 
        corpus[i] = re.sub('cobranças','cobrança',corpus[i]) 
        corpus[i] = re.sub('aposentados','aposentado',corpus[i]) 
        corpus[i] = re.sub('consignados','consignado',corpus[i]) 
        corpus[i] = re.sub('servidores','servidor',corpus[i]) 
        corpus[i] = re.sub('autoridades','autoridade',corpus[i]) 
        corpus[i] = re.sub('podres','podre',corpus[i]) 
        corpus[i] = re.sub('reclamações','reclamação',corpus[i]) 
        corpus[i] = re.sub('enormes','enorme',corpus[i]) 
        corpus[i] = re.sub('riscos','risco',corpus[i]) 
        corpus[i] = re.sub('problemas','problema',corpus[i]) 
        corpus[i] = re.sub('milagres','milagre',corpus[i]) 
        corpus[i] = re.sub('argumentos','argumento',corpus[i]) 
        corpus[i] = re.sub('apostas','aposta',corpus[i]) 
        corpus[i] = re.sub('impactos','impacto',corpus[i]) 
        corpus[i] = re.sub('investidores','investidor',corpus[i]) 
        corpus[i] = re.sub('políticos','político',corpus[i]) 
        corpus[i] = re.sub('inflaçãooão','inflação',corpus[i])
        corpus[i] = re.sub('taxa_de_juross','taxa_de_juros',corpus[i])
        corpus[i] = re.sub('consecutivoo','consecutivo',corpus[i])
    return corpus