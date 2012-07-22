# index.coffee
# Copyright 2012 Compucius

models = require("../models")

exports.index = (req, res) ->
  res.render "index",
    title: "Express"
