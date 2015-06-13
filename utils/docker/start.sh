#!/bin/bash

# Give MySQL time to wake up
SECONDS_LEFT=120
while true; do
  sleep 1
  mysqladmin -h mysql --password=${MYSQL_ENV_MYSQL_ROOT_PASSWORD} ping
  if [ $? -eq 0 ];then
    break; # Success
  fi
  let SECONDS_LEFT=SECONDS_LEFT-1 

  # If we have waited >120 seconds, give up
  # ZM should never have a database that large!
  # if $COUNTER -lt 120
  if [ $SECONDS_LEFT -eq 0 ];then
    return -1;
  fi
done

# If the ZoneMinder does not exist,
# Create the ZoneMinder database and add the ZoneMinder DB user
mysql -h mysql --user=zm --password=zm --database=zm --execute='select * from Config limit 1;' || \
( mysql -h mysql -u root --password=${MYSQL_ENV_MYSQL_ROOT_PASSWORD} < db/zm_create.sql && \
mysql -h mysql -u root --password=${MYSQL_ENV_MYSQL_ROOT_PASSWORD} -e "grant insert,select,update,delete,lock tables,alter on zm.* to 'zm'@'%' identified by 'zm'" )

# Start ZoneMinder
/usr/local/bin/zmpkg.pl start

# Start apache
/usr/sbin/apache2ctl -D FOREGROUND

