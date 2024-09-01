### sasl-oauth2 in lxc 

sample for lxc.

```sh
git clone git@github.com:takuya/postfix-gmail-smtp-for-oauth.git
cd postfix-gmail-smtp-for-oauth
```

### launch ubuntu in lxc
```sh
LXC_NAME=postfix-test

if lxc info $LXC_NAME > /dev/null ; then 
  lxc stop $LXC_NAME
  lxc delete $LXC_NAME
fi

##
lxc launch ubuntu:20.04 $LXC_NAME
lxc config device add $LXC_NAME eth0 nic nictype=macvlan parent=br0
```

### root shell in LXC 
Enter LXC 
```sh
lxc shell $LXC_NAME
```
####  Run this in root shell 
```sh
## use apt-caching-proxy if needed.
# echo 'Acquire::HTTP::Proxy "http://apt-cacher.lan";' |sudo tee  /etc/# apt/apt.conf.d/01proxy

## no-man 
echo -e  "APT::Install-Suggests 0;\nAPT::Install-Recommends 0;" | sudo tee /etc/apt/apt.conf.d/00-no-install-recommends

## use JP mirror for amd64 (armf does not mirrored in JP )
URL=http://ftp.jaist.ac.jp/pub/Linux/ubuntu/
sudo sed -i "s|http://archive.ubuntu.com/ubuntu/\?|${URL}|" /etc/apt/sources.list

## no doc 
cat <<EOF > 01-nodoc
# Delete locales
path-exclude=/usr/share/locale/*

# Delete man pages
path-exclude=/usr/share/man/*

# Delete docs
path-exclude=/usr/share/doc/*
path-include=/usr/share/doc/*/copyrigh

EOF
sudo mv 01-nodoc /etc/dpkg/dpkg.cfg.d/01-nodoc

sudo apt update 
sudo apt install -y vim-nox 

### install sasl-xoauth2

sudo apt-get install -y software-properties-common &&\
  add-apt-repository -y ppa:sasl-xoauth2/stable && \
  apt-get install -y postfix sasl-xoauth2 sasl2-bin &&\
  saslpluginviewer 
## choose 'no config' at dpkg configure postfix showed. 

```

### debugging tools 

デバッグに使うツールをいれる。
```sh
lxc exec $LXC_NAME -- apt-get install -y vim-nox iproute2 ncat curl rsyslog
```

### import files 

```sh
## in host shell 
## copy files 
lxc exec $LXC_NAME -- mkdir /root/conf/
lxc file push ./docker-build/etc/sasl-xoauth2.conf         $LXC_NAME/root/conf/sasl-xoauth2.conf
lxc file push ./docker-build/etc/sender.tokens.json        $LXC_NAME/root/conf/sender.tokens.json
lxc file push ./docker-build/etc/postfix/main.cf           $LXC_NAME/root/conf/main.cf
lxc file push ./docker-build/etc/postfix/sasl_passwd       $LXC_NAME/root/conf/sasl_passwd
lxc file push ./docker-build/postfix.sh                    $LXC_NAME/root/postfix.sh
lxc exec $LXC_NAME -- chmod +x /root/postfix.sh
## copy ENV
lxc file push env_vars  $LXC_NAME/root/env_vars
```

### configure postfix 

環境変数を用意して
```sh
lxc shell $LXC_NAME
```
```sh
## in lxc 
cat env_vars  | xargs -I@ echo export @ > out&& source out && rm out
env |grep ^__ | sort
## write ENV to files
./postfix.sh
```


## Watch Mail.log
```
lxc shell $LXC_NAME
##
tail -f /var/log/mail.log
```

`Permission Error ` とか ` certificate xxx ` とかのエラーメッセージに注意する。

### メール送信

```sh
$RCPT_ADDR=takuya@example.com

curl -v --url 'smtp://127.0.0.1:25' \
  --mail-from  $__SMTP_USER_ADDR\
  --mail-rcpt  $RCPT_ADDR \
  --form-string content=hello
```

### メール再送 キュー再送

メールがキューに溜まってる状態なら
```sh
postfix flush
```

キューを再送するだけでメールを送れる

キューに失敗メールが溜まってる状態で、curl コマンドを何度も実行すると、更にキューに溜まるだけ。

### truncate Mail Queue
```sh
postsuper -d ALL
```


削除されるキューが０個なら、メールは正しく送信されている。

削除されるキューが１個以上なら、メールは送信失敗で残ってる。







