#!/bin/bash
mysql -u${MYSQL_USER} -p${MYSQL_PASSWORD} -h host.docker.internal -P 3307 ${MYSQL_DATABASE}