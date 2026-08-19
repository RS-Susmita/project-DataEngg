--Spotify pipeline: setup infrastructure, load CSV from stage, 


USE ROLE ACCOUNTADMIN;
USE WAREHOUSE LAB_WH_SR
USE DATABASE retail_db_SR;
USE SCHEMA raw;
DROP TABLE IF EXISTS SPOTIFY_TBL;
DROP STAGE IF EXISTS SPOTIFY_STAGE;
DROP FILE FORMAT IF EXISTS CSV_FORMAT;

CREATE FILE FORMAT CSV_FORMAT
  TYPE = 'CSV'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

SHOW FILE FORMATS IN SCHEMA retail_db_SR.raw;

CREATE STAGE STAGE_SPOTIFY
FILE_FORMAT = CSV_FORMAT;
SHOW STAGES IN SCHEMA retail_db_SR.raw;
LIST @retail_db_SR.raw.STAGE_SPOTIFY;


SELECT
    $1, $2, $3, $4, $5, $6, $7, $8, $9,
    $10, $11, $12, $13, $14, $15, $16, $17
FROM @retail_db_SR.raw.stage_spotify
LIMIT 5;

SELECT
    METADATA$FILE_ROW_NUMBER AS row_number,
    $1, $2, $3, $4, $5, $6, $7, $8, $9,
    $10, $11, $12, $13, $14, $15, $16, $17, $18
FROM @retail_db_SR.raw.stage_spotify
(FILE_FORMAT => 'retail_db_SR.raw.CSV_FORMAT')
WHERE $18 IS NOT NULL
LIMIT 20;

CREATE TABLE SPOTIFY_tbl (
  id INT,
  acousticness FLOAT,
  danceability FLOAT,
  duration_ms INT,
  energy FLOAT,
  instrumentalness FLOAT,
  key INT,
  liveness FLOAT,
  loudness FLOAT,
  mode INT,
  speechiness FLOAT,
  tempo FLOAT,
  time_signature INT,
  valence FLOAT,
  target INT,
  song_title STRING,
  artist STRING
);

COPY INTO SPOTIFY_TBL
FROM @stage_spotify
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'ABORT_STATEMENT';


SELECT COUNT(*) FROM SPOTIFY_TBL;

SELECT *
FROM SPOTIFY_TBL
LIMIT 10;


------- Write a query to find the top 3 songs by Drake.


SELECT
    song_title,
    artist
FROM retail_db_SR.raw.SPOTIFY_TBL
WHERE artist = 'Drake'
LIMIT 3;






---REMOVE @retail_db_SR.raw.spotify_stage/Spotify_data.csv;
---LIST @retail_db_SR.raw.spotify_stage




S