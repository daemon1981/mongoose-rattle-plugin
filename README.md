# mongoose-rattle-plugin [![Build Status](https://secure.travis-ci.org/daemon1981/mongoose-rattle-plugin.png)](https://travis-ci.org/daemon1981/mongoose-rattle-plugin)

## Description

Add social interactions (messages and likes) to mongoose document.

You can :
 - like/unlike the document
 - add/remove comments to the document
 - add/remove replies to a comment
 - like/unlike a comment or a reply

## Installation

```
$ npm install mongoose-rattle-plugin
```

## Overview

### Add the plugin to a schema

```
var mongoose           = require('mongoose');
var MongooseRattlePlugin = require('mongoose-rattle-plugin');

var MySchema = new mongoose.Schema();

MySchema.plugin(MongooseRattlePlugin);

MySchema.add({
  'myPersonalField': String
});

var MyModel = mongoose.model("MyModel", MySchema);

module.exports = MyModel;
```

### Specifications

Please see the [specifications here](https://github.com/daemon1981/mongoose-rattle-plugin/blob/master/test-unit.md)
