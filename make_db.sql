CREATE TABLE fitelist(
    listid  INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description   VARCHAR(255),
    expires_on  DATETIME NOT NULL
);

CREATE TABLE fite(
    fiteid   INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_fiter  VARCHAR(255)  NOT NULL,
    right_fiter  VARCHAR(255)  NOT NULL,
    description  VARCHAR(255),
    fitelist INTEGER NOT NULL,
    FOREIGN KEY(fitelist) REFERENCES fitelist(listid)
);
