mongoose = require 'mongoose'

Schema   = mongoose.Schema

RattlePlugin = require '../../src/plugins/rattle'

ThingummySchema = new Schema()
ThingummySchema.plugin RattlePlugin, name: 'thingummy'

Thingummy = mongoose.model "Thingummy", ThingummySchema

module.exports = Thingummy
