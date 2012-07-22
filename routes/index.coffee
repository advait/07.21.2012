# index.coffee
# Copyright 2012 Compucius

models = require("../models")

exports.index = (req, res) ->
  context = {}
  context.title = 'Home'
  context.user = null
  if req.session.auth?
    models.User.findById Number(req.session.auth.userId), (err, doc) ->
      if doc?
        context.user = doc 
      res.render "index",
        context: context
  else
    res.render "index",
      context: context
