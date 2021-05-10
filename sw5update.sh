#!/bin/bash




# path to shopware installation path
docroot=""
# temp path
temp=""
# db name
dbname=""







if [[ ! -d $docroot ]]; then
  echo "docroot path not not found"
  exit
fi

if [[ ! -d $temp ]]; then
  echo "temp path not not found"
  exit
fi

if [[ -z $dbname ]]; then
  echo "dbname not not set"
  exit
fi

if [[ ! $(which curl) ]]; then
  echo "curl not installed"
  exit
fi

if [[ ! $(which jq)  ]]; then
  echo "jq not installed"
  exit
fi

if [[ ! $(which unp)  ]]; then
  echo "unp not installed"
  exit
fi

if [[ ! $(which sha1sum)  ]]; then
  echo "sha1sum not installed"
  exit
fi

if [[ ! $(which sha256sum)  ]]; then
  echo "sha256sum not installed"
  exit
fi

if [[ ! $(which mysqldump)  ]]; then
  echo "mysqldump not installed"
  exit
fi

# backup
mysqldump -Q $dbname > ${temp}/${dbname}.sql
tar -zcf ${temp}/shop_docroot.tar.gz ${docroot}/

# download
upjson_uri="https://update-api.shopware.com/v1/release/update?channel=stable&shopware_version=5"
curl -s ${upjson_uri} -o ${temp}/update.json

updl_version=$(cat update.json | jq '.version' | tr -d \" )
updl_uri=$(cat update.json | jq '.uri' | tr \\/ / | tr -d \" )
updl_sha1=$(cat update.json | jq '.sha1' | tr -d \" )
updl_sha256=$(cat update.json | jq '.sha256' | tr -d \" )
updl_file="update_${updl_version}_${updl_sha1}.zip"
curl -s "${updl_uri}" -o ${temp}/${updl_file}

# checksum
if [[ $(sha1sum ${temp}/${updl_file} | cut -d " " -f1 ) != ${updl_sha1} ]]; then
	echo "sha1sum missmatch"
	exit
fi

if [[ $(sha256sum ${temp}/${updl_file} | cut -d " " -f1 ) != ${updl_sha256} ]]; then
	echo "sha256sum missmatch"
	exit
fi



cp "${temp}/${updl_file}" "${docroot}/${updl_file}"

#update
cd ${docroot}

unp "${updl_file}"
#php recovery/update/index.php --no-interaction --quiet
php recovery/update/index.php --no-interaction

# after update

rm UPGRADE-*.md
rm CONTRIBUTING.md
rm eula_en.txt
rm eula.txt
rm license.txt
rm README.md

rm -rf update-assets
rm "${docroot}/${updl_file}"
rm "${temp}/update.json"

chmod 700 bin/console
chgrp www-data bin/console
chmod g+rx bin/console

cd var/cache/
chmod 700 clear_cache.sh
./clear_cache.sh
rm -rf production_*
