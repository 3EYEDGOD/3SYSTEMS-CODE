#!/bin/bash
# Title         :CC-Config.sh
# Description   :Get PBS Information & Configure System
# Author        :Juan Garcia
# Date          :05:05:2022
# Version       :3.0
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
# psql needs to be installed: sudo apt-get install postgresql-client-common -y
# lynx needs to be installed: sudo apt-get install lynx -y
# curl needs to be installed: sudo apt-get install curl -y
#########################################################################################################
# TROUBLESHOOTING IF SCRIPT DOES NOT WORK:
#
# 1. Check IP ensure it's correct.
# 2. Ensure IP is pingable.
# 3. Reboot the sytsem you are on and try again.
# 4. Try from different system.
# 5. If script uses ssh try to manualy ssh into the system the IP may have an old key in the system that the script is running from. You may need to get rid of that ssh key.
# 6. The byte order mark (BOM) may be set. Vi IP.txt after entering your information you will see an ^M. Uncheck byte order mark in your txt editor. Re-enter info.
# 7. In your txt editor go to tools and change End of line to Unix.
# 8. When inputing serials on IP.txt leave a blank line at end of document otherwise last line won't be read.
#########################################################################################################

set -x

# Removing previous temp folder

rm -rf ix-tmp/

# Making temp file for SWQC check *.txt
# This is the directory where the data we collect will go

mkdir ix-tmp

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>ix-tmp/cc-person.txt
CCPERSON=$(cat ix-tmp/cc-person.txt | tr a-z A-Z)

# Collecting order number for systems

dialog --inputbox "Enter Order Number" 10 60 2>ix-tmp/ordertemp.txt
ORDER=$(cat ix-tmp/ordertemp.txt)

# Removing previous files

rm -rf $ORDER-CC-CONF.tar.gz $ORDER-CC-CONF/


echo "==========================================================================" >> ix-tmp/swqc-output.txt


echo "ORDER INFORMATION:" >> ix-tmp/swqc-output.txt
echo "Order Number: $ORDER" >> ix-tmp/swqc-output.txt

touch ix-tmp/$ORDER-PBS-output.txt
clear


echo "==========================================================================" >> ix-tmp/swqc-output.txt

# Header for CC report

echo "------------------------------------------" >> ix-tmp/$ORDER-REPORT.txt
printf "IXSYSTEMS INC. CLIENT CONFIGURATION REPORT\n" >> ix-tmp/$ORDER-REPORT.txt
echo "------------------------------------------" >> ix-tmp/$ORDER-REPORT.txt
printf "\n" >> ix-tmp/$ORDER-REPORT.txt
date >> ix-tmp/$ORDER-REPORT.txt
printf "\n"------------------------------------------"\nCC PERSON:\n$CCPERSON\n\n"------------------------------------------"\n"------------------------------------------"\nORDER NUMBER:\n$ORDER\n\n"------------------------------------------"\n\n\n\n" >> ix-tmp/$ORDER-REPORT.txt

# Grabbring serial number from IP.txt

touch ix-tmp/system-serial-output.txt

FILE=IP.txt
SERIAL=""
exec 3<&0
exec 0<$FILE
while read line
do
SERIAL=$(echo $line | cut -d " " -f1)

echo "$SERIAL" >> ix-tmp/swqc-output.txt

echo "IP.txt System-Serial is $SERIAL"

echo "$SERIAL" > ix-tmp/system-serial-output.txt

touch ix-tmp/$ORDER-PBS-output.txt
touch ix-tmp/$SERIAL-username.txt
touch ix-tmp/IP.txt


echo "==========================================================================" >> ix-tmp/swqc-output.txt


# Grabbing Burn-In information from PBS logs

curl -ks https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/ | tail -3 | head -1 | cut -c10-24 > ix-tmp/$SERIAL-dir.txt

if $(cat ix-tmp/$SERIAL-dir.txt | cut -d '"' -f1 | sed "s,/$,," | fgrep -wqi -e "Debug"); then
  curl -ks https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/ | tail -4 | head -1 | cut -c10-24 > ix-tmp/$SERIAL-dir.txt
  PBSDIRECTORY=$(cat ix-tmp/$SERIAL-dir.txt)
  curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/$PBSDIRECTORY/ipmi_summary.txt -o ix-tmp/$SERIAL-PBS-ipmi_summary.txt

elif PBSDIRECTORY=$(cat ix-tmp/$SERIAL-dir.txt); then
  echo "$PBSDIRECTORY" > ix-tmp/test1.txt
  curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/$PBSDIRECTORY/ipmi_summary.txt -o ix-tmp/$SERIAL-PBS-ipmi_summary.txt

fi


# Grabbing Passmark Log

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/$PBSDIRECTORY/Passmark_Log.html -o ix-tmp/$SERIAL-Passmark_Log.html
lynx --dump ix-tmp/$SERIAL-Passmark_Log.html | fgrep "TEST RUN" > ix-tmp/$SERIAL-test-run.txt
tr -s ' ' <  ix-tmp/$SERIAL-test-run.txt | cut -d ' ' -f 4 > ix-tmp/$SERIAL-pf.txt

PASSFAIL=$(cat ix-tmp/$SERIAL-pf.txt | xargs)

if $(echo $PASSFAIL | grep -oh "\w*PASSED\w*" | fgrep -wqi -e PASSED); then
  echo "[PASSED]" > ix-tmp/$SERIAL-passed.txt
fi


PASSVER=$(cat ix-tmp/$SERIAL-passed.txt)


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/$PBSDIRECTORY/Passmark_Log.html -o ix-tmp/$SERIAL-Passmark_Log.html
echo "https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/$PBSDIRECTORY/Passmark_Log.html" > ix-tmp/$SERIAL-CERT.txt
CERT=$(cat ix-tmp/$SERIAL-CERT.txt)


# CPU presence check

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/$PBSDIRECTORY/temperatures.csv  -o ix-tmp/$SERIAL-ipmi_lan.txt



lynx --dump ix-tmp/$SERIAL-Passmark_Log.html | egrep -i 'CPU 0|CPU 1' > ix-tmp/$SERIAL-CPU-presence.txt
if ! [ -s ix-tmp/$SERIAL-CPU-presence.txt ]; then
  echo "[NO CPU TEMP DETECTED]" > ix-tmp/$SERIAL-NO-CPU-presence.txt
fi


NOCPUTEMP=$(cat ix-tmp/$SERIAL-NO-CPU-presence.txt)

# CPU temp check

lynx --dump ix-tmp/$SERIAL-Passmark_Log.html | egrep -i 'CPU 0|CPU 1' > ix-tmp/$SERIAL-CPU-temp.txt
cat ix-tmp/$SERIAL-CPU-temp.txt | xargs | cut -d " " -f6 | cut -c 1-2 > ix-tmp/$SERIAL-CPU-max.txt
read -r num < ix-tmp/$SERIAL-CPU-max.txt
if [[ "$num" -gt 89 ]]; then
  echo "[CPU TEMP ABOVE THRESHOLD]" > ix-tmp/$SERIAL-CPU-error.txt
else
  echo "[CPU TEMP OK]" > ix-tmp/$SERIAL-CPU-error.txt
fi


CPUTEMP=$(cat ix-tmp/$SERIAL-CPU-error.txt)

# Checking to ensure system ran with test disk

lynx --dump ix-tmp/$SERIAL-Passmark_Log.html | fgrep "Disk (00)" > ix-tmp/$SERIAL-disk00-pf.txt
DISK00PF=$(cat ix-tmp/$SERIAL-disk00-pf.txt | xargs)

# Collects test duration

lynx --dump ix-tmp/$SERIAL-Passmark_Log.html | fgrep "Test Duration" > ix-tmp/$SERIAL-testduration-pf.txt
TESTDURATION=$(cat ix-tmp/$SERIAL-testduration-pf.txt | xargs)

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/$PBSDIRECTORY/ipmi_lan.txt -o ix-tmp/$SERIAL-ipmi_lan.txt

cat ix-tmp/$SERIAL-ipmi_lan.txt | egrep -i "IP Address              : " | cut -d ":" -f2 > ix-tmp/$SERIAL-ipmi-ipadddress.txt
IPMIIP=$(cat ix-tmp/$SERIAL-ipmi-ipadddress.txt | xargs)

# Collect IPMI IP address

cat ix-tmp/$SERIAL-ipmi_lan.txt | egrep -i "MAC Address             : " | xargs | cut -d ' ' -f 4 > ix-tmp/$SERIAL-ipmi-bmc-mac.txt
IPMIMAC=$(cat ix-tmp/$SERIAL-ipmi-bmc-mac.txt)

# Collecting STD info

psql -h std.ixsystems.com -U std2 -d std2 -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" > ix-tmp/$SERIAL-std-parts.txt
cat ix-tmp/$SERIAL-std-parts.txt | grep -i "IPMI Password" | cut -d "|" -f2-3 | tr -d "|"  > ix-tmp/$SERIAL-ipmi-password.txt
tr -s ' ' < ix-tmp/$SERIAL-ipmi-password.txt | cut -d ' ' -f4 > ix-tmp/$SERIAL-ipmi-pw.txt
IPMIPASSWORD=$(cat ix-tmp/$SERIAL-ipmi-pw.txt)

# Checking for break-out cable

cat ix-tmp/$SERIAL-std-parts.txt | grep -i cable > ix-tmp/$SERIAL-networkcable.txt

cat ix-tmp/$SERIAL-networkcable.txt | cut -d "|" -f1 > ix-tmp/$SERIAL-networkcable-cp.txt
cat ix-tmp/$SERIAL-networkcable.txt | cut -d "|" -f2 > ix-tmp/$SERIAL-networkcable-model.txt
cat ix-tmp/$SERIAL-networkcable.txt | cut -d "|" -f3 > ix-tmp/$SERIAL-networkcable-serial.txt

NETCABCP=$(cat ix-tmp/$SERIAL-networkcable-cp.txt)
NETCABMODEL=$(cat ix-tmp/$SERIAL-networkcable-model.txt)
NETCABSERIAL=$(cat ix-tmp/$SERIAL-networkcable-serial.txt)

if $(echo $NETCABCP | grep -oh "\w*CABLE\w*" | fgrep -wqi -e CABLE); then
  echo "Network Cable $NETCABMODEL Present Check If NIC Is Configure For Break Out" >> ix-tmp/swqc-output.txt
  echo "[BREAK-OUT CABLE]" > ix-tmp/$SERIAL-break-out.txt
fi


BREAKOUT=$(cat ix-tmp/$SERIAL-break-out.txt)

# Getting motherboard manufacturer info

lynx --dump ix-tmp/$SERIAL-Passmark_Log.html | fgrep "Motherboard Manufacturer:" | xargs | cut -d ' ' -f3 > ix-tmp/$SERIAL-motherboard-manufacturer.txt
MOTHERMAN=$(cat ix-tmp/$SERIAL-motherboard-manufacturer.txt)

# Getting system model type

lynx --dump ix-tmp/$SERIAL-Passmark_Log.html | fgrep "Motherboard Model:" | xargs | cut -d " " -f3 > ix-tmp/$SERIAL-system-model.txt
MODELTYPE=$(cat ix-tmp/$SERIAL-system-model.txt)

# Checking for wrong memory serial for TrueNAS systems

#curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/$SERIAL/$PBSDIRECTORY/DIMM_MemoryChipData.txt -o ix-tmp/$SERIAL-PBS-DIMM_MemoryChipData.txt
#cat ix-tmp/$SERIAL-PBS-DIMM_MemoryChipData.txt | grep -i 'XF' > ix-tmp/$SERIAL-Mem-Check.txt
#MEMSERIALCHECK=$(cat ix-tmp/$SERIAL-Mem-Check.txt)
#if $(echo "$MEMSERIALCHECK" | fgrep -wqi -e 'XF' ); then
#    echo "[NVDIMM ERROR]" > ix-tmp/Mem-Error.txt
#else
#    echo "[CORRECT NVDIMM]" > ix-tmp/Mem-Error.txt
#fi


#MEMERROR=$(cat ix-tmp/Mem-Error.txt)

# Check for presence of QLOGIC fibre card

psql -h std.ixsystems.com -U std2 -d std2 -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" > ix-tmp/$SERIAL-std-parts.txt
cat ix-tmp/$SERIAL-std-parts.txt | grep -i QLE | cut -d "|" -f2 | grep -i -o -P '.{0,0}qle.{0,0}' > ix-tmp/$SERIAL-qle-output.txt

QLE=$(cat ix-tmp/$SERIAL-qle-output.txt)

if $(echo "$QLE" | fgrep -wqi -e QLE); then

echo "QLOGIC-CARD-Present-Check-TrueNAS-License" > ix-tmp/$SERIAL-qlogic-check.txt
echo "[QLOGIC/FC]" > ix-tmp/$SERIAL-qlogic-msg.txt
QLOGIC=$(cat ix-tmp/$SERIAL-qlogic-msg.txt)

fi


echo "==========================================================================" >> ix-tmp/swqc-output.txt


# Reseting GIGABYTE IPMI to default

if $(echo "$MOTHERMAN" | fgrep -wqi -e GIGABYTE); then
  echo "admin" > ix-tmp/$SERIAL-username.txt

  ipmitool -I lanplus -H $IPMIIP -U admin -P password user set password 2 $IPMIPASSWORD

  sleep 1

  # Check password change completed

  ipmitool -I lanplus -H $IPMIIP -U admin -P $IPMIPASSWORD lan print 1 > ix-tmp/$SERIAL-passwdcheck.txt

  cat ix-tmp/$SERIAL-passwdcheck.txt | grep -i Complete
  PWSTATUS=$(cat ix-tmp/$SERIAL-passwdcheck.txt)

  tr -s ' ' < ix-tmp/$SERIAL-passwdcheck.txt | grep -i Complete | cut -d " " -f6 > ix-tmp/$SERIAL-pwc.txt
  PWC=$(cat ix-tmp/$SERIAL-pwc.txt)

fi


# Check for alternate default password

if ! [ -s ix-tmp/$SERIAL-passwdcheck.txt ]; then
  ipmitool -I lanplus -H $IPMIIP -U admin -P administrator user set password 2 $IPMIPASSWORD && ipmitool -I lanplus -H $IPMIIP -U admin -P $IPMIPASSWORD lan print 1 > ix-tmp/$SERIAL-passwdcheck.txt

  cat ix-tmp/$SERIAL-passwdcheck.txt | grep -i Complete
  PWSTATUS=$(cat ix-tmp/$SERIAL-passwdcheck.txt)

  tr -s ' ' < ix-tmp/$SERIAL-passwdcheck.txt | grep -i Complete | cut -d " " -f6 > ix-tmp/$SERIAL-pwc.txt
  PWC=$(cat ix-tmp/$SERIAL-pwc.txt)

fi


# Verify password changed

if $(echo "$MOTHERMAN" | fgrep -wqi -e GIGABYTE) && $(echo "$PWC" | grep -oh "\w*Complete\w*" | fgrep -wqi -e Complete); then
  echo "[PWD VERIFIED]" > ix-tmp/pwd-verified.txt
  PWDV=$(cat ix-tmp/pwd-verified.txt)

fi


echo "==========================================================================" >> ix-tmp/swqc-output.txt


# IPMIUSER changes based on motherboard manufacturer

IPMIUSER=$(cat ix-tmp/$SERIAL-username.txt)


echo "==========================================================================" >> ix-tmp/swqc-output.txt

mkdir ix-tmp/PBS_LOGS
wget -np -r -nH --cut-dirs=4 https://archive.pbs.ixsystems.com/pbsv4/pbs_logs/$SERIAL/$PBSDIRECTORY/ -P ix-tmp/PBS_LOGS/

# Grabbing MAC address for Asset List

touch ix-tmp/mac-address-list.txt
echo -e "==========================================================================\n" >> ix-tmp/mac-address-list.txt
printf "$SERIAL MELLANOX CHECK:\n\n" >> ix-tmp/mac-address-list.txt
cat ix-tmp/$SERIAL-ifconfig.txt | grep -i -A3 -B1 mellanox | xargs -0 | sed 's/^ *//g' >> ix-tmp/mac-address-list.txt
echo -e "\n==========================================================================\n" >> ix-tmp/mac-address-list.txt
printf "$SERIAL IPMI:\n\n" >> ix-tmp/mac-address-list.txt
cat ix-tmp/$SERIAL-ipmi_lan.txt | grep "MAC Address             :" | sed "s/://g" >> ix-tmp/mac-address-list.txt
echo -e "\n==========================================================================\n" >> ix-tmp/mac-address-list.txt
printf "$SERIAL ONBOARD NICS:\n\n" >> ix-tmp/mac-address-list.txt
cat ix-tmp/$SERIAL-ifconfig.txt | egrep -A5 -i --color '(o1:|o2:)' | xargs -0 | sed 's/^ *//g' >> ix-tmp/mac-address-list.txt
echo -e "\n==========================================================================" >> ix-tmp/mac-address-list.txt
sed "/A1-/! s/-//g" ix-tmp/mac-address-list.txt > ix-tmp/fixed-mac-address-list.txt

# Grabbing SEL, SDR, & SENSOR info

yes | pv -SpeL1 -s 45 > /dev/null

ipmitool -I lanplus -H $IPMIIP -U $IPMIUSER -P $IPMIPASSWORD sel list > ix-tmp/$SERIAL-SEL-Data.txt
if ! [ -s ix-tmp/$SERIAL-SEL-Data.txt ]; then
  ipmitool -H $IPMIIP -U $IPMIUSER -P $IPMIPASSWORD sel list > ix-tmp/$SERIAL-SEL-Data.txt
fi

ipmitool -I lanplus -H $IPMIIP -U $IPMIUSER -P $IPMIPASSWORD sdr list > ix-tmp/$SERIAL-SDR-Data.txt
if ! [ -s ix-tmp/$SERIAL-SDR-Data.txt ]; then
  ipmitool -H $IPMIIP -U $IPMIUSER -P $IPMIPASSWORD sdr list > ix-tmp/$SERIAL-SDR-Data.txt
fi

ipmitool -I lanplus -H $IPMIIP -U $IPMIUSER -P $IPMIPASSWORD sensor list > ix-tmp/$SERIAL-SENSOR-Data.txt
if ! [ -s ix-tmp/$SERIAL-SENSOR-Data.txt ]; then
  ipmitool -H $IPMIIP -U $IPMIUSER -P $IPMIPASSWORD sensor list > ix-tmp/$SERIAL-SENSOR-Data.txt
fi

# Check for missing fans

if $(echo "$MODELTYPE" | fgrep -wqi -e IX-4224GP2-IXN); then
  cat ix-tmp/$SERIAL-SDR-Data.txt | grep -i -v "FAN10" |  grep -i 'FAN[17]' > ix-tmp/$SERIAL-FAN-Data.txt
fi

if cat ix-tmp/$SERIAL-FAN-Data.txt | grep "no reading"; then
  echo "[CHECK FANS]" > ix-tmp/$SERIAL-FAN-Check.txt
fi

FANERROR=$(cat ix-tmp/$SERIAL-FAN-Check.txt)


# Dumping data to consolidated output file

echo "$SERIAL $IPMIIP $IPMIMAC $PASSFAIL $DISK00PF $TESTDURATION $FANERROR $MEMERROR $IPMIPASSWORD $PWDV $MOTHERMAN $MODELTYPE $BREAKOUT $CPUTEMP $NOCPUTEMP $MINIEFANERROR $QLOGIC" | xargs >> ix-tmp/$ORDER-PBS-output.txt

printf "===========================================================================\nSERIAL NUMBER:\n$SERIAL\n\n===========================================================================\nIPMI IP:\n$IPMIIP\n\n===========================================================================\nIPMI USER:\n$IPMIUSER\n\n===========================================================================\nIPMI PASSWORD:\n$IPMIPASSWORD\n$PWDV\n\n===========================================================================\nIPMI MAC ADDRESS:\n$IPMIMAC\n\n===========================================================================\nBURN-IN RESULTS:\n$PASSVER\n$DISK00PF\n$TESTDURATION\n\n$CERT\n\n===========================================================================\nSYSTEM INFO:\n$MOTHERMAN\n$MODELTYPE \n\n===========================================================================\nCONFIGURATIONS:\n$NETSET\n$FANSET\n\n===========================================================================\nSYSTEM WARNINGS:\n$CPUTEMP\n$MEMERROR\n$NOCPUTEMP\n$BREAKOUT\n$QLOGIC\n$FANERROR\n$MINIEFANERROR\n" >> ix-tmp/$ORDER-REPORT.txt
printf "\n\n------------------------------------END------------------------------------\n\n\n" >> ix-tmp/$ORDER-REPORT.txt

echo "$SERIAL $IPMIIP $IPMIUSER $IPMIPASSWORD $IPMIMAC" >> ix-tmp/IP.txt

done

# Creating CSV file for data transfer

tr -s " " < ix-tmp/IP.txt > ix-tmp/IP.csv


echo "==========================================================================" >> ix-tmp/swqc-output.txt


# Creating GOLD file for diff

LINE=$(head -n 1 IP.txt)

cp ix-tmp/$LINE-SEL-Data.txt ix-tmp/GOLD-SEL-Data.txt
cp ix-tmp/$LINE-SDR-Data.txt ix-tmp/GOLD-SDR-Data.txt
cp ix-tmp/$LINE-SENSOR-Data.txt ix-tmp/GOLD-SENSOR-Data.txt

# Diffing each system for errors

FILE=IP.txt
SERIAL=""
exec 3<&0
exec 0<$FILE
while read line
do
  SERIAL=$(echo $line | cut -d " " -f 1)

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >> ix-tmp/SEL-DIFF.txt
  diff -y -W 200 --suppress-common-lines ix-tmp/GOLD-SEL-Data.txt ix-tmp/$SERIAL-SEL-Data.txt >> ix-tmp/SEL-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >> ix-tmp/SDR-DIFF.txt
  diff -y -W 200 --suppress-common-lines ix-tmp/GOLD-SDR-Data.txt ix-tmp/$SERIAL-SDR-Data.txt >> ix-tmp/SDR-DIFF.txt

  echo "------------------------------------------------------$SERIAL------------------------------------------------------" >> ix-tmp/SENSOR-DIFF.txt
  diff -y -W 200 --suppress-common-lines ix-tmp/GOLD-SENSOR-Data.txt ix-tmp/$SERIAL-SENSOR-Data.txt >> ix-tmp/SENSOR-DIFF.txt

done


echo "=====================================END=====================================" >> ix-tmp/swqc-output.txt

mv ix-tmp $ORDER-CC-CONF

# Compress output file

tar cfz "$ORDER-CC-CONF.tar.gz" $ORDER-CC-CONF/


exit
