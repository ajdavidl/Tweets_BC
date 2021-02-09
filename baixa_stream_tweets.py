import tweepy
#import pandas as pd
from datetime import datetime
#import time
import json
import pickle

#intervalo em minutos
#intervalo = 10/60
#
## Twitter Api Credentials

# Twitter authentication stuff
global api
access_token = 'XXXXXXXXXX'
access_token_secret = 'XXXXXXXXXX'
consumer_key = 'XXXXXXXXXX'
consumer_secret = 'XXXXXXXXXX'
auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth, wait_on_rate_limit = True)
#api = tweepy.API(auth)

# Stream Listener class
class TweetStreamListener(tweepy.StreamListener):

    def __init__(self):
        super(TweetStreamListener, self).__init__()
        #initializes the counter
        self.counter = 0  
    # When data is received
    def on_data(self, posts):

        # Error handling because teachers say to do this
        try:
            dateTimeObj = datetime.now()
            timestampStr = dateTimeObj.strftime("%Y-%m-%d-%H-%M-%S-%f")
            print(timestampStr)
            dic = json.loads(posts)
            with open('dados\\tweets\\stream-tweets-'+timestampStr+'.pickle', 'wb') as f:
                pickle.dump(dic, f)
            f.close()
            self.counter = self.counter + 1
            print(dic['user']['screen_name'])
            print(dic['text'])
            print(self.counter, ' - ok\n')

        except Exception as e:
            print(e)
            pass

        if self.counter == 1000:
            return False
        else:
            return True

    def on_error(self, status_code):
        if status_code == 420:
            #returning False in on_error disconnects the stream
            return False



lista_queries = ["bc lang:pt filter:verified","bacen lang:pt",
                 "banco central lang:pt", "bcb lang:pt",
                 "#bancocentral lang:pt", "#bcb lang:pt", "#bc lang:pt",
                 "#bacen lang:pt","BancoCentralBR",
                 "Conselho Monetário Nacional","política monetária lang:pt",
                 "copom lang:pt", "#copom lang:pt" ,"#BancocentraldoBrasil"#,
                 ]

# Run the stream!
l = TweetStreamListener()
stream = tweepy.Stream(api.auth, l)

# Filter the stream for these keywords. Add whatever you want here!
stream.filter(track=lista_queries)

#ProtocolError: ('Connection broken: IncompleteRead(10 bytes read)', IncompleteRead(10 bytes read))