module.exports = (db_setup) ->
  qdb = require 'q-sqlite3'
  fs = require 'fs'
  db = null
  file = 'fite.db'

  db_setup.make = () ->

    exists = fs.existsSync file
    qdb.createDatabase(file).then (new_db) ->
      db = new_db

    if exists
      db.serialize () ->
        db.run "CREATE TABLE fitelist(
            listid  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
            description   VARCHAR(255),
            expires_on  DATETIME NOT NULL,
            is_active BOOLEAN DEFAULT 0 NOT NULL
            );",



