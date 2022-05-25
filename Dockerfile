FROM rockylinux:8

ARG USER_ID=14
ARG GROUP_ID=50

MAINTAINER Fer Uria <fauria@gmail.com>
LABEL Description="vsftpd Docker image based on Rocky Linux 8. Supports passive mode and virtual users." \
        License="Apache License 2.0" \
        Usage="docker run -d -p [HOST PORT NUMBER]:21 -v [HOST FTP HOME]:/home/vsftpd fauria/vsftpd" \
        Version="1.0"

RUN dnf -y upgrade && dnf install -y vsftpd iproute && \ 
    dnf clean all && rm -rf /tmp/*

COPY ./shell_vsftpd/vsftpd.conf /etc/vsftpd/
COPY ./shell_vsftpd/createusers.sh /etc/vsftpd/
COPY ./shell_vsftpd/vsftpd_virtual /etc/pam.d/
COPY ./shell_vsftpd/run-vsftpd.sh /usr/sbin/

RUN chmod +x /usr/sbin/run-vsftpd.sh && \
    chmod +x /etc/vsftpd/createusers.sh && \
    mkdir -p /home/vsftpd/ && \
    chown -R ftp:ftp /home/vsftpd/ && \
    usermod -u ${USER_ID} ftp && \ 
    groupmod -g ${GROUP_ID} ftp


ENV FTP_USER **String**
ENV FTP_PASS **Random**
ENV PASV_ADDRESS **IPv4**
ENV PASV_ADDR_RESOLVE NO
ENV PASV_ENABLE YES
ENV PASV_MIN_PORT 21100
ENV PASV_MAX_PORT 21110
ENV XFERLOG_STD_FORMAT NO
ENV LOG_STDOUT **Boolean**
ENV FILE_OPEN_MODE 0666
ENV LOCAL_UMASK 077
ENV REVERSE_LOOKUP_ENABLE YES
ENV PASV_PROMISCUOUS NO
ENV PORT_PROMISCUOUS NO
ENV RESERVE_LOOKUP_ENABLE YES
ENV SSL_ENABLE NO
ENV TLS_CERT cert.pem
ENV TLS_KEY key.pem

VOLUME /home/vsftpd
VOLUME /var/log/vsftpd
VOLUME /etc/vsftpd/cert

EXPOSE 20 21

CMD ["/usr/sbin/run-vsftpd.sh"]
