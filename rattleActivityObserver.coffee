events = require 'events'

activity = new events.EventEmitter()

activity.on 'update', (object) ->
  # save in activity collection
  # send email

activity.on 'addComment', (object, userId, message) ->
  # save in activity collection
  # send email

module.exports = activity
