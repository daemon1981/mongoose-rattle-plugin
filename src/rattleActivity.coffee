events = require 'events'
moment = require 'moment'

Activity = require './model/activity'

rattleActivity = new events.EventEmitter()

rattleActivity.mailer = null

rattleActivity.on 'objectCreation', (object) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.objectCreation
    objectId:      object._id
    objectName:    object.name
    targetId:      object._id
    actor:         object.owner
    date:          moment()
  }).save()
  # send email

rattleActivity.on 'addComment', (object, message) ->
  # save in activity collection
  new Activity({
    action:        Activity.actions.addComment
    objectId:      object._id
    objectName:    object.name
    targetId:      message._id
    actor:         message.creator
    date:          moment()
  }).save()
  # send email
  # this.sendEmail('addComment', object, message)

rattleActivity.on 'addReplyToComment', (object, commentId, reply) ->
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

rattleActivity.on 'removeComment', (object, message) ->
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

rattleActivity.on 'addLike', (object, userId) ->
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

rattleActivity.on 'addLikeToComment', (object, userId, commentId) ->
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

rattleActivity.on 'removeLike', (object, userId) ->
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

rattleActivity.on 'removeLikeFromComment', (object, userId, commentId) ->
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

rattleActivity.setMailer = (mailer) ->
  @mailer = mailer

rattleActivity.getMailer = ->
  @mailer

module.exports = rattleActivity
