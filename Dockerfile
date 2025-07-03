FROM laravelsail/php83-composer:latest

RUN apt update && apt install -y \
    gnupg2 \
    lsb-release \
    curl \
    libicu-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-install intl pdo_mysql

RUN apt install -y fish tree

RUN chsh -s /usr/bin/fish www-data

WORKDIR /var/www/html

COPY ./src /var/www/html

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 8000 465

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
