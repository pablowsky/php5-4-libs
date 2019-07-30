FROM php:5.4.45-apache

# Instalacion de librerias
RUN apt-get update && apt-get install -y \
        unzip \
		libaio1 \
		libmcrypt-dev \
		libbz2-dev \
		libssl-dev \
		libgmp-dev \
		libldap2-dev \
		libmcrypt-dev \
		mysql-client \
		librecode0 \
		librecode-dev \
		libxml2-dev \
		php-soap \
		libxslt-dev \
        libpng-dev \
	 && rm -rf /var/lib/apt/lists/*

# Configuraciones adicionales
COPY docker-php.conf /etc/apache2/conf-enabled/docker-php.conf
COPY pm-custom.ini /usr/local/etc/php/conf.d/pm-custom.ini

RUN printf "log_errors = On \nerror_log = /dev/stderr\n" > /usr/local/etc/php/conf.d/php-logs.ini

RUN a2enmod rewrite

# Oracle instantclient
ADD instantclient/instantclient-basiclite-linux.x64-11.2.0.4.0.zip /tmp/
ADD instantclient/instantclient-sdk-linux.x64-11.2.0.4.0.zip /tmp/

RUN unzip /tmp/instantclient-basiclite-linux.x64-11.2.0.4.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_11_2 /usr/local/instantclient									
RUN ln -s /usr/local/instantclient/libclntsh.so.11.1 /usr/local/instantclient/libclntsh.so
RUN ln -s /usr/local/instantclient/libocci.so.11.1 /usr/local/instantclient/libocci.so
									

ENV LD_LIBRARY_PATH=/usr/local/instantclient
ENV ORACLE_HOME=/usr/local/instantclient
RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8-2.0.12
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient,11.2.0.4.0
RUN docker-php-ext-install pdo_oci
RUN docker-php-ext-enable oci8

# Librerias adicionales PHP
RUN docker-php-ext-install bz2
RUN docker-php-ext-install exif
RUN docker-php-ext-install ftp
RUN docker-php-ext-install gd
RUN docker-php-ext-install gettext

RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
RUN docker-php-ext-install gmp

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-install ldap

RUN docker-php-ext-install mbstring
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install pdo_mysql 
RUN docker-php-ext-install mysqli
#RUN docker-php-ext-install posix
#RUN docker-php-ext-install recode
RUN docker-php-ext-install shmop
RUN docker-php-ext-install soap
RUN docker-php-ext-install xmlrpc
RUN docker-php-ext-install sockets
RUN docker-php-ext-install tokenizer
RUN docker-php-ext-install wddx
RUN docker-php-ext-install zip
RUN docker-php-ext-install xsl


RUN echo "<?php echo phpinfo(); ?>" > /var/www/html/phpinfo.php

EXPOSE 80
