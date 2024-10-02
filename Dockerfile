FROM php:7.2-apache

RUN apt update && apt upgrade -y \
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

COPY . /home/wordpress

WORKDIR /home/wordpress

RUN a2ensite wordpress && a2ensite rewrite && a2dissite 000-default

EXPOSE 80

CMD ["apache2-foreground"]