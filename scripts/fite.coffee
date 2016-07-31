sqlite = require 'sqlite3'
db = new sqlite.Database "fite.db"
util = require 'util'
queries = require './sql_queries.coffee'

Deferred = require('promise.coffee').Deferred

queries.init(db)

module.exports = (robot) ->
  robot.hear /badger/i, (res) ->
    res.send "what i nthe fuck"

  robot.hear /list/i, (res)->
      resp = queries.get_latest().then (data) ->
          data = data[0]
          resp = util.format 'This is the "%s" Fite!  It expires on %s!', data.description, data.expires_on
          res.reply resp

  robot.hear /insert it/i, (res) ->
      ins_query()
      res.reply 'done'

  robot.hear /activate list (\d)/i, (res) ->
      promise = queries.activate_list res.match[1]
      promise.then (data) ->
          res.reply data

  robot.hear /make list "(.*)"/i, (res) ->
      promise = queries.new_list res.match[1]
      promise.then (data) ->
          res.reply data


  robot.hear /get all/i, (res) ->
      (queries.get_all()).then (data) ->
          response_str = ''
          data.forEach (row) ->
              response_str = response_str.concat(util.format '\n %s   %s', row.listid, row.description)

          res.reply response_str
