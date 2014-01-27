# TOC
   - [Thingy](#thingy)
     - [When saving](#thingy-when-saving)
     - [Playing rattle](#thingy-playing-rattle)
       - [When getting a comment](#thingy-playing-rattle-when-getting-a-comment)
       - [When adding a comment](#thingy-playing-rattle-when-adding-a-comment)
       - [When editing a comment](#thingy-playing-rattle-when-editing-a-comment)
         - [when user is not the creator](#thingy-playing-rattle-when-editing-a-comment-when-user-is-not-the-creator)
         - [when user is the creator](#thingy-playing-rattle-when-editing-a-comment-when-user-is-the-creator)
       - [When removing a comment](#thingy-playing-rattle-when-removing-a-comment)
         - [when user is not the creator](#thingy-playing-rattle-when-removing-a-comment-when-user-is-not-the-creator)
         - [when user is the creator](#thingy-playing-rattle-when-removing-a-comment-when-user-is-the-creator)
       - [When adding a user like](#thingy-playing-rattle-when-adding-a-user-like)
       - [When removing a user like](#thingy-playing-rattle-when-removing-a-user-like)
       - [When adding a reply to a comment](#thingy-playing-rattle-when-adding-a-reply-to-a-comment)
       - [When adding a user like to a comment](#thingy-playing-rattle-when-adding-a-user-like-to-a-comment)
       - [When removing a user like from a comment](#thingy-playing-rattle-when-removing-a-user-like-from-a-comment)
   - [Activity](#activity)
<a name=""></a>

<a name="thingy"></a>
# Thingy
<a name="thingy-when-saving"></a>
## When saving
should update dateCreation and dateUpdate when inserting.

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

should only update dateUpdate when updating.

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

<a name="thingy-playing-rattle"></a>
## Playing rattle
<a name="thingy-playing-rattle-when-getting-a-comment"></a>
### When getting a comment
should retrieve null if comment doesn't exist.

```js
return assert.equal(null, thingy.getComment('n0t3x1t1n9'));
```

should be able to retrieve a simple level comment.

```js
assert.equal(level1UserOneMsg, thingy.getComment(commentIds['level 1 ' + userOneId]).message);
return assert.equal(level1UserTwoMsg, thingy.getComment(commentIds['level 1 ' + userTwoId]).message);
```

should be able to retrieve a second level comment.

```js
assert.equal(level2UserOneMsg, thingy.getComment(commentIds['level 2 ' + userOneId]).message);
return assert.equal(level2UserTwoMsg, thingy.getComment(commentIds['level 2 ' + userTwoId]).message);
```

should be able to retrieve a third level comment.

```js
return assert.equal(level3UserTwoMsg, thingy.getComment(commentIds['level 3 ' + userOneId]).message);
```

<a name="thingy-playing-rattle-when-adding-a-comment"></a>
### When adding a comment
should fails if message length is out of min and max.

```js
return thingy.addComment(commentorUserId, '', function(err) {
  should.exists(err);
  return done();
});
```

should append a new comment and return comment id.

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

should update dateCreation and dateUpdated.

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

<a name="thingy-playing-rattle-when-editing-a-comment"></a>
### When editing a comment
should fails if message length is out of min and max.

```js
return thingy.editComment(commentorUserId, commentId, '', function(err) {
  should.exists(err);
  return done();
});
```

<a name="thingy-playing-rattle-when-editing-a-comment-when-user-is-not-the-creator"></a>
#### when user is not the creator
should fails.

```js
return thingy.editComment('n0t3x1t1n9', commentId, updatedMessage, function(err) {
  should.exists(err);
  return done();
});
```

<a name="thingy-playing-rattle-when-editing-a-comment-when-user-is-the-creator"></a>
#### when user is the creator
should edit comment and return comment id if user is the owner.

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

should update dateCreation and dateUpdated.

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

<a name="thingy-playing-rattle-when-removing-a-comment"></a>
### When removing a comment
should fails if comment doesn't exist.

```js
return thingy.removeComment(commentorUserId, 'n0t3x1t1n9', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

<a name="thingy-playing-rattle-when-removing-a-comment-when-user-is-not-the-creator"></a>
#### when user is not the creator
should not remove comment.

```js
return thingy.removeComment('n0t3x1t1n9', commentIds['level 1'], function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.exists(updatedThingy.getComment(commentIds['level 1']));
  return done();
});
```

<a name="thingy-playing-rattle-when-removing-a-comment-when-user-is-the-creator"></a>
#### when user is the creator
should remove comment of level1.

```js
return thingy.removeComment(commentorUserId, commentIds['level 1'], function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.not.exists(updatedThingy.getComment(commentIds['level 1']));
  return done();
});
```

should remove comment of level2.

```js
return thingy.removeComment(commentorUserId, commentIds['level 2'], function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.not.exists(updatedThingy.getComment(commentIds['level 2']));
  return done();
});
```

should remove comment of level3.

```js
return thingy.removeComment(commentorUserId, commentIds['level 3'], function(err, updatedThingy) {
  should.exists(updatedThingy);
  should.not.exists(updatedThingy.getComment(commentIds['level 3']));
  return done();
});
```

<a name="thingy-playing-rattle-when-adding-a-user-like"></a>
### When adding a user like
should add one user like if user doesn't already liked.

```js
return thingy.addLike(commentorUserId, function(err, updatedThingy) {
  assert.equal(1, updatedThingy.likes.length);
  return done();
});
```

shouldn't add an other user like if user already liked.

```js
return thingy.addLike(commentorUserId, function(err, updatedThingy) {
  return thingy.addLike(commentorUserId, function(err, updatedThingy) {
    assert.equal(1, thingy.likes.length);
    return done();
  });
});
```

<a name="thingy-playing-rattle-when-removing-a-user-like"></a>
### When removing a user like
should not affect current likes list if user didn'nt already liked.

```js
return thingy.removeLike(userTwoId, function(err, updatedThingy) {
  assert.equal(2, updatedThingy.likes.length);
  return done();
});
```

should remove user like from likes list if user already liked.

```js
return thingy.removeLike(commentorUserId, function(err, updatedThingy) {
  assert.equal(1, updatedThingy.likes.length);
  return done();
});
```

<a name="thingy-playing-rattle-when-adding-a-reply-to-a-comment"></a>
### When adding a reply to a comment
should fails if comment doesn't exist.

```js
return thingy.addReplyToComment(commentorUserId, 'n0t3x1t1n9', 'dummy message', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

should fails if message length is out of min and max.

```js
return thingy.addReplyToComment(commentorUserId, commentId, '', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

should append a new comment to the parent comment if parent comment exists.

```js
return thingy.addReplyToComment(commentorUserId, commentId, 'dummy message', function(err, updatedThingy) {
  assert.equal(1, updatedThingy.getComment(commentId).comments.length);
  return done();
});
```

<a name="thingy-playing-rattle-when-adding-a-user-like-to-a-comment"></a>
### When adding a user like to a comment
should fails if comment doesn't exist.

```js
return thingy.addLikeToComment(commentorUserId, 'n0t3x1t1n9', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

should add one user like if user doesn't already liked and comment exists.

```js
return thingy.addLikeToComment(commentorUserId, commentId, function(err, updatedThingy) {
  assert.equal(1, updatedThingy.getComment(commentId).likes.length);
  return done();
});
```

shouldn't add an other user like if user already liked and comment exists.

```js
return thingy.addLikeToComment(commentorUserId, commentId, function(err, updatedThingy) {
  return thingy.addLikeToComment(commentorUserId, commentId, function(err, updatedThingy) {
    assert.equal(1, updatedThingy.getComment(commentId).likes.length);
    return done();
  });
});
```

<a name="thingy-playing-rattle-when-removing-a-user-like-from-a-comment"></a>
### When removing a user like from a comment
should fails if comment doesn't exist.

```js
return thingy.removeLikeFromComment(commentorUserId, 'n0t3x1t1n9', function(err, updatedThingy) {
  should.exists(err);
  return done();
});
```

should not affect current likes list if user didn'nt already liked.

```js
return thingy.removeLikeFromComment(new ObjectId(), commentId, function(err, updatedThingy) {
  assert.equal(2, updatedThingy.getComment(commentId).likes.length);
  return done();
});
```

should remove user like from likes list if user already liked.

```js
return thingy.removeLikeFromComment(commentorUserId, commentId, function(err, updatedThingy) {
  assert.equal(1, updatedThingy.getComment(commentId).likes.length);
  return done();
});
```

<a name="activity"></a>
# Activity
should save all activities.

```js
return Activity.find(function(err, activities) {
  should.not.exists(err);
  assert.equal(8, activities.length);
  return done();
});
```

get activities on objectCreation of type thingy.

```js
return Activity.findByObjectNameAndAction('Thingy', Activity.actions.objectCreation, function(err, activities) {
  should.not.exists(err);
  assert.equal(1, activities.length);
  return done();
});
```
