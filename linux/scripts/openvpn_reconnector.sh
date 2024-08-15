#!/bin/bash

# Your IP inside lan to check VPN connection
IP_TO_CHECK=192.168.0.254

# Your .ovpn file
OVPN_FILE=/root/my.ovpn

# Your credits file (login/password on new line each)
CRD_FILE=/root/my.crd

CONNECTED=$(ping -c 3 $IP_TO_CHECK >> /dev/null; echo $?)
LOG_FILE=/var/log/messages
LOG_PREFIX="$(date) OPENVPN:"
COUNTER=1


while [ $CONNECTED -ne 0]
do
        echo "[WARNING] $LOG_PREFIX NOT connected, reconnecting." >> $LOG_FILE
        openvpn --config $OVPN_FILE --auth-user-pass $CRD_FILE
        sleep 60
        CONNECTED=$(ping -c 3 $IP_TO_CHECK >> /dev/null; echo $?)
        COUNTER=$(echo $COUNTER + 1 | bc)
        if [ $COUNTER -eq 5 ]
        then
                echo "[CRITICAL] $LOG_PREFIX Didn't connect, given up. Check server." >> $LOG_FILE
                exit 1
        fi

done

echo "[OK] $LOG_PREFIX Still connected, doesn't need to reconnect." >> $LOG_FILE
exit 0
~                   
