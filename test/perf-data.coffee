require './bootstrap-perf'

mongoose = require 'mongoose'
async    = require 'async'
winston  = require 'winston'

winston.remove winston.transports.Console
winston.add winston.transports.Console, colorize: true

Thingy   = require './models/thingy'

ObjectId  = mongoose.Types.ObjectId;

numThingies = 5
numLikes = 20000
numCommentLikes = 20
blockNumComments = 5000
numBlocks = 4

i = 0
likes = []
while i < numCommentLikes
  likes.push new ObjectId()
  i++

dummyComment =
  message:       'duuuuuuuuuuuummmmmmmmmmmmmmmmyyyyyyyyyyyyy meeeeeeeeeeeeessssssssssssaaaaaaaaaaaaaageeeeee'
  creator:       new ObjectId()
  likes:         likes
  likesCount:    type: Number, default: 0
  dateCreation:  type: Date
  dateUpdate:    type: Date

i = 0
comments = []
while i < blockNumComments
  comments.push dummyComment
  i++

createNewThingy = (callback) ->
  async.waterfall [
    createThingy = (next) ->
      winston.info('Create a new thingy');
      new Thingy(
        creator: new ObjectId()
      ).save next
    addComments = (createdThingy, numAffected, next) ->
      winston.info('Add comments with likes');

      i = 0
      async.whilst (->
        i < numBlocks
      ), ((callback) ->
        winston.info('Add block ' + (i + 1) + ' of ' + blockNumComments + ' comments');
        Thingy.update { _id: createdThingy._id }, { $pushAll: { comments: comments } }, (err) ->
          i++
          callback()
      ), (err) ->
        winston.info('Add likes');
        i = 0
        likes = []
        while i < numLikes
          likes.push new ObjectId()
          i++
        createdThingy.likes = likes
        createdThingy.save next
      
  ], (err) ->
    return callback(err) if err
    winston.info('Thingy saved');
    callback()


winston.info('Clear thingy collection');
Thingy.remove (err) ->
  count = 0
  async.whilst (->
    count < numThingies
  ), ((next) ->
    createNewThingy (err) ->
      return next(err) if err
      count++
      next()
  ), (err) ->
    winston.error err if err
    process.exit(1);