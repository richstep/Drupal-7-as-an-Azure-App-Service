#!/bin/bash
cat >/etc/motd <<EOL 
  _____                               
  /  _  \ __________ _________   ____  
 /  /_\  \\___   /  |  \_  __ \_/ __ \ 
/    |    \/    /|  |  /|  | \/\  ___/ 
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/ 
A P P   S E R V I C E   O N   L I N U X

Documentation: http://aka.ms/webapp-linux
PHP quickstart: https://aka.ms/php-qs

EOL

set -e

if [ ! $WEBSITES_ENABLE_APP_SERVICE_STORAGE ]; then
	echo "INFO: NOT in Azure, chown for "$DRUPAL_HOME
	chown -R www-data:www-data $DRUPAL_HOME
else
    cat /etc/motd
fi


#Get environment variables to show up in SSH session
#eval $(printenv | awk -F= '{print "export " $1"="$2 }' >> /etc/profile)


echo "Starting SSH ..."
service ssh start

test ! -d "$DRUPAL_HOME/sites" && echo "INFO: $DRUPAL_HOME/sites not found"  

#start apache
/usr/sbin/apache2ctl -D FOREGROUND