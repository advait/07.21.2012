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

exports.client = (req, res) ->
  res.render 'client',
    title: 'Client'

exports.jobs_new = (req, res) ->
  default_code = """
generateChunk(key) {
  return [{key: value}];
}

generateMap(key, value) {
  return [{key: value}];
}

generateReduction(key, value) {
  return [{key: value}];
}
  """
  res.render 'new_job',
    title: 'New Job'
    default_code: default_code

exports.jobs_new_process = (req, res) ->
  new_job = new models.Job(
    name: req.body.name
    data_type: req.body.data_type
    data: [req.body.data]
    code: req.body.code
    shard_count: Number(req.body.shard_count)
    dev_id: req.user._id
  )
  console.log req
  console.log new_job
  new_job.save (err) ->
    if !err
      # success
      res.send 'success', 200
    else
      res.send 'failure', 400
