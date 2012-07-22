# models.coffee
# Copyright 2012 Compucius

mongoose = require 'mongoose'
exports.mongoose = mongoose

# Jobs
exports.Job = mongoose.model 'Job', new mongoose.Schema(
  state:
    type: String
    enum: ['queued', 'in-progress', 'done', 'failed']
    required: true

  devId:
    type: Number
    ref: 'User'

  code:
    type: String

  data: [
    type: String
  ]

  data_type:
    type: String
    enum: ['json', 'text']

  shard_count:
    type: Number
    default: 0

  result:
    type: Mixed
)

# Users
UserSchema = new mongoose.Schema(
  _id:
    type: Number

  first_name:
    type: String
    required: true

  last_name:
    type: String
    required: true

  email:
    type: String
    required: true

  fb_access_token:
    type: String

  is_developer:
    type: Boolean
    default: false

  credits:
    type: Number
    default: 0
)
UserSchema.virtual('name').get () ->
  return this.first_name + ' ' + this.last_name
exports.User = mongoose.model 'User', UserSchema
