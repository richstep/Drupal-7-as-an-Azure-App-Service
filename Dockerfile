#### DOCKER FILE FOR BASE IMAGE #####
#FROM php:7.2.4-apache-stretch

##/bin/sh: 1: a2enmod: not found
##FROM php:7.2.4-fpm-stretch 

###/bin/sh: 1: a2enmod: not found
###FROM php:7.0-fpm-jessie
#This file was inspired by: https://github.com/bitnami/bitnami-docker-apache
FROM bitnami/apache:latest

ENV DRUPAL_HOME "/home/site/wwwroot"

ENV SSH_PASSWD "root:Docker!"

COPY init_container.sh /bin/
COPY my_vhost.conf /bitnami/apache/conf/vhosts/

#COPY apache2.conf /bin/
COPY Base/hostingfile.html $DRUPAL_HOME/index.html

RUN apt-get update && apt-get install -y \
    dos2unix   openssh-server \
    && echo "$SSH_PASSWD" | chpasswd 
# Run dos2unix so script will execute properly if image is build by Docker for Windows
RUN dos2unix /bin/init_container.sh 

COPY sshd_config /etc/ssh/

ADD drupal7-codebase/. ${DRUPAL_HOME}

EXPOSE 2222 80

ENTRYPOINT ["init_container.sh"]