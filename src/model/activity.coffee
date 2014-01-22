mongoose = require 'mongoose'
config   = require 'config'
moment   = require 'moment'

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

ActivitySchema.statics.findByObjectNameAndAction = (objectName, action, callback) ->
  this.find({objectName: objectName, action: action}, callback);

Activity = mongoose.model config.mongooseRattle.Activity, ActivitySchema

Activity.mailer = null

Activity.prototype.setMailer = (mailer) ->
  @mailer = mailer

Activity.prototype.getMailer = ->
  @mailer

Activity.on 'objectCreation', (object) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.objectCreation
    objectId:      object._id
    objectName:    object.constructor.modelName
    targetId:      object._id
    actor:         object.owner
    date:          moment()
  }).save()
  # send email

Activity.on 'addComment', (object, message) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.addComment
    objectId:      object._id
    objectName:    object.constructor.modelName
    targetId:      message._id
    actor:         message.creator
    date:          moment()
  }).save()
  # send email
  # this.sendEmail('addComment', object, message)

Activity.on 'addReplyToComment', (object, reply) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.addReplyToComment
    objectId:      object._id
    objectName:    object.constructor.modelName
    targetId:      reply._id
    actor:         reply.creator
    date:          moment()
  }).save()
  # send email

Activity.on 'removeComment', (object, message) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.removeComment
    objectId:      object._id
    objectName:    object.constructor.modelName
    targetId:      object._id
    actor:         message.creator
    date:          moment()
  }).save()
  # send email

Activity.on 'addLike', (object, userId) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.addLike
    objectId:      object._id
    objectName:    object.constructor.modelName
    targetId:      userId
    actor:         userId
    date:          moment()
  }).save()
  # send email

Activity.on 'addLikeToComment', (object, commentId, userId) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.addLikeToComment
    objectId:      object._id
    objectName:    object.constructor.modelName
    targetId:      commentId
    actor:         userId
    date:          moment()
  }).save()
  # send email

Activity.on 'removeLike', (object, userId) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.removeLike
    objectId:      object._id
    objectName:    object.constructor.modelName
    targetId:      userId
    actor:         userId
    date:          moment()
  }).save()
  # send email

Activity.on 'removeLikeFromComment', (object, userId, commentId) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.removeLikeFromComment
    objectId:      object._id
    objectName:    object.constructor.modelName
    targetId:      commentId
    actor:         userId
    date:          moment()
  }).save()
  # send email

module.exports = Activity
