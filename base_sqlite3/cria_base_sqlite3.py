
import GetOldTweets3 as got
import sqlite3

# CRIA A BASE DE DADOS SQLITE3 

connection = sqlite3.connect("tweets.db")

cursor = connection.cursor()

sql_command = """
CREATE TABLE tweet ( 
id VARCHAR(100) PRIMARY KEY, 
author_id INTEGER,
date DATE,
favorites INTEGER,
formatted_date VARCHAR(50),
geo VARCHAR(400),
hashtags VARCHAR(400),
mentions VARCHAR(400),
permalink VARCHAR(400),
replies INTEGER,
retweets INTEGER,
text VARCHAR(400),
urls VARCHAR(400),
username VARCHAR(400)
);"""

cursor.execute(sql_command)

tweetCriteria = got.manager.TweetCriteria().setQuerySearch('copom selic')\
                                           .setSince("2020-08-01")\
                                           .setUntil("2020-08-31")\
                                           .setMaxTweets(5)\
                                           .setLang('pt')
tweet = got.manager.TweetManager.getTweets(tweetCriteria)


for i in range(len(tweet)):
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
    cursor.execute(sql_command)

connection.commit()

connection.close()
