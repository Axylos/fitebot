module.exports = (api) ->

  setup_db = require './fitedb/db_setup'
  db = null
  fitedb = null
  setup_db().then (new_db) ->#setup_db takes an optional param force to refresh the db
    db = new_db
    fitedb = require('./fitedb/fitedb')(db)

    api.badger = () ->
      "what?!"

    api.shout = () ->
      'SHOUT'

    api.get_current_list = () ->
      fitedb.get_current_list()
        .then (data) ->
          data
        .catch (err) ->
          err

    api.get_pending_list = () ->
      fitedb.get_pending_list()
      .then (data) ->
        data
      .catch (err) ->
        err

    api.create_list = (name) ->
      fitedb.create_list(name)
        .then (data) ->
          data
        .catch (err) ->
          err

    api.add_fite = (left, right) ->
      fitedb.get_pending_list().then (listid) ->
        fitedb.add_fite_to_list(left, right)
        .then (data) ->
          data
        .catch (err) ->
          err
