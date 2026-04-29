#!/usr/bin/env bash

set -eux

export DEBIAN_FRONTEND=noninteractive
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2);

# Install the MSSQl Server client.
if [ -d /opt/mssql-tools18 ]; then
	echo "Installing MSSQl Server client..."
	sudo apt-get update -y --no-install-recommends
	sudo apt-get install -y --no-install-recommends unixodbc-dev libgssapi-krb5-2;
	sudo pecl install sqlsrv pdo_sqlsrv;
	sudo echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/00_sqlsrv.ini
	sudo echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/10_pdo_sqlsrv.ini
fi

echo "Done!"
