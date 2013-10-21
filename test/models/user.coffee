mongoose = require 'mongoose'

Schema   = mongoose.Schema

UserSchema = new Schema()

User = mongoose.model "User", UserSchema

module.exports = User
