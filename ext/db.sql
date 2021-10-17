CREATE DATABASE lua_url_shortener;
USE lua_url_shortener;

CREATE TABLE urls (
    id int NOT NULL,
    url varchar(255) NOT NULL,
    short varchar(255),
    PRIMARY KEY (id)
); 

CREATE TABLE urls_info (
    id int NOT NULL,
    date_added int,
    clicks int,
    PRIMARY KEY (id)
); 
