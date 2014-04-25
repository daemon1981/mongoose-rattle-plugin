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
task = (msg) ->
   log(3, chalk.yellow(msg))
info = (msg) ->
   log(4, chalk.blue(msg))

Thingy   = require './models/thingy'

title('Benchmarking rattle plugin')
description('In collections: 2 documents with 20000 likes, 20000 comments with 20 likes each')

async.series [
  getList = (done) ->
    target('#getList')
    task('retrieve two document with the last two comments')
    count = 1
    async.whilst (->
      count <= 5
    ), ((next) ->
      task('try ' + count)
      # hd = new memwatch.HeapDiff()
      start = Date.now()
      Thingy.getList 2, 0, (err, thingies) ->
        # diff = hd.end()
        end = Date.now()
        count++
        # log.info('memory diff after the operation (in bytes): ' + diff.change.size_bytes)
        info('time for the operation (in ms): ' + (end - start))
        next()
      return
    ), done
], (err) ->
  process.exit(1);
