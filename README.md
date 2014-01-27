# mongoose-rattle-plugin [![Build Status](https://secure.travis-ci.org/daemon1981/mongoose-rattle-plugin.png)](https://travis-ci.org/daemon1981/mongoose-rattle-plugin)

## Description

Add social interactions to document

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
