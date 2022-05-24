#!/bin/bash

#sourcelists="/temp/initdata/users.txt"
ftppath="/home/vsftpd"
sourcelists="/etc/vsftpd/virtual_users.txt"
targetlists="/etc/vsftpd/virtual_users.txt"
targetdb="/etc/vsftpd/virtual_users.db"

# Clean File Content
#: > ${filename}


# Create UserFolder & Add DBData
while read odd_line
do
  a=`echo ${odd_line} | awk -F '/' '{print $1}'`

  read even_line
  p=`echo ${even_line} | awk -F '/' '{print $1}'`

  [ -d ${ftppath}/${a} ] || mkdir -p -m 755 ${ftppath}/${a}
  [ -d ${ftppath}/${a} ] && chown ftp:ftp ${ftppath}/${a}

  #echo -e ${a} >> ${targetlists}
  #echo -e ${p} >> ${targetlists}

done < ${sourcelists}

#/usr/bin/db_load -T -t hash -f ${targetlists} ${targetdb}

