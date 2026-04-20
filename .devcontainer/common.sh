#!/bin/bash
set -e

# If LOCAL_PHP_XDEBUG=true xdebug extension will be enabled
if [ "$LOCAL_PHP_XDEBUG" = true ]; then
	docker-php-ext-enable xdebug
	rm -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
else
	docker-php-ext-enable opcache || true
	rm -f /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
fi

# If LOCAL_PHP_MEMCACHED=true memcached extension will be enabled
if [ "$LOCAL_PHP_MEMCACHED" = true ]; then
	docker-php-ext-enable memcached
else
	rm -f /usr/local/etc/php/conf.d/docker-php-ext-memcached.ini
fi

# MSSQL Client Setup
export PATH="$PATH:/opt/mssql-tools18/bin"

### Change UID/GID
LARAVEL_PHP_UID="${PHP_FPM_UID-1000}"
LARAVEL_PHP_GID="${PHP_FPM_GID-1000}"

if [ "$LARAVEL_PHP_UID" != "`id -u laravel_php`" ]; then
	usermod -o -u "${LARAVEL_PHP_UID}" "laravel_php"
fi

if [ "$LARAVEL_PHP_GID" != "`id -g laravel_php`" ]; then
	groupmod -o -g "${LARAVEL_PHP_GID}" "laravel_php"
fi
