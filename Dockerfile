FROM php:8.1-fpm

# Установить зависимости
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    unzip \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip

# Установить Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Разрешить использование Composer как суперадмина
ENV COMPOSER_ALLOW_SUPERUSER=1

# Скопировать исходный код приложения Laravel
COPY . /var/www/html

# Установить директорию для работы
WORKDIR /var/www/html

# Установить зависимости Composer
RUN composer install --no-interaction --no-plugins --no-scripts --prefer-dist

# Права на папку для кеша и хранилища Laravel
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache && \
    chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Открыть порт 9000 , только не понял зачем....
EXPOSE 9000

# Запустить PHP-FPM
CMD ["php-fpm"]
