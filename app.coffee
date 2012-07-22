# compuci.us
# COMPUCIUS SAY THIS IS OUR SERVER

colors = require 'colors'
connect = require 'connect'
connect_assets = require 'connect-assets'
cookie = require 'cookie'
everyauth = require 'everyauth'
express = require 'express'
http = require 'http'
io = require 'socket.io'
redis = require 'redis'
routes = require './routes'


# Redis things
redis_client = redis.createClient()
RedisStore = require('connect-redis')(connect)
session_store = new RedisStore {client: redis_client}

# Create server
app = module.exports = express.createServer()

# Store users and sessions in local memory
# TODO: MOVE THESE TO REDIS!
app.users = {}

# Setup everyauth facbeook
#em = everyauth.everymodule
fb = everyauth.facebook
fb.appId '422148541157960'
fb.appSecret '8e5f5afc2d8a3eacd20604b4c6047442'
fb.entryPath('/auth/facebook')
fb.callbackPath('/auth/facebook/callback')
fb.scope('email')
fb.handleAuthCallbackError (req, res) ->
  # If a user denies your app, Facebook will redirect the user to
  # /auth/facebook/callback?error_reason=user_denied&error=access_denied&error_description=The+user+denied+your+request.
  # This configurable route handler defines how you want to respond to
  # that.
  # If you do not configure this, everyauth renders a default fallback
  # view notifying the user that their authentication failed and why.
  console.log 'FACBEOOK ERROR HAPPENED!'
fb.findOrCreateUser (session, accessToken, accessTokExtra, fbUserMetadata) ->
  # TODO move this to mongo
  promise = @Promise()
  user_key = "user:#{fbUserMetadata.id}"
  console.log 'REDIS GET'.blue
  redis_client.hgetall user_key, (err, user) ->
    if err? or not user?
      # Insert user
      user = fbUserMetadata
      redis_client.hmset user_key, fbUserMetadata
    promise.fulfill user
fb.redirectPath '/'

# App configuration
app.configure ->
  app.set 'port', process.env.PORT ? 8000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.set 'view options', {layout: false}
  # Middleware
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session {store: session_store, secret: 'GREYLOCKu!'}
  app.use everyauth.middleware()
  app.use app.router
  app.use connect_assets()  # Serve compiled assets
  #app.use express.static(__dirname + '/public')

# Add everyauth view helpers
everyauth.helpExpress app

# Dev/prod
app.configure 'development', ->
  app.use express.errorHandler({dumpExceptions: true, showStack: true})
app.configure 'production', ->
  app.use express.errorHandler()

# Routes
app.get '/', routes.index

# Setup web server
app.listen 8000, ->
  console.log "Express server listening"

# Setup socket.io
sio = io.listen app
sio.set 'authorization', (data, accept) ->
  # Only accept incoming sockets if we have a cookie
  if not data.headers.cookie?
    accept 'No cookies transmitted.', false  # Reject socket
  else
    data.cookie = cookie.parse data.headers.cookie
    data.sid = data.cookie['connect.sid']
    data.session_store = session_store
    session_store.get data.sid, (err, session) ->
      if err or not session? or not session.auth?
        accept err, false  # Reject socket
      else
        data.session = new connect.middleware.session.Session data, session
        accept null, true  # Accept socket
sio.sockets.on 'connection', (socket) ->
  hs = socket.handshake
  console.log "Socket from #{hs.session.auth.facebook.user.name}".red
