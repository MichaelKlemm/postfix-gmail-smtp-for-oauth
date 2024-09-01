FROM ubuntu:20.04
ENV DEBCONF_NOWARNINGS=yes

RUN echo "Apt Config" && \
apt-get update && \
apt-get upgrade -y 

###################################
## for develop use apt-proxy for speed-up.
# RUN echo "Apt Config" && \
# echo "APT::Install-Suggests 0;\nAPT::Install-Recommends 0;" | tee /etc/apt/apt.conf.d/00-no-install-recommends && \
# echo "path-exclude=/usr/share/locale/*\npath-exclude=/usr/share/man/*\npath-exclude=/usr/share/doc/*\n" | tee  /etc/dpkg/dpkg.cfg.d/01-nodoc && \
# apt-get update && \
# apt-get upgrade -y 


RUN apt-get install -y software-properties-common &&\
  add-apt-repository -y ppa:sasl-xoauth2/stable && \
  apt-get install -y postfix sasl-xoauth2 sasl2-bin &&\
  saslpluginviewer 

#########################
## for debug
# RUN apt-get install -y vim-nox iproute2 ncat curl rsyslog jq iputils-ping &&\
# echo install working.

WORKDIR /root
RUN mkdir /root/conf
COPY etc/sasl-xoauth2.conf         /root/conf/sasl-xoauth2.conf
COPY etc/sender.tokens.json        /root/conf/sender.tokens.json
COPY etc/postfix/main.cf           /root/conf/main.cf
COPY etc/postfix/sasl_passwd       /root/conf/sasl_passwd
COPY postfix.sh                    /root/postfix.sh
RUN chmod +x /root/postfix.sh

## finish 
ENV TZ Asia/Tokyo
EXPOSE 25/tcp
CMD /root/postfix.sh

