mongoose = require 'mongoose'
async    = require 'async'

mongoose.connect "mongodb://127.0.0.1:27017/mongoose-rattle-test-perf", {}, (err) ->
  throw err if err

Thingy   = require '../models/thingy'

ObjectId  = mongoose.Types.ObjectId;

numLikes = 20000
numCommentLikes = 20
blockNumComments = 5000
numBlocks = 4

thingy = {}
userId = new ObjectId()

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

async.waterfall [
  removeThingy = (next) ->
    console.log('Clear thingy collection');
    Thingy.remove next
  createThingy = (numAffected, next) ->
    console.log('Create a new thingy');
    new Thingy(
      creator: userId
    ).save next
  addComments = (createdThingy, numAffected, next) ->
    console.log('Add comments with likes');

    i = 0
    async.whilst (->
      i < numBlocks
    ), ((callback) ->
      console.log('Add block ' + (i + 1) + ' of ' + blockNumComments + ' comments');
      Thingy.update { _id: createdThingy._id }, { $pushAll: { comments: comments } }, (err) ->
        i++
        callback()
    ), (err) ->
      console.log('Add likes');
      i = 0
      likes = []
      while i < numLikes
        likes.push new ObjectId()
        i++
      createdThingy.likes = likes
      createdThingy.save next
    
], (err) ->
  console.log('Thingy saved');
  process.exit(1);
