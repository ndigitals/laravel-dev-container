#!/usr/bin/env bash

set -eux

export DEBIAN_FRONTEND=noninteractive
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2);

# Install the MSSQl Server client.
if [ -d /opt/mssql-tools18 ]; then
	echo "Installing MSSQl Server client..."
	sudo apt-get update -y --no-install-recommends
	sudo apt-get install -y --no-install-recommends unixodbc-dev libgssapi-krb5-2;
	sudo pickle install sqlsrv;
	sudo pickle install pdo_sqlsrv;
	sudo -E docker-php-ext-enable sqlsrv pdo_sqlsrv;
fi

echo "Done!"
