Deferred = require('promise.coffee').Deferred
util = require 'util'

db = null

init = (new_db) ->
  db = new_db
  db.run "PRAGMA foreign_keys = ON;"


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

add_fite_query = "INSERT INTO fite (left_fiter, right_fiter, description, fitelist) VALUES ('%s', '%s', '%s', '%s')" 

new_list_query = (description) ->
  db.run("INSERT INTO fitelist (description, expires_on) VALUES ($description,"+time_query+");",
    {$description: description})

list_query = "SELECT * FROM fitelist;"

get_latest_query = "SELECT * FROM fitelist where is_active = 1 ORDER BY listid DESC LIMIT 1;"

activate_list_query = (listid) ->
    util.format "UPDATE fitelist SET is_active = 1 WHERE listid = %d", listid

activate_list_fn = (id) ->
    insert_wrapper (activate_list_query id)

get_last_inactive = ->
    query_wrapper "SELECT listid FROM fitelist WHERE is_active = 0 ORDER BY listid DESC LIMIT 1;"

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

add_fite = (left, right) ->
    last_id = get_last_inactive().then (list) ->
      query_s = util.format add_fite_query, left, right, "the two hole", list[0].listid
      console.log(query_s)
      insert_wrapper query_s

vacuum_fites = ->
    insert_wrapper "DELETE FROM fite WHERE fitelist IN (SELECT listid FROM fitelist WHERE is_active = 0);"

module.exports = {
    get_list: get_list,
    get_latest: get_latest,
    activate_list: activate_list_fn,
    new_list: new_list,
    get_all: get_all,
    delete_list: delete_list,
    add_fite: add_fite,
    vacuum_fites: vacuum_fites
    init: init
}
