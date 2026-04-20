#!/usr/bin/env bash

set -eux

export DEBIAN_FRONTEND=noninteractive
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2);

# Install the MSSQl Server client.
if [ ! -f /usr/bin/mysql ]; then
	echo "Installing MSSQl Server client..."
	sudo apt-get update -y --no-install-recommends
	sudo apt-get install -y --no-install-recommends unixodbc-dev libgssapi-krb5-2;
	sudo pickle install sqlsrv;
	sudo pickle install pdo_sqlsrv;
	sudo su;
	printf "; priority=20\nextension=sqlsrv.so\n" > "/etc/php/$PHP_VERSION/mods-available/sqlsrv.ini";
	printf "; priority=30\nextension=pdo_sqlsrv.so\n" > "/etc/php/$PHP_VERSION/mods-available/pdo_sqlsrv.ini";
	exit;
	sudo docker-php-ext-enable sqlsrv pdo_sqlsrv;
fi

echo "Done!"
