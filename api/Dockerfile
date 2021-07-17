ARG PHP_VERSION=8.0
ARG NGINX_VERSION=1.17
ARG ALPINE_VERSION=3.13
ARG TZ=Europe/Warsaw

FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS php

#timezone
RUN apk add --no-cache tzdata
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "${TZ}"\n' > /$PHP_INI_DIR/conf.d/tzone.ini

# persistent / runtime deps
RUN apk add --no-cache \
		acl \
		fcgi \
		file \
		gettext \
		git \
		gnu-libiconv \
	;

# install gnu-libiconv and set LD_PRELOAD env to make iconv work fully on Alpine image.
# see https://github.com/docker-library/php/issues/240#issuecomment-763112749
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

ARG APCU_VERSION=5.1.20
RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		icu-dev \
		libzip-dev \
		zlib-dev \
	; \
	\
	docker-php-ext-configure zip; \
	docker-php-ext-install -j$(nproc) \
		intl \
		zip \
	; \
	pecl install \
		apcu-${APCU_VERSION} \
	; \
	pecl clear-cache; \
	docker-php-ext-enable \
		apcu \
		opcache \
	;

COPY docker/php/docker-healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck

HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["docker-healthcheck"]

COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

WORKDIR /srv

ARG APP_ENV=prod

COPY composer.json composer.lock symfony.lock ./

# copy only specifically what we need
COPY .env ./
COPY bin bin/
COPY config config/
COPY public public/
COPY src src/

RUN mkdir -p var vendor
RUN chown -R www-data:www-data .
RUN chown -R www-data:www-data /usr/local/etc/php
VOLUME /srv/var

USER www-data

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]

FROM php AS php_prod

# do not use .env files in production
RUN composer dump-env prod; \
	rm .env

# "nginx" stage
# depends on the "php" stage above
FROM nginx:${NGINX_VERSION}-alpine AS nginx

COPY docker/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /srv/public

COPY --from=php /srv/public ./
