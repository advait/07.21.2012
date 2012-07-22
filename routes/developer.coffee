# developer.coffee
# Copyright 2012 Compucius

models = require '../models'

exports.index = (req, res) ->
  context = {}
  context.title = 'Developer'
  context.user = null
  if req.session.auth?
    models.User.findById Number(req.session.auth.userId), (err, doc) ->
      if doc?
        context.user = doc 
      res.render "developer",
        context: context
  else
    res.render "developer",
      context: context

