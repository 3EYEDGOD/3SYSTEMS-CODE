#!/bin/bash
# Title         :R50BM-SCP.sh
# Description   :Designed To Run AOC-SLG3-4E2P.sh
# Author		    :3EYEDGOD
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

# Usin SCP to copy files to TrueNAS R50BM

sshpass -p abcd1234 scp -P22 -qo  StrictHostKeyChecking=no /home/$USER/ixsystems-cc/VALIDATION/R50BM/plx_eeprom root@$IP:/var/tmp
sshpass -p abcd1234 scp -P22 -qo  StrictHostKeyChecking=no /home/$USER/ixsystems-cc/VALIDATION/R50BM/sm_patch2.eep root@$IP:/var/tmp

# Using cat to run validation script AOC-SLG3-4E2P.sh on TrueNAS R50BM

cat VALIDATION/R50BM/AOC-SLG3-4E2P.sh | sshpass -vp abcd1234 ssh -tt -oStrictHostKeyChecking=no root@$IP -yes | pv

done

exit
