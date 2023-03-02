import tweepy
import pymongo

# Mongo DB
db_connection = "mongodb://127.0.0.1:27017/"
myclient = pymongo.MongoClient(db_connection)
mydb = myclient["Twitter"]
mycol = mydb["AUT"]
# Twitter API
auth = tweepy.OAuthHandler("your_auth_here", "your_auth_here")
auth.set_access_token("your_access_token_here", "your_access_token_here")
api = tweepy.API(auth)
idlist = [
    "46623193",  # @sebastiankurz
    "117052823",  # @hcstrachefp
    "26750370",  # @spoe_at
    "444969570",  # @bmeinl
    "168482405",  # @peter_pilz
]


class MyStreamListener(tweepy.StreamListener):
    def on_status(self, status):
        mycol.insert_one(status._json)


myStreamListener = MyStreamListener()
myStream = tweepy.Stream(
    auth=api.auth, listener=myStreamListener, tweet_mode="extended"
)
myStream.filter(follow=idlist)
