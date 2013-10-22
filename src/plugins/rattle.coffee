mongoose = require 'mongoose'
config   = require 'config'
moment   = require 'moment'

Schema   = mongoose.Schema
ObjectId = Schema.Types.ObjectId

rattleActivity = require '../rattleActivity'

module.exports = rattlePlugin = (schema, options) ->
  throw new Error('You must specify the name of the rattle object') if !options or !options.name

  # Schema strategies for embedded comments
  #
  # http://docs.mongodb.org/ecosystem/use-cases/storing-comments/
  # http://stackoverflow.com/questions/7992185/mongoose-recursive-embedded-document-in-coffeescript
  # http://stackoverflow.com/questions/17416924/create-embedded-docs-with-mongoose-and-express

  CommentSchema = new Schema()

  CommentSchema.add
    message:       type: String, required: true, max: 2000, min: 1
    likes:         [type: ObjectId, ref: config.mongooseRattle.User]
    comments:      [CommentSchema]
    creator:       type: ObjectId, ref: config.mongooseRattle.User, required: true

  schema.add
    creator:       type: ObjectId, ref: config.mongooseRattle.User, required: true
    owner:         type: ObjectId, ref: config.mongooseRattle.User, required: true
    dateCreation:  type: Date
    dateUpdate:    type: Date
    likes:         [type: ObjectId, ref: config.mongooseRattle.User]
    comments:      [CommentSchema]

  schema.pre "save", (next) ->
    if this.isNew
      rattleActivity.emit('objectCreation', this)
      this.dateCreation = moment().toDate()

    this.dateUpdate = moment().toDate()
    next()

  schema.methods.addComment = (userId, message, callback) ->
    self = this

    comment =
      message:       message
      creator:       userId
    this.comments.push(comment)

    this.save (err, data) ->
      return callback(err) if err isnt null
      rattleActivity.emit('addComment', self, comment)
      callback(err, data)

    return this.comments[this.comments.length - 1]._id

  schema.methods.addReplyToComment = (userId, commentId, message, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    self = this

    reply =
      message:       message
      creator:       userId
    comment.comments.push(reply)

    this.save (err, data) ->
      return callback(err) if err isnt null
      rattleActivity.emit('addReplyToComment', self, userId, reply)
      callback(err, data)

    return comment.comments[comment.comments.length - 1]._id

  schema.methods.removeComment = (userId, commentId, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    removeComment = (comments, commentId) ->
      comments = comments.filter (comment) ->
        return comment.creator isnt userId || comment._id isnt commentId

      for reply in comments
        reply.comments = removeComment(reply.comments, commentId)

      return comments

    this.comments = removeComment(this.comments, commentId)

    self = this

    this.save (err, data) ->
      return callback(err) if err isnt null
      rattleActivity.emit('removeComment', self, comment)
      callback(err, data)

  schema.methods.addLike = (userId, callback) ->
    hasAlreadyLiked = this.likes.some (likeUserId) ->
      return likeUserId is userId

    this.likes.push userId if !hasAlreadyLiked

    self = this

    this.save (err, data) ->
      return callback(err) if err isnt null
      rattleActivity.emit('addLike', self, userId)
      callback(err, data)

  schema.methods.addLikeToComment = (userId, commentId, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    hasAlreadyLiked = comment.likes.some (likeUserId) ->
      return likeUserId is userId

    comment.likes.push userId  if !hasAlreadyLiked

    self = this

    this.save (err, data) ->
      return callback(err) if err isnt null
      rattleActivity.emit('addLikeToComment', self, userId, commentId)
      callback(err, data)

  schema.methods.removeLike = (userId, callback) ->
    this.likes = this.likes.filter (likeUserId) ->
      return likeUserId isnt userId

    self = this

    this.save (err, data) ->
      return callback(err) if err isnt null
      rattleActivity.emit('removeLike', self, userId)
      callback(err, data)

  schema.methods.removeLikeFromComment = (userId, commentId, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    comment.likes = comment.likes.filter (likeUserId) ->
      return likeUserId isnt userId

    self = this

    this.save (err, data) ->
      return callback(err) if err isnt null
      # => trigger removeLike activity
      rattleActivity.emit('removeLikeFromComment', self, userId, commentId)
      callback(err, data)

  schema.methods.getComment = (commentId) ->
    searchComment = (comments, commentId) ->
      for comment in comments
        if comment._id is commentId
          return comment
        comment = searchComment(comment.comments, commentId)
        return comment if comment isnt null
      null

    return searchComment(this.comments, commentId)
