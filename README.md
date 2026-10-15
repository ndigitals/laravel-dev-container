# Laravel Dev Container

[![Release Status](https://github.com/ndigitals/laravel-dev-container/actions/workflows/release-build.yml/badge.svg?branch=main)](https://github.com/ndigitals/laravel-dev-container/actions/workflows/release-build.yml)

Laravel &amp; PHP/NodeJS Dev Container

## Supported tags

- `php-8.4-node-24`
- `php-8.3-node-24`

## Prerequisites

- [Install Docker](https://www.docker.com/)

## Usage

When setting up your Dev Container choose a tag for the PHP & NodeJS version you need.

- Local Development Options
  - Visual Studio Code w/ [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
    - [Tutorial](https://code.visualstudio.com/docs/devcontainers/tutorial)
  - [DevPod](https://devpod.sh/) using either the [GUI](https://devpod.sh/docs/getting-started/install) or [CLI](https://devpod.sh/docs/getting-started/quickstart-devpod-cli)
- [Codespaces](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers)

## Features & Services

The following tools, CLIs, and services are built into the image (via the `Dockerfile`) or
added through [Dev Container Features](https://containers.dev/features) configured in
[`devcontainer.json`](.devcontainer/devcontainer.json).

| Feature / Service | Source | Notes |
| ------------------------ | ------------------------------------------------------- | ----------------------------------------------------------------- |
| PHP-FPM | `Dockerfile` (`php:${PHP_VERSION}-fpm-trixie`) | See [PHP Extensions](#php-extensions) below |
| Composer | `Dockerfile` | Installed & verified via official installer signature |
| Node.js & npm | `ghcr.io/devcontainers/features/node:2` | Version set via `NODE_VERSION` |
| Git | `ghcr.io/devcontainers/features/git:1` | |
| GitHub CLI (`gh`) | `ghcr.io/devcontainers/features/github-cli:1` | |
| GitHub Copilot CLI | `ghcr.io/devcontainers/features/copilot-cli:1` | |
| Redis CLI | `ghcr.io/42atomys/devcontainers-features/redis-cli:1` | `redis-cli` client only, not a Redis server |
| PostgreSQL Client | `ghcr.io/rails/devcontainer/features/postgres-client:1` | `psql` client only, not a PostgreSQL server |
| MySQL/MariaDB Client | `./local-features/mysql-client` | Installs `default-mysql-client` (`mysql` CLI) |
| MSSQL Server ODBC Driver | `./local-features/mssql-odbc` | Installs `msodbcsql`, `mssql-tools18` (`sqlcmd`, `bcp`), `sqlpackage` |
| MSSQL Server PHP Client | `./local-features/mssql-client` | Installs the `sqlsrv`/`pdo_sqlsrv` PHP extensions (requires the MSSQL ODBC feature above) |
| PHP LDAP Extension | `./local-features/php-ldap` | Installs & enables the `ldap` PHP extension |
| Subversion CLI | `./local-features/subversion` | Installs the `svn` CLI |
| PHP CLI w/ Xdebug Config | `./local-features/php-cli-xdebug` | Configures a dedicated `php-cli.ini` for CLI usage |
| Common Utils (`sudo`, etc.) | `ghcr.io/devcontainers/features/common-utils:2` | Configures the non-root `laravel_php` user |

## PHP Extensions

| Extension | Purpose | Status |
| --------------- | --------------------------------------- | ----------------------------------------------------------------------- |
| `opcache` | PHP bytecode caching | Enabled by default; disabled when `LOCAL_PHP_XDEBUG=true` |
| `sockets` | Low-level socket communication | Always enabled |
| `gd` | Image processing (JPEG/WebP support) | Always enabled |
| `mysqli` | MySQL/MariaDB driver | Always enabled |
| `pdo_mysql` | PDO driver for MySQL/MariaDB | Always enabled |
| `pgsql` | PostgreSQL driver | Always enabled |
| `pdo_pgsql` | PDO driver for PostgreSQL | Always enabled |
| `zip` | ZIP archive support | Always enabled |
| `exif` | Image metadata reading | Always enabled |
| `intl` | Internationalization/localization | Always enabled |
| `mbstring` | Multibyte string handling | Always enabled |
| `xml` | XML parsing | Always enabled |
| `xsl` | XSLT transformations | Always enabled |
| `redis` | Redis client driver | Always enabled |
| `imagick` | ImageMagick bindings | Always enabled |
| `memcached` | Memcached client driver | Compiled in; enabled only when `LOCAL_PHP_MEMCACHED=true` |
| `xdebug` | Step debugging & profiling | Compiled in; enabled only when `LOCAL_PHP_XDEBUG=true` (disables `opcache`) |
| `ldap` | LDAP directory access | Enabled via the `php-ldap` Dev Container Feature |
| `sqlsrv` | SQL Server driver | Enabled via the `mssql-client` Dev Container Feature |
| `pdo_sqlsrv` | PDO driver for SQL Server | Enabled via the `mssql-client` Dev Container Feature |

## Support & Feedback

If you have any questions or issues after using the image, you can report any issues via [Github](https://github.com/ndigitals/laravel-dev-container/issues).

## Contributing

Pull requests are always welcome.
