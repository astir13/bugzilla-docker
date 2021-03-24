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

# ------------------------- SECTION 2 ----------------------------------
# setup postfix to receive mails from git to update bug comments from git commits
# ----------------------------------------------------------------------
if [ -z "$POSTFIX_HOSTNAME" -a -z "$POSTFIX_NETWORKS" ]; then
	    echo >&2 'error: postfix option missing '
	        echo >&2 '  You need to specify POSTFIX_HOSTNAME and POSTFIX_NETWORKS for receiving mails from a local git server'
		    exit 1
fi

# Create postfix folders
mkdir -p /var/spool/postfix/
mkdir -p /var/spool/postfix/pid

# Disable SMTPUTF8, because libraries (ICU) are missing in Alpine
postconf -e "smtputf8_enable=no"

# Log to stdout
postconf -e "maillog_file=/dev/stdout"

# Update aliases database. It's not used, but postfix complains if the .db file is missing
postalias /etc/postfix/aliases

# local mail delivery
postconf -e "mydestination=${POSTFIX_HOSTNNAME}"

# Limit message size to 1MB
postconf -e "message_size_limit=1024000"

# Reject invalid HELOs
postconf -e "smtpd_delay_reject=yes"
postconf -e "smtpd_helo_required=yes"
postconf -e "smtpd_helo_restrictions=permit_mynetworks,reject_invalid_helo_hostname,permit"

# Don't allow requests from outside
postconf -e "mynetworks=${POSTFIX_NETWORKS}"

# Set up hostname
postconf -e myhostname=$POSTFIX_HOSTNAME

# Do not relay mail from untrusted networks
postconf -e "relay_domains="

postconf -e "smtpd_recipient_restrictions=reject_non_fqdn_recipient,reject_unknown_recipient_domain,reject_unverified_recipient"

# Use 587 (submission)
sed -i -r -e 's/^#submission/submission/' /etc/postfix/master.cf

cd /tmp
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
