mongoose = require 'mongoose'

Schema   = mongoose.Schema

RattlePlugin = require '../../src/index'

ThingySchema = new Schema()
ThingySchema.plugin RattlePlugin, name: 'thingy'

Thingy = mongoose.model "Thingy", ThingySchema

module.exports = Thingy
