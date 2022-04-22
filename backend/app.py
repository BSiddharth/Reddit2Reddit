from flask import Flask, request
import praw
from dotenv import load_dotenv
import os

load_dotenv()


app = Flask(__name__)


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"

@app.route("/reddit-redirect/")
def reddit():
    code = request.args['code']
    state = request.args['state']
    print(code, state)
    reddit = praw.Reddit(
        client_id=os.getenv('APP_ID'),
        client_secret=os.getenv('SECRET'),
        user_agent=os.getenv('USER_AGENT'),  
        redirect_uri = 'http://192.168.1.52:5000/reddit-redirect/'   
    )
    reddit.auth.authorize(code)
    print(reddit.user.me().name)
    print(reddit.user.me().icon_img)

    return "<p>You can close the browser now!</p>"
