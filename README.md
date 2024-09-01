## postfix docker with xoauth2

postfix enabled xoauth2 in docker

This postfix is for gmail(xoauth2).

Postfix will send mail via `smtp-relay.gmail.com:587` or `smtp.gmail.com:587` by smart relay.

## usage 

```sh
IMAGE=ghcr.io/takuya/takuya/postfix-gmail:latest
docker pull $IMAGE

ENV_FILE=env_vars
cp env_vars.sample $ENV_FILE
vim $ENV_FILE


docker run \
  --env-file $ENV_FILE \
  -p 127.0.0.1:2525:25 \
  --name xoauth2 \
  --rm \
  $IMAGE
```

## bases on 

- Ubuntu 20.04
- ppa:sasl-xoauth2/stable


## prepare env_vars

#### Set up Client ID

Go https://console.cloud.google.com. and `Select your roject ` 

Go `APIs & Services`->`Credentials`->`Create Credentials`-> `OAuth 2.0 Client IDs` 

Select `Web App` and Click `Add URI` and Enter `oauth2.dance`.

`https://oauth2.dance/` as a redirect addr to make refresh token.

```sh
wget https://raw.githubusercontent.com/google/gmail-oauth2-tools/master/python/oauth2.py
python oauth2.py --generate_oauth2_token --client_id="${client_id}" --client_secret="{$client_secret}"
```


## env_var file
```
cp env_vars.sample env_vars
vim env_vars
```

write `env_vars` with generated  refresh_token.
```sh
__SMTP_SERVER___=smtp.gmail.com
__SMTP_TLS_PORT_=587
__SMTP_USER_ADDR=your-oauth2-granded-user@your-google-apps.tld
__ACCESS_TOKEN__=your-access-token-genereated.(should)
__REFRESH_TOKEN_=your-refresh-token-genereated.(must)
__CLIENT_ID_____=your-app-id-in-project
__PROJECT_ID____=your-project-name-id
__CLIENT_SECRET_=your-apps-client-secret
__MY_NETWORKS___=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
__RELAY_HOST____=[smtp.gmail.com]:587
```

___Caution___ : ___Don't quotes variables___


## docker 

run docker with env_vars.

```sh
IMAGE=ghcr.io/takuya/takuya/postfix-gmail-smtp-for-oauth:latest
docker pull $IMAGE
docker run -p 127.0.0.1:25252:25 --env-file env_vars --name xoauth2  --rm $IMAGE
``` 

## TODO

- docker images 
  - [x] testing
  - [x] file to environment
  - [x] auto build image

## references 

- https://github.com/tarickb/sasl-xoauth2
- https://github.com/moriyoshi/cyrus-sasl-xoauth2
- https://salsa.debian.org/uwabami/libsasl2-module-xoauth2
- https://unix.stackexchange.com/questions/584125/postfix-using-oauth2-authentication-for-relay-host



### developing 

Dockerfile を開いて、`postfix start-fg ` 関連を削除して、rsyslog と postfix を service で起動する。

LXCなどで先にテストしてからが良い。

## rsyslog are needed.

sasl_xoauth2 error / debug messages are written to `/var/log/mail.log`.

rsyslog がないと、SASL-xoauthエラーが見えてこない。

## check your token by lxc

if postfix cannot send mail. you can test your tokens. in LXC

Read `SASL-XOAUTH2-in-LXD.md` in this projet.

## Postfix chroot and start-fg will failed

Debian/Ubuntu packaged postfix will start under CHROOT env.
Start command: `service postfix start` definition  is in `/etc/init.d/postfix` .
Preparing chroot /etc files is also in `/etc/init.d/postfix`.

So that, just start postfix (ex `postfix start-fg `) command, will start in chroot which not properly prepared.
Postfix chroot (`/var/spool/postfix/etc` ) will unprocessed, remains empty /var/spool/postfix/etc.
`postfix start-fg` will be sucess but SMTP will be failed because of lacking chroot files ( ex `/etc/resolve.conf` ).

`postfix start-fg` はdocker で使う分には便利だけど。chroot で動かすには致命的にやばい。

Debian/ubuntuでは chroot 環境をservice startで整えるが、start-fg では空っぽの、chroot (/var/spool/postfix/etc)ままである。

対策としては２つあって

- chroot を諦める ( master.cf の変更 )
- start-fg に必要なファイルを持ってくる（大変）

chroot を諦める場合
```
postconf -F smtp/inet/chroot=n
```


必要なファイルを持ってくる場合(smtpdだけ)
```
/etc/host.conf 
/etc/hosts
/etc/localtime
/etc/nsswitch.conf
/etc/postfix
/etc/resolv.conf
/etc/services
/etc/ssl
```
が必要になる。ただ、pickupやcleanup,qmgr,flushはこれだけで動くのかは知らない。

`/etc/init.d/postfix` は`/usr/lib/postfix/configure-instance.sh` を動かしているので

/usr/lib/postfix/configure-instance.sh を動かせばchroot環境へコピーされる。
そしてとりあえず動くようにはなる。

Debian/ubuntu を使ったらchrootを外すのは大変なので、debainの流儀に沿って `/usr/lib/postfix/configure-instance.sh`を起動することで、starf-fg を可能にしている。


