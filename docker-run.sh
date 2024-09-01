IMAGE="${IMAGE:=takuya/postfix-gmail-smtp-for-oauth:latest}"
docker run --name xoauth2 --env-file env_vars --rm -it $IMAGE bash
