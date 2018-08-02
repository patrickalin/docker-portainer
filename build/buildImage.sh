#!/bin/bash
#Version 2.0

DIRECTORY=$(cd `dirname $0` && pwd)
cd $DIRECTORY

set -e
source ./env

echo "##################################"
echo -e "$BLUE Test internet / proxy $NC"

status=$(curl -s -o /dev/null -w "%{http_code}" http://www.google.be)
if [ $status != 200 ]; then echo $status; echo -e "$RED" "$REGISTRY_FROM down" "$NC"; exit 1;fi;
echo -e "$GREEN" "$status" "$NC"

echo -e "$BLUE Test registry From : $REGISTRY_FROM $NC"

if [ -n "$REGISTRY_FROM" ]
then
	status=$(curl -s -o /dev/null -w "%{http_code}" http://$REGISTRY_FROM)

	if [ $status != 200 ]; then echo $status; echo -e "$RED" "$REGISTRY_FROM down" "$NC"; exit 1;fi;
	echo -e "$GREEN" "$REGISTRY_FROM" : "$status" "$NC"	
else
	echo -e "$GREEN" "Use Docker Hub" "$NC"
fi

echo -e "$BLUE Test registry To : $REGISTRY_TO $NC"

if [ -n "$REGISTRY_TO" ]
then
	status=$(curl -s -o /dev/null -w "%{http_code}" http://$REGISTRY_TO)

	if [ $status != 200 ]; then echo $status; echo -e "$RED" "$REGISTRY_TO down" "$NC"; exit 1;fi;
	echo -e "$GREEN" "$REGISTRY_TO" : "$status" "$NC"
else
        echo -e "$GREEN" "Use Docker Hub" "$NC"
fi


echo "\n##################################"
echo -e "$BLUE Image to pull : $GREEN" $REGISTRY_FROM${REGISTRY_FROM:+/}$IMAGE_FROM:$TAG_FROM "$NC"
docker pull 	$REGISTRY_FROM${REGISTRY_FROM:+/}$IMAGE_FROM:$TAG_FROM

echo "##################################"
echo -e "$BLUE Tag Image : $GREEN" $REGISTRY_FROM${REGISTRY_FROM:+/}$IMAGE_FROM:$TAG_FROM "$NC"
docker tag 	$REGISTRY_FROM${REGISTRY_FROM:+/}$IMAGE_FROM:$TAG_FROM 		$REGISTRY_TO${REGISTRY_TO:+/}$IMAGE_FROM:$TAG_FROM

echo "##################################"
echo -e "$BLUE Push : $GREEN" $REGISTRY_TO${REGISTRY_TO:+/}$IMAGE_FROM:$TAG_FROM "$NC"
docker push 	$REGISTRY_TO${REGISTRY_TO:+/}$IMAGE_FROM:$TAG_FROM

echo "##################################"
echo -e "$BLUE Remove : $GREEN" $IMAGE_FROM:$TAG_FROM "$NC"
docker rmi 	$REGISTRY_FROM${REGISTRY_FROM:+/}$IMAGE_FROM:$TAG_FROM

echo "##################################"
echo -e "$BLUE Generate Dockerfile $NC"
echo "# Don't edit this file, use DockerfileTemplate and buildImage.sh" > Dockerfile
echo "###############################################" >> Dockerfile
$(REGISTRY=$REGISTRY_TO IMAGE_FROM=$IMAGE_FROM TAG_FROM=$TAG_FROM envsubst < DockerfileTemplate >> Dockerfile)

echo "##################################"
echo -e "$BLUE Build and push $GREEN $REGISTRY_TO/$IMAGE_TO-$POSTFIX_TO:$TAG_TO $NC"
docker build -t 	$REGISTRY_TO/$IMAGE_TO-$POSTFIX_TO:$TAG_TO .
docker push 		$REGISTRY_TO/$IMAGE_TO-$POSTFIX_TO:$TAG_TO

echo "##################################"
echo -e "$BLUE Remove : $GREEN" $REGISTRY_FROM${REGISTRY_FROM:+/}$IMAGE_FROM:$TAG_FROM "$NC"
docker rmi $REGISTRY_TO${REGISTRY_TO:+/}$IMAGE_FROM:$TAG_FROM

docker rmi $REGISTRY_TO${REGISTRY_TO:+/}$IMAGE_TO-$POSTFIX_TO:$TAG_TO

echo "##################################"
echo -e "$BLUE List images $NC"
docker images | grep $IMAGE_TO
