# Greylocku!
# TODO: get a name

colors = require 'colors'
connect = require 'connect'
connect_assets = require 'connect-assets'
cookie = require 'cookie'
express = require 'express'
http = require 'http'
io = require 'socket.io'
routes = require './routes'


# Create server
app = module.exports = express.createServer()

app.configure ->
  app.set 'port', process.env.PORT || 8000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  # Middleware
  app.use express.favicon()
  app.use express.logger('dev')
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use connect_assets()  # Serve compiled assets
  #app.use express.static(__dirname + '/public')

# Dev/prod
app.configure 'development', ->
  app.use express.errorHandler({dumpExceptions: true, showStack: true})
app.configure 'production', ->
  app.use express.errorHandler()

# Routes
app.get '/', routes.index

# Setup web server
app.listen app.get('port'), ->
  console.log "Express server listening on port #{app.get('port')}"

# Setup socket.io
sio = io.listen app
sio.sockets.on 'connection', (socket) ->
  console.log "Recieved socket connection!".red
