# client.coffee
# Copyright 2012 Compucius

models = require("../models")

exports.client = (req, res) ->
  context = {}
  context.title = 'Client'
  context.user = null
  if req.session.auth?
    models.User.findById Number(req.session.auth.userId), (err, doc) ->
      if doc?
        context.user = doc 
      res.render "client",
        context: context
  else
    res.render "client",
      context: context

