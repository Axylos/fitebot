# Description
#   conceptual warfare (with voting)
#
# Configuration:
#   LIST_OF_ENV_VARS_TO_SET
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Axylos[@<org>]

api = require './api'
db_setup = require './fitedb/db_setup'

#setup and conditionall build db
db = {}
db_setup(db)
db.make #make takes an optional boolean param to force a db refresh

module.exports = (robot) ->
  robot.respond /hello/, (msg) ->
    msg.reply "hello!"

  robot.hear /orly/, ->
    msg.send "yarly"

  robot.hear /badger/i, (res) ->
    msg.reply api.badger()

  robot.respond /current list/i, (res) ->
    res.reply api.get_current_list
