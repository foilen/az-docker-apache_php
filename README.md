# Description

An Apache PHP image for Microsoft Azure that has a lot of PHP extensions installed and also a sendmail replacement that supports a lot of different ways of sending emails with PHP.

It is using the instruction from https://docs.microsoft.com/en-us/azure/app-service/configure-custom-container?pivots=container-linux to have a usable image.

The sendmail replacement is https://github.com/foilen/sendmail-to-msmtp .

It is serving /home/site/wwwroot .
Log files are in /home/LogFiles .

The PHP header to tell the application that it is protected by HTTPS is set when the load-balancer tells it that it is protected.

# Build and test

```
./create-local-release.sh

docker run -ti --rm az-docker-apache_php:master-SNAPSHOT

```

# Available environment config and their defaults

- WEBSITES_ENABLE_APP_SERVICE_STORAGE=false

- PHP_MAX_EXECUTION_TIME_SEC=300
- PHP_MAX_UPLOAD_FILESIZE_MB=64
- PHP_MAX_MEMORY_LIMIT_MB=192
    - must be at least 3 times PHP_MAX_UPLOAD_FILESIZE_MB

- EMAIL_DEFAULT_FROM_ADDRESS
- EMAIL_HOSTNAME
- EMAIL_PORT
- EMAIL_USER
- EMAIL_PASSWORD
