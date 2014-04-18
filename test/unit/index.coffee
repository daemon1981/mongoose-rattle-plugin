require '../bootstrap'

async    = require 'async'
sinon    = require 'sinon'
assert   = require 'assert'
moment   = require 'moment'
should   = require 'should'
mongoose = require 'mongoose'

Thingy   = require '../models/thingy'
User     = require '../models/user'

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
        clock.restore()
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
      commentIds = {}

      beforeEach (done) ->
        thingy.comments = [
          message:       level1UserOneMsg
          creator:       userOneId
        ,
          message:       level1UserTwoMsg
          creator:       userTwoId
        ]
        commentIds['level 1 ' + userOneId] = thingy.comments[0]._id
        commentIds['level 1 ' + userTwoId] = thingy.comments[1]._id
        thingy.save done

      it "retrieve null if comment doesn't exist", ->
        assert.equal(null, thingy.getComment('n0t3x1t1n9'))
      it "retrieve comment", ->
        assert.equal(level1UserOneMsg, thingy.getComment(commentIds['level 1 ' + userOneId]).message)
        assert.equal(level1UserTwoMsg, thingy.getComment(commentIds['level 1 ' + userTwoId]).message)
      it "retrieve a comment when commentId is a string and not an ObjectId", ->
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
          clock.restore()
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
          clock.restore()
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
        checkEditCommentWhenOwner = (commentorUserId, commentId, updatedMessage, done) ->
          thingy.editComment commentorUserId, commentId, updatedMessage, (err) ->
            should.not.exists(err)
            should.exists(commentId)
            Thingy.findById thingy._id, (err, updatedThingy) ->
              should.exists(updatedThingy)
              assert.equal(1, updatedThingy.comments.length)
              assert.equal(updatedMessage, updatedThingy.comments[0].message)
              done()
        it "edit comment and return comment id if user is the owner", (done) ->
          checkEditCommentWhenOwner(commentorUserId, commentId, updatedMessage, done)
        it "edit comment and return comment id if user is the owner when userId is a string", (done) ->
          checkEditCommentWhenOwner(String(commentorUserId), commentId, updatedMessage, done)
        it "update dateCreation and dateUpdated", (done) ->
          clock = sinon.useFakeTimers(new Date(2012, 0, 1, 1, 1, 36).getTime())
          thingy.editComment commentorUserId, commentId, updatedMessage, (err, updatedThingy) ->
            assert.notDeepEqual(new Date(), updatedThingy.getComment(commentId).dateCreation)
            assert.deepEqual(new Date(), updatedThingy.getComment(commentId).dateUpdate)
            clock.restore()
            done()

    describe "document.removeComment(userId, commentId, callback)", ->
      level1Msg = 'level1 message'
      commentIds = {}

      beforeEach (done) ->
        thingy.comments = [
          message:       level1Msg
          creator:       commentorUserId
        ,
          message:       'level1 second message'
          creator:       commentorUserId
        ]
        commentIds['level 1'] = thingy.comments[0]._id
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
        it "can remove comment", (done) ->
          thingy.removeComment commentorUserId, commentIds['level 1'], (err, updatedThingy) ->
            should.exists(updatedThingy)
            should.not.exists(updatedThingy.getComment(commentIds['level 1']))
            done()
        it "remove comment when userId param is a string", (done) ->
          thingy.removeComment String(commentorUserId), commentIds['level 1'], (err, updatedThingy) ->
            should.exists(updatedThingy)
            should.not.exists(updatedThingy.getComment(commentIds['level 1']))
            done()
        it "remove comment when commentId is a string", (done) ->
          thingy.removeComment commentorUserId, String(commentIds['level 1']), (err, updatedThingy) ->
            should.exists(updatedThingy)
            should.not.exists(updatedThingy.getComment(commentIds['level 1']))
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

      it "not add an other user like if user already liked when userId param is a string", (done) ->
        thingy.addLike commentorUserId, (err, updatedThingy) ->
          thingy.addLike String(commentorUserId), (err, updatedThingy) ->
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
      it "not add an other user like if user already liked and comment exists when userId param is a string", (done) ->
        thingy.addLikeToComment String(commentorUserId), commentId, (err, updatedThingy) ->
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

  describe "Plugin statics", ->

    describe "document.getList", ->
      creator1Id = new ObjectId()
      creator2Id = new ObjectId()
      beforeEach (done) ->
        rattles = [
          creator:      creator1Id
          comments: [
            message:       '11'
            creator:       new ObjectId()
          ,
            message:       '12'
            creator:       new ObjectId()
          ]
        ,
          creator:  creator2Id
          comments: [
            message:       '21'
            creator:       new ObjectId()
          ,
            message:       '22'
            creator:       new ObjectId()
          ]
        ]
        async.eachSeries rattles, (save = (rattleData, next) ->
          new Thingy(rattleData).save next
        ), done

      describe "(num, maxNumLastPostComments, callback)", ->
        it "get list of the number of 'num' last rattles", (done) ->
          Thingy.find {}, (err, rattles) ->
            Thingy.getList 1, 0, (err, rattles) ->
              should.not.exists(err)
              assert.equal rattles.length, 1
              assert.deepEqual rattles[0].creator, creator2Id
              done()
        it "get all rattles if 'num' is greater than the number of rattles", (done) ->
          Thingy.getList 3, 0, (err, rattles) ->
            should.not.exists(err)
            assert.equal rattles.length, 2
            done()
        it "each rattle get the maximum of 'maxLastComments' last comments", (done) ->
          Thingy.getList 1, 1, (err, rattles) ->
            should.not.exists(err)
            assert.equal rattles.length, 1
            assert.deepEqual rattles[0].creator, creator2Id
            should.exists(rattles[0].comments)
            assert.equal rattles[0].comments.length, 1
            assert.equal rattles[0].comments[0].message, '22'
            done()
        it "each all comments when 'maxLastComments' is greater than number of comments", (done) ->
          Thingy.getList 1, 3, (err, rattles) ->
            should.not.exists(err)
            assert.equal rattles.length, 1
            should.exists(rattles[0].comments)
            assert.equal rattles[0].comments.length, 2
            done()
      describe "(num, maxNumLastPostComments, options, callback)", ->
        describe "from a creation date", ->
          it "get list of last rattles created from the 'fromDate'", (done) ->
            # retrieve last rattle
            Thingy.getList 1, 0, (err, rattles) ->
              Thingy.getList 1, 0, fromCreationDate: rattles[0].dateCreation, (err, rattles) ->
                should.not.exists(err)
                assert.equal rattles.length, 1
                assert.deepEqual rattles[0].creator, creator1Id
                done()
          it "get all last rattles if 'num' is greater than the number of last rattles", (done) ->
            # retrieve last rattle
            Thingy.getList 1, 0, (err, rattles) ->
              Thingy.getList 2, 0, fromCreationDate: rattles[0].dateCreation, (err, rattles) ->
                should.not.exists(err)
                assert.equal rattles.length, 1
                done()
          it "each rattle get the maximum of 'maxLastComments' last comments", (done) ->
            # retrieve last rattle
            Thingy.getList 1, 0, (err, rattles) ->
              Thingy.getList 1, 1, fromCreationDate: rattles[0].dateCreation, (err, rattles) ->
                should.not.exists(err)
                assert.equal rattles.length, 1
                assert.deepEqual rattles[0].creator, creator1Id
                should.exists(rattles[0].comments)
                assert.equal rattles[0].comments.length, 1
                assert.equal rattles[0].comments[0].message, '12'
                done()
        describe "populating", ->
          it "build", (done) ->
            new User({_id: creator2Id, name: 'Dummy Name'}).save (err) ->
              # retrieve last rattle
              Thingy.getList 1, 0, {populate: 'creator'}, (err, rattles) ->
                  should.not.exists(err)
                  assert.equal rattles.length, 1
                  should.exists(rattles[0].creator.name)
                  assert.equal rattles[0].creator.name, 'Dummy Name'
                  done()

    describe "document.getListOfCommentsById(rattleId, num, offsetFromEnd, callback)", ->
      creatorId = new ObjectId()
      rattleId = null
      beforeEach (done) ->
        async.waterfall [
          saveThingy = (next) ->
            new Thingy(
              creator:      creatorId
            ).save (err, data) ->
              next(err) if err
              rattleId = data._id
              next(null, data)
          pushComments = (thingy, next) ->
            comments = [
              message:       '11'
              creator:       new ObjectId()
            ,
              message:       '12'
              creator:       new ObjectId()
            ,
              message:       '13'
              creator:       new ObjectId()
            ]
            async.eachSeries comments, (push = (comment, next) ->
              thingy.addComment comment.creator, comment.message, next
            ), next
        ], done

      it "get last 'num' of comments for 'rattleId' when offsetFromEnd is 0", (done) ->
        Thingy.getListOfCommentsById rattleId, 1, 0, (err, comments) ->
          should.not.exists(err)
          assert.equal comments.length, 1
          assert.equal comments[0].message, '13'
          done()
      it "get last num of comments from the offsetFromEnd", (done) ->
        Thingy.getListOfCommentsById rattleId, 1, 1, (err, comments) ->
          should.not.exists(err)
          assert.equal comments.length, 1
          assert.equal comments[0].message, '12'
          done()
      it "get no comments when offsetFromEnd is equal to the number of comments", (done) ->
        Thingy.getListOfCommentsById rattleId, 1, 3, (err, comments) ->
          should.not.exists(err)
          assert.equal comments.length, 0
          done()
      it "limit comments when offsetFromEnd + num is greater that the number of comments", (done) ->
        Thingy.getListOfCommentsById rattleId, 3, 1, (err, comments) ->
          should.not.exists(err)
          assert.equal comments[0].message, '11'
          assert.equal comments[1].message, '12'
          assert.equal comments.length, 2
          done()
      it "keep comments order", (done) ->
        Thingy.getListOfCommentsById rattleId, 3, 0, (err, comments) ->
          should.not.exists(err)
          assert.equal comments[0].message, '11'
          assert.equal comments[1].message, '12'
          assert.equal comments[2].message, '13'
          assert.equal comments.length, 3
          done()
