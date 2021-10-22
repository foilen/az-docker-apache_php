#!/bin/bash
set -e

echo "SSH Start"
service ssh start

# Configure emails
echo "EMAIL_DEFAULT_FROM_ADDRESS : $EMAIL_DEFAULT_FROM_ADDRESS"
if [ -n "$EMAIL_DEFAULT_FROM_ADDRESS" ]; then
  echo "Create sendmail-to-msmtp config"
  cat > /etc/sendmail-to-msmtp.json << _EOF
{
  "defaultFrom" : "$EMAIL_DEFAULT_FROM_ADDRESS"
}
_EOF
fi

echo "EMAIL_HOSTNAME : $EMAIL_HOSTNAME"
echo "EMAIL_PORT : $EMAIL_PORT"
echo "EMAIL_USER : $EMAIL_USER"
if [ -n "$EMAIL_PASSWORD" ]; then
  echo "EMAIL_PASSWORD : --IS SET--"
else
  echo "EMAIL_PASSWORD : --IS NOT SET--"
fi
echo "Create msmtprc"
cat > /etc/msmtprc << _EOF
account default
host $EMAIL_HOSTNAME
port $EMAIL_PORT
auth on
user $EMAIL_USER
password $EMAIL_PASSWORD
tls on
tls_certcheck off
_EOF


echo "Create base paths"
mkdir -p /home/LogFiles/
mkdir -p /home/site/wwwroot/


echo "Configure PHP"

if [ -z "$PHP_MAX_EXECUTION_TIME_SEC" ]; then
  PHP_MAX_EXECUTION_TIME_SEC=300
fi
echo "PHP_MAX_EXECUTION_TIME_SEC : $PHP_MAX_EXECUTION_TIME_SEC"

if [ -z "$PHP_MAX_UPLOAD_FILESIZE_MB" ]; then
  PHP_MAX_UPLOAD_FILESIZE_MB=64
fi
echo "PHP_MAX_UPLOAD_FILESIZE_MB : $PHP_MAX_UPLOAD_FILESIZE_MB"

if [ -z "$PHP_MAX_MEMORY_LIMIT_MB" ]; then
  PHP_MAX_MEMORY_LIMIT_MB=192
fi
echo "PHP_MAX_MEMORY_LIMIT_MB (must be at least 3 times PHP_MAX_UPLOAD_FILESIZE_MB) : $PHP_MAX_MEMORY_LIMIT_MB"

PHP_CONFIG_FILES="/etc/php/7.4/apache2/conf.d/99-cloud.ini"
PHP_CONFIG_FILES="$PHP_CONFIG_FILES /etc/php/7.4/cli/conf.d/99-cloud.ini"
for PHP_CONFIG_FILE in $PHP_CONFIG_FILES; do
echo Save PHP config file $PHP_CONFIG_FILE
cat > $PHP_CONFIG_FILE << _EOF
[PHP]
max_execution_time = $PHP_MAX_EXECUTION_TIME_SEC

upload_max_filesize = ${PHP_MAX_UPLOAD_FILESIZE_MB}M
post_max_size = 0
max_file_uploads = 100

memory_limit = ${PHP_MAX_MEMORY_LIMIT_MB}M
_EOF
done


echo "Apache Start"
service apache2 start

APP_ID=$(cat /var/run/apache2/apache2.pid)
if [ -z "$APP_ID" ]; then
  echo apache is not running
  exit 1
fi

echo apache is running with pid $APP_PID and is ready to serve
while [ -d /proc/$APP_PID ]; do
  sleep 5s
done
