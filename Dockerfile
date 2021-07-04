# the different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target


# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG PHP_VERSION=8.0
ARG NGINX_VERSION=1.17
ARG ALPINE_VERSION=3.13


# "php" stage
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS php

#timezone
RUN apk add --no-cache tzdata
ENV TZ=Europe/Warsaw
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN printf '[PHP]\ndate.timezone = "Europe/Warsaw"\n' > /$PHP_INI_DIR/conf.d/tzone.ini

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

WORKDIR /srv

ARG APP_ENV=prod

COPY composer.json composer.lock symfony.lock ./

# copy only specifically what we need
COPY .env ./
COPY bin bin/
COPY config config/
COPY public public/
COPY src src/

# download vendors
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install

RUN mkdir -p var
RUN chmod -R 777 var
RUN chmod +x bin/console
VOLUME /srv/var

COPY docker/php/docker-healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck

HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["docker-healthcheck"]

COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

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
