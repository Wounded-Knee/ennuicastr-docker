#$/bin/bash
docker-compose exec web bash -c "echo -e '.headers on\nselect * from errors limit 100\n'|sqlite3 /ennuicastr-server/njsp/nodejs-server-pages-error.db"
