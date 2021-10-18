# lua-url-shortener

![total lines](https://img.shields.io/tokei/lines/github/CyanPiano/lua-url-shortener) ![last commit](https://img.shields.io/github/last-commit/CyanPiano/lua-url-shortener) ![repo size](https://img.shields.io/github/repo-size/CyanPiano/lua-url-shortener)

URL shortening API written in lua. Similar to how [bit.ly](https://bitly.com/) works. This isn't meant to be a serious project and I made it mostly for getting better at the language. This api won't scale at all and I probably spent more time writing helper functions than actually writing the api.

## Installation
This api requires MySQL (or MariaDB) to be installed and configured. First install the required luarocks.
```sh
$ luarocks install http
$ luarocks install luasql-mysql MYSQL_INCDIR=/usr/include/mysql # or wherever you have your mysql dir.
$ luarocks install json-lua
```

Execute `ext/db.sql`.
```
$ mysql -u user -p
mysql> source /path/to/api/ext/db.sql;
```

Copy and configure `config.json`.
```sh
$ cp ext/config.sample.json ./config.json
$ nano config.json
```

Finally, run the api with:
```sh
$ lua app.lua
```

## Dependencies
`rxi/log.lua` and `golgote/neturl` don't exist on luarocks and are installed in the `/lib` directory.

- [rxi/log.lua](https://github.com/rxi/log.lua)
- [keplerproject/luasql](https://github.com/keplerproject/luasql/)
- [daurnimator/lua-http](https://github.com/daurnimator/lua-http)
- [jiyinyiyong/json-lua](https://github.com/jiyinyiyong/json-lua)
- [golgote/neturl](https://github.com/golgote/neturl)
