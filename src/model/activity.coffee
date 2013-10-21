mongoose = require 'mongoose'

Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId

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
  objectId:      type: ObjectId
  objectName:    type: String
  targetId:      type: ObjectId
  actor:         type: ObjectId, ref: 'User', required: true
  date:          type: Date, index: true
)

ActivitySchema.statics.actions =
  update:              actions[0]
  addComment:          actions[1]
  addReplyToComment:   actions[2]
  removeComment:       actions[3]
  addLike:             actions[4]
  addLikeToComment:    actions[5]
  removeLike:          actions[6]
  removeLikeToComment: actions[7]

Activity = mongoose.model "Activity", ActivitySchema

module.exports = Activity
