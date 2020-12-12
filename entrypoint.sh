#!/bin/bash
cd /var/www/html/bugzilla
sed -i "s/\$db_host =.*/\$db_host = ${BUGZILLA_DB_HOST}/" localconfig                                        
sed -i "s/\$db_name =.*/\$db_name = ${BUGZILLA_DB_NAME}/" localconfig                                        
sed -i "s/\$db_user =.*/\$db_user = ${BUGZILLA_DB_USER}/" localconfig                                        
sed -i "s/\$db_pass =.*/\$db_pass = ${BUGZILLA_DB_PASS}/" localconfig                                        
./checksetup.pl  # generates localconfig file

cd /tmp
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
