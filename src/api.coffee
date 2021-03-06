module.exports = (api) ->

  setup_db = require './fitedb/db_setup'
  q = require 'q'
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
          throw err

    api.get_pending_list = () ->
      fitedb.get_pending_list()
      .then (data) ->
        data
      .catch (err) ->
        throw err

    api.create_list = (name) ->
      fitedb.create_list(name)
        .then (data) ->
          data

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

    api.get_list_by_id = (id) ->
      fitedb.get_list_by_id id
        .then (data) ->
          data

    api.begin_transaction = () ->
      fitedb.begin_transaction()
        .then (data) ->
          data

    api.rollback_transaction = () ->
      fitedb.rollback_transaction()
        .then (data) ->
          data

    api.fetch_all_pending_lists = () ->
      fitedb.fetch_all_pending_lists()
        .then (data) ->
          data

    api.activate_pending_list = () ->
      fitedb.activate_pending()
        .then (data) ->
          data
        .catch (err) ->
          throw err

    q.resolve fitedb



