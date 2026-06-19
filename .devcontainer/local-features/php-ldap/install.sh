#!/usr/bin/env bash

set -eux

export DEBIAN_FRONTEND=noninteractive

# Install the PHP LDAP Extension.
if [ ! -f /usr/lib/php/*/ldap.so ]; then
	echo "Installing PHP LDAP Extension...";
	sudo apt-get update -y --no-install-recommends;
	sudo apt-get install -y --no-install-recommends libldap2-dev;
	sudo rm -rf /var/lib/apt/lists/*;
	sudo -E docker-php-ext-install ldap;
	sudo -E docker-php-ext-configure ldap --with-libdir=lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH);
	sudo -E docker-php-ext-enable ldap;
fi

echo "Done!"
