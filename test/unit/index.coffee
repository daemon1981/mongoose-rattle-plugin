require '../bootstrap'

async    = require 'async'
sinon    = require 'sinon'
assert   = require 'assert'
moment   = require 'moment'
should   = require 'should'
mongoose = require 'mongoose'

Thingy   = require '../models/thingy'

ObjectId  = mongoose.Types.ObjectId;

describe "MongooseRattlePlugin", ->
  thingy = {}
  commentorUserId = new ObjectId()
  objectCreatorUserId = new ObjectId()

  beforeEach (done) ->
    Thingy.remove done

  describe "document.save(callback)", ->
    it "update dateCreation and dateUpdate when inserting", (done) ->
      clock = sinon.useFakeTimers()
      new Thingy(creator: objectCreatorUserId, owner: objectCreatorUserId).save (err, thingySaved) ->
        assert.deepEqual(new Date(), thingySaved.dateCreation)
        assert.deepEqual(new Date(), thingySaved.dateUpdate)
        clock.restore()
        done()
    it "only update dateUpdate when updating", (done) ->
      clock = sinon.useFakeTimers(new Date(2011, 0, 1, 1, 1, 36).getTime())
      new Thingy(creator: objectCreatorUserId, owner: objectCreatorUserId).save (err, thingySaved) ->
        clock = sinon.useFakeTimers(new Date(2012, 0, 1, 1, 1, 36).getTime())
        thingySaved.save (err, thingySaved) ->
          assert.notDeepEqual(new Date(), thingySaved.dateCreation)
          assert.deepEqual(new Date(), thingySaved.dateUpdate)
          clock.restore()
          done()

  describe "Plugin methods", ->
    beforeEach (done) ->
      new Thingy(creator: objectCreatorUserId, owner: objectCreatorUserId).save (err, thingySaved) ->
        thingy = thingySaved
        done()

    describe "document.getComment(commentId)", ->
      userOneId = new ObjectId()
      userTwoId = new ObjectId()
      level1UserOneMsg = 'level1 message ' + userOneId
      level1UserTwoMsg = 'level1 message ' + userTwoId
      level2UserOneMsg = 'level2 message ' + userOneId
      level2UserTwoMsg = 'level2 message ' + userTwoId
      level3UserTwoMsg = 'level3 message ' + userOneId
      commentIds = {}

      beforeEach (done) ->
        thingy.comments = [
          message:       level1UserOneMsg
          creator:       userOneId
        ,
          message:       level1UserTwoMsg
          creator:       userTwoId
          comments: [
            message:       level2UserOneMsg
            creator:       userOneId
          ,
            message:       level2UserTwoMsg
            creator:       userTwoId
            comments: [
              message:       level3UserTwoMsg
              creator:       userOneId
            ]
          ]
        ]
        commentIds['level 1 ' + userOneId] = thingy.comments[0]._id
        commentIds['level 1 ' + userTwoId] = thingy.comments[1]._id
        commentIds['level 2 ' + userOneId] = thingy.comments[1].comments[0]._id
        commentIds['level 2 ' + userTwoId] = thingy.comments[1].comments[1]._id
        commentIds['level 3 ' + userOneId] = thingy.comments[1].comments[1].comments[0]._id
        thingy.save done

      it "retrieve null if comment doesn't exist", ->
        assert.equal(null, thingy.getComment('n0t3x1t1n9'))
      it "can retrieve a simple level comment", ->
        assert.equal(level1UserOneMsg, thingy.getComment(commentIds['level 1 ' + userOneId]).message)
        assert.equal(level1UserTwoMsg, thingy.getComment(commentIds['level 1 ' + userTwoId]).message)
      it "can retrieve a second level comment", ->
        assert.equal(level2UserOneMsg, thingy.getComment(commentIds['level 2 ' + userOneId]).message)
        assert.equal(level2UserTwoMsg, thingy.getComment(commentIds['level 2 ' + userTwoId]).message)
      it "can retrieve a third level comment", ->
        assert.equal(level3UserTwoMsg, thingy.getComment(commentIds['level 3 ' + userOneId]).message)
      it "can retrieve a comment when commentId is a string and not an ObjectId", ->
        assert.equal(level1UserOneMsg, thingy.getComment(String(commentIds['level 1 ' + userOneId])).message)

    describe "document.addComment(userId, message, callback)", ->
      it "append a new comment and return comment id", (done) ->
        commentId = thingy.addComment commentorUserId, 'dummy message', (err) ->
          should.not.exists(err)
          should.exists(commentId)
          Thingy.findById thingy._id, (err, updatedThingy) ->
            should.exists(updatedThingy)
            assert.equal(1, updatedThingy.comments.length)
            done()
      it "update dateCreation and dateUpdated", (done) ->
        clock = sinon.useFakeTimers()
        commentId = thingy.addComment commentorUserId, 'dummy message', (err, updatedThingy) ->
          assert.deepEqual(new Date(), updatedThingy.getComment(commentId).dateCreation)
          assert.deepEqual(new Date(), updatedThingy.getComment(commentId).dateUpdate)
          clock = sinon.restore()
          done()
      it "fails if message length is out of min and max", (done) ->
        thingy.addComment commentorUserId, '', (err) ->
          should.exists(err)
          done()

    describe "document.editComment(userId, commentId, message, callback)", ->
      commentId = null
      updatedMessage = 'dummy message updated'
      beforeEach (done) ->
        clock = sinon.useFakeTimers(new Date(2011, 0, 1, 1, 1, 36).getTime())
        commentId = thingy.addComment commentorUserId, 'dummy message', (err) ->
          clock = sinon.restore()
          done()

      it "fails if message length is out of min and max", (done) ->
        thingy.editComment commentorUserId, commentId, '', (err) ->
          should.exists(err)
          done()
      describe 'when user is not the creator', ->
        it "always fails", (done) ->
          thingy.editComment 'n0t3x1t1n9', commentId, updatedMessage, (err) ->
            should.exists(err)
            done()
      describe 'when user is the creator', ->
        it "edit comment and return comment id if user is the owner", (done) ->
          thingy.editComment commentorUserId, commentId, updatedMessage, (err) ->
            should.not.exists(err)
            should.exists(commentId)
            Thingy.findById thingy._id, (err, updatedThingy) ->
              should.exists(updatedThingy)
              assert.equal(1, updatedThingy.comments.length)
              assert.equal(updatedMessage, updatedThingy.comments[0].message)
              done()
        it "update dateCreation and dateUpdated", (done) ->
          clock = sinon.useFakeTimers(new Date(2012, 0, 1, 1, 1, 36).getTime())
          thingy.editComment commentorUserId, commentId, updatedMessage, (err, updatedThingy) ->
            assert.notDeepEqual(new Date(), updatedThingy.getComment(commentId).dateCreation)
            assert.deepEqual(new Date(), updatedThingy.getComment(commentId).dateUpdate)
            clock = sinon.restore()
            done()

    describe "document.removeComment(userId, commentId, callback)", ->
      level1Msg = 'level1 message'
      level2Msg = 'level2 message'
      level3Msg = 'level3 message'
      commentIds = {}

      beforeEach (done) ->
        thingy.comments = [
          message:       level1Msg
          creator:       commentorUserId
          comments: [
            message:       level2Msg
            creator:       commentorUserId
            comments: [
              message:       level3Msg
              creator:       commentorUserId
            ]
          ],
        ,
          message:       'level1 second message'
          creator:       commentorUserId
        ]
        commentIds['level 1'] = thingy.comments[0]._id
        commentIds['level 2'] = thingy.comments[0].comments[0]._id
        commentIds['level 3'] = thingy.comments[0].comments[0].comments[0]._id
        thingy.save done

      it "fails if comment doesn't exist", (done) ->
        thingy.removeComment commentorUserId, 'n0t3x1t1n9', (err, updatedThingy) ->
          should.exists(err)
          done()
      describe 'when user is not the creator', ->
        it "it's not removing the comment", (done) ->
          thingy.removeComment 'n0t3x1t1n9', commentIds['level 1'], (err, updatedThingy) ->
            should.exists(updatedThingy)
            should.exists(updatedThingy.getComment(commentIds['level 1']))
            done()
      describe 'when user is the creator', ->
        it "can remove comment at depth 1", (done) ->
          thingy.removeComment commentorUserId, commentIds['level 1'], (err, updatedThingy) ->
            should.exists(updatedThingy)
            should.not.exists(updatedThingy.getComment(commentIds['level 1']))
            done()
        it "can remove comment at depth 2", (done) ->
          thingy.removeComment commentorUserId, commentIds['level 2'], (err, updatedThingy) ->
            should.exists(updatedThingy)
            should.not.exists(updatedThingy.getComment(commentIds['level 2']))
            done()
        it "can remove comment at depth 3", (done) ->
          thingy.removeComment commentorUserId, commentIds['level 3'], (err, updatedThingy) ->
            should.exists(updatedThingy)
            should.not.exists(updatedThingy.getComment(commentIds['level 3']))
            done()

    describe "document.addLike(userId, callback)", ->
      it "add one user like if user doesn't already liked", (done) ->
        thingy.addLike commentorUserId, (err, updatedThingy) ->
          assert.equal(1, updatedThingy.likes.length)
          done()

      it "not add an other user like if user already liked", (done) ->
        thingy.addLike commentorUserId, (err, updatedThingy) ->
          thingy.addLike commentorUserId, (err, updatedThingy) ->
            assert.equal(1, thingy.likes.length)
            done()

    describe "document.removeLike(userId, callback)", ->
      userOneId = new ObjectId()
      userTwoId = new ObjectId()

      beforeEach (done) ->
        async.series [(callback) ->
          thingy.addLike commentorUserId, (err, updatedThingy) ->
            thingy = updatedThingy
            callback()
        , (callback) ->
          thingy.addLike userOneId, (err, updatedThingy) ->
            thingy = updatedThingy
            callback()
        ], done

      it "not affect current likes list if user didn'nt already liked", (done) ->
        thingy.removeLike userTwoId, (err, updatedThingy) ->
          assert.equal(2, updatedThingy.likes.length)
          done()

      it "remove user like from likes list if user already liked", (done) ->
        thingy.removeLike commentorUserId, (err, updatedThingy) ->
          assert.equal(1, updatedThingy.likes.length)
          done()

      it "remove user like from likes list if user already liked when userId param is a string", (done) ->
        thingy.removeLike String(commentorUserId), (err, updatedThingy) ->
          assert.equal(1, updatedThingy.likes.length)
          done()

    describe "document.addReplyToComment(userId, commentId, message, callback)", ->
      userOneId = new ObjectId()
      userTwoId = new ObjectId()
      level1UserOneMsg = 'level1 message ' + userOneId
      level1UserOneMsgRef = 'level 1 ' + userOneId
      commentId = ''

      beforeEach (done) ->
        thingy.comments = [
          message:       level1UserOneMsg
          creator:       userOneId
        ]
        commentId = thingy.comments[0]._id;
        thingy.save done

      it "fails if comment doesn't exist", (done) ->
        thingy.addReplyToComment commentorUserId, 'n0t3x1t1n9', 'dummy message', (err, updatedThingy) ->
          should.exists(err)
          done()
      it "fails if message length is out of min and max", (done) ->
        thingy.addReplyToComment commentorUserId, commentId, '', (err, updatedThingy) ->
          should.exists(err)
          done()
      it "append a new comment to the parent comment if parent comment exists", (done) ->
        thingy.addReplyToComment commentorUserId, commentId, 'dummy message', (err, updatedThingy) ->
          assert.equal 1, updatedThingy.getComment(commentId).comments.length
          done()

    describe "document.addLikeToComment(userId, commentId, callback)", ->
      level1Msg = 'level1 message'
      commentId = ''

      beforeEach (done) ->
        thingy.comments = [
          message:       'level1 message'
          creator:       commentorUserId
        ]
        commentId = thingy.comments[0]._id
        thingy.save done

      it "fails if comment doesn't exist", (done) ->
        thingy.addLikeToComment commentorUserId, 'n0t3x1t1n9', (err, updatedThingy) ->
          should.exists(err)
          done()
      it "add one user like if user doesn't already liked and comment exists", (done) ->
        thingy.addLikeToComment commentorUserId, commentId, (err, updatedThingy) ->
          assert.equal 1, updatedThingy.getComment(commentId).likes.length
          done()
      it "not add an other user like if user already liked and comment exists", (done) ->
        thingy.addLikeToComment commentorUserId, commentId, (err, updatedThingy) ->
          thingy.addLikeToComment commentorUserId, commentId, (err, updatedThingy) ->
            assert.equal 1, updatedThingy.getComment(commentId).likes.length
            done()

    describe "document.removeLikeFromComment(userId, commentId, callback)", ->
      level1Msg = 'level1 message'
      commentId = ''

      beforeEach (done) ->
        thingy.comments = [
          message:   'level1 message'
          creator:   commentorUserId
          likes:     [commentorUserId, new ObjectId()]
        ]
        commentId = thingy.comments[0]._id
        thingy.save done

      it "fails if comment doesn't exist", (done) ->
        thingy.removeLikeFromComment commentorUserId, 'n0t3x1t1n9', (err, updatedThingy) ->
          should.exists(err)
          done()
      it "not affect current likes list if user didn'nt already liked", (done) ->
        thingy.removeLikeFromComment new ObjectId(), commentId, (err, updatedThingy) ->
          assert.equal 2, updatedThingy.getComment(commentId).likes.length
          done()
      it "remove user like from likes list if user already liked", (done) ->
        thingy.removeLikeFromComment commentorUserId, commentId, (err, updatedThingy) ->
          assert.equal 1, updatedThingy.getComment(commentId).likes.length
          done()
      it "remove user like from likes list if user already liked when userId param is a string", (done) ->
        thingy.removeLikeFromComment String(commentorUserId), commentId, (err, updatedThingy) ->
          assert.equal 1, updatedThingy.getComment(commentId).likes.length
          done()
