#!/bin/bash
sqlite3 ../run/web/ennuicastr/db/ennuicastr.db 'update credits set credits=$V+1000, purchased=$V+1000,  subscription=2, subscription_expiry="2099-12-31";'

