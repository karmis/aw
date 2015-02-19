#!/bin/sh
wr="/server/www/"
vhd="/etc/apache2/sites-available/"
sf="/home/karmis/App/addwebsite/skeleton"
ext=".conf"
rcmd="/usr/bin/sudo service apache2 reload"
getroot="/usr/bin/sudo"
domain='';

addwebsite(){
  local $*;
  echo "wr: $wr \r\n VIRTUAL HOST DIR: $vhd \r\n SKELETON FILE: $sf \r\n EXTENSION FOR CONF: $ext \r\n Domain: $domain";

  wrdomain="$wr$domain/www"
if [ "$domain" != '' ]; then
	$getroot
    if [ ! -f "$vhd$domain$ext" ]; then
        cp "$sf" "$vhd$domain$ext"
        echo "created $vhd$domain$ext"
    else
        mv "$vhd$domain$ext" "$vhd$domain$ext.bak"
        cp "$sf" "$vhd$domain$ext"
        echo "created $vhd$domain$ext and made a backup of the existing$ext"
    fi
    find "$vhd$domain$ext" -type f -exec sed -i "s|WB_ROOT_SKEL|$wrdomain|g" {} \;
    find "$vhd$domain$ext" -type f -exec sed -i "s|DOMAIN_SKEL|$domain|g" {} \;

    if [ ! -d "$wr$domain/" ]; then
        mkdir -p "$wr$domain/www"
        chown -R apache:apache "$wr$domain/"
        echo "created $wr$domain/"
    else
        echo "$wr$domain/ already exists"
    fi
    sudo a2ensite $domain
    echo "127.0.1.2		$domain		$domain" >> "/etc/hosts"
    chmod -R 777 $wrdomain
    $rcmd
    echo "reloaded apache"
elif [ "$domain" = 'help' ] || [ "$domain" = '' ]; then
    echo "usage:"
    echo "sudo addwebsite "
    echo "example: to create hostname.localhost just run the command 'sudo addwebsite domain=hostname.localhost'"
fi


}
addwebsite $*