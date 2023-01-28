#!/bin/bash -x
# Title         :AOC-SLG3-4E2P.sh
# Description   :Designed To Flash AOC-SLG3-4E2P On TrueNAS-R50BM
# Author		    :Juan Garcia
# Date          :11-11-22
# Version       :1.0
#########################################################################################################


# This is the directory where the data we collect will go

cd /var/tmp
mkdir ix-tmp


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Grabbing serial number

dmidecode -t1 | grep -E -o -i "A1-.{0,6}" > ix-tmp/System-Serial.txt
SERIAL=$(cat ix-tmp/System-Serial.txt)

# Making file executable

chmod +x ./plx_eeprom

# Scanning for and finding PCI-E devices

pciconf -lvb | grep -A5 "PEX" | head -5 | grep "base" | cut -d "," -f3 | xargs | cut -d " " -f2- > ix-tmp/PCI-E-Devices.txt
PCIE=$(cat ix-tmp/PCI-E-Devices.txt)

# Checking eeprom image status

printf "EEPROM STATUS PRE-FLASH:\n\n" >> ix-tmp/$SERIAL-R50BM-FLASH.txt
./plx_eeprom -b $PCIE > ix-tmp/EEPROM-Status.txt
./plx_eeprom -b $PCIE >> ix-tmp/$SERIAL-R50BM-FLASH.txt

# Flashing the Card using EEPROM image

printf "\n\n-----\n" >> ix-tmp/$SERIAL-R50BM-FLASH.txt
./plx_eeprom -b $PCIE -w -f /var/tmp/sm_patch2.eep > ix-tmp/EEPROM-Flash-Check.txt
./plx_eeprom -b $PCIE -w -f /var/tmp/sm_patch2.eep >> ix-tmp/$SERIAL-R50BM-FLASH.txt
printf "-----\n\n" >> ix-tmp/$SERIAL-R50BM-FLASH.txt

# Checking eeprom image status after flashing

printf "EEPROM STATUS POST-FLASH:\n\n" >> ix-tmp/$SERIAL-R50BM-FLASH.txt
./plx_eeprom -b $PCIE > ix-tmp/EEPROM-Status-Flashed.txt
./plx_eeprom -b $PCIE >> ix-tmp/$SERIAL-R50BM-FLASH.txt


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Compress output file

tar cfz "$SERIAL-AOC-SLG3-4E2P.tar.gz" ix-tmp/


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


echo "[XXXXXXX.XXXXXXXXX.XXX:USER]" > ~/.nsmbrc
echo "password=xxxxxxxx" >> ~/.nsmbrc
cat ~/.nsmbrc
mkdir /mnt/FOLDER
mount_smbfs -N -I <DOMAIN> //root@<DOMAIN>/PATH/ /mnt/FOLDER
echo "SJ Storage Mounted"


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


echo "Copying tar.gz File To PATH On sj-storage"
cd /var/tmp
cp *.tar.gz /mnt/FOLDER/PATH
echo "Finished Copying tar.gz File To PATH On sj-storage"


echo "==========================================================================" >> ix-tmp/LINE-Output.txt

rm -rf  *.tar.gz ix-tmp/

exit
