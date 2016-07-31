Deferred = require('promise.coffee').Deferred
util = require 'util'

db = null

init = (new_db) ->
  db = new_db


query_wrapper = (query) ->
    deferred = new Deferred()
    db.all query,
        (err, rows) ->
            deferred.resolve rows

    deferred.promise

insert_wrapper = (query) ->
    deferred = new Deferred()
    db.run query,
        (err) ->
            deferred.resolve err
    deferred.promise


time_query = "(select strftime('%Y-%m-%d %H:%M', (select date('now', '+3 days')), '12:00'))"

get_all_query = "SELECT listid, description FROM fitelist;"

new_list_query = (description) ->
  db.run("INSERT INTO fitelist (description, expires_on) VALUES ($description,"+time_query+");",
    {$description: description})

list_query = "SELECT * FROM fitelist;"

get_latest_query = "SELECT * FROM fitelist where is_active = 1 ORDER BY listid DESC LIMIT 1;"

activate_list_query = (listid) ->
    util.format "UPDATE fitelist SET is_active = 1 WHERE listid = %d", listid

activate_list_fn = (id) ->
    insert_wrapper (activate_list_query id)

get_latest = () ->
  query_wrapper(get_latest_query)

get_list = () ->
    query_wrapper select_query

new_list = (description) ->
    insert_wrapper(new_list_query description)

get_all = ->
    query_wrapper get_all_query

delete_list = (listid) ->
    query_wrapper util.format "DELETE FROM fitelist WHERE listid = %d", listid

module.exports = {
    get_list: get_list,
    get_latest: get_latest,
    activate_list: activate_list_fn,
    new_list: new_list,
    get_all: get_all,
    delete_list: delete_list,
    init: init
}
