#### DOCKER FILE FOR BASE IMAGE #####
FROM php:7.0-apache
#This file was inspired by: https://github.com/Azure/app-service-builtin-images/tree/master/php/7.2.1-apache


ENV DRUPAL_HOME "/home/site/wwwroot"
ENV DRUPAL_FILE_TEMP_HOME "/var/mydrupalcode"
ENV APACHE_RUN_USER www-data
ENV PHP_VERSION 7.2.1
ENV SSH_PASSWD "root:Docker!"

COPY init_container.sh /bin/
COPY apache2.conf /bin/

# installs
RUN a2enmod rewrite deflate

RUN apt-get update && apt-get install -y \
    curl \
    dos2unix \
    libjpeg-dev  \
    libpng-dev \
    nano \
    openssh-server \
    tcptraceroute \
    wget \
        && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
        && docker-php-ext-install gd mysqli opcache pcntl pdo pdo_mysql \
        && echo "$SSH_PASSWD" | chpasswd \
        && chmod 755 /bin/init_container.sh \
        && echo "cd /home" >> /etc/bash.bashrc

RUN   \
   rm -f /var/log/apache2/* \
   && rmdir /var/lock/apache2 \
   && rmdir /var/run/apache2 \
   && rmdir /var/log/apache2 \
   && chmod 777 /var/log \
   && chmod 777 /var/run \
   && chmod 777 /var/lock \
   && chmod 777 /bin/init_container.sh \
   && cp /bin/apache2.conf /etc/apache2/apache2.conf \
   && rm -rf /var/www/html \
   && rm -rf /var/log/apache2 \
   && mkdir -p /home/LogFiles \
   && ln -s $DRUPAL_HOME /var/www/html \
   && ln -s /home/LogFiles /var/log/apache2 \
   # Run dos2unix so script will execute properly if image is build by Docker for Windows
   && dos2unix /bin/init_container.sh \
   && rm -rf /var/lib/apt/lists/* 
   
RUN { \
                echo 'opcache.memory_consumption=128'; \
                echo 'opcache.interned_strings_buffer=8'; \
                echo 'opcache.max_accelerated_files=4000'; \
                echo 'opcache.revalidate_freq=60'; \
                echo 'opcache.fast_shutdown=1'; \
                echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
                echo 'error_log=/var/log/apache2/php-error.log'; \
                echo 'display_errors=Off'; \
                echo 'log_errors=On'; \
                echo 'display_startup_errors=Off'; \
                echo 'date.timezone=UTC'; \
    } > /usr/local/etc/php/conf.d/php.ini



COPY sshd_config /etc/ssh/

EXPOSE 2222 80

ENV WEBSITE_ROLE_INSTANCE_ID localRoleInstance
ENV WEBSITE_INSTANCE_ID localInstance
ENV PATH ${PATH}:/home/site/wwwroot

WORKDIR /var/www/html

ENTRYPOINT ["init_container.sh"]