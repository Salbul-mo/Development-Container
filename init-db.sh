#!/bin/bash
envsubst < /docker-entrypoint-initdb.d/init.sql > /docker-entrypoint-initdb.d/init-processed.sql
mysql -u root -p"$MYSQL_ROOT_PASSWORD" < /docker-entrypoint-initdb.d/init-processed.sql
