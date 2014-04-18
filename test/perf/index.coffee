require '../bootstrap'

async    = require 'async'
assert   = require 'assert'
moment   = require 'moment'
mongoose = require 'mongoose'

Thingy   = require '../models/thingy'
User     = require '../models/user'

ObjectId  = mongoose.Types.ObjectId;

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
        createdThingy.comments.push [
          message: 'dummy message'
          creator: userId
        ]
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
