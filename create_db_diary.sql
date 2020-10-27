CREATE TABLE diary_data (
    id BIGINT  PRIMARY KEY
                    UNIQUE,
    chat_id   BIGINT,
    record    TEXT,
    month     INTEGER
);
