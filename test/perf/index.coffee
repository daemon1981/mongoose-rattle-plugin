require '../bootstrap-perf'

mongoose = require 'mongoose'
async    = require 'async'
assert   = require 'assert'
memwatch = require 'memwatch'

Thingy   = require '../models/thingy'

describe "MongooseRattlePlugin", ->
  before (done) ->
    Thingy.count (err, count) ->
      throw new Error('You should populate with command "coffee test/perf-data"') if count is 0
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
        it "not exceeding 800Ko node memory usage for the operation", (done) ->
          count = 0
          async.whilst (->
            count < 3
          ), ((next) ->
            hd = new memwatch.HeapDiff()
            start = Date.now()
            Thingy.getList 1, 1, (err, thingies) ->
              diff = hd.end()
              end = Date.now()
              count++
              assert.equal thingies.length, 1
              assert parseFloat(diff.change.size_bytes) < 100000
              console.log(end - start);
              next()
            return
          ), done
      describe "(num, maxNumLastPostComments, options, callback)", ->
        describe "from a creation date", ->
          it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"
        describe "populating", ->
          it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"

    describe "document.getListOfCommentsById(rattleId, num, offsetFromEnd, callback)", ->
      it "not exceeding XKo node memory usage for the query with a document having 20 000 comments"
