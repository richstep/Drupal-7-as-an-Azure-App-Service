FROM creg7smg.azurecr.io/drupal7_for_docker:base
#This file was inspired by: https://github.com/Azure/app-service-builtin-images/tree/master/php/7.2.1-apache

# RUN apt-get update

ENV DRUPAL_HOME "/home/site/wwwroot"
ENV DRUPAL_FILE_TEMP_HOME "/var/mydrupalcode"
ENV APACHE_RUN_USER www-data
ENV PHP_VERSION 7.2.1

COPY init_container.sh /bin/

RUN chmod 777 /bin/init_container.sh \
   # Run dos2unix so script will execute properly if image is build by Docker for Windows
   && dos2unix /bin/init_container.sh \
   && rm -rf /var/lib/apt/lists/* 

RUN mkdir -p /myvol \
    && echo "hello world" > /myvol/greeting
VOLUME /myvol

RUN mkdir -p ${DRUPAL_HOME}/sites/default/files \
    && echo "hello world defaultfiles" > ${DRUPAL_HOME}/sites/default/files/greeting2
VOLUME ${DRUPAL_HOME}/sites/default/files

# *** Add your Drupal 7 files to the image ***
ADD drupal7-codebase/. $DRUPAL_FILE_TEMP_HOME
#ADD drupal7-codebase/. /var/mydrupalcode

EXPOSE 2222 80

ENV WEBSITE_ROLE_INSTANCE_ID localRoleInstance
ENV WEBSITE_INSTANCE_ID localInstance
ENV PATH ${PATH}:/home/site/wwwroot

WORKDIR /var/www/html

ENTRYPOINT ["init_container.sh"]