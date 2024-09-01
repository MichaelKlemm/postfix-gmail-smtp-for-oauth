
IMAGE="${IMAGE:=takuya/postfix-gmail-smtp-for-oauth:latest}"



cd $(dirname $0)/docker-build
docker build -t $IMAGE .
cd -