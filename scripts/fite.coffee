{spawn, exec} = require 'child_process'
sqlite = require 'sqlite'
db = sqlite.openDatabasesync "fite.db"



module.exports = (robot) ->
  robot.hear /badger/i, (res) ->
    res.send "what i nthe fuck"

  robot.respond /open the pod bay doors/i, (res) ->
      res.reply "fuck off"

  robot.respond /get list/i, (res) ->
      res.reply 'hey there'

  robot.hear /foobar/i, (res) ->
    response = exec "pwd"

    response.stdout.on 'data', (data) ->
        res.reply data.toString()


