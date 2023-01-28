#! /bin/bash
# Title         :Run-Redfish-Disable
# Description   :Designed To Disable Redfish User
# Author		:Juan Garcia
# Date          :1-19-23
# Version       :1.0
#########################################################################################################

FILE=IP.txt
SERIAL=””
IPMI=””
IPMIPASSWD=””
GUIIP=””
exec 3<&0
exec 0<$FILE
while read line
do

SERIAL=$(echo $line | cut -d " " -f 1)
IPMI=$(echo $line | cut -d " " -f 2)
IPMIPASSWD=$(echo $line | cut -d " " -f 3)
GUIIP=$(echo $line | cut -d " " -f 4)


echo "==========================================================================" >> swqc-tmp/swqc-output.txt

# Using sed to add our variables to scripts being run on remote system

sed -i "s/IPMIIP/$IPMI/g" VALIDATION/Redfish-Disable.sh # updating Redfish-Disable.sh via sed to supply IPMI IP

sed -i "s/IPMIPASSWD/$IPMIPASSWD/g" VALIDATION/Redfish-Disable.sh # updateing Redfish-Disable.sh to via sed to supply IPMI Password


echo "==========================================================================" >> swqc-tmp/swqc-output.txt


# Executing script on remote server over ssh using sshpass

cat VALIDATION/Redfish-Disable.sh | sshpass -vp abcd1234 ssh -tt -oStrictHostKeyChecking=no root@$GUIIP -yes


# Cleanup of script for reusability

sed -i "s/$IPMI/IPMIIP/g" VALIDATION/Redfish-Disable.sh # Reverting sed changed

sed -i "s/$IPMIPASSWD/IPMIPASSWD/g" VALIDATION/Redfish-Disable.sh # Reverting sed changed


done

