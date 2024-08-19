#!/bin/bash

used=$(df -h | awk '/\/$/ {print $--NF-0}')
if [ $used -ge 90 ]
then 
	echo "$(date) - DOCKER BUILDER CACHE CLEANER - Less, than 10% left on / ($(echo 100 - $used | bc)%), pruning docker builder cache" >> /var/log/messages
	docker builder prune -f --filter until=48h && 
		echo "$(date) - DOCKER BUILDER CACHE CLEANER - Done"  >> /var/log/messages || 
		echo "$(date) - DOCKER BUILDER CACHE CLEANER - ERROR!"  >> /var/log/messages
else
	echo "$(date) - DOCKER BUILDER CACHE CLEANER - More, than 10% left on / ($left%), unneed to prune docker builder cache" >> /var/log/messages
fi
