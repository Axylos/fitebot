module.exports = (api) ->

  setup_db = require './fitedb/db_setup'
  db = null
  fitedb = null
  #setup_db takes an optional param force to refresh the db
  setup_db().then (new_db) ->
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
      fitedb.add_fite_to_list(left, right)
        .then (data) ->
          data
        .catch (err) ->
          throw new Error err

    api.get_row_count = (table) ->
      fitedb.get_row_count table
        .then (data) ->
          data
        .catch (err) ->
          err
