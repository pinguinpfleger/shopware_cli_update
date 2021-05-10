#!/bin/bash

SHOPWARE_PATH="/var/www/vhosts/shopware/docroot"
MAILTO="root"
SUBJECT="Shopware Update!"
USER="www-data"
MAIL=$(which mailx)
PHPCLI=$(which php)
TMPFLE=$(tempfile)

/usr/bin/sudo -u $USER $PHPCLI $SHOPWARE_PATH/bin/console sw:store:list:updates --no-ansi > $TMPFLE
if [[ $(wc -l $TMPFLE | cut -d" " -f1) > 3 ]]; then
  MAILRC=/dev/null $MAIL -n -s "$SUBJECT" $MAILTO < $TMPFLE
fi
rm $TMPFLE
