mongoose = require 'mongoose'

mongoose.connect "mongodb://127.0.0.1:27017/mongoose-rattle-test-perf", {}, (err) ->
  throw err if err
