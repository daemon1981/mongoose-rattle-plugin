keystone = require 'keystone'

mongoose = keystone.mongoose
moment   = require 'moment'

Schema   = mongoose.Schema

module.exports = rattlePlugin = (schema, options) ->
  options = {} if (!options)
  options.UserSchemaName = 'User' if (!options.UserSchemaName)
  options.UserIdType = Schema.Types.ObjectId if (!options.UserIdType)

  # Schema strategies for embedded comments
  #
  # http://docs.mongodb.org/ecosystem/use-cases/storing-comments/

  CommentSchema = new Schema
    message:       type: String, required: true, max: 2000, min: 1
    creator:       type: options.UserIdType, ref: options.UserSchemaName, required: true
    likes:         [type: options.UserIdType, ref: options.UserSchemaName]
    likesCount:    type: Number, default: 0
    dateCreation:  type: Date
    dateUpdate:    type: Date

  schema.add
    creator:       type: options.UserIdType, ref: options.UserShcemaName, required: true
    likes:         [type: options.UserIdType, ref: options.UserSchemaName]
    likesCount:    type: Number, default: 0
    comments:      [CommentSchema]
    dateCreation:  type: Date
    dateUpdate:    type: Date

  schema.pre "save", (next) ->
    if this.isNew
      # emit objectCreation event with information on object, targetId, actor
      this.emit('objectCreation', this._id, this, this.creator)
      this.dateCreation = moment().toDate()

    this.dateUpdate = moment().toDate()
    this.likesCount = this.likes.length
    next()
  CommentSchema.pre "save", (next) ->
    this.likesCount = this.likes.length
    next()

  ####################################################################
  # statics
  ####################################################################

  ###*
   * Get the list of rattles with limited amount of comments
   *
   * @param {Number} num - number of rattles
   * @param {Number} maxLastComments - number max of comments retrieved
   * @param {Object} options:
   *                   fromCreationDate: creation date from which we retrieve rattles
   *                   populate:         list of fields to populate (example: 'fieldName' or 'fieldName1 fieldName2')
   * @callback(err, rattles)
  ###
  schema.statics.getList = (num, maxLastComments, options, callback) ->
    if 'function' is typeof options
      callback = options;
      options = {};

    query = {}
    if options.fromCreationDate
      query =
        dateCreation: { $lt: options.fromCreationDate }

    fields =
      text:         1
      creator:      1
      dateCreation: 1
      dateUpdate:   1
      likesCount:   1

    if maxLastComments > 0
      fields.comments = { $slice: [-maxLastComments, maxLastComments] }

    query = this.find(query, fields)
      .sort('-dateCreation')
      .limit(num)

    if options.populate
      query.populate options.populate

    query.exec(callback)

  ###*
   * Get the list of comments from a rattle id
   *
   * @param {Number} rattleId - id of the rattle
   * @param {Number} num - number of comments required
   * @param {Number} offsetFromEnd - offset from end of the list of comments
   * @callback(err, comments)
  ###
  schema.statics.getListOfCommentsById = (rattleId, num, offsetFromEnd, callback) ->
    self = this

    this.aggregate {$unwind: "$comments"}, {$group: {_id: '', count: {$sum: 1}}}, (err, summary) ->
      start = -num - offsetFromEnd
      limit = num

      if summary[0].count < Math.abs(start)
        diff = Math.abs(start) - summary[0].count
        start += diff
        limit -= diff

      return callback(null, []) if limit <= 0

      fields =
        comments: { $slice: [start, limit] }

      self.findById(rattleId, fields).exec (err, rattle) ->
        return callback(err) if err
        callback(null, rattle.comments)

  ####################################################################
  # methods
  ####################################################################

  ###*
   * Emit an event
   *
   * @param {String} eventName - event name
   * @param {Number} targetId  - object to which the event occured
   * @param {Object} resource  - object from which the event occured
   * @param {Number} actor     - actor who triggered the event
  ###
  schema.methods.emit = (eventName, targetId, resource, actor) ->
    if options.emitter
      options.emitter.emit(eventName, targetId, resource, actor)

  ###*
   * Add a comment
   *
   * @param {Number} userId  - user id adding comment
   * @param {String} message - text message
   * @callback(err, updatedRattle)
  ###
  schema.methods.addComment = (userId, message, callback) ->
    self = this

    comment =
      message:       message
      creator:       userId
      dateCreation:  moment().toDate()
      dateUpdate:    moment().toDate()
    this.comments.push(comment)

    this.save (err, updatedRattle) ->
      return callback(err) if err isnt null
      # emit addComment event with information on object, targetId, actor
      self.emit('addComment', comment._id, self, userId)
      callback(err, updatedRattle)

    return this.comments[this.comments.length - 1]._id

  ###*
   * Add a reply to a comment
   *
   * @param {Number} userId    - user id replying to the comment
   * @param {Number} commentId - comment id on which the user reply
   * @param {String} message   - text message
   * @callback(err, updatedRattle)
  ###
  schema.methods.addReplyToComment = (userId, commentId, message, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    self = this

    reply =
      message:       message
      creator:       userId
      dateCreation:  moment().toDate()
      dateUpdate:    moment().toDate()
    comment.comments.push(reply)

    this.save (err, updatedRattle) ->
      return callback(err) if err isnt null
      # emit addReplyToComment event with information on object, targetId, actor
      self.emit('addReplyToComment', reply._id, comment, userId)
      callback(err, updatedRattle)

    return comment.comments[comment.comments.length - 1]._id

  ###*
   * Edit a comment
   *
   * @param {Number} userId    - user id editing the comment
   * @param {Number} commentId - comment id on which the user edit
   * @param {String} message   - text message
   * @callback(err, updatedRattle)
  ###
  schema.methods.editComment = (userId, commentId, message, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment
    return callback(new Error('Only owner can edit comment')) if String(comment.creator) isnt String(userId)

    comment.message    = message
    comment.dateUpdate = moment().toDate()

    self = this

    this.save (err, updatedRattle) ->
      return callback(err) if err isnt null
      # emit editComment event with information on object, targetId, actor
      self.emit('editComment', comment._id, self, userId)
      callback(err, updatedRattle)

    return this.comments[this.comments.length - 1]._id

  ###*
   * Remove a comment
   *
   * @param {Number} userId    - user id removing the comment
   * @param {Number} commentId - comment id removed
   * @callback(err, updatedRattle)
  ###
  schema.methods.removeComment = (userId, commentId, callback) ->
    return callback(new Error('Comment doesn\'t exist')) if !this.getComment(commentId)

    found = false
    this.comments = this.comments.filter (comment) ->
      keep = String(comment.creator) isnt String(userId) || String(comment._id) isnt String(commentId)
      found = found || !keep
      return keep

    return callback(new Error('Comment not found among creator\'s comments'), this) if !found
    self = this

    this.save (err, updatedRattle) ->
      return callback(err) if err isnt null
      # emit removeComment event with information on object, targetId, actor
      self.emit('removeComment', self._id, self, userId)
      callback(err, updatedRattle)

  ###*
   * Like a rattle
   *
   * @param {Number} userId - user id liking
   * @callback(err, updatedRattle)
  ###
  schema.methods.addLike = (userId, callback) ->
    hasAlreadyLiked = this.likes.some (likeUserId) ->
      return String(likeUserId) is String(userId)

    return callback(new Error('User has already liked this'), this) if hasAlreadyLiked

    this.likes.push userId
    self = this

    this.save (err, updatedRattle) ->
      return callback(err) if err isnt null
      # emit addLike event with information on object, targetId, actor
      self.emit('addLike', userId, self, userId)
      callback(err, updatedRattle)

  ###*
   * Like a comment
   *
   * @param {Number} userId    - user id liking
   * @param {Number} commentId - comment id to be liked
   * @callback(err, updatedRattle)
  ###
  schema.methods.addLikeToComment = (userId, commentId, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    hasAlreadyLiked = comment.likes.some (likeUserId) ->
      return String(likeUserId) is String(userId)

    return callback(new Error('User has already liked this comment'), this) if hasAlreadyLiked
    comment.likes.push userId

    self = this

    this.save (err, updatedRattle) ->
      return callback(err) if err isnt null
      # emit addLikeToComment event with information on object, targetId, actor
      self.emit('addLikeToComment', commentId, self, userId)
      callback(err, updatedRattle)

  ###*
   * Unlike a rattle
   *
   * @param {Number} userId - user id unliking
   * @callback(err, updatedRattle)
  ###
  schema.methods.removeLike = (userId, callback) ->
    found = false
    this.likes = this.likes.filter (likeUserId) ->
      keep = String(likeUserId) isnt String(userId)
      found = found || !keep
      return keep

    return callback(new Error('User\'s like not found among document\'s likes'), this) if !found
    self = this

    this.save (err, updatedRattle) ->
      return callback(err) if err isnt null
      # emit removeLike event with information on object, targetId, actor
      self.emit('removeLike', userId, self, userId)
      callback(err, updatedRattle)

  ###*
   * Unlike a comment
   *
   * @param {Number} userId    - user id unliking
   * @param {Number} commentId - comment id to be unliked
   * @callback(err, updatedRattle)
  ###
  schema.methods.removeLikeFromComment = (userId, commentId, callback) ->
    comment = this.getComment(commentId)
    return callback(new Error('Comment doesn\'t exist')) if !comment

    found = false
    comment.likes = comment.likes.filter (likeUserId) ->
      keep = String(likeUserId) isnt String(userId)
      found = found || !keep
      return keep

    return callback(new Error('User\'s like not found among comment\'s likes'), this) if !found
    self = this

    this.save (err, updatedRattle) ->
      return callback(err) if err isnt null
      # emit removeLike event with information on object, targetId, actor
      self.emit('removeLikeFromComment', commentId, self, userId)
      callback(err, updatedRattle)

  ###*
   * Get comment by id
   *
   * @param {Number} commentId - comment id to be retrieved
   * @return {Object} comment found
  ###
  schema.methods.getComment = (commentId) ->
    for comment in this.comments
      if String(comment._id) is String(commentId)
        return comment
    return null
