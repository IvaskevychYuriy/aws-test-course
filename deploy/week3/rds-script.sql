CREATE DATABASE TEST_DB;

CREATE TABLE TEST_TABLE
(
    ID INTEGER PRIMARY KEY,
    NAME VARCHAR(256)
);

INSERT INTO TEST_TABLE VALUES
(1, 'Hello'),
(2, 'World');

SELECT * FROM TEST_TABLE