## postfix docker with xoauth2

postfix enabled xoauth2 in docker

This postfix is for gmail(xoauth2).

Postfix will send mail via `smtp-relay.gmail.com:587` or `smtp.gmail.com:587` by smart relay.

## usage 

```sh
## enter client_id and client_secret
vim docker-build/etc/sasl-xoauth2.conf
## enter sender's access_token and refresh_token
vim docker-build/etc/tokens/sender.tokens.json
## enter mailaddress my own
MY_MAIL=example@gmail.example.com
sed -i "s|yourmail@example.com|$MY_MAIL|" docker-build/etc/postfix/sasl_passwd
./start.sh
```

## relay server config 

In `sasl_passwd`, config is `smtp-relay.gmail.com` , restricted to google workspace user.

if use a general gmail account, change  it to `smtp.gmail.com`.

```sh
## for general gmail not gsuite
sed -i 's|smtp-relay.gmail.com|smtp.gmail.com|' docker-build/etc/postfix/sasl_passwd
sed -i 's|smtp-relay.gmail.com|smtp.gmail.com|' docker-build/etc/postfix/main.cf
## for gsuite
## do nothing .
```

## client secret / refresh token required.

`client secret` from google cloud console 

refresh token from oauth


## build and run 
```shell
## build
cd docker-build
IMAGE=takuya/postfix-gmail:latest
docker build -t $IMAGE .
## run
docker run -p 25:25 $IMAGE 

```

## bases on 

- Ubuntu 20.04
- ppa:sasl-xoauth2/stable

## docker 

```
docker pull ghcr.io/takuya/takuya/postfix-gmail
```

## TODO

- docker images 
  - [ ] testing
  - [ ] file to environment
  - [x] auto build image


## references 

- https://github.com/tarickb/sasl-xoauth2
- https://github.com/moriyoshi/cyrus-sasl-xoauth2
- https://salsa.debian.org/uwabami/libsasl2-module-xoauth2
- https://unix.stackexchange.com/questions/584125/postfix-using-oauth2-authentication-for-relay-host
