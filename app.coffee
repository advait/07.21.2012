# Greylocku!
# TODO: get a name

colors = require 'colors'
connect = require 'connect'
connect_assets = require 'connect-assets'
cookie = require 'cookie'
everyauth = require 'everyauth'
express = require 'express'
http = require 'http'
io = require 'socket.io'
routes = require './routes'


# Create server
app = module.exports = express.createServer()

# Store users and sessions in local memory
# TODO: MOVE THESE TO REDIS!
session_store = new connect.middleware.session.MemoryStore()
app.users = {}

# Setup everyauth facbeook
em = everyauth.everymodule
fb = everyauth.facebook
fb.appId '422148541157960'
fb.appSecret '8e5f5afc2d8a3eacd20604b4c6047442'
fb.entryPath('/auth/facebook')
fb.callbackPath('/auth/facebook/callback')
fb.scope('email')
em.findUserById (id, callback) ->
  # TODO: Make this work through redis
  if not app.users[id]?
    callback 'User not found'
  else
    callback null, app.users[id]
fb.handleAuthCallbackError (req, res) ->
  # If a user denies your app, Facebook will redirect the user to
  # /auth/facebook/callback?error_reason=user_denied&error=access_denied&error_description=The+user+denied+your+request.
  # This configurable route handler defines how you want to respond to
  # that.
  # If you do not configure this, everyauth renders a default fallback
  # view notifying the user that their authentication failed and why.
  console.log 'FACBEOOK ERROR HAPPENED!'
fb.findOrCreateUser (session, accessToken, accessTokExtra, fbUserMetadata) ->
  # TODO move this to redis
  app.users[fbUserMetadata.id] = fbUserMetadata
  # This is a "promise", a function that returns the use in the future
  promise = @Promise().fulfill fbUserMetadata
fb.redirectPath '/'

# App configuration
app.configure ->
  app.set 'port', process.env.PORT || 8000
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
  console.log "Express server listening on port #{app.get('port')}"

# Setup socket.io
sio = io.listen app
sio.sockets.on 'connection', (socket) ->
  console.log "Recieved socket connection!".red
