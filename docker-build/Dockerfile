FROM ubuntu:20.04
## 以下の ubuntu でも動くが、Imageサイズで不利なので2004にする
#FROM ubuntu:22.04
#FROM ubuntu:22.04

ENV DEBCONF_NOWARNINGS=yes
#ENV DEBIAN_FRONTEND=noninteractive 

###################################
## for develop use apt-proxy for speed-up.
# RUN echo "Apt Config" && \
# apt-get update && \
# apt-get upgrade -y 
# 
# RUN echo "Apt Config" && \
# echo "APT::Install-Suggests 0;\nAPT::Install-Recommends 0;" | tee /etc/apt/apt.conf.d/00-no-install-recommends && \
# echo "path-exclude=/usr/share/locale/*\npath-exclude=/usr/share/man/*\npath-exclude=/usr/share/doc/*\n" | tee  /etc/dpkg/dpkg.cfg.d/01-nodoc && \
# apt-get update && \
# apt-get upgrade -y 


RUN echo "### --- Apt Config" && \
apt-get update && \
apt-get upgrade -y && \
echo "### --- Install Postfix " && \
echo "postfix postfix/main_mailer_type select No configuration" | debconf-set-selections && \
apt-get install -y software-properties-common &&\
  add-apt-repository -y ppa:sasl-xoauth2/stable && \
  apt-get install -y postfix sasl-xoauth2 sasl2-bin && \
  saslpluginviewer  && \
echo "### --- Mkdir " && \
  mkdir /root/conf


#########################
## for debug
# RUN apt-get install -y vim-nox iproute2 ncat curl rsyslog jq iputils-ping &&\
# echo install working.


COPY etc/sasl-xoauth2.conf   \
     etc/sender.tokens.json  \
     etc/postfix/main.cf     \
     etc/postfix/sasl_passwd \
     postfix.sh \ 
     /root/conf/

## finish 
WORKDIR /root
ENV TZ Asia/Tokyo
EXPOSE 25/tcp
CMD /root/conf/postfix.sh

