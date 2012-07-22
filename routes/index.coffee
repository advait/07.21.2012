# index.coffee
# Copyright 2012 Compucius

models = require("../models")

exports.index = (req, res) ->
  console.log res
  res.render "index",
    title: "Express"
