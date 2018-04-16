#### DOCKER FILE FOR BASE IMAGE #####
FROM drupal:7.58-apache
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
