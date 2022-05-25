#!/bin/bash

export VSFTP_PATH='/etc/vsftpd/'
export VSFTP_CONFIG='vsftpd.conf'

# If no env var for FTP_USER has been specified, use 'admin':
if [ "$FTP_USER" = "**String**" ]; then
    export FTP_USER='admin'
fi

# If no env var has been specified, generate a random password for FTP_USER:
if [ "$FTP_PASS" = "**Random**" ]; then
    export FTP_PASS=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}`
fi

# Do not log to STDOUT by default:
if [ "$LOG_STDOUT" = "**Boolean**" ]; then
    export LOG_STDOUT=''
else
    export LOG_STDOUT='Yes.'
fi

# Create home dir and update vsftpd user db:
mkdir -p "/home/vsftpd/${FTP_USER}"
chown -R ftp:ftp /home/vsftpd/

echo -e "${FTP_USER}\n${FTP_PASS}" > ${VSFTP_PATH}virtual_users.txt
/usr/bin/db_load -T -t hash -f ${VSFTP_PATH}virtual_users.txt ${VSFTP_PATH}virtual_users.db

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
    export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
fi

echo "pasv_address=${PASV_ADDRESS}" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "pasv_max_port=${PASV_MAX_PORT}" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "pasv_min_port=${PASV_MIN_PORT}" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "pasv_addr_resolve=${PASV_ADDR_RESOLVE}" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "pasv_enable=${PASV_ENABLE}" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "file_open_mode=${FILE_OPEN_MODE}" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "local_umask=${LOCAL_UMASK}" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "xferlog_std_format=${XFERLOG_STD_FORMAT}" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "pasv_promiscuous=${PASV_PROMISCUOUS}" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "port_promiscuous=${PORT_PROMISCUOUS}" >> ${VSFTP_PATH}${VSFTP_CONFIG}

echo "## 關閉反解查詢" >> ${VSFTP_PATH}${VSFTP_CONFIG}
echo "reverse_lookup_enable=${REVERSE_LOOKUP_ENABLE}" >> ${VSFTP_PATH}${VSFTP_CONFIG}

# Add ssl options
if [ "$SSL_ENABLE" = "YES" ]; then
	echo "ssl_enable=YES" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "allow_anon_ssl=NO" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "force_local_data_ssl=YES" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "force_local_logins_ssl=YES" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "ssl_tlsv1=YES" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "ssl_sslv2=NO" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "ssl_sslv3=NO" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "require_ssl_reuse=YES" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "ssl_ciphers=HIGH" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "rsa_cert_file=${VSFTP_PATH}cert/$TLS_CERT" >> ${VSFTP_PATH}${VSFTP_CONFIG}
	echo "rsa_private_key_file=${VSFTP_PATH}cert/$TLS_KEY" >> ${VSFTP_PATH}${VSFTP_CONFIG}
fi

# Get log file path
export LOG_FILE=`grep xferlog_file ${VSFTP_PATH}${VSFTP_CONFIG}|cut -d= -f2`

# stdout server info:
if [ ! $LOG_STDOUT ]; then
cat << EOB
	*************************************************
	*                                               *
	*    Docker image: fauria/vsftpd                *
	*    https://github.com/fauria/docker-vsftpd    *
	*                                               *
	*************************************************

	SERVER SETTINGS
	---------------
	· FTP User: $FTP_USER
	· FTP Password: $FTP_PASS
	· Log file: $LOG_FILE
	· Redirect vsftpd log to STDOUT: No.
EOB
else
    /usr/bin/ln -sf /dev/stdout $LOG_FILE
fi

# Run vsftpd:
&>/dev/null /usr/sbin/vsftpd ${VSFTP_PATH}${VSFTP_CONFIG}
