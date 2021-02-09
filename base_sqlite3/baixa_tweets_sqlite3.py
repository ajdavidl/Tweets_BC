
import GetOldTweets3 as got
import sqlite3
import re
import time
from datetime import datetime

def baixa_periodo(query, data_inicial, data_final):
    timestampStr = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    print(timestampStr," - ",data_inicial," - ",data_final," - ",query)
    #tweetCriteria = got.manager.TweetCriteria().setUsername("BancoCentralBR")\
    tweetCriteria = got.manager.TweetCriteria().setQuerySearch(query)\
                                               .setSince(data_inicial)\
                                               .setUntil(data_final)\
                                               .setMaxTweets(-1)\
                                               .setLang('pt')
    tweet = got.manager.TweetManager.getTweets(tweetCriteria)
    print(len(tweet))
    # insert into sqlite3
    for i in range(len(tweet)):
        if tweet[i].id not in lista_id:
            if '"' in tweet[i].text:
                #Necessário pois o caracter '"' quebra a query do sql
                tweet[i].text = re.sub('"','',tweet[i].text) 
            sql_command = """
            INSERT INTO tweet (id, author_id, date, favorites, formatted_date,
            geo, hashtags, mentions, permalink, replies, retweets, text, urls,
            username) VALUES ("{}", "{}", {}, {}, "{}", "{}", "{}", "{}", "{}", {}, {}, 
                              "{}", "{}", "{}");""".format(tweet[i].id,
                                              tweet[i].author_id,
                                              tweet[i].date.strftime("%Y-%m-%d-%H-%M-%S-%f"),
                                              tweet[i].favorites,
                                              tweet[i].formatted_date,
                                              tweet[i].geo,
                                              tweet[i].hashtags,
                                              tweet[i].mentions,
                                              tweet[i].permalink,
                                              tweet[i].replies,
                                              tweet[i].retweets,
                                              tweet[i].text,
                                              tweet[i].urls,
                                              tweet[i].username)
            lista_id.append(tweet[i].id) # necessário pois vem ids repetidos numa mesma leva
            cursor.execute(sql_command)
    print("Total de tweets: ",len(lista_id))
    connection.commit()
    return

connection = sqlite3.connect("tweets.db")
cursor = connection.cursor()


lista_queries = ["copom selic",
                 "copom juros",
                 "copom inflação",
                 "copom ipca",
                 "copom ata",
                 "copom comunicado",
                 "copom câmbio",
                 "copom dólar",
                 "copom bc",
                 "copom banco central",
                 "copom bcb",
                 "copom política monetária",
                 "copom relatório",
                 "copom pib",
                 "copom bacen",
                 "copom focus",
                 "focus bc",
                 "focus banco central",
                 "focus bacen",
                 "focus selic",
                 "focus juros",
                 "focus inflação",
                 "focus ipca",
                 "focus câmbio",
                 "focus dólar",
                 "focus pib",
                 "política monetária bc",
                 "política monetária bacen",
                 "política monetária banco central",
                 "BancoCentralBR",
                 "estabilidade financeira bc",
                 "estabilidade financeira bacen",
                 "estabilidade financeira banco central",
                 "comef bc",
                 "comef bacen",
                 "comef bcb",
                 "comef banco central",
                 "conselho monetário nacional",
                 "regulação bc",
                 "regulação banco central",
                 "regulação bacen",
                 "crédito banco central",
                 "crédito bacen",
                 "crédito bc",
                 "crédito bcb",
                 "inflação banco central",
                 "inflação bacen",
                 "inflação bc",
                 "inflação bcb",
                 "reservas internacionais banco central",
                 "reservas internacionais bacen",
                 "reservas internacionais bc",
                 "reservas internacionais bcb",
                 "comunicação banco central",
                 "comunicação bacen",
                 "comunicação bcb",
                 "comunicação bc",
                 "credibilidade banco central",
                 "credibilidade bacen",
                 "credibilidade bcb",
                 "credibilidade bc",
                 "redesconto banco central",
                 "redesconto bacen",
                 "redesconto bcb",
                 "redesconto bc"
                 ]


for query in lista_queries:
	#query = lista_queries[0]
		

	sql_command = """SELECT ID FROM tweet;"""

	cursor.execute(sql_command)

	lista_id = cursor.fetchall()

	lista_id = [idx[0] for idx in lista_id]


	for ano in range(2007,2021,1):


		for mes in range(1,13,1):
			#montagem das datas inicial e final
			if mes<10:
				data_inicial = str(ano)+'-0'+str(mes)+'-01'
				if mes==9:
					data_final = str(ano)+'-'+str(mes+1)+'-01'
				else:
					data_final = str(ano)+'-0'+str(mes+1)+'-01'
			else:
				if mes==12:
					data_inicial = str(ano)+'-'+str(mes)+'-01'
					data_final = str(ano+1)+'-01-01'
				else:
					data_inicial = str(ano)+'-'+str(mes)+'-01'
					data_final = str(ano)+'-'+str(mes+1)+'-01'
			if data_inicial == "2020-09-01":
				break
			timestampStr = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
			print(timestampStr," - ",data_inicial," - ",data_final," - ",query)
			
			# query para o twitter
			#tweetCriteria = got.manager.TweetCriteria().setUsername("BancoCentralBR")\
			tweetCriteria = got.manager.TweetCriteria().setQuerySearch(query)\
													   .setSince(data_inicial)\
													   .setUntil(data_final)\
													   .setMaxTweets(-1)\
													   .setLang('pt')
			tweet = got.manager.TweetManager.getTweets(tweetCriteria)
			print(len(tweet),"tweets em ",ano,"/",mes)
			# insert into sqlite3
			for i in range(len(tweet)):
				if tweet[i].id not in lista_id:
					if '"' in tweet[i].text:
						#Necessário pois o caracter '"' quebra a query do sql
						tweet[i].text = re.sub('"','',tweet[i].text) 
					sql_command = """
					INSERT INTO tweet (id, author_id, date, favorites, formatted_date,
					geo, hashtags, mentions, permalink, replies, retweets, text, urls,
					username) VALUES ("{}", "{}", {}, {}, "{}", "{}", "{}", "{}", "{}", {}, {}, 
									  "{}", "{}", "{}");""".format(tweet[i].id,
													  tweet[i].author_id,
													  tweet[i].date.strftime("%Y-%m-%d-%H-%M-%S-%f"),
													  tweet[i].favorites,
													  tweet[i].formatted_date,
													  tweet[i].geo,
													  tweet[i].hashtags,
													  tweet[i].mentions,
													  tweet[i].permalink,
													  tweet[i].replies,
													  tweet[i].retweets,
													  tweet[i].text,
													  tweet[i].urls,
													  tweet[i].username)
					lista_id.append(tweet[i].id) # necessário pois vem ids repetidos numa mesma leva
					cursor.execute(sql_command)
			print("Total de tweets: ",len(lista_id))
			connection.commit()
			#intervalo de tempo em segundos entre queries 
			intervalo = 25
			print("Esperando {:1}s...".format(intervalo))
			time.sleep(intervalo)