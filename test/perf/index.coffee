mongoose = require 'mongoose'

mongoose.connect "mongodb://127.0.0.1:27017/mongoose-rattle-test-perf", {}, (err) ->
  throw err if err

async    = require 'async'
assert   = require 'assert'

Thingy   = require '../models/thingy'
User     = require '../models/user'

ObjectId  = mongoose.Types.ObjectId;

numLikes = 100
numComments = 1000

describe "MongooseRattlePlugin", ->
  thingy = {}
  userId = new ObjectId()

  before (done) ->
    async.waterfall [
      removeThingy = (next) ->
        Thingy.remove next
      createThingy = (numAffected, next) ->
        new Thingy(
          creator: userId
        ).save next
      addComments = (createdThingy, numAffected, next) ->
        i = 0
        likes = []
        while i < numLikes
          likes.push new ObjectId()
          i++

        dummyComment =
          message:       'duuuuuuuuuuuummmmmmmmmmmmmmmmyyyyyyyyyyyyy meeeeeeeeeeeeessssssssssssaaaaaaaaaaaaaageeeeee'
          creator:       new ObjectId()
          likes:         likes
          likesCount:    type: Number, default: 0
          dateCreation:  type: Date
          dateUpdate:    type: Date

        comments = []
        i = 0
        while i < numComments
          comments.push dummyComment
          i++

        createdThingy.comments = comments
        createdThingy.save next
    ], (err) ->
      Thingy.find (err, createdThingy) ->
        thingy = createdThingy
        done()

  describe "Plugin methods", ->
    describe "document.getComment(commentId)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

    describe "document.addComment(userId, message, callback)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

    describe "document.editComment(userId, commentId, message, callback)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

    describe "document.removeComment(userId, commentId, callback)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

    describe "document.addLike(userId, callback)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

    describe "document.removeLike(userId, callback)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

    describe "document.addLikeToComment(userId, commentId, callback)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

    describe "document.removeLikeFromComment(userId, commentId, callback)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

  describe "Plugin statics", ->

    describe "document.getList", ->
      describe "(num, maxNumLastPostComments, callback)", ->
        it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"
      describe "(num, maxNumLastPostComments, options, callback)", ->
        describe "from a creation date", ->
          it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"
        describe "populating", ->
          it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

    describe "document.getListOfCommentsById(rattleId, num, offsetFromEnd, callback)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"
