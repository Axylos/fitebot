module.exports = (robot) ->
  robot.hear /badger/i, (res) ->
    res.send "what i nthe fuck"

  robot.respond /open the pod bay doors/i, (res) ->
      res.reply "fuck off"

