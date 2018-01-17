#!/bin/bash

SERVICE="portainer"
IMAGE="$SERVICE-image"

OPTION=$(whiptail --title $SERVICE --menu "Choose your option" 15 60 4 \
"0" "Build $SERVICE" \
"1" "Start service $SERVICE"  \
"2" "Restart service $SERVICE" \
"3" "Stop service $SERVICE" 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Your chosen option:" $OPTION
else
    echo "You chose Cancel."
fi

case "$OPTION" in

0)  cd $IMAGE
    docker build -t $IMAGE .
    docker tag $IMAGE registry-srv.services.alin.be/$IMAGE
    ;;
1)  docker-compose up -d
    ;;
2)  docker-compose down
    sleep 3
    docker-compose up -d
    ;;
3)  docker-compose down
    docker-compose rm
    ;;
esac

