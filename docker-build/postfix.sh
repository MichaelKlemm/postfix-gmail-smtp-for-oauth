#!/bin/bash

## prepare dirs
mkdir -p /etc/postfix/tokens

## copy config-template to dest
cp conf/sender.tokens.json /etc/postfix/tokens/sender.tokens.json
cp conf/sasl_passwd        /etc/postfix/sasl_passwd
cp conf/sasl-xoauth2.conf  /etc/sasl-xoauth2.conf
cp conf/main.cf            /etc/postfix/main.cf

## replace smart relay config
sed -e '/^smtp_tls/ s/^/#/'  -i  /etc/postfix/main.cf
sed -e "s/^relayhost =.*$//g" -i /etc/postfix/main.cf
echo "

smtp_tls_security_level=encrypt
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache

smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options =
smtp_sasl_mechanism_filter = xoauth2

inet_protocols = ipv4

mynetworks = __MY_NETWORKS___
smtpd_client_restrictions = permit_mynetworks permit_sasl_authenticated permit
relayhost = __RELAY_HOST____

" >> /etc/postfix/main.cf
########################
## replace varialbles
########################

## vars
__SMTP_SERVER___="${__SMTP_SERVER___:=smtp-relay.gmail.com}"
__SMTP_TLS_PORT_="${__SMTP_TLS_PORT_:=587}"
__SMTP_USER_ADDR="${__SMTP_USER_ADDR:=yourmail@example.com}"
__ACCESS_TOKEN__="${__ACCESS_TOKEN__:=ya29.A0ARrdaM-Sdab5RlAxxxxx}"
__REFRESH_TOKEN_="${__REFRESH_TOKEN_:=1//0e2dj8C3gRDyeCgYIARAAG}"
__CLIENT_ID_____="${__CLIENT_ID_____:=XXXXX-xxxxxx.apps.googleusercontent.com}"
__PROJECT_ID____="${__PROJECT_ID____:=gcp-project-334}"
__CLIENT_SECRET_="${__CLIENT_SECRET_:=GOCSPX-XXX-XXXXXXXX}"
__MY_NETWORKS___="${__MY_NETWORKS___:=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16}"
__RELAY_HOST____="[${__SMTP_SERVER___}]:${__SMTP_TLS_PORT_}"
## replace
sed  -e "s|__ACCESS_TOKEN__|${__ACCESS_TOKEN__}|" -i /etc/postfix/tokens/sender.tokens.json
sed  -e "s|__REFRESH_TOKEN_|${__REFRESH_TOKEN_}|" -i /etc/postfix/tokens/sender.tokens.json
sed  -e "s|__SMTP_SERVER___|${__SMTP_SERVER___}|" -i /etc/postfix/sasl_passwd
sed  -e "s|__SMTP_TLS_PORT_|${__SMTP_TLS_PORT_}|" -i /etc/postfix/sasl_passwd
sed  -e "s|__SMTP_USER_ADDR|${__SMTP_USER_ADDR}|" -i /etc/postfix/sasl_passwd
sed  -e "s|__MY_NETWORKS___|${__MY_NETWORKS___}|" -i /etc/postfix/main.cf
sed  -e "s|__RELAY_HOST____|${__RELAY_HOST____}|" -i /etc/postfix/main.cf
sed  -e "s|__CLIENT_ID_____|${__CLIENT_ID_____}|" -i /etc/sasl-xoauth2.conf
sed  -e "s|__PROJECT_ID____|${__PROJECT_ID____}|" -i /etc/sasl-xoauth2.conf
sed  -e "s|__CLIENT_SECRET_|${__CLIENT_SECRET_}|" -i /etc/sasl-xoauth2.conf



##compile SASL PASSWD
postmap /etc/postfix/sasl_passwd
touch  /etc/mailname

## refresh token
sasl-xoauth2-tool test-token-refresh /etc/postfix/tokens/sender.tokens.json

## enable verbose log
sed -e 's/"$/",/' -i /etc/sasl-xoauth2.conf
sed -e '/}/i\ \ "log_full_trace_on_failure" : "yes",'  -i /etc/sasl-xoauth2.conf
sed -e '/}/i\ \ "always_log_to_syslog" : "yes"' -i /etc/sasl-xoauth2.conf

## for chroot-ed  Postfix 
mkdir -p /var/spool/postfix/etc/postfix
cp -r /etc/postfix/tokens /var/spool/postfix/etc/postfix/
chown postfix:postfix /var/spool/postfix/etc/postfix/tokens/
chown postfix:postfix /var/spool/postfix/etc/postfix/tokens/sender.tokens.json
chmod 775 /var/spool/postfix/etc/postfix/tokens/
chmod 660 /var/spool/postfix/etc/postfix/tokens/sender.tokens.json
update-ca-certificates 2&> /dev/null
mkdir -p /var/spool/postfix/etc/ssl/certs
cp  /etc/ssl/certs/* /var/spool/postfix/etc/ssl/certs/



########################
## for debug
########################
## start rsyslog for debug 
#sed -e '/load="imklog"/s/^/#/' -i /etc/rsyslog.conf
#service rsyslog start
## start postfix
#service postfix start

## CMD for debugging
#sleep 5 && tail -f /var/log/mail.log

## CMD for prod 
/usr/lib/postfix/configure-instance.sh
postconf -e 'maillog_file=/dev/stdout'
exec /usr/sbin/postfix -c /etc/postfix start-fg
