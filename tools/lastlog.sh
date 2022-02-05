#$/bin/bash
echo -e ".headers on\nselect * from log order by time desc limit 100\n"|sqlite3 ../run/web/ennuicastr/db/log.db
