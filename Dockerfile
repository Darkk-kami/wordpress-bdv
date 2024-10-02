FROM php:7.2-apache

RUN apt update && apt upgrade -y && apt install -y \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip

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