mongoose = require 'mongoose'

Schema   = mongoose.Schema

UserSchema = new Schema({name: String})

User = mongoose.model "User", UserSchema

module.exports = User
