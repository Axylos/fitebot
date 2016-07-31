sqlite = require 'sqlite3'
db = new sqlite.Database "fite.db"
util = require "util"
queries = require './sql_queries.coffee'

Deferred = require('promise.coffee').Deferred

queries.init(db)

module.exports = (robot) ->
  robot.hear /badger/i, (res) ->
    res.send "what i nthe fuck"

  robot.hear /current list/i, (res)->
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

  robot.hear /delete list (\d)/i, (res) ->
      (queries.delete_list(res.match[1])).then (data) ->
         res.reply data

  robot.hear /add fite "(.*)" "(.*)"/i, (res) ->
      left = res.match[1]
      right = res.match[2]

      (queries.add_fite left, right).then (data) ->
          res.reply(data)

  robot.hear /vacuum fites/i, (res) ->
      queries.vacuum_fites().then (data) ->
          res.reply data

  robot.hear /simsalabimbamba saladu saladim/i, (res) ->
      user = res.message.user

      rejected = (err) ->
          res.reply err

      fulfilled = (data) ->
          save_fulfilled = (data) ->
              res.reply "You did it!"

          queries.make_admin_user(user).then save_fulfilled, rejected

      queries.is_first_admin(user).then fulfilled, rejected

  robot.hear /am I an admin/i, (res) ->
      user = res.message.user

      queries.is_user_admin(user).then (data) ->
          if data[0].is_admin == 1
              res.reply "Yes"
          else
              res.reply "No"

  robot.hear /add admin (\d)/i, (res) ->
      user = res.message.user
      queries.is_user_admin(user).then (data) ->
          if data[0].is_admin == 1
              fulfilled = (data) ->
                  res.reply data
              rejected = (err) ->
                  res.reply err

              queries.add_admin(res.match[1]).then fulfilled, rejected
          else
              res.reply "You're not an admin!  Good Luck!"

  robot.hear /get user (\d)/i, (res) ->
      fulfilled = (data) ->
          res.reply data

      rejected = (err) ->
          res.reply err
      queries.get_user(res.match[1]).then fulfilled, rejected
