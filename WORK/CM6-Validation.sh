#!/bin/bash
# Title         :CM6-Check.sh
# Description   :Designed To Run CM6-Flash.sh
# Author		:3EYEDGOD
# Date          :11-11-22
# Version       :1.0
#########################################################################################################

# Grabbring serial number & ip from IP.txt

FILE=IP.txt
IP=””
exec 3<&0
exec 0<$FILE
while read line
do
IP=$(echo $line | cut -d " " -f 1)

# Using cat to run validation script CM6-Flash.sh

cat VALIDATION/CM6-Flash.sh | sshpass -vp abcd1234 ssh -tt -oStrictHostKeyChecking=no root@$IP -yes

done

exit
