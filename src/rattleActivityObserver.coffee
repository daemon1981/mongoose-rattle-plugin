events = require 'events'
moment = require 'moment'

Activity = require './model/activity'

activityObserver = new events.EventEmitter()

activityObserver.mailer = null

activityObserver.on 'update', (object) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.update
    objectId:      object._id
    objectName:    object.name
    targetId:      object._id
    actor:         object.owner
    date:          moment()
  }).save()
  # send email

activityObserver.on 'addComment', (object, message) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.update
    objectId:      object._id
    objectName:    object.name
    targetId:      message._id
    actor:         message.creator
    date:          moment()
  }).save()
  # send email
  # this.sendEmail('addComment', object, message)

activityObserver.on 'addReplyToComment', (object, commentId, reply) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.addReplyToComment
    objectId:      object._id
    objectName:    object.name
    targetId:      reply._id
    actor:         reply.creator
    date:          moment()
  }).save()
  # send email

activityObserver.on 'removeComment', (object, message) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.removeComment
    objectId:      object._id
    objectName:    object.name
    targetId:      object._id
    actor:         message.creator
    date:          moment()
  }).save()
  # send email

activityObserver.on 'addLike', (object, userId) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.addLike
    objectId:      object._id
    objectName:    object.name
    targetId:      userId
    actor:         userId
    date:          moment()
  }).save()
  # send email

activityObserver.on 'addLikeToComment', (object, userId, commentId) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.addLikeToComment
    objectId:      object._id
    objectName:    object.name
    targetId:      commentId
    actor:         userId
    date:          moment()
  }).save()
  # send email

activityObserver.on 'removeLike', (object, userId) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.removeLike
    objectId:      object._id
    objectName:    object.name
    targetId:      userId
    actor:         userId
    date:          moment()
  }).save()
  # send email

activityObserver.on 'removeLikeFromComment', (object, userId, commentId) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.removeLikeFromComment
    objectId:      object._id
    objectName:    object.name
    targetId:      commentId
    actor:         userId
    date:          moment()
  }).save()
  # send email

activityObserver.setMailer = (mailer) ->
  @mailer = mailer

activityObserver.getMailer = ->
  @mailer

module.exports = activityObserver
