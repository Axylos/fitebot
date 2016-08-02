module.exports = (db) ->
  util = require 'util'

  TIME_QUERY = "SELECT strftime('%Y-%m-%d %H:%M', (SELECT date('now', '+3 days')), '12:00')"

  get_wrapper = (query_s) ->
    db.get(query_s)
      .then (data) -> 
        data

      .catch (err) ->
        err


  get_current_list = () ->
    query_s = "SELECT *
               FROM fitelist
               WHERE is_active = 1 AND expires_on > datetime('now')
               LIMIT 1;"

    get_wrapper(query_s)

  create_list = (name) ->
    query_s = "INSERT INTO fitelist
               (description, expires_on)
               VALUES ('%s', (%s));"

    db.run util.format(query_s, name, TIME_QUERY)

  get_last_pending_list = () ->
    query_s = "SELECT *
               FROM fitelist
               WHERE is_active = 0 AND expires_on > datetime('now')
               ORDER BY listid DESC
               LIMIT 1;"

    get_wrapper query_s

  add_fite_to_list = (left, right) ->
    query_s = "INSERT INTO fite
               (left, right, fitelist)
               VALUES ('%s', '%s', %d);"

    list = get_last_pending_list()
      .then (list) ->
        query = util.format(query_s, left, right, list.listid)
        db.run query

  {
    get_current_list: get_current_list
    create_list: create_list
    add_fite_to_list: add_fite_to_list
    get_pending_list: get_last_pending_list
  }
