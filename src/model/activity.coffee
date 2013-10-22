mongoose = require 'mongoose'
config   = require 'config'

Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId

actions = [
  'objectCreation',
  'addComment',
  'addReplyToComment',
  'removeComment',
  'addLike',
  'addLikeToComment',
  'removeLike',
  'removeLikeFromComment'
]

ActivitySchema = new Schema(
  action:        type: String, index: true, enum: actions
  objectId:      type: ObjectId
  objectName:    type: String
  targetId:      type: ObjectId
  actor:         type: ObjectId, ref: config.mongooseRattle.User, required: true
  date:          type: Date, index: true
)

ActivitySchema.statics.actions =
  objectCreation:        actions[0]
  addComment:            actions[1]
  addReplyToComment:     actions[2]
  removeComment:         actions[3]
  addLike:               actions[4]
  addLikeToComment:      actions[5]
  removeLike:            actions[6]
  removeLikeFromComment: actions[7]

Activity = mongoose.model config.mongooseRattle.Activity, ActivitySchema

module.exports = Activity
