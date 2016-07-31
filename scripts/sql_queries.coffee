Deferred = require('promise.coffee').Deferred
util = require 'util'

db = null

init = (new_db) ->
  db = new_db
  db.run "PRAGMA foreign_keys = ON;"


query_wrapper = (query) ->
    console.log query
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

make_admin_user_query = "INSERT INTO user (userid, is_admin, name) VALUES ('%s', %d, '%s');"

time_query = "(select strftime('%Y-%m-%d %H:%M', (select date('now', '+3 days')), '12:00'))"

pending_list_query = "SELECT * FROM fitelist WHERE is_active = 0 ORDER BY listid DESC LIMIT 1;"

pending_listid_query = "SELECT listid FROM fitelist WHERE is_active = 0 ORDER BY listid DESC LIMIT 1"

active_listid_query = "SELECT listid FROM fitelist WHERE is_active = 1 AND expires_on > datetime('now') ORDER BY listid DESC LIMIT 1"

get_all_query = "SELECT listid, description FROM fitelist;"

add_fite_query = "INSERT INTO fite (left_fiter, right_fiter, description, fitelist) VALUES ('%s', '%s', '%s', '%s');"

new_list_query = (description) ->
  main_string = "INSERT INTO fitelist (description, expires_on) VALUES ('%s', %s);"
  query_s = util.format main_string, description, time_query

list_query = "SELECT * FROM fitelist;"

get_latest_query = "SELECT * FROM fitelist where is_active = 1 AND expires_on > datetime('now') ORDER BY listid DESC LIMIT 1;"

activate_list_bit = () ->
    insert_wrapper util.format("UPDATE fitelist SET is_active = 1, expires_on = (%s) WHERE listid = (%s)", time_query, pending_listid_query)

activate_list_fn = () ->
    console.log 'activa lister'
    fulfilled = (data) ->
        get_current_fites().then (fites) ->
           i = 0
           while i < fites.length
               fite = fites[i]
               count = ++i
               insert_wrapper util.format("UPDATE fite SET rank = %d WHERE fiteid = '%s';", count, fite.fiteid)


    rejected = (err) ->
        console.log err
        err


    console.log 'making call'
    activate_list_bit().then fulfilled, rejected
       
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
        console.log list
        query_s = util.format add_fite_query, left, right, "the two hole", list[0].listid
        insert_wrapper query_s

vacuum_fites = ->
    insert_wrapper "DELETE FROM fite WHERE fitelist IN (SELECT listid FROM fitelist WHERE is_active = 0);"

make_admin_user = (user) ->
    query = util.format make_admin_user_query, user.id, 1, user.name
    insert_wrapper(query)

is_first_admin = (user) ->
    deferred = new Deferred()
    query_wrapper(util.format 'SELECT COUNT(*) AS admin_count FROM user WHERE is_admin = 1;').then (data) ->
        if parseInt(data[0].admin_count) > 0
            deferred.reject "Sorry, you're not the first to try that!"
        else
            deferred.resolve data

        deferred.promise

is_user_admin = (user) ->
    user_id = user.id
    query_wrapper(util.format "SELECT is_admin FROM user WHERE userid = %s;", user_id)


get_user = (userid) ->
    query_wrapper(util.format "SELECT * FROM user WHERE userid = '%s'", userid)

user_exists = (userid) ->
    query_wrapper(util.format "SELECT COUNT(*) > 0 AS user_exists FROM user WHERE userid = '%s'", userid).then (data) ->
        if data[0].user_exists == 1
            true
        else 
            false

add_admin = (userid) ->
    user_exists(userid).then (it_exists) ->
        if it_exists
            insert_wrapper(util.format "UPDATE user SET is_admin = 1 WHERE userid = '%s';", userid)
        else 
            "User does not exist"

vacuum_lists = () ->
    insert_wrapper "DELETE FROM fitelist WHERE is_active = 0;"


get_pending_list = () ->
  #only ever one pending
  query_wrapper pending_list_query

get_pending_fites = () ->
  query_wrapper(util.format "SELECT * FROM fite WHERE fitelist = (%s);", pending_listid_query)

get_current_fites = () ->
    query_wrapper(util.format "SELECT * FROM fite WHERE fitelist = (%s);", active_listid_query)

expire_list = () ->
    insert_wrapper util.format("UPDATE fitelist SET expires_on = datetime('now') WHERE listid = (%s);", active_listid_query)

maybeMakeUser = (user) ->
    user_exists(user.id).then (it_exists) ->
        console.log it_exists
        if it_exists == false
            query_s = "INSERT INTO user (userid, name) VALUES ('%s', '%s')"
            insert_wrapper util.format(query_s, user.id, user.name)
        else
            deferred = new Deferred()
            deferred.resolve(true)


get_fite_id = (rank) ->
    query_wrapper util.format("SELECT fiteid FROM fite WHERE fitelist = (%s) AND rank = %d;", active_listid_query, rank)

vote = (userid, rank, choice) ->
    #promises are terrible
  #first get fite id, then check if the vote is valid then cast it

    got_fite = (row) ->
        fite_id = row[0].fiteid

        valid_vote = (data) ->
            if data[0] && data[0].vote_count
                "You can only vote once!"
            else
                cast_vote userid, fite_id, choice

        invalid_vote = (err) ->
            err

        query_s = util.format "SELECT COUNT(*) AS vote_count FROM vote WHERE user = '%s' AND fiteid = %s;", userid, fite_id
        query_wrapper(query_s)
            .then valid_vote, invalid_vote

    fite_failed = (err) ->
        console.log 'err'
        err

    get_fite_id(rank).then got_fite, fite_failed



cast_vote = (user, fite_id, choice) ->
    query_s = util.format "INSERT into vote (user, fiteid, choice) VALUES ('%s', %s,'%s');", user, fite_id, choice
    insert_wrapper(query_s).then (data) ->
        "You voted " + choice + "!"

module.exports = {
    get_list: get_list,
    get_latest: get_latest,
    activate_list: activate_list_fn,
    new_list: new_list,
    get_all: get_all,
    delete_list: delete_list,
    add_fite: add_fite,
    vacuum_fites: vacuum_fites,
    make_admin_user: make_admin_user,
    is_first_admin: is_first_admin,
    is_user_admin: is_user_admin,
    add_admin: add_admin,
    vacuum_lists: vacuum_lists,
    get_user: get_user,
    get_pending_list: get_pending_list,
    get_pending_fites: get_pending_fites,
    get_current_fites: get_current_fites,
    expire_list: expire_list,
    maybeMakeUser: maybeMakeUser,
    vote: vote,
    init: init
}
