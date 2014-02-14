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
  clock = sinon.restore();
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
return thingy.editComment(commentorUserId, commentId, updatedMessage, function(err) {
  should.not.exists(err);
  should.exists(commentId);
  return Thingy.findById(thingy._id, function(err, updatedThingy) {
    should.exists(updatedThingy);
    assert.equal(1, updatedThingy.comments.length);
    assert.equal(updatedMessage, updatedThingy.comments[0].message);
    return done();
  });
});
```

update dateCreation and dateUpdated.

```js
var clock;
clock = sinon.useFakeTimers(new Date(2012, 0, 1, 1, 1, 36).getTime());
return thingy.editComment(commentorUserId, commentId, updatedMessage, function(err, updatedThingy) {
  assert.notDeepEqual(new Date(), updatedThingy.getComment(commentId).dateCreation);
  assert.deepEqual(new Date(), updatedThingy.getComment(commentId).dateUpdate);
  clock = sinon.restore();
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
