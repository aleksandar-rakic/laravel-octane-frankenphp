FROM dunglas/frankenphp:latest-php8.3-alpine AS base

LABEL maintainer="Aleksandar Rakić <aleksandar@theordinarycompany.io>"

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV SERVER_NAME=":80"

RUN install-php-extensions \
    bcmath \
    gd \
    intl \
    opcache \
    pcntl \
    pdo_pgsql \
    pdo_mysql \
    redis \
    zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# ---- deps ----
FROM base AS deps

COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist

# ---- app ----
FROM base AS app

COPY --from=deps /app/vendor ./vendor
COPY . .

RUN composer dump-autoload --optimize \
    && php artisan octane:install --server=frankenphp \
    && chown -R www-data:www-data storage bootstrap/cache

# ---- dev ----
FROM app AS dev

RUN composer install --no-scripts
COPY docker/frankenphp/Caddyfile /etc/caddy/Caddyfile

EXPOSE 80 443

CMD ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=80", "--workers=auto"]

# ---- production ----
FROM app AS production

ENV APP_ENV=production
ENV APP_DEBUG=false
ENV OCTANE_SERVER=frankenphp

COPY docker/frankenphp/Caddyfile /etc/caddy/Caddyfile

EXPOSE 80 443

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost/up || exit 1

CMD ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=80", "--workers=auto", "--max-requests=500"]
