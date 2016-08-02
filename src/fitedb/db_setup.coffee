module.exports = (db_setup) ->
  qdb = require 'q-sqlite3'
  fs = require 'fs'
  db = null
  file = './fite.db'

  db_setup.make = (force) ->

    if force && fs.existsSync file
      fs.unlinkSync(file)

    exists = fs.existsSync file

    if !exists
      qdb.createDatabase(file).then (new_db) ->
        db = new_db
      .then () ->

        if !exists || force
          db.run "CREATE TABLE fitelist(
              listid  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
              description   VARCHAR(255),
              expires_on  DATETIME NOT NULL,
              is_active BOOLEAN DEFAULT 0 NOT NULL
              );"
              .then (data) ->
                db.run "CREATE TABLE fite(
                  fiteid   INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                  created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                  left_fiter  VARCHAR(255)  NOT NULL,
                  right_fiter  VARCHAR(255)  NOT NULL,
                  description  VARCHAR(255),
                  fitelist INTEGER NOT NULL,
                  rank INTEGER,
                  FOREIGN KEY(fitelist) REFERENCES fitelist(listid)
                  );"
              .then (data) ->
                db.run "CREATE TABLE user(
                  userid VARCHAR(255) PRIMARY KEY NOT NULL,
                  created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                  is_admin BOOLEAN DEFAULT 0 NOT NULL,
                  name VARCHAR(255) NOT NULL
                  );",

              .then (data) ->
                db.run "CREATE TABLE vote(
                  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                  created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                  choice varchar(5) NOT NULL,
                  fiteid INTEGER NOT NULL,
                  user VARCHAR(255) NOT NULL,
                  FOREIGN KEY(fiteid) REFERENCES fite(fiteid),
                  FOREIGN KEY(user) REFERENCES user(userid),
                  UNIQUE(user, fiteid)
                  );"
              .catch (err) ->
                console.log err
          .then (data) ->
            console.log data
