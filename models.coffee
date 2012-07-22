# models.coffee
# Copyright 2012 Compucius

mongoose = require 'mongoose'

# Connect to the database
mongoose.connect('mongodb://localhost/compucius');

# Jobs 
exports.Job = mongoose.model 'Job', new mongoose.Schema(
  state:
    type: String 
    enum: ['queued', 'in-progress', 'done', 'failed']
    required: true

  devId:
    type: String
    ref: 'User'

  code:
    type: String

  data: [
    type: String
  ]

  shardCount:
    type: Number
    default: 0
)

# Users
exports.User = mongoose.model 'User', new mongoose.Schema(
  firstName:
    type: String
    required: true

  lastName:
    type: String
    required: true

  email:
    type: String
    required: true

  fbAccessToken:
    type: String

  fbId:
    type: Number

  credits:
    type: Number
    default: 0
    required: true
)
