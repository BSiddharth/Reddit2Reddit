from flask import Flask, request
import flask
import praw
from dotenv import load_dotenv
import os
from flask_sqlalchemy import SQLAlchemy
from requests import post
from praw.models import Comment, Submission


load_dotenv()


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///test.db'
db = SQLAlchemy(app)

class RedditUser(db.Model):
    id = db.Column(db.Integer, primary_key = True)
    state = db.Column(db.String, nullable = False)
    access_token = db.Column(db.String)
    img_link = db.Column(db.String)


@app.route("/reddit-redirect/")
def reddit():
    code = request.args['code']
    state = request.args['state']
    reddit = praw.Reddit(
        client_id=os.getenv('APP_ID'),
        client_secret=os.getenv('SECRET'),
        user_agent=os.getenv('USER_AGENT'),  
        redirect_uri = 'http://192.168.1.52:5000/reddit-redirect/'   
    )
    access_token = reddit.auth.authorize(code)
    print('kya ye bhi read only hai?',reddit.read_only)
    icon_img = reddit.user.me().icon_img
    
    user = RedditUser(state = state, access_token = access_token, img_link = icon_img)

    db.session.add(user)
    db.session.commit()

    return flask.Response(status=200)

@app.route("/profileImage/", methods = ["POST"])
def sendProfileImageLink():
    state = request.form['state']
    img_link = RedditUser.query.filter_by(state=state).first().img_link
    response = {'img_link' : img_link}

    return response


@app.route("/transfer/", methods = ["POST"])
def transfer():
    fromState = request.form['fromState']
    toState = request.form['toState']
    comments = True if request.form['comments'] == 'true' else False
    posts = True if request.form['posts'] == 'true' else False
    subreddits = True if request.form['subreddits'] == 'true' else False
    redditors = True if request.form['redditors'] == 'true' else False

    fromAccountToken = RedditUser.query.filter_by(state=fromState).first().access_token
    fromAccount = praw.Reddit(
       client_id=os.getenv('APP_ID'),
        client_secret=os.getenv('SECRET'),
        user_agent=os.getenv('USER_AGENT'),         
        refresh_token= fromAccountToken,       
    )

    toAccountToken = RedditUser.query.filter_by(state=toState).first().access_token
    toAccount = praw.Reddit(
       client_id=os.getenv('APP_ID'),
        client_secret=os.getenv('SECRET'),
        user_agent=os.getenv('USER_AGENT'),  
        refresh_token= toAccountToken,        
    )
    

    if subreddits:
        for subreddit in fromAccount.user.subreddits(limit=None):
            toAccount.subreddit(subreddit.display_name).subscribe()
    
    if posts or comments:
        for item in fromAccount.user.me().saved(limit=None):
            if isinstance(item, Comment) and comments:
                toAccount.comment(id=item.id).save()
            elif isinstance(item, Submission) and posts:
                toAccount.submission(id=item.id).save()         
    
    if redditors:
        for friend in fromAccount.user.friends():
            toAccount.redditor(friend.name).friend()

    return flask.Response(status=200)