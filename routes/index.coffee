# index.coffee
# Copyright 2012 Compucius

models = require("../models")

exports.index = (req, res) ->
  console.log 'REQUEST'.red, req.user
  res.render "index",
    title: 'Jobs'

exports.jobs = (req, res) ->
  res.render 'jobs',
    title: 'Jobs'
