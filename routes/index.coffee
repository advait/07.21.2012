# index.coffee
# Copyright 2012 Compucius

models = require("../models")

exports.index = (req, res) ->
  res.render "index",
    title: "Express"

exports.webworker = (req, res) ->
  job_id = req.param('jid', -1)
  res.send "self.postMessage('Hi there!');"
