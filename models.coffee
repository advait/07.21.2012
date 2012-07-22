# models.coffee
# Copyright 2012 Compucius

mongoose = require 'mongoose'

# Connect to the database
mongoose.connect('mongodb://local.host/compucius');

# Jobs 
exports.Job = mongoose.model 'Job', new mongoose.Schema(
  states:
    type: String 
    enum: ['queued', 'in-progress', 'done', 'failed']
    required: true

  dev_id:
    type: mongoose.Schema.ObjectId
    ref: 'User'

  code: [
    type: String
  ]

  data:
    type: String
    default: ''

  shard_count:
    type: Number
    default: 0
)

# Users
UserSchema = new mongoose.Schema(
  _id:
    type: String

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
