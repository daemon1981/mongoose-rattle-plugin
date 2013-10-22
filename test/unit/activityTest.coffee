require '../bootstrap'

async     = require 'async'
assert    = require 'assert'
should    = require 'should'
mongoose  = require 'mongoose'
fixtures  = require 'pow-mongoose-fixtures'

Thingy    = require '../models/thingy'
Thingummy = require '../models/thingummy'
User      = require '../models/user'
Activity  = require '../../src/model/activity'

ObjectId  = mongoose.Types.ObjectId;

describe "Activity", ->
  thingy = {}
  playingUser = objectCreatorUser = null
  message1 = message2 = message3 = null
  message1Id = message2Id = message3Id = null

  before (done) ->
    async.waterfall [removeThingy = (callback) ->
      Thingy.remove callback
    , removeUsers = (removeResult, callback) ->
      User.remove callback
    , removeActivities = (removeResult, callback) ->
      Activity.remove callback
    , addObjectCreatorUser = (removeResult, callback) ->
      new User().save callback
    , addPlayingUser = (objectCreatorUserSaved, saveResult, callback) ->
      objectCreatorUser = objectCreatorUserSaved
      new User().save callback
    , addThingyFromObjectCreator = (playingUserSaved, saveResult, callback) ->
      playingUser = playingUserSaved
      new Thingy({creator: objectCreatorUser._id, owner: objectCreatorUser._id}).save callback
    , addCommentFromPlayingUser = (thingy, saveResult, callback) ->
      message1 = 'message from ' + playingUser._id
      message1Id = thingy.addComment playingUser._id, message1, callback
    , addCommentFromObjectCreatorUser = (thingy, callback) ->
      message2 = 'message from ' + objectCreatorUser._id
      message2Id = thingy.addComment objectCreatorUser._id, message2, callback
    , addReplayToCommentFromPlayingUser = (thingy, callback) ->
      message3 = 'reply from ' + playingUser._id
      message3Id = thingy.addReplyToComment playingUser._id, message2Id, message3, callback
    , addLikeFromPlayingUser = (thingy, callback) ->
      thingy.addLike playingUser._id, callback
    , addLikeFromObjectCreatorUser = (thingy, callback) ->
      thingy.addLike objectCreatorUser._id, callback
    , addLikeToCommentFromObjectCreatorUser = (thingy, callback) ->
      thingy.addLikeToComment playingUser._id, message3Id, callback
    , addThingyFromPlayingUser = (thingy, callback) ->
      new Thingummy({creator: playingUser._id, owner: playingUser._id}).save callback
    ], (err, thingySaved) ->
      thingy = thingySaved
      done()

  it 'get activities on objectCreation of type thingy'
  it 'get activities on addComment'
