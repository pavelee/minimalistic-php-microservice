ARG PHP_VERSION=8.0
ARG NGINX_VERSION=1.17
ARG ALPINE_VERSION=3.13

FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS php

#timezone
ENV TZ=Europe/Warsaw
RUN apk add --no-cache tzdata
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
	; \
	apk del .build-deps \
	;

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

RUN chown -R www-data:www-data .
RUN chown -R www-data:www-data /usr/local/etc/php
RUN chmod -R +x bin
VOLUME /srv/var

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
