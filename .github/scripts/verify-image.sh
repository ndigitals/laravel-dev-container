#!/usr/bin/env bash
#
# Verifies that a built/running Laravel Dev Container image provides the
# features, CLI commands, and versions that the Dockerfile and
# devcontainer.json features are expected to configure.
#
# Intended to be run via `devcontainer exec` (or `docker exec`) against a
# running container, e.g. from the "Validate Image" GitHub Actions workflow.
#
# Usage: verify-image.sh <expected-php-version> <expected-node-version>

set -euo pipefail

EXPECTED_PHP_VERSION="${1:-}"
EXPECTED_NODE_VERSION="${2:-}"

FAILURES=0

pass() {
	echo "  [PASS] $1"
}

fail() {
	echo "  [FAIL] $1"
	FAILURES=$((FAILURES + 1))
}

section() {
	echo ""
	echo "== $1 =="
}

check_command() {
	local label="$1"
	local cmd="$2"
	local version_output

	if command -v "$cmd" > /dev/null 2>&1; then
		# Filter out noisy PHP startup deprecation notices some tools (e.g.
		# Composer, which is itself a PHP script) may emit before their
		# actual version line.
		version_output="$("$cmd" --version 2>&1 | grep -v -i 'PHP \(Startup\|Deprecated\)\|^Deprecated:' | head -n 1)"
		pass "$label ($version_output)"
	else
		fail "$label is not available on PATH (command: $cmd)"
	fi
}

check_file() {
	local label="$1"
	local path="$2"

	if [ -e "$path" ]; then
		pass "$label ($path)"
	else
		fail "$label is missing ($path)"
	fi
}

check_php_extension() {
	local extension="$1"
	local pattern="^${extension}\$"

	# phpinfo() renders Zend extensions (opcache, xdebug) under a "Zend "
	# prefixed section header (e.g. "Zend OPcache") rather than their bare
	# module name.
	if [ "$extension" = "opcache" ]; then
		pattern="^(zend )?opcache\$"
	fi

	if grep -qiE "$pattern" <<< "$PHP_INFO_HEADERS"; then
		pass "PHP extension loaded: $extension"
	else
		fail "PHP extension NOT loaded: $extension"
	fi
}

check_php_extension_conditional() {
	local extension="$1"

	# These extensions aren't necessarily enabled by default (e.g. xdebug
	# carries a runtime performance cost many devs only want opt-in), so
	# "not currently loaded" alone isn't a failure. Fall back to checking
	# that the compiled .so is at least present under $PHP_EXTENSION_DIR -
	# reusing the extension_dir value already parsed out of $PHP_INFO, so
	# this never needs another `php` invocation.
	if grep -qi "^${extension}\$" <<< "$PHP_INFO_HEADERS"; then
		pass "PHP extension loaded: $extension"
	elif [ -f "${PHP_EXTENSION_DIR}/${extension}.so" ]; then
		pass "PHP extension compiled & present (not loaded by default): $extension (${PHP_EXTENSION_DIR}/${extension}.so)"
	else
		fail "PHP extension NOT compiled: $extension (expected ${PHP_EXTENSION_DIR}/${extension}.so)"
	fi
}

section "PHP Runtime"
# A single `php -i` (phpinfo()) invocation backs every check below. Calling
# `php` once per extension (15+ separate process spawns, one per `php -m` /
# per-file-check call) was observed to intermittently starve on the
# resource-constrained self-hosted arm64 runner, producing spurious "NOT
# loaded" failures for a different, non-deterministic set of extensions on
# every run (with no warning/error output, since affected processes were
# being killed outright rather than failing gracefully).
PHP_INFO="$(php -i)"
# phpinfo() renders each loaded extension as its own section, structured as
# a standalone line with the extension's name followed by "key => value"
# detail lines. Restricting matches to lines without "=>" isolates those
# section-header lines from phpinfo's (much larger) set of ini/config
# value lines, so a short extension name like "zip" or "xml" can't
# accidentally match inside unrelated detail text.
PHP_INFO_HEADERS="$(grep -v '=>' <<< "$PHP_INFO")"
PHP_EXTENSION_DIR="$(grep -m1 '^extension_dir =>' <<< "$PHP_INFO" | awk -F' => ' '{print $2}')"
ACTUAL_PHP_VERSION_FULL="$(grep -m1 '^PHP Version =>' <<< "$PHP_INFO" | sed 's/^PHP Version => //')"
ACTUAL_PHP_VERSION="$(cut -d. -f1,2 <<< "$ACTUAL_PHP_VERSION_FULL")"
if [ -n "$EXPECTED_PHP_VERSION" ]; then
	if [ "$ACTUAL_PHP_VERSION" = "$EXPECTED_PHP_VERSION" ]; then
		pass "PHP version matches expected $EXPECTED_PHP_VERSION (found PHP $ACTUAL_PHP_VERSION_FULL)"
	else
		fail "PHP version mismatch: expected $EXPECTED_PHP_VERSION, found $ACTUAL_PHP_VERSION"
	fi
else
	pass "PHP installed (PHP $ACTUAL_PHP_VERSION_FULL)"
fi

section "PHP Extensions (always enabled)"
for ext in mysqli pdo_mysql pgsql pdo_pgsql gd zip exif intl mbstring xml xsl sockets opcache; do
	check_php_extension "$ext"
done

section "PHP Extensions (compiled, conditionally enabled at runtime)"
for ext in redis memcached xdebug imagick; do
	check_php_extension_conditional "$ext"
done

section "PHP Extensions (local devcontainer features)"
check_php_extension "ldap"
check_php_extension "sqlsrv"
check_php_extension "pdo_sqlsrv"

section "Composer"
check_command "Composer" composer

section "Node.js / NPM"
check_command "Node.js" node
check_command "npm" npm
if [ -n "$EXPECTED_NODE_VERSION" ]; then
	ACTUAL_NODE_VERSION="$(node -e 'console.log(process.versions.node.split(".")[0])')"
	if [ "$ACTUAL_NODE_VERSION" = "$EXPECTED_NODE_VERSION" ]; then
		pass "Node.js major version matches expected $EXPECTED_NODE_VERSION"
	else
		fail "Node.js major version mismatch: expected $EXPECTED_NODE_VERSION, found $ACTUAL_NODE_VERSION"
	fi
fi

section "Git / GitHub CLI / Copilot CLI"
check_command "git" git
check_command "GitHub CLI" gh
check_command "Copilot CLI" copilot

section "Database Clients"
check_command "redis-cli" redis-cli
check_command "psql (postgres-client feature)" psql
check_command "mysql client" mysql
check_file "sqlcmd (mssql-odbc feature)" /opt/mssql-tools18/bin/sqlcmd

section "Subversion"
check_command "svn" svn

section "Summary"
if [ "$FAILURES" -eq 0 ]; then
	echo "All checks passed."
	exit 0
else
	echo "$FAILURES check(s) failed."
	exit 1
fi
