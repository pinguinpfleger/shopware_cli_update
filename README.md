# shopware_cli_update

## sw5update.sh
**does:**
backup docroot   
backup mysqldb  
download latest shopware update   
verify checksum    
install the update   
cleanup stuff  
clear cache  

**config**   
```
#path to shopware installation path.  
docroot=""   
#temp path  
temp=""   
#db name   
dbname=""  
```

## sw_plup_mailer.sh
**does:**
send an email if an update for an installed plugin is available.

**config**
```
SHOPWARE_PATH="/var/www/vhosts/shopware/docroot"
MAILTO="root"
SUBJECT="Shopware Update!"
USER="www-data"
MAIL=$(which mailx)
PHPCLI=$(which php)
TMPFLE=$(tempfile)
PHPCLI=$(which php)
```

add the the script to your cronjobs 
