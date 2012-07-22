# index.coffee
# Copyright 2012 Compucius

access_token = '2334787993255525024264726173982699884554'

models = require '../models'

exports.index = (req, res) ->
  console.log 'REQUEST'.red, req.user
  res.render "index",
    title: 'Jobs'

exports.jobs = (req, res) ->
  if !req.user?
    res.send('must be logged in')
  models.Job.find {'dev_id': Number(req.user._id)}, (err, jobs) ->
    if jobs.length == 0
      console.log 'couldnt find'.red
    else
      res.render 'jobs',
        title: 'Jobs'
        jobs: jobs

exports.client = (req, res) ->
  res.render 'client',
    title: 'Client'

exports.result = (req, res) ->
  models.Job.findById req.params.id, (err, doc) ->
    console.log doc
    res.send(doc)

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
  devid = if req.user? then req.user._id else if req.body.access == access_token then access_token else undefined
  console.log devid
  new_job = new models.Job(
    name: req.body.name
    data_type: req.body.data_type
    data: [req.body.data]
    code: req.body.code
    shard_count: Number(req.body.shard_count)
    dev_id: devid
  )
  console.log req.body
  new_job.save (err) ->
    if !err
      # success
      res.send 'success', 200
    else
      res.send 'failure', 400
      console.log err

