require './bootstrap-perf'

mongoose = require 'mongoose'
async    = require 'async'
memwatch = require 'memwatch'
chalk    = require 'chalk'

log = (level, msg) ->
  console.log(Array(level).join('  ') + msg)
title = (msg) ->
   log(1, chalk.bold.magenta.underline(msg))
description = (msg) ->
   log(1, chalk.bold.italic(msg))
target = (msg) ->
   log(2, chalk.green(msg))
info = (msg) ->
   log(4, chalk.blue(msg))

Thingy   = require './models/thingy'

numOccurence = 3

# hd = new memwatch.HeapDiff()
# diff = hd.end()
# log.info('memory diff after the operation (in bytes): ' + diff.change.size_bytes)

task = () ->
  msg      = arguments[0]
  obj      = arguments[1]
  fctName  = arguments[2]
  args     = Array::slice.call(arguments, 3, arguments.length - 1)
  callback = arguments[arguments.length - 1]

  log(3, chalk.yellow(msg))
  count = 1
  totalTime = 0
  async.whilst (->
    count <= numOccurence
  ), ((next) ->
    start = Date.now()

    cb = (err) ->
      return next(err) if err
      end = Date.now()
      time = end - start
      totalTime += time
      info("[iteration #{count}] time for the operation (in ms): #{time}")
      count++
      next()

    fctArgs = args.slice(0)
    fctArgs.push(cb)
    obj[fctName].apply obj, fctArgs
    return
  ), (err) ->
    return callback(err) if err
    avg = Math.ceil(totalTime / numOccurence)
    info("=> average time: #{avg}")
    callback()

title("Benchmarking rattle plugin (number of occurence: #{numOccurence})")
description('In collections: 2 documents with 20000 likes, 20000 comments with 20 likes each')

# describe 'Thingy', ->
#   describe 'getList', ->
#     analyse('retrieve 2 documents with no comments', Thingy, 'getList', 2, 0, next)
#     analyse('retrieve 3 documents with the last 5 comments', Thingy, 'getList', 3, 5, next)

async.series [
  getList = (done) ->
    target('#getList')
    async.series [
      (next) ->
        task('retrieve two documents with no comments', Thingy, 'getList', 2, 0, next)
    ], done
    
], (err) ->
  process.exit(1);
