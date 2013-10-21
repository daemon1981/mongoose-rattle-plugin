require '../bootstrap'

async    = require 'async'
assert   = require 'assert'
should   = require 'should'
mongoose = require 'mongoose'
fixtures = require 'pow-mongoose-fixtures'

RattlePlugin = require '../../plugins/rattle'

ObjectId  = mongoose.Types.ObjectId;
Schema   = mongoose.Schema

ThingySchema = new Schema()
ThingySchema.plugin RattlePlugin, name: 'thingy'
Thingy = mongoose.model "Thingy", ThingySchema

describe "Thingy", ->
  thingy = {}
  commentorUserId = new ObjectId()

  beforeEach (done) ->
    async.series [(callback) ->
      Thingy.remove callback
    , (callback) ->
      new Thingy().save (err, thingySaved) ->
        thingy = thingySaved
        callback()
    ], done

  describe "When getting a comment", ->
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

    it "should retrieve null if comment doesn't exist", ->
      assert.equal(null, thingy.getComment('n0t3x1t1n9'))
    it "should be able to retrieve a simple level comment", ->
      assert.equal(level1UserOneMsg, thingy.getComment(commentIds['level 1 ' + userOneId]).message)
      assert.equal(level1UserTwoMsg, thingy.getComment(commentIds['level 1 ' + userTwoId]).message)
    it "should be able to retrieve a second level comment", ->
      assert.equal(level2UserOneMsg, thingy.getComment(commentIds['level 2 ' + userOneId]).message)
      assert.equal(level2UserTwoMsg, thingy.getComment(commentIds['level 2 ' + userTwoId]).message)
    it "should be able to retrieve a third level comment", ->
      assert.equal(level3UserTwoMsg, thingy.getComment(commentIds['level 3 ' + userOneId]).message)

  describe "When adding a comment", ->
    it "should fails if message length is out of min and max", (done) ->
      thingy.addComment commentorUserId, '', (err) ->
        should.exists(err)
        done()
    it "should append a new comment and return comment id", (done) ->
      commentId = thingy.addComment commentorUserId, 'dummy message', (err) ->
        should.not.exists(err)
        should.exists(commentId)
        Thingy.findById thingy._id, (err, updatedThingy) ->
          should.exists(updatedThingy)
          assert.equal(1, updatedThingy.comments.length)
          done()

  describe "When removing a comment", ->
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

    describe 'when user is the not creator', ->
      it "should fails", (done) ->
        thingy.removeComment 'n0t3x1t1n9', commentIds['level 1'], (err, updatedThingy) ->
          should.exists(updatedThingy)
          should.exists(updatedThingy.getComment(commentIds['level 1']))
          done()
    describe 'when user is the creator', ->
      it "should remove comment of level1", (done) ->
        thingy.removeComment commentorUserId, commentIds['level 1'], (err, updatedThingy) ->
          should.exists(updatedThingy)
          should.not.exists(updatedThingy.getComment(commentIds['level 1']))
          done()
      it.skip "should remove comment of level2", (done) ->
        thingy.removeComment commentorUserId, commentIds['level 2'], (err, updatedThingy) ->
          should.exists(updatedThingy)
          should.not.exists(updatedThingy.getComment(commentIds['level 2']))
          done()
      it.skip "should remove comment of level3", (done) ->
        thingy.removeComment commentorUserId, commentIds['level 3'], (err, updatedThingy) ->
          should.exists(updatedThingy)
          should.not.exists(updatedThingy.getComment(commentIds['level 3']))
          done()

  describe "When adding a user like", ->
    it "should add one user like if user doesn't already liked", (done) ->
      thingy.addLike commentorUserId, (err, updatedThingy) ->
        assert.equal(1, updatedThingy.likes.length)
        done()

    it "shouldn't add an other user like if user already liked", (done) ->
      thingy.addLike commentorUserId, (err, updatedThingy) ->
        thingy.addLike commentorUserId, (err, updatedThingy) ->
          assert.equal(1, thingy.likes.length)
          done()

  describe "When removing a user like", ->
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

    it "should not affect current likes list if user didn'nt already liked", (done) ->
      thingy.removeLike userTwoId, (err, updatedThingy) ->
        assert.equal(2, updatedThingy.likes.length)
        done()

    it "should remove user like from likes list if user already liked", (done) ->
      thingy.removeLike commentorUserId, (err, updatedThingy) ->
        assert.equal(1, updatedThingy.likes.length)
        done()

  describe "When adding a reply to a comment", ->
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

    it "should fails if comment doesn't exist", (done) ->
      thingy.addReplyToComment commentorUserId, 'n0t3x1t1n9', 'dummy message', (err, updatedThingy) ->
        should.exists(err)
        done()
    it "should fails if message length is out of min and max", (done) ->
      thingy.addReplyToComment commentorUserId, commentId, '', (err, updatedThingy) ->
        should.exists(err)
        done()
    it "should append a new comment to the parent comment if parent comment exists", (done) ->
      thingy.addReplyToComment commentorUserId, commentId, 'dummy message', (err, updatedThingy) ->
        assert.equal 1, updatedThingy.getComment(commentId).comments.length
        done()

  describe "When adding a user like to a comment", ->
    level1Msg = 'level1 message'
    commentId = ''

    beforeEach (done) ->
      thingy.comments = [
        message:       'level1 message'
        creator:       commentorUserId
      ]
      commentId = thingy.comments[0]._id
      thingy.save done

    it "should fails if comment doesn't exist", (done) ->
      thingy.addLikeToComment commentorUserId, 'n0t3x1t1n9', (err, updatedThingy) ->
        should.exists(err)
        done()
    it "should add one user like if user doesn't already liked and comment exists", (done) ->
      thingy.addLikeToComment commentorUserId, commentId, (err, updatedThingy) ->
        assert.equal 1, updatedThingy.getComment(commentId).likes.length
        done()
    it "shouldn't add an other user like if user already liked and comment exists", (done) ->
      thingy.addLikeToComment commentorUserId, commentId, (err, updatedThingy) ->
        thingy.addLikeToComment commentorUserId, commentId, (err, updatedThingy) ->
          assert.equal 1, updatedThingy.getComment(commentId).likes.length
          done()

  describe "When removing a user like from a comment", ->
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

    it "should fails if comment doesn't exist", (done) ->
      thingy.removeLikeToComment commentorUserId, 'n0t3x1t1n9', (err, updatedThingy) ->
        should.exists(err)
        done()
    it "should not affect current likes list if user didn'nt already liked", (done) ->
      thingy.removeLikeToComment new ObjectId(), commentId, (err, updatedThingy) ->
        assert.equal 2, updatedThingy.getComment(commentId).likes.length
        done()
    it "should remove user like from likes list if user already liked", (done) ->
      thingy.removeLikeToComment commentorUserId, commentId, (err, updatedThingy) ->
        assert.equal 1, updatedThingy.getComment(commentId).likes.length
        done()
