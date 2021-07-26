#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

APP_ENV=${JWT_PASSPHRASE:-$(grep ''^APP_ENV='' .env | cut -f 2 -d ''='')}
if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ]; then
	PHP_INI_RECOMMENDED="$PHP_INI_DIR/php.ini-production"
	if [ "$APP_ENV" != 'prod' ]; then
		PHP_INI_RECOMMENDED="$PHP_INI_DIR/php.ini-development"
		composer install --no-scripts --no-interaction --prefer-dist --optimize-autoloader
	fi
	ln -sf "$PHP_INI_RECOMMENDED" "$PHP_INI_DIR/php.ini"
fi

bin/console cache:clear

exec docker-php-entrypoint "$@"
