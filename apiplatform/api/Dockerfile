ARG PHP_VERSION=8.1
ARG NGINX_VERSION=1.17
ARG ALPINE_VERSION=3.14


FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS php

ENV LANG=pl_PL.UTF-8 \
    LANGUAGE=pl_PL.UTF-8

#timezone
RUN	apk add --no-cache tzdata; \
	ln -snf /usr/share/zoneinfo/Europe/Warsaw/etc/localtime && echo Europe/Warsaw > /etc/timezone; \
	printf '[PHP]\ndate.timezone = "Europe/Warsaw"\n' > /$PHP_INI_DIR/conf.d/tzone.ini;

# persistent packages 
# install gnu-libiconv and set LD_PRELOAD env to make iconv work fully on Alpine image.
# see https://github.com/docker-library/php/issues/240#issuecomment-763112749
RUN apk add --no-cache gnu-libiconv fcgi openssh sshpass
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

ARG APCU_VERSION=5.1.21
RUN set -eux; \
	apk add --no-cache --virtual .build-deps $PHPIZE_DEPS icu-dev libzip-dev zlib-dev postgresql-dev ; \
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) intl zip pdo_pgsql; \
	pecl install apcu-${APCU_VERSION}; \
	pecl clear-cache; \
	docker-php-ext-enable apcu opcache; \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .api-phpexts-rundeps $runDeps; \
	\
	apk del .build-deps

WORKDIR /srv

ARG APP_ENV=dev

ARG USER_ID=1000
RUN apk --no-cache add shadow && usermod -u ${USER_ID} www-data

# copy only specifically what we need
COPY composer.json composer.lock symfony.lock ./
COPY .env ./
COPY bin bin
COPY config config/
COPY public public/
COPY src src/
COPY var var/

VOLUME /srv/var

RUN chown -R www-data:www-data .; \
	chown -R www-data:www-data /usr/local/etc/php; \
	chmod -R +x bin;

COPY --from=composer:2.1 /usr/bin/composer /usr/bin/composer

COPY docker/php/docker-healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck

HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["docker-healthcheck"]

COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

USER www-data

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]

FROM php AS php_prod

ARG APP_ENV=prod

RUN composer install --no-dev --no-scripts --no-interaction --prefer-dist --optimize-autoloader

# do not use .env files in production
RUN composer dump-env prod; \
	rm .env

# "nginx" stage
# depends on the "php" stage above
FROM nginx:${NGINX_VERSION}-alpine AS nginx

COPY docker/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /srv/public

COPY --from=php /srv/public ./
