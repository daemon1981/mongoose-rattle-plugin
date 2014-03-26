# TOC
   - [MongooseRattlePlugin](#mongooserattleplugin)
     - [document.save(callback)](#mongooserattleplugin-documentsavecallback)
     - [Plugin methods](#mongooserattleplugin-plugin-methods)
       - [document.getComment(commentId)](#mongooserattleplugin-plugin-methods-documentgetcommentcommentid)
       - [document.addComment(userId, message, callback)](#mongooserattleplugin-plugin-methods-documentaddcommentuserid-message-callback)
       - [document.editComment(userId, commentId, message, callback)](#mongooserattleplugin-plugin-methods-documenteditcommentuserid-commentid-message-callback)
         - [when user is not the creator](#mongooserattleplugin-plugin-methods-documenteditcommentuserid-commentid-message-callback-when-user-is-not-the-creator)
         - [when user is the creator](#mongooserattleplugin-plugin-methods-documenteditcommentuserid-commentid-message-callback-when-user-is-the-creator)
       - [document.removeComment(userId, commentId, callback)](#mongooserattleplugin-plugin-methods-documentremovecommentuserid-commentid-callback)
         - [when user is not the creator](#mongooserattleplugin-plugin-methods-documentremovecommentuserid-commentid-callback-when-user-is-not-the-creator)
         - [when user is the creator](#mongooserattleplugin-plugin-methods-documentremovecommentuserid-commentid-callback-when-user-is-the-creator)
       - [document.addLike(userId, callback)](#mongooserattleplugin-plugin-methods-documentaddlikeuserid-callback)
       - [document.removeLike(userId, callback)](#mongooserattleplugin-plugin-methods-documentremovelikeuserid-callback)
       - [document.addReplyToComment(userId, commentId, message, callback)](#mongooserattleplugin-plugin-methods-documentaddreplytocommentuserid-commentid-message-callback)
       - [document.addLikeToComment(userId, commentId, callback)](#mongooserattleplugin-plugin-methods-documentaddliketocommentuserid-commentid-callback)
       - [document.removeLikeFromComment(userId, commentId, callback)](#mongooserattleplugin-plugin-methods-documentremovelikefromcommentuserid-commentid-callback)
     - [Plugin statics](#mongooserattleplugin-plugin-statics)
       - [document.getList](#mongooserattleplugin-plugin-statics-documentgetlist)
         - [(num, maxNumLastPostComments, callback)](#mongooserattleplugin-plugin-statics-documentgetlist-num-maxnumlastpostcomments-callback)
         - [(num, maxNumLastPostComments, fromDate, callback)](#mongooserattleplugin-plugin-statics-documentgetlist-num-maxnumlastpostcomments-fromdate-callback)
       - [document.getListOfCommentsById(rattleId, num, offsetFromEnd, callback)](#mongooserattleplugin-plugin-statics-documentgetlistofcommentsbyidrattleid-num-offsetfromend-callback)
<a name=""></a>
 
<a name="mongooserattleplugin"></a>
# MongooseRattlePlugin
<a name="mongooserattleplugin-documentsavecallback"></a>
## document.save(callback)
update dateCreation and dateUpdate when inserting.

```js
var clock;
clock = sinon.useFakeTimers();
return new Thingy({
  creator: objectCreatorUserId,
  owner: objectCreatorUserId
}).save(function(err, thingySaved) {
  assert.deepEqual(new Date(), thingySaved.dateCreation);
  assert.deepEqual(new Date(), thingySaved.dateUpdate);
  clock.restore();
  return done();
});
```

only update dateUpdate when updating.

```js
var clock;
clock = sinon.useFakeTimers(new Date(2011, 0, 1, 1, 1, 36).getTime());
return new Thingy({
  creator: objectCreatorUserId,
  owner: objectCreatorUserId
}).save(function(err, thingySaved) {
  clock.restore();
  clock = sinon.useFakeTimers(new Date(2012, 0, 1, 1, 1, 36).getTime());
  return thingySaved.save(function(err, thingySaved) {
    assert.notDeepEqual(new Date(), thingySaved.dateCreation);
    assert.deepEqual(new Date(), thingySaved.dateUpdate);
    clock.restore();
    return done();
  });
});
```

<a name="mongooserattleplugin-plugin-methods"></a>
## Plugin methods
<a name="mongooserattleplugin-plugin-methods-documentgetcommentcommentid"></a>
### document.getComment(commentId)
retrieve null if comment doesn't exist.

```js
return assert.equal(null, thingy.getComment('n0t3x1t1n9'));
```

can retrieve a simple level comment.

```js
assert.equal(level1UserOneMsg, thingy.getComment(commentIds['level 1 ' + userOneId]).message);
return assert.equal(level1UserTwoMsg, thingy.getComment(commentIds['level 1 ' + userTwoId]).message);
```

can retrieve a second level comment.

```js
assert.equal(level2UserOneMsg, thingy.getComment(commentIds['level 2 ' + userOneId]).message);
return assert.equal(level2UserTwoMsg, thingy.getComment(commentIds['level 2 ' + userTwoId]).message);
```

can retrieve a third level comment.

```js
return assert.equal(level3UserTwoMsg, thingy.getComment(commentIds['level 3 ' + userOneId]).message);
```

can retrieve a comment when commentId is a string and not an ObjectId.

```js
return assert.equal(level1UserOneMsg, thingy.getComment(String(commentIds['level 1 ' + userOneId])).message);
```

<a name="mongooserattleplugin-plugin-methods-documentaddcommentuserid-message-callback"></a>
### document.addComment(userId, message, callback)
append a new comment and return comment id.

```js
var commentId;
return commentId = thingy.addComment(commentorUserId, 'dummy message', function(err) {
  should.not.exists(err);
  should.exists(commentId);
  return Thingy.findById(thingy._id, function(err, updatedThingy) {
    should.exists(updatedThingy);
    assert.equal(1, updatedThingy.comments.length);
    return done();
  });
});
```

update dateCreation and dateUpdated.

```js
var clock, commentId;
clock = sinon.useFakeTimers();
return commentId = thingy.addComment(commentorUserId, 'dummy message', function(err, updatedThingy) {
  assert.deepEqual(new Date(), updatedThingy.getComment(commentId).dateCreation);
  assert.deepEqual(new Date(), updatedThingy.getComment(commentId).dateUpdate);
  clock.restore();
  return done();
});
```

fails if message length is out of min and max.

```js
return thingy.addComment(commentorUserId, '', function(err) {
  should.exists(err);
  return done();
});
```

<a name="mongooserattleplugin-plugin-methods-documenteditcommentuserid-commentid-message-callback"></a>
### document.editComment(userId, commentId, message, callback)
fails if message length is out of min and max.

```js
return thingy.editComment(commentorUserId, commentId, '', function(err) {
  should.exists(err);
  return done();
});
```

<a name="mongooserattleplugin-plugin-methods-documenteditcommentuserid-commentid-message-callback-when-user-is-not-the-creator"></a>
#### when user is not the creator
always fails.

```js
return thingy.editComment('n0t3x1t1n9', commentId, updatedMessage, function(err) {
  should.exists(err);
  return done();
});
```

<a name="mongooserattleplugin-plugin-methods-documenteditcommentuserid-commentid-message-callback-when-user-is-the-creator"></a>
#### when user is the creator
edit comment and return comment id if user is the owner.

```js
return checkEditCommentWhenOwner(commentorUserId, commentId, updatedMessage, done);
```

edit comment and return comment id if user is the owner when userId is a string.

```js
return checkEditCommentWhenOwner(String(commentorUserId), commentId, updatedMessage, done);
```

update dateCreation and dateUpdated.

```js
var clock;
clock = sinon.useFakeTimers(new Date(2012, 0, 1, 1, 1, 36).getTime());
return thingy.editComment(commentorUserId, commentId, updatedMessage, function(err, updatedThingy) {
  assert.notDeepEqual(new Date(), updatedThingy.getComment(commentId).dateCreation);
  assert.deepEqual(new Date(), updatedThingy.getComment(commentId).dateUpdate);
  clock.restore();
  return done();
});
```

<a name="mongooserattleplugin-plugin-methods-documentremovecommentuserid-commentid-callback"></a>
### document.removeComment(userId, commentId, callback)
fails if comment doesn't exist.

```js
return thingy.removeComment(commentorUserId, 'n0t3x1t1n9', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

<a name="mongooserattleplugin-plugin-methods-documentremovecommentuserid-commentid-callback-when-user-is-not-the-creator"></a>
#### when user is not the creator
it's not removing the comment.

```js
return thingy.removeComment('n0t3x1t1n9', commentIds['level 1'], function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.exists(updatedThingy.getComment(commentIds['level 1']));
  return done();
});
```

<a name="mongooserattleplugin-plugin-methods-documentremovecommentuserid-commentid-callback-when-user-is-the-creator"></a>
#### when user is the creator
can remove comment at depth 1.

```js
return thingy.removeComment(commentorUserId, commentIds['level 1'], function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.not.exists(updatedThingy.getComment(commentIds['level 1']));
  return done();
});
```

can remove comment at depth 2.

```js
return thingy.removeComment(commentorUserId, commentIds['level 2'], function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.not.exists(updatedThingy.getComment(commentIds['level 2']));
  return done();
});
```

can remove comment at depth 3.

```js
return thingy.removeComment(commentorUserId, commentIds['level 3'], function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.not.exists(updatedThingy.getComment(commentIds['level 3']));
  return done();
});
```

remove comment when userId param is a string.

```js
return thingy.removeComment(String(commentorUserId), commentIds['level 1'], function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.not.exists(updatedThingy.getComment(commentIds['level 1']));
  return done();
});
```

remove comment when commentId is a string.

```js
return thingy.removeComment(commentorUserId, String(commentIds['level 1']), function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.not.exists(updatedThingy.getComment(commentIds['level 1']));
  return done();
});
```

<a name="mongooserattleplugin-plugin-methods-documentaddlikeuserid-callback"></a>
### document.addLike(userId, callback)
add one user like if user doesn't already liked.

```js
return thingy.addLike(commentorUserId, function(err, updatedThingy) {
  assert.equal(1, updatedThingy.likes.length);
  return done();
});
```

not add an other user like if user already liked.

```js
return thingy.addLike(commentorUserId, function(err, updatedThingy) {
  return thingy.addLike(commentorUserId, function(err, updatedThingy) {
    assert.equal(1, thingy.likes.length);
    return done();
  });
});
```

not add an other user like if user already liked when userId param is a string.

```js
return thingy.addLike(commentorUserId, function(err, updatedThingy) {
  return thingy.addLike(String(commentorUserId), function(err, updatedThingy) {
    assert.equal(1, thingy.likes.length);
    return done();
  });
});
```

<a name="mongooserattleplugin-plugin-methods-documentremovelikeuserid-callback"></a>
### document.removeLike(userId, callback)
not affect current likes list if user didn'nt already liked.

```js
return thingy.removeLike(userTwoId, function(err, updatedThingy) {
  assert.equal(2, updatedThingy.likes.length);
  return done();
});
```

remove user like from likes list if user already liked.

```js
return thingy.removeLike(commentorUserId, function(err, updatedThingy) {
  assert.equal(1, updatedThingy.likes.length);
  return done();
});
```

remove user like from likes list if user already liked when userId param is a string.

```js
return thingy.removeLike(String(commentorUserId), function(err, updatedThingy) {
  assert.equal(1, updatedThingy.likes.length);
  return done();
});
```

<a name="mongooserattleplugin-plugin-methods-documentaddreplytocommentuserid-commentid-message-callback"></a>
### document.addReplyToComment(userId, commentId, message, callback)
fails if comment doesn't exist.

```js
return thingy.addReplyToComment(commentorUserId, 'n0t3x1t1n9', 'dummy message', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

fails if message length is out of min and max.

```js
return thingy.addReplyToComment(commentorUserId, commentId, '', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

append a new comment to the parent comment if parent comment exists.

```js
return thingy.addReplyToComment(commentorUserId, commentId, 'dummy message', function(err, updatedThingy) {
  assert.equal(1, updatedThingy.getComment(commentId).comments.length);
  return done();
});
```

<a name="mongooserattleplugin-plugin-methods-documentaddliketocommentuserid-commentid-callback"></a>
### document.addLikeToComment(userId, commentId, callback)
fails if comment doesn't exist.

```js
return thingy.addLikeToComment(commentorUserId, 'n0t3x1t1n9', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

add one user like if user doesn't already liked and comment exists.

```js
return thingy.addLikeToComment(commentorUserId, commentId, function(err, updatedThingy) {
  assert.equal(1, updatedThingy.getComment(commentId).likes.length);
  return done();
});
```

not add an other user like if user already liked and comment exists.

```js
return thingy.addLikeToComment(commentorUserId, commentId, function(err, updatedThingy) {
  return thingy.addLikeToComment(commentorUserId, commentId, function(err, updatedThingy) {
    assert.equal(1, updatedThingy.getComment(commentId).likes.length);
    return done();
  });
});
```

not add an other user like if user already liked and comment exists when userId param is a string.

```js
return thingy.addLikeToComment(String(commentorUserId), commentId, function(err, updatedThingy) {
  return thingy.addLikeToComment(commentorUserId, commentId, function(err, updatedThingy) {
    assert.equal(1, updatedThingy.getComment(commentId).likes.length);
    return done();
  });
});
```

<a name="mongooserattleplugin-plugin-methods-documentremovelikefromcommentuserid-commentid-callback"></a>
### document.removeLikeFromComment(userId, commentId, callback)
fails if comment doesn't exist.

```js
return thingy.removeLikeFromComment(commentorUserId, 'n0t3x1t1n9', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

not affect current likes list if user didn'nt already liked.

```js
return thingy.removeLikeFromComment(new ObjectId(), commentId, function(err, updatedThingy) {
  assert.equal(2, updatedThingy.getComment(commentId).likes.length);
  return done();
});
```

remove user like from likes list if user already liked.

```js
return thingy.removeLikeFromComment(commentorUserId, commentId, function(err, updatedThingy) {
  assert.equal(1, updatedThingy.getComment(commentId).likes.length);
  return done();
});
```

remove user like from likes list if user already liked when userId param is a string.

```js
return thingy.removeLikeFromComment(String(commentorUserId), commentId, function(err, updatedThingy) {
  assert.equal(1, updatedThingy.getComment(commentId).likes.length);
  return done();
});
```

<a name="mongooserattleplugin-plugin-statics"></a>
## Plugin statics
<a name="mongooserattleplugin-plugin-statics-documentgetlist"></a>
### document.getList
<a name="mongooserattleplugin-plugin-statics-documentgetlist-num-maxnumlastpostcomments-callback"></a>
#### (num, maxNumLastPostComments, callback)
get list of the number of 'num' last rattles.

```js
return Thingy.find({}, function(err, rattles) {
  return Thingy.getList(1, 0, function(err, rattles) {
    should.not.exists(err);
    assert.equal(rattles.length, 1);
    assert.deepEqual(rattles[0].creator, creator2Id);
    return done();
  });
});
```

get all rattles if 'num' is greater than the number of rattles.

```js
return Thingy.getList(3, 0, function(err, rattles) {
  should.not.exists(err);
  assert.equal(rattles.length, 2);
  return done();
});
```

each rattle get the maximum of 'maxLastComments' last comments.

```js
return Thingy.getList(1, 1, function(err, rattles) {
  should.not.exists(err);
  assert.equal(rattles.length, 1);
  assert.deepEqual(rattles[0].creator, creator2Id);
  should.exists(rattles[0].comments);
  assert.equal(rattles[0].comments.length, 1);
  assert.equal(rattles[0].comments[0].message, '22');
  return done();
});
```

each all comments when 'maxLastComments' is greater than number of comments.

```js
return Thingy.getList(1, 3, function(err, rattles) {
  should.not.exists(err);
  assert.equal(rattles.length, 1);
  should.exists(rattles[0].comments);
  assert.equal(rattles[0].comments.length, 2);
  return done();
});
```

<a name="mongooserattleplugin-plugin-statics-documentgetlist-num-maxnumlastpostcomments-fromdate-callback"></a>
#### (num, maxNumLastPostComments, fromDate, callback)
get list of last rattles created from the 'fromDate'.

```js
return Thingy.getList(1, 0, function(err, rattles) {
  return Thingy.getList(1, 0, rattles[0].dateCreation, function(err, rattles) {
    should.not.exists(err);
    assert.equal(rattles.length, 1);
    assert.deepEqual(rattles[0].creator, creator1Id);
    return done();
  });
});
```

get all last rattles if 'num' is greater than the number of last rattles.

```js
return Thingy.getList(1, 0, function(err, rattles) {
  return Thingy.getList(2, 0, rattles[0].dateCreation, function(err, rattles) {
    should.not.exists(err);
    assert.equal(rattles.length, 1);
    return done();
  });
});
```

each rattle get the maximum of 'maxLastComments' last comments.

```js
return Thingy.getList(1, 0, function(err, rattles) {
  return Thingy.getList(1, 1, rattles[0].dateCreation, function(err, rattles) {
    should.not.exists(err);
    assert.equal(rattles.length, 1);
    assert.deepEqual(rattles[0].creator, creator1Id);
    should.exists(rattles[0].comments);
    assert.equal(rattles[0].comments.length, 1);
    assert.equal(rattles[0].comments[0].message, '12');
    return done();
  });
});
```

<a name="mongooserattleplugin-plugin-statics-documentgetlistofcommentsbyidrattleid-num-offsetfromend-callback"></a>
### document.getListOfCommentsById(rattleId, num, offsetFromEnd, callback)
get last 'num' of comments for 'rattleId' when offsetFromEnd is 0.

```js
return Thingy.getListOfCommentsById(rattleId, 1, 0, function(err, comments) {
  should.not.exists(err);
  assert.equal(comments.length, 1);
  assert.equal(comments[0].message, '13');
  return done();
});
```

get last num of comments from the offsetFromEnd.

```js
return Thingy.getListOfCommentsById(rattleId, 1, 1, function(err, comments) {
  should.not.exists(err);
  assert.equal(comments.length, 1);
  assert.equal(comments[0].message, '12');
  return done();
});
```

get no comments when offsetFromEnd is equal to the number of comments.

```js
return Thingy.getListOfCommentsById(rattleId, 1, 3, function(err, comments) {
  should.not.exists(err);
  assert.equal(comments.length, 0);
  return done();
});
```

limit comments when offsetFromEnd + num is greater that the number of comments.

```js
return Thingy.getListOfCommentsById(rattleId, 3, 1, function(err, comments) {
  should.not.exists(err);
  assert.equal(comments[0].message, '11');
  assert.equal(comments[1].message, '12');
  assert.equal(comments.length, 2);
  return done();
});
```

keep comments order.

```js
return Thingy.getListOfCommentsById(rattleId, 3, 0, function(err, comments) {
  should.not.exists(err);
  assert.equal(comments[0].message, '11');
  assert.equal(comments[1].message, '12');
  assert.equal(comments[2].message, '13');
  assert.equal(comments.length, 3);
  return done();
});
```

