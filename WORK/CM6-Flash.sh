#!/bin/bash
# Title         :CM6-Flash.sh
# Description   :Designed To Flash CM6 Drives
# Author		:3EYEDGOD
# Date          :11-11-22
# Version       :1.0
#########################################################################################################


# This is the directory where the data we collect will go

cd /var/tmp
mkdir cm6-tmp


echo "==========================================================================" >> cm6-tmp/LINE-Output.txt


# Grabbing serial number

dmidecode -t1 | grep -E -o -i "A1-.{0,6}" > cm6-tmp/System-Serial.txt
SERIAL=$(cat cm6-tmp/System-Serial.txt)


echo "==========================================================================" >> cm6-tmp/LINE-Output.txt


echo -e "+----------------+" >> cm6-tmp/"$SERIAL"-CM6-CHECK.txt
echo "+[CM6 NVME FLASH]+" >> cm6-tmp/"$SERIAL"-CM6-CHECK.txt
echo -e "+----------------+\n\n" >> cm6-tmp/"$SERIAL"-CM6-CHECK.txt
nvmecontrol devlist | grep -F -e "CM6" >> cm6-tmp/NVMEcontrol-Check.txt
nvmecontrol devlist | grep -F -e "CM6" | sed 's/^ *//g'  >> cm6-tmp/"$SERIAL"-CM6-CHECK.txt
echo -e "\n" >> cm6-tmp/"$SERIAL"-CM6-CHECK.txt
cat cm6-tmp/NVMEcontrol-Check.txt | cut -d ":" -f1 | sed 's/^ *//g' | xargs -0 | sed '$d' >> cm6-tmp/NVD-List.txt


FILE=/tmp/cm6-tmp/NVD-List.txt
NVME=""
exec 3<&0
exec 0<$FILE
while read line
do
NVME=$(echo $line | cut -d " " -f1)

echo "nvmecontrol admin-passthru -o 0xC4 -n=0 -4 0x0100 -5 0x0 -6 0x0 $NVME" >> cm6-tmp/"$SERIAL"-CM6-CHECK.txt
nvmecontrol admin-passthru -o 0xC4 -n=0 -4 0x0100 -5 0x0 -6 0x0 "$NVME" >> cm6-tmp/"$SERIAL"-CM6-CHECK.txt

done


echo "==========================================================================" >> cm6-tmp/LINE-Output.txt


# Compress output file

tar cfz ""$SERIAL"-CM6-Flash.tar.gz" cm6-tmp/


echo "==========================================================================" >> cm6-tmp/LINE-Output.txt


echo "[ECHONAS.IXSYSTEMS.COM:ROOT]" > ~/.nsmbrc
echo "password=abcd1234" >> ~/.nsmbrc
cat ~/.nsmbrc
mkdir /mnt/sj-storage
mount_smbfs -N -I 10.246.0.110 //root@10.246.0.110/sj-storage/ /mnt/sj-storage
echo "SJ Storage Mounted"


echo "==========================================================================" >> cm6-tmp/LINE-Output.txt


echo "Copying tar.gz File To swqc-output On sj-storage"
cd /var/tmp
cp *.tar.gz /mnt/sj-storage/swqc-output
echo "Finished Copying tar.gz File To swqc-output On sj-storage"


echo "==========================================================================" >> cm6-tmp/LINE-Output.txt

rm -rf  *.tar.gz cm6-tmp/

exit
