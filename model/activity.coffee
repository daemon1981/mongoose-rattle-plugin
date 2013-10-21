mongoose = require 'mongoose'

Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId
User     = require './user'

actions = [
  'update',
  'addComment',
  'addReplyToComment',
  'removeComment',
  'addLike',
  'addLikeToComment',
  'removeLike',
  'removeLikeToComment'
 ]

ActivitySchema = new Schema(
  action:        type: String, index: true, enum: actions
  objectLink:    type: ObjectId
  objectName:    type: String
  actor:         type: ObjectId, ref: 'User', required: true
  date:          type: Date, index: true
)

Activity = mongoose.model "Activity", ActivitySchema

module.exports = Activity
