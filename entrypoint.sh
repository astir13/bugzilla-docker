#!/bin/bash
cd /var/www/html/bugzilla

# check if the necessary variables are set in the environment/docker_compose.yml
unset error_happened
for testvar in "BUGZILLA_DB_HOST" "BUGZILLA_DB_NAME" "BUGZILLA_DB_USER" "BUGZILLA_DB_PASS" "BUGZILLA_ADMIN_EMAIL" "BUGZILLA_ADMIN_PASS" "BUGZILLA_ADMIN_REALNAME"; do
  if [ -z ${!testvar+x} ]; then
    echo "[F]ATAL ERROR: Variable '${testvar}' not defined"
    error_happened=1 
  fi
done
if [ -z ${error_happened+x} ]; then
  echo "all necessary variables found"
else
  echo "stopping after errors from variable check."
  exit 1
fi

# set localconfig
sed -i "s/\$db_host =.*/\$db_host = '${BUGZILLA_DB_HOST}';/" localconfig
sed -i "s/\$db_name =.*/\$db_name = '${BUGZILLA_DB_NAME}';/" localconfig
sed -i "s/\$db_user =.*/\$db_user = '${BUGZILLA_DB_USER}';/" localconfig
sed -i "s/\$db_pass =.*/\$db_pass = '${BUGZILLA_DB_PASS}';/" localconfig
sed -i "s/\$webservergroup = .*/\$webservergroup = 'www-data';/" localconfig

# create answers to the interactively asked questions by checksetup.pl
echo "\$answer{'ADMIN_EMAIL'} = '${BUGZILLA_ADMIN_EMAIL}';" > /tmp/checksetup_answers.txt
echo "\$answer{'ADMIN_PASSWORD'} = '${BUGZILLA_ADMIN_PASS}';" >> /tmp/checksetup_answers.txt
echo "\$answer{'ADMIN_REALNAME'} = '${BUGZILLA_ADMIN_REALNAME}';" >> /tmp/checksetup_answers.txt
echo "\$answer{'urlbase'} = '${SERVERNAME}';" >> /tmp/checksetup_answers.txt
cat /tmp/checksetup_answers.txt

./checksetup.pl /tmp/checksetup_answers.txt # generates localconfig file
# rm /tmp/checksetup_answers.txt

cd /tmp
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
