sql_stmts = [

    "CREATE TABLE fitelist(
        listid  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
        description   VARCHAR(255),
        expires_on  DATETIME NOT NULL,
        is_active BOOLEAN DEFAULT 0 NOT NULL
    );",

    "CREATE TABLE fite(
        fiteid   INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
        left_fiter  VARCHAR(255)  NOT NULL,
        right_fiter  VARCHAR(255)  NOT NULL,
        description  VARCHAR(255),
        fitelist INTEGER NOT NULL,
        rank INTEGER,
        FOREIGN KEY(fitelist) REFERENCES fitelist(listid)
    );",

    "CREATE TABLE user(
        userid VARCHAR(255) PRIMARY KEY NOT NULL,
        created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
        is_admin BOOLEAN DEFAULT 0 NOT NULL,
        name VARCHAR(255) NOT NULL
    );",

    "CREATE TABLE vote(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
        choice varchar(5) NOT NULL,
        fiteid INTEGER NOT NULL,
        user VARCHAR(255) NOT NULL,
        FOREIGN KEY(fiteid) REFERENCES fite(fiteid),
        FOREIGN KEY(user) REFERENCES user(userid),
        UNIQUE(user, fiteid)
    );"
]
setup_db = (db) ->
    console.log 'setting up db'
    db.serialize () ->
        sql_stmts.forEach (stmt) ->
            db.run stmt

module.exports = {
    setup_db: setup_db
}
