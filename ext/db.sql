CREATE DATABASE lua_url_shortener;
USE lua_url_shortener;

CREATE TABLE urls (
    id int NOT NULL AUTO_INCREMENT,
    url varchar(255) NOT NULL,
    short varchar(255),
    PRIMARY KEY (id)
); 
