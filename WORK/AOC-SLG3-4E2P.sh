#!/bin/bash -x
# Title: AOC-SLG3-4E2P.sh
# Description: Designed To Flash AOC-SLG3-4E2P On TrueNAS-R50BM
# Author: 3EYEDGOD
# Date: 11-11-22
# Version: 1.0
#########################################################################################################


# This is the directory where the data we collect will go

cd /var/tmp || exit
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

printf "EEPROM STATUS PRE-FLASH:\n\n" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt
./plx_eeprom -b "$PCIE" > ix-tmp/EEPROM-Status.txt
./plx_eeprom -b "$PCIE" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt

# Flashing the Card using EEPROM image

printf "\n\n-----\n" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt
./plx_eeprom -b "$PCIE" -w -f /var/tmp/sm_patch2.eep > ix-tmp/EEPROM-Flash-Check.txt
./plx_eeprom -b "$PCIE" -w -f /var/tmp/sm_patch2.eep >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt
printf "-----\n\n" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt

# Checking eeprom image status after flashing

printf "EEPROM STATUS POST-FLASH:\n\n" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt
./plx_eeprom -b "$PCIE" > ix-tmp/EEPROM-Status-Flashed.txt
./plx_eeprom -b "$PCIE" >> ix-tmp/"$SERIAL"-R50BM-FLASH.txt


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Compress output file

tar cfz "$SERIAL-AOC-SLG3-4E2P.tar.gz" ix-tmp/


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


echo "[ECHONAS.IXSYSTEMS.COM:ROOT]" > ~/.nsmbrc
echo "password=abcd1234" >> ~/.nsmbrc
cat ~/.nsmbrc
mkdir /mnt/sj-storage
mount_smbfs -N -I 10.246.0.110 //root@10.246.0.110/sj-storage/ /mnt/sj-storage
echo "SJ Storage Mounted"


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


echo "Copying tar.gz File To swqc-output On sj-storage"
cd /var/tmp || return
cp *.tar.gz /mnt/sj-storage/swqc-output
echo "Finished Copying tar.gz File To swqc-output On sj-storage"


echo "==========================================================================" >> ix-tmp/LINE-Output.txt

rm -rf  *.tar.gz ix-tmp/

exit
