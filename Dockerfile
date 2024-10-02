FROM php:8.3-apache

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ghostscript \
	rm -rf /var/lib/apt/lists/*

RUN apk add --no-cache \
		bash \
		less \
		mysql-client


RUN	apt-get update; \
	apt-get install -y --no-install-recommends \
		libavif-dev \
		libfreetype6-dev \
		libicu-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libwebp-dev \
		libzip-dev \

RUN	docker-php-ext-configure gd \
		--with-avif \
		--with-freetype \
		--with-jpeg \
		--with-webp \

RUN	docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		intl \
		mysqli \
		zip

RUN	pecl install imagick-3.7.0; \
	docker-php-ext-enable imagick; \
	rm -r /tmp/pear; \

COPY wordpress.conf /etc/apache2/sites-available/

COPY . /var/www/wordpress-main/

# Set the working directory
WORKDIR /var/www/wordpress-main/

# Delete existing salt definitions in wp-config.php
RUN sed -i '/define(.*_KEY/d; /define(.*_SALT/d' wp-config.php && \
    # Fetch new salt keys and insert them
    curl -s https://api.wordpress.org/secret-key/1.1/salt/ > /tmp/wp-salts && \
    sed -i '/#@-/r /tmp/wp-salts' wp-config.php && \
    rm /tmp/wp-salts


RUN a2ensite wordpress && a2ensite rewrite && a2dissite 000-default

EXPOSE 80

CMD ["apache2-foreground"]