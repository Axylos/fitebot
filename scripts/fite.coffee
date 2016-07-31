sqlite = require 'sqlite3'
db = new sqlite.Database "fite.db"
util = require "util"
queries = require './sql_queries.coffee'
printer = require './fite_printer.coffee'

Deferred = require('promise.coffee').Deferred

queries.init(db)

module.exports = (robot) ->
  robot.hear /badger/i, (res) ->
    res.send "what i nthe fuck"

  robot.hear /current list/i, (res)->
      resp = queries.get_latest().then (data) ->
          if data.length == 0
            res.reply "There are no current fites.  Here are past fites"
            (queries.get_all()).then (data) ->
                      response_str = ''
                      data.forEach (row) ->
                          response_str = response_str.concat(util.format '\n %s   %s', row.listid, row.description)

                      res.reply response_str

          else 

            data = data[0]
            resp = util.format 'This is the "%s" Fite!  It expires on %s!', data.description, data.expires_on

            fulfilled = (fites) ->
                fite_table = printer.print_fites(fites)
                resp_string = resp + '\n' + fite_table

                res.reply resp_string

            rejected = (err) ->
                res.reply err

            queries.get_current_fites().then fulfilled, rejected


  robot.hear /get pending list/i, (res) ->
      fulfilled = (data) ->
          res.reply JSON.stringify data
          queries.get_pending_fites().then (fites) ->
              res.reply printer.print_pending_fites(fites)
      rejected = (err) ->
          res.reply err

      queries.get_pending_list().then fulfilled, rejected

  robot.hear /get pending fites/i, (res) ->
      fulfilled = (data) ->
          res.reply printer.print_pending_fites(data)
      rejected = (err) ->
          res.reply err

      queries.get_pending_fites().then fulfilled, rejected


  robot.hear /activate list/i, (res) ->
      fulfilled = (data) ->
          res.reply JSON.stringify(data)
      rejected = (err) ->
          res.reply err

      expire_fulfilled = (accepted) ->
          res.reply JSON.stringify(accepted)
          queries.activate_list().then fulfilled, rejected
      expire_rejected = (err) ->
          res.reply err

      queries.expire_list().then expire_fulfilled, expire_rejected

      queries.expire_list().then ->

  robot.hear /expire list/i, (res) ->
      fulfilled = (data) ->
          res.reply data
      rejected = (err) ->
          res.reply err

      queries.expire_list().then fulfilled, rejected

  robot.hear /make list "(.*)"/i, (res) ->
      fulfilled = (data) ->
          res.reply data
      rejected = (err) ->
          res.reply err
      queries.new_list(res.match[1]).then fulfilled, rejected


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

      fulfilled = (data) ->
          res.reply data

      rejected = (err) ->
          res.reply err

      queries.add_fite(left, right).then fulfilled, rejected

  robot.hear /vacuum fites/i, (res) ->
      queries.vacuum_fites().then (data) ->
          res.reply data

  robot.hear /vacuum inactive lists/i, (res) ->
      fulfilled = (data) ->
          res.reply data

      rejected = (err) ->
          res.reply err

      queries.vacuum_lists().then  fulfilled, rejected


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
          res.reply err + "You can only vote once!"
      queries.get_user(res.match[1]).then fulfilled, rejected

  robot.hear /vote\s+(\d)\s+(left|right)/i, (res) ->
      user = res.message.user
      fulfilled = (data) ->
          vote_good = (vote) ->
              res.reply JSON.stringify(vote)

          vote_bad = (err) ->
              eonsole.log 'failed'
              res.reply JSON.stringify err

          queries.vote(user.id, res.match[1], res.match[2]).then vote_good, vote_bad

      rejected = (err) ->
          res.reply err

      queries.maybeMakeUser(user).then fulfilled, rejected
      res.reply res.match[2]
