module.exports = (db) ->
  util = require 'util'
  q = require 'q'

  TIME_QUERY = "SELECT strftime('%Y-%m-%d %H:%M',
                                (SELECT date('now', '+3 days')),
                                 '12:00')"

  get_wrapper = (query_s) ->
    db.get(query_s)
      .then (data) ->
        data
      .catch (err) ->
        throw err

  all_wrapper = (query_s) ->
    db.all(query_s)
      .then (data) ->
        data
      .catch (err) ->
        console.log err
        throw err

  run_wrapper = (query_s) ->
    db.run(query_s)
      .then (data) ->
        if !data.lastID
          throw 'NoUpdateOrInsert'
        data

  get_current_list = () ->
    query_s = "SELECT *
               FROM fitelist
               WHERE is_active = 1 AND expires_on > datetime('now')
               LIMIT 1;"

    get_wrapper(query_s)

  create_list = (name) ->
    query_s = "INSERT INTO fitelist
               (name, expires_on)
               VALUES ('%s', (%s));"

    run_wrapper util.format(query_s, name, TIME_QUERY)

  get_last_pending_list = () ->
    #interesting to note that an orm will automatically nest one-to-many type
    #relationships hierarchically but this seems very hard to do with raw
    #queries sadly two queries are needed rather than a join
    query_s = "SELECT *
               FROM fitelist
               WHERE is_active = 0 AND expires_on > datetime('now')
               ORDER BY listid DESC
               LIMIT 1;"

    get_wrapper query_s
      .then (list) ->
        if !list
          throw new Error 'no list'

        fites_query = "SELECT *
                       FROM fite
                       WHERE fitelist = '%s';"

        all_wrapper(util.format(fites_query, list.listid))
          .then (fites) ->
            list.fites = fites
            list

  add_fite_to_list = (left, right) ->
    query_s = "INSERT INTO fite
               (left_fiter, right_fiter, fitelist)
               VALUES ('%s', '%s', %d);"

    list = get_last_pending_list()
      .then (list) ->
        query = util.format(query_s, left, right, list.listid)
        db.run query

  get_row_count = (table) ->
    query_s = "SELECT COUNT(*) AS count FROM
               %s;"


    get_wrapper util.format(query_s, table)
    .then (row) ->
      row.count

  get_list_by_id = (id) ->
    query_s = "SELECT *
               FROM fitelist
               WHERE listid = '%s';"

    get_wrapper util.format(query_s, id)

  fetch_all_lists = () ->
    query_s = "SELECT name, listid
               FROM fitelist
               WHERE is_active = 0
                     AND expires_on > date('now');"

    all_wrapper query_s

  begin_transaction = () ->
    db.exec 'BEGIN'

  rollback_transaction = () ->
    db.exec 'ROLLBACK'

  activate_pending = () ->
    get_last_pending_list()
      .then (list) ->
        query_s = 'UPDATE fitelist SET is_active = 1 WHERE listid = %d'
        all_wrapper util.format(query_s, list.listid)

  api = {
    get_current_list: get_current_list
    create_list: create_list
    add_fite_to_list: add_fite_to_list
    get_list_by_id: get_list_by_id
    get_pending_list: get_last_pending_list
    get_row_count: get_row_count
    begin_transaction: begin_transaction
    rollback_transaction: rollback_transaction
    fetch_all_lists: fetch_all_lists
    activate_pending: activate_pending
  }

  api
