#!/bin/bash
# Title         :CC-Config.sh
# Description   :Get PBS Information & Configure System
# Author        :Juan Garcia
# Date          :05:05:2022
# Version       :4.0
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
# psql needs to be installed: sudo apt-get install postgresql-client -y
# lynx needs to be installed: sudo apt-get install lynx -y
# curl needs to be installed: sudo apt-get install curl -y
# pv needs to be installed: sudo apt-get install pv -y
# pdfgrep needs to be installed: sudo apt-get install pdfgrep -y
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
# 9. Sometimes when PBS logs are missing some information we use for our variables, it can cause the script to fail
#########################################################################################################

set -x

# Removing previous temp folder

rm -rf ix-tmp/

# This is the directories where the data we collect will go

mkdir ix-tmp
mkdir ix-tmp/SWQC
mkdir ix-tmp/CC

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>ix-tmp/CC-Person.txt
CCPERSON=$( ix-tmp/CC-Person.txt | tr "[:lower:]" "[:upper:]" )

# Collecting order number for systems

dialog --inputbox "Enter Order Number" 10 60 2>ix-tmp/ORDER-Num.txt
ORDER=$( ix-tmp/ORDER-Num.txt)

# Removing previous files

rm -rf "$ORDER"-CC-CONF.tar.gz "$ORDER"-CC-CONF/

clear


echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Header for CC report

{ echo "------------------------------------------";
printf "IXSYSTEMS INC. CLIENT CONFIGURATION REPORT\n";
printf "\n";
date;
echo -e "\n------------------------------------------\nCC PERSON:\n'$CCPERSON'\n\n------------------------------------------\n------------------------------------------\nORDER NUMBER:\n'$ORDER'\n\n------------------------------------------\n\n\n\n";
}  >> ix-tmp/"$ORDER"-REPORT.txt


# Grabbring serial number from IP.txt

FILE=IP.txt
SERIAL=""
exec 3<&0
exec 0<$FILE
while read -r line
do

SERIAL=$(echo "$line" | cut -d " " -f1)

touch ix-tmp/CC/"$ORDER"-PBS-OUTPUT.txt
touch ix-tmp/"$SERIAL"-Username.txt
touch ix-tmp/IP.txt


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Grabbing Burn-In information from PBS logs

curl -ks https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/ | tail -3 | head -1 | cut -c10-24 > ix-tmp/"$SERIAL"-DIR.txt

if ix-tmp/"$SERIAL"-DIR.txt | cut -d '"' -f1 | sed "s,/$,," | grep -F -wqi -e "Debug"; then
  curl -ks https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/ | tail -4 | head -1 | cut -c10-24 > ix-tmp/"$SERIAL"-DIR.txt
  PBSDIRECTORY=$( ix-tmp/"$SERIAL"-DIR.txt)
  curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

elif PBSDIRECTORY=$( ix-tmp/"$SERIAL"-DIR.txt); then
  echo "$PBSDIRECTORY" > ix-tmp/"$SERIAL"-DIR-CHECK.txt
  curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

fi

# Grabbing Passmark Log

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.cert.htm -o ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm
lynx --dump ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "TEST RUN" > ix-tmp/"$SERIAL"-Test-Run.txt
tr -s ' ' <  ix-tmp/"$SERIAL"-Test-Run.txt | cut -d ' ' -f 4 > ix-tmp/"$SERIAL"-PF.txt
PASSFAIL=$( ix-tmp/"$SERIAL"-PF.txt | xargs)

if [ "$PASSFAIL" == "PASSED" ]; then
  echo "[PASSED]" > ix-tmp/"$SERIAL"-Passed.txt
fi

PASSVER=$( ix-tmp/"$SERIAL"-Passed.txt)

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.htm -o ix-tmp/"$SERIAL"-PBS-Passmark_Log.htm
echo "https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/'$SERIAL'/'$PBSDIRECTORY'/Passmark_Log.cert.htm" > ix-tmp/"$SERIAL"-CERT.txt
CERT=$( ix-tmp/"$SERIAL"-CERT.txt)

# CPU presence check

lynx --dump ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' > ix-tmp/"$SERIAL"-CPU-Presence.txt
if ! [ -s ix-tmp/"$SERIAL"-CPU-Presence.txt ]; then
  echo "[NO CPU TEMP DETECTED]" > ix-tmp/"$SERIAL"-NO-CPU-Presence.txt
fi

NOCPUTEMP=$( ix-tmp/"$SERIAL"-NO-CPU-Presence.txt)

# CPU temp check

lynx --dump ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' | xargs > ix-tmp/"$SERIAL"-CPU-Temp.txt
ix-tmp/"$SERIAL"-CPU-Temp.txt | cut -d " " -f5 | cut -c 1-2 > ix-tmp/"$SERIAL"-CPU-Max.txt
read -r num < ix-tmp/"$SERIAL"-CPU-Max.txt
if [[ "$num" -gt 89 ]]; then
  echo "[CPU TEMP ABOVE THRESHOLD]" > ix-tmp/"$SERIAL"-CPU-Error.txt
else
  echo "[CPU TEMP OK]"
fi

CPUTEMP=$( ix-tmp/"$SERIAL"-CPU-Error.txt)

# Checking to ensure system ran with test disk

lynx --dump ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Disk (00)" > ix-tmp/"$SERIAL"-Disk00-pf.txt
DISK00PF=$( ix-tmp/"$SERIAL"-Disk00-pf.txt | xargs)

# Collecting test duration

lynx --dump ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Test Duration" > ix-tmp/"$SERIAL"-Test-Duration-pf.txt
TESTDURATION=$( ix-tmp/"$SERIAL"-Test-Duration-pf.txt | xargs)

# Collecting IPMI IP address

sed -e "s/\r//g" ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt > ix-tmp/"$SERIAL"-IPMI-Summary.txt

ix-tmp/"$SERIAL"-IPMI-Summary.txt | grep -E -i "IPv4 Address           : " | cut -d ":" -f2 > ix-tmp/"$SERIAL"-IPMI-IPAdddress.txt
IPMIIP=$( ix-tmp/"$SERIAL"-IPMI-IPAdddress.txt | xargs)

# Collecting IPMI MAC address

ix-tmp/"$SERIAL"-IPMI-Summary.txt | grep -E -i "BMC MAC Address        : " > ix-tmp/"$SERIAL"-IPMI-BMC-MAC.txt
tr -s ' ' <  ix-tmp/"$SERIAL"-IPMI-BMC-MAC.txt | cut -d ' ' -f 5  > ix-tmp/"$SERIAL"-BMC-MAC.txt
IPMIMAC=$( ix-tmp/"$SERIAL"-BMC-MAC.txt)

# Collecting STD info

psql -h std.ixsystems.com -U std2 -d std2 -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" > ix-tmp/"$SERIAL"-STD-Parts.txt
ix-tmp/"$SERIAL"-STD-Parts.txt | grep "Unique Password" | cut -d "|" -f3 | xargs > ix-tmp/"$SERIAL"-IPMI-Password.txt
IPMIPASSWORD=$( ix-tmp/"$SERIAL"-IPMI-Password.txt)

# Checking for break-out cable

ix-tmp/"$SERIAL"-STD-Parts.txt | grep -i Break > ix-tmp/"$SERIAL"-Network-Cable.txt

ix-tmp/"$SERIAL"-Network-Cable.txt | cut -d "|" -f1 > ix-tmp/"$SERIAL"-Network-Cable-CP.txt
ix-tmp/"$SERIAL"-Network-Cable.txt | cut -d "|" -f2 > ix-tmp/"$SERIAL"-Network-Cable-Model.txt
ix-tmp/"$SERIAL"-Network-Cable.txt | cut -d "|" -f3 > ix-tmp/"$SERIAL"-Network-Cable-Serial.txt

NETCABCP=$( ix-tmp/"$SERIAL"-Network-Cable-CP.txt)

if [ "$NETCABCP" == "Break" ]; then
  echo "[BREAK-OUT CABLE]" > ix-tmp/"$SERIAL"-Break-Out.txt
fi

BREAKOUT=$( ix-tmp/"$SERIAL"-Break-Out.txt)

# Checking for inlet temp

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_temperature.txt -o ix-tmp/"$SERIAL"-PBS-IPMI_Temperature.txt
ix-tmp/"$SERIAL"-PBS-IPMI_Temperature.txt | grep -i "Inlet Temp" | cut -d "|" -f1 > ix-tmp/Inlet.txt
if grep -q "OK" "ix-tmp/Inlet.txt" && [ -s ix-tmp/Inlet.txt ]; then
  echo "[INLET OK]" > ix-tmp/Inlet-warning.txt
elif ! grep -q "OK" "ix-tmp/Inlet.txt" && [ -s ix-tmp/Inlet.txt ]; then
  echo "[INLET TEMP NOT OK]" > ix-tmp/Inlet-warning.txt
fi

INLET=$( ix-tmp/Inlet-warning.txt)

# Getting motherboard manufacturer info

lynx --dump ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Motherboard manufacturer" > ix-tmp/"$SERIAL"-Motherboard-Manufacturer.txt
sed -e "s/\r//g" ix-tmp/"$SERIAL"-Motherboard-Manufacturer.txt | cut -d ' ' -f 6 > ix-tmp/"$SERIAL"-MBMAN.txt
MOTHERMAN=$( ix-tmp/"$SERIAL"-MBMAN.txt)

# Getting system model type

lynx --dump ix-tmp/"$SERIAL"-PBS-Passmark_Log.htm | grep -F "System Model:" > ix-tmp/"$SERIAL"-System-Model.txt
ix-tmp/"$SERIAL"-System-Model.txt | cut -d " " -f19 > ix-tmp/"$SERIAL"-Model-Type.txt
MODELTYPE=$( ix-tmp/"$SERIAL"-Model-Type.txt)

# Checking for wrong memory serial for TrueNAS systems

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/DIMM_MemoryChipData.txt -o ix-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt
ix-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt | grep -i 'XF' > ix-tmp/"$SERIAL"-Mem-Check.txt
MEMSERIALCHECK=$( ix-tmp/"$SERIAL"-Mem-Check.txt)

if echo "$MEMSERIALCHECK" | grep -F -wqi -e 'XF' ; then
    echo "[NVDIMM ERROR]" > ix-tmp/"$SERIAL"-Mem-Error.txt
else
    echo "[CORRECT NVDIMM]" 
fi

MEMERROR=$( ix-tmp/"$SERIAL"-Mem-Error.txt)

# Check for presence of QLOGIC fibre card

psql -h std.ixsystems.com -U std2 -d std2 -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" > ix-tmp/"$SERIAL"-STD-Parts.txt
ix-tmp/"$SERIAL"-STD-Parts.txt | grep -i QLE | cut -d "|" -f2 | grep -i -o -P '.{0,0}qle.{0,0}' > ix-tmp/"$SERIAL"-QLE-Output.txt

QLE=$( ix-tmp/"$SERIAL"-QLE-Output.txt)

if [ "$QLE" == "QLE" ]; then

  echo "QLOGIC-CARD-Present-Check-TrueNAS-License" > ix-tmp/"$SERIAL"-QLOGIC-Check.txt
  echo "[QLOGIC/FC]" > ix-tmp/"$SERIAL"-QLOGIC-msg.txt
  QLOGIC=$( ix-tmp/"$SERIAL"-QLOGIC-msg.txt)

fi


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Creating function for password check

function PWD-CHECK(){
  IPMIUSER=$( ix-tmp/"$SERIAL"-Username.txt)
  ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" lan print 1 > ix-tmp/"$SERIAL"-Passwd-Check.txt

  tr -s ' ' < ix-tmp/"$SERIAL"-Passwd-Check.txt | grep -i Complete | cut -d " " -f6 > ix-tmp/"$SERIAL"-PWC.txt
  PWC=$( ix-tmp/"$SERIAL"-PWC.txt)
}

# Creating function for verifying password change

function PWD-VERIFY(){

  if echo "$PWC" | grep -oh "\w*Complete\w*" | grep -F -wqi -e Complete; then
    echo "[PWD VERIFIED]" > ix-tmp/"$SERIAL"-PWD-Verified.txt
    PWDV=$( ix-tmp/"$SERIAL"-PWD-Verified.txt)

  fi
}


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Resetting Supermicro IPMI to default

if [ "$MOTHERMAN" == "Supermicro" ] && [[ -n "$IPMIPASSWORD" ]]; then
  echo "ADMIN" > ix-tmp/"$SERIAL"-Username.txt
  IPMIUSER=$( ix-tmp/"$SERIAL"-Username.txt)

  lynx --dump ix-tmp/"$SERIAL"-PBS-Passmark_Log.htm | grep -i "Motherboard Name:" | xargs | cut -d " " -f3 > ix-tmp/"$SERIAL"-Super.txt
  SUPER=$( ix-tmp/"$SERIAL"-Super.txt)

fi

if [ "$MOTHERMAN" == "Supermicro" ] && [[ -n "$IPMIPASSWORD" ]] && [ "$SUPER" == "A2SDi-H-TF" ]; then
  ipmitool -H "$IPMIIP" -U ADMIN -P ADMIN user set password 2 "$IPMIPASSWORD"

  sleep 1

  # Check password change completed

  PWD-CHECK
  PWD-VERIFY

elif [ "$MOTHERMAN" == "Supermicro" ] && [[ -n "$IPMIPASSWORD" ]]; then
  ipmitool -I lanplus -H "$IPMIIP" -U ADMIN -P ADMIN raw 0x3c 0x40

  yes | pv -SpeL1 -s 45 > /dev/null

  # Check password change completed

  PWD-CHECK
  PWD-VERIFY

fi

# Setting network and fan speeds to required settings

if [[ "$MODELTYPE" == @(TRUENAS-MINI-3.0-X+|TRUENAS-MINI-3.0-XL+|TRUENAS-MINI-R) ]]; then
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
  echo "<NETWORK: DEDICATED>" > ix-tmp/"$SERIAL"-Net-Change.txt
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x00 # Set fan to Standard
  echo "<FAN: STANDARD>" > ix-tmp/"$SERIAL"-Fan-Set.txt

elif [[ "$MODELTYPE" == @(TRUENAS-R10|TRUENAS-R40) ]]; then
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
  echo "<NETWORK: DEDICATED>" > ix-tmp/"$SERIAL"-Net-Change.txt
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x00 # Set fan to Standard
  echo "<FAN: STANDARD>" > ix-tmp/"$SERIAL"-Fan-Set.txt

elif [[ "$MODELTYPE" == @(TRUENAS-M30-S|TRUENAS-M30-HA|TRUENAS-M40-S|TRUENAS-M40-HA|TRUENAS-M50-S|TRUENAS-M50-HA|TRUENAS-M60-S|TRUENAS-M60-HA) ]]; then
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
  echo "<NETWORK: DEDICATED>" > ix-tmp/"$SERIAL"-Net-Change.txt
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x00 # Set fan to Standard
  echo "<FAN: STANDARD>" > ix-tmp/"$SERIAL"-Fan-Set.txt

elif [[ "$MODELTYPE" == @(TRUENAS-R20B) ]]; then
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
  echo "<NETWORK: DEDICATED>" > ix-tmp/"$SERIAL"-Net-Change.txt
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x04 # Set fan to Heavy IO
  echo "<FAN: HEAVY IO>" > ix-tmp/"$SERIAL"-Fan-Set.txt

elif [[ "$MODELTYPE" == @(TRUENAS-R50B) ]]; then
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
  echo "<NETWORK: DEDICATED>" > ix-tmp/"$SERIAL"-Net-Change.txt
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x01 # Set fan to Full Speed
  echo "<FAN: FULL SPEED>" > ix-tmp/"$SERIAL"-Fan-Set.txt

elif [[ "$MODELTYPE" == @(TRUENAS-R50BM) ]]; then
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x70 0x0c 1 0 # Set network to Dedicated
  echo "<NETWORK: DEDICATED>" > ix-tmp/"$SERIAL"-Net-Change.txt
  ipmitool -H "$IPMIIP" -U ADMIN -P "$IPMIPASSWORD" raw 0x30 0x45 0x01 0x02 # Set fan to Full Speed
  echo "<FAN: OPTIMAL>" > ix-tmp/"$SERIAL"-Fan-Set.txt

fi

# Setting fan threshold for TrueNAS MINI X+ & XL+

if [[ "$MODELTYPE" == @(TRUENAS-MINI-3.0-X+) ]]; then
  ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FANA lower 200 300 500
  echo "<FAN: THRESHOLD SET 200 300 500 (FANA)>" >> ix-tmp/"$SERIAL"-Fan-Set.txt

elif [[ "$MODELTYPE" == @(TRUENAS-MINI-3.0-XL+) ]]; then
  ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FANA lower 200 300 500
  ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN1 lower 200 300 500
  ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN2 lower 200 300 500
  echo "<FAN: THRESHOLD SET 200 300 500 (FANA,FAN1,FAN2)>" >> ix-tmp/"$SERIAL"-Fan-Set.txt

fi

# Setting fan threshold for TrueNAS-R20B

if [[ "$MODELTYPE" == @(TRUENAS-R20B) ]]; then
  ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN2 lower 100 200 200
  ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN3 lower 100 200 200
  ipmitool -I lanplus -U ADMIN -P "$IPMIPASSWORD" -H "$IPMIIP" sensor thresh FAN4 lower 100 200 200
  echo "<FAN: THRESHOLD SET 100 200 200 (FAN2,FAN3,FAN4)>" >> ix-tmp/"$SERIAL"-Fan-Set.txt

fi

NETSET=$( cat ix-tmp/"$SERIAL"-Net-Change.txt)
FANSET=$( cat ix-tmp/"$SERIAL"-Fan-Set.txt)


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Resetting ASUSTeK IPMI to default

if [ "$MOTHERMAN" == "ASUSTeK" ] && [[ -n "$IPMIPASSWORD" ]]; then
  echo "admin" > ix-tmp/"$SERIAL"-Username.txt
  IPMIUSER=$( ix-tmp/"$SERIAL"-Username.txt)

  ipmitool -I lanplus -H "$IPMIIP" -U admin -P administrator user set password 2 "$IPMIPASSWORD"
  sleep 1

  # Check password change completed

  PWD-CHECK
  PWD-VERIFY

fi

# Check for alternate default password

if ! [ -s ix-tmp/"$SERIAL"-Passwd-Check.txt ] && [[ -n "$IPMIPASSWORD" ]]; then
  ipmitool -I lanplus -H "$IPMIIP" -U admin -P admin user set password 2 "$IPMIPASSWORD" && PWD-CHECK && PWD-VERIFY

fi


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Resetting ASRockRack IPMI to default

if [ "$MOTHERMAN" == "ASRockRack" ] && [[ -n "$IPMIPASSWORD" ]]; then
  echo "admin" > ix-tmp/"$SERIAL"-Username.txt
  IPMIUSER=$( ix-tmp/"$SERIAL"-Username.txt)

  ipmitool -I lanplus -H "$IPMIIP" -U admin -P admin user set password 2 "$IPMIPASSWORD"
  sleep 1

  # Check password change completed

  PWD-CHECK
  PWD-VERIFY

fi


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Resetting GIGABYTE IPMI to default

if [ "$MOTHERMAN" == "GIGABYTE" ] && [[ -n "$IPMIPASSWORD" ]]; then
  echo "admin" > ix-tmp/"$SERIAL"-Username.txt
  IPMIUSER=$( ix-tmp/"$SERIAL"-Username.txt)

  ipmitool -I lanplus -H "$IPMIIP" -U admin -P password user set password 2 "$IPMIPASSWORD"
  sleep 1

  # Check password change completed

  PWD-CHECK
  PWD-VERIFY

fi

# Check for alternate default password

if ! [ -s ix-tmp/"$SERIAL"-Passwd-Check.txt ] && [[ -n "$IPMIPASSWORD" ]]; then
  ipmitool -I lanplus -H "$IPMIIP" -U admin -P administrator user set password 2 "$IPMIPASSWORD" && PWD-CHECK && PWD-VERIFY

fi


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ifconfig.txt -o ix-tmp/"$SERIAL"-PBS-IFCONFIG.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_powersupply_status.txt -o ix-tmp/"$SERIAL"-PBS-IPMI_Powersupply_Status.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_sel_list.txt -o ix-tmp/"$SERIAL"-PBS-IPMI_SEL_List.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_temperature.txt -o ix-tmp/"$SERIAL"-PBS-IPMI_Temperature.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_Bios.txt -o ix-tmp/"$SERIAL"-PBS-WMIC_BIOS.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/wmic_full_information.txt -o ix-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/DiskDrive_AllInformation.txt -o ix-tmp/"$SERIAL"-PBS-DiskDrive_AllInformation.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/DiskDrive_SerialNumbers.txt -o ix-tmp/"$SERIAL"-PBS-DiskDrive_SerialNumbers.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/Enclosures.txt -o ix-tmp/"$SERIAL"-PBS-Enclosures.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/IP_Address.txt -o ix-tmp/"$SERIAL"-PBS-IP_Address.txt


curl http://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/passmark_image.png -o ix-tmp/"$SERIAL"-PBS-Passmark_Image.png


echo "==========================================================================" >> ix-tmp/LINE-Output.txt

# Checking if OOB/DCMS license is needed (Must add work order to TMP folder)

pdgrep 'SFT-OOB-LIC' TMP/*.pdf | xargs | cut -d " " -f1 > ix-tmp/OOB-Check.txt

if grep -q "SFT-OOB-LIC" "ix-tmp/OOB-Check.txt"; then
  echo "[OOB LICENSE REQUIRED]" > ix-tmp/OOB-Alert.txt
fi

pdgrep 'SFT-DCMS-SINGLE' TMP/*.pdf | xargs | cut -d " " -f1 > ix-tmp/DCMS-Check.txt

if grep -q "SFT-DCMS-SINGLE" "ix-tmp/DCMS-Check.txt"; then
  echo "[DCMS LICENSE REQUIRED]" > ix-tmp/DCMS-Alert.txt
fi

SFTOOB=$( ix-tmp/OOB-Alert.txt)
SFTDCMS=$( ix-tmp/DCMS-Alert.txt)

# Grabbing parts lists for DIFF between systems

printf "==========================================================================\n\n" >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
touch ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
ix-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt | grep -E -i "product=" > ix-tmp/"$SERIAL"-Motherboard.txt
printf "[MOTHERBOARD]\n-------------\n\n" >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
ix-tmp/"$SERIAL"-Motherboard.txt | cut -d "=" -f2- >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
printf "\n" >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
printf "[CPU]\n-----\n\n" >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
lynx --dump ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "CPU type" | xargs >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
printf "\n\n" >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
printf "[MEMORY]\n--------\n\n" >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
sed -n -e '/Physical Memory Information:/,/CPU Information:/ p' ix-tmp/"$SERIAL"-PBS-WMIC_Full_Information.txt | head -n -1 >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
printf "[DRIVES]\n--------\n\n" >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
iconv -f UTF-16LE -t UTF-8 ix-tmp/"$SERIAL"-PBS-DiskDrive_SerialNumbers.txt >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt
printf "\n==========================================================================" >> ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt

# Grabbing Mellanox MAC address for SWQC/Asset List

touch ix-tmp/SWQC/MAC-ADDR-List.txt
echo -e "==========================================================================\n" >> ix-tmp/SWQC/MAC-ADDR-List.txt
echo -e "'$SERIAL' MELLANOX CHECK:\n------------------------\n\n" >> ix-tmp/SWQC/MAC-ADDR-List.txt
ix-tmp/"$SERIAL"-PBS-IFCONFIG.txt | grep -i -A3 -B1 mellanox | xargs -0 | sed 's/^ *//g' | sed "/A1-/! s/-//g" >> ix-tmp/SWQC/MAC-ADDR-List.txt
printf "\n==========================================================================\n" >> ix-tmp/SWQC/MAC-ADDR-List.txt
echo -e "'$SERIAL' IPMI:\n--------------\n\n" >> ix-tmp/SWQC/MAC-ADDR-List.txt
ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt | grep BMC | sed "s/://g" | sed "/A1-/! s/-//g" >> ix-tmp/SWQC/MAC-ADDR-List.txt
echo -e "\n==========================================================================\n" >> ix-tmp/SWQC/MAC-ADDR-List.txt
echo -e "'$SERIAL' ONBOARD NICS:\n----------------------\n\n" >> ix-tmp/SWQC/MAC-ADDR-List.txt
ix-tmp/"$SERIAL"-PBS-IFCONFIG.txt | grep -E -A5 -i --color '(Ethernet:|Ethernet 2:)' | xargs -0 | sed 's/^ *//g' | sed "/A1-/! s/-//g" >> ix-tmp/SWQC/MAC-ADDR-List.txt
echo -e "\n==========================================================================" >> ix-tmp/SWQC/MAC-ADDR-List.txt
#sed "/A1-/! s/-//g" ix-tmp/SWQC/MAC-ADDR-List.txt > ix-tmp/"$ORDER"-MELLANOX-LIST.txt

# MAC address list

touch ix-tmp/Full-MAC-ADDR-List.txt
printf "==========================================================================\n\n" >> ix-tmp/Full-MAC-ADDR-List.txt
echo -e "MAC ADDRESSES FOR '$SERIAL'\n--------------------------\n\n" >> ix-tmp/Full-MAC-ADDR-List.txt
ix-tmp/"$SERIAL"-PBS-IFCONFIG.txt | grep -E -iB5 "physical Address"| grep -E -iv " media disconnected| connection specific" | sed "/A1-/! s/-//g" >> ix-tmp/Full-MAC-ADDR-List.txt
printf "\n" >> ix-tmp/Full-MAC-ADDR-List.txt
ix-tmp/"$SERIAL"-PBS-IPMI_Summary.txt | grep -i BMC | sed "s/://g" | sed "/A1-/! s/-//g"  >> ix-tmp/Full-MAC-ADDR-List.txt
printf "\n" >> ix-tmp/Full-MAC-ADDR-List.txt
printf "==========================================================================\n" >> ix-tmp/Full-MAC-ADDR-List.txt
#sed "/A1-/! s/-//g" ix-tmp/Full-MAC-ADDR-List.txt >> ix-tmp/fixed-mac-address-list.txt
ix-tmp/Full-MAC-ADDR-List.txt | sed 's/^ *//g' > ix-tmp/SWQC/"$ORDER"-MAC-LIST.txt


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Grabbing SEL, SDR, & SENSOR info

yes | pv -SpeL1 -s 45 > /dev/null

if [[ -n "$IPMIPASSWORD" ]]; then
ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list > ix-tmp/"$SERIAL"-SEL-Data.txt
elif ! [ -s ix-tmp/"$SERIAL"-SEL-Data.txt ] && [[ -n "$IPMIPASSWORD" ]]; then
  ipmitool -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sel list > ix-tmp/"$SERIAL"-SEL-Data.txt
fi

if [[ -n "$IPMIPASSWORD" ]]; then
ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list > ix-tmp/"$SERIAL"-SDR-Data.txt
elif ! [ -s ix-tmp/"$SERIAL"-SDR-Data.txt ] && [[ -n "$IPMIPASSWORD" ]]; then
  ipmitool -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list > ix-tmp/"$SERIAL"-SDR-Data.txt
fi

if [[ -n "$IPMIPASSWORD" ]]; then
ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list > ix-tmp/"$SERIAL"-SENSOR-Data.txt
elif ! [ -s ix-tmp/"$SERIAL"-SENSOR-Data.txt ] && [[ -n "$IPMIPASSWORD" ]]; then
  ipmitool -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sensor list > ix-tmp/"$SERIAL"-SENSOR-Data.txt
fi

# Get line count for SDR OK

if [[ -n "$IPMIPASSWORD" ]]; then
ipmitool -I lanplus -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list | grep -ic ok > ix-tmp/"$SERIAL"-SDR-OK.txt
elif ! [ -s ix-tmp/"$SERIAL"-SDR-OK.txt ] && [[ -n "$IPMIPASSWORD" ]]; then
  ipmitool -H "$IPMIIP" -U "$IPMIUSER" -P "$IPMIPASSWORD" sdr list | grep -ic ok > ix-tmp/"$SERIAL"-SDR-OK.txt
fi

# Check for missing fans for IX-4224GP2-IXN model

if [[ "$MODELTYPE" == @(IX-4224GP2-IXN) ]]; then
  ix-tmp/"$SERIAL"-SDR-Data.txt | grep -i -v "FAN10" |  grep -i 'FAN[17]' > ix-tmp/"$SERIAL"-FAN-Data.txt

elif ix-tmp/"$SERIAL"-FAN-Data.txt | grep "no reading"; then
  echo "[CHECK FANS]" > ix-tmp/"$SERIAL"-FAN-Check.txt
fi

FANERROR=$( ix-tmp/"$SERIAL"-FAN-Check.txt)


# Dumping data to consolidate output file

echo "$SERIAL $IPMIIP $IPMIMAC $PASSFAIL $DISK00PF $TESTDURATION $FANERROR $MEMERROR $IPMIPASSWORD $PWDV $MOTHERMAN $MODELTYPE $BREAKOUT $CPUTEMP $NOCPUTEMP $QLOGIC $SFTOOB $SFTDCMS $INLET" | xargs >> ix-tmp/CC/"$ORDER"-PBS-OUTPUT.txt

echo -e "===========================================================================\nSERIAL NUMBER:\n'$SERIAL'\n\n===========================================================================\nIPMI IP:\n'$IPMIIP'\n\n===========================================================================\nIPMI USER:\n'$IPMIUSER'\n\n===========================================================================\nIPMI PASSWORD:\n'$IPMIPASSWORD'\n$PWDV\n\n===========================================================================\nIPMI MAC ADDRESS:\n$IPMIMAC\n\n===========================================================================\nBURN-IN RESULTS:\n$PASSVER\n$DISK00PF\n$TESTDURATION\n\n$CERT\n\n===========================================================================\nSYSTEM INFO:\n$MOTHERMAN\n$MODELTYPE \n\n===========================================================================\nCONFIGURATIONS:\n$NETSET\n$FANSET\n\n===========================================================================\nSYSTEM WARNINGS:\n$CPUTEMP\n$MEMERROR\n$NOCPUTEMP\n$BREAKOUT\n$QLOGIC\n$FANERROR\n$MINIEFANERROR\n$SFTOOB\n$SFTDCMS\n$INLET" >> ix-tmp/"$ORDER"-REPORT.txt
printf "\n\n------------------------------------END------------------------------------\n\n\n" >> ix-tmp/"$ORDER"-REPORT.txt

echo "$SERIAL $IPMIIP $IPMIUSER $IPMIPASSWORD $IPMIMAC" >> ix-tmp/IP.txt

done

# Creating CSV file for data transfer

tr -s " " < ix-tmp/IP.txt > ix-tmp/CC/"$ORDER"-IP.csv


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Creating GOLD file for diff

LINE=$(head -n 1 IP.txt)

cp ix-tmp/"$LINE"-SEL-Data.txt ix-tmp/SWQC/GOLD-SEL-Data.txt
cp ix-tmp/"$LINE"-SDR-Data.txt ix-tmp/SWQC/GOLD-SDR-Data.txt
cp ix-tmp/"$LINE"-SENSOR-Data.txt ix-tmp/SWQC/GOLD-SENSOR-Data.txt
cp ix-tmp/SWQC/"$LINE"-PARTS-List.txt ix-tmp/SWQC/GOLD-PARTS-List.txt
cp ix-tmp/"$LINE"-SDR-OK.txt ix-tmp/SWQC/GOLD-SDR-OK.txt

# Diffing each system for errors

FILE=IP.txt
SERIAL=""
exec 3<&0
exec 0<$FILE
while read -r line
do
  SERIAL=$(echo "$line" | cut -d " " -f 1)

  echo "------------------------------------------------------'$SERIAL'------------------------------------------------------" >> ix-tmp/SWQC/"$ORDER"-SEL-DIFF.txt
  diff -y -W 200 --suppress-common-lines ix-tmp/SWQC/GOLD-SEL-Data.txt ix-tmp/"$SERIAL"-SEL-Data.txt >> ix-tmp/SWQC/"$ORDER"-SEL-DIFF.txt

  echo "------------------------------------------------------'$SERIAL'------------------------------------------------------" >> ix-tmp/SWQC/"$ORDER"-SDR-DIFF.txt
  diff -y -W 200 --suppress-common-lines ix-tmp/SWQC/GOLD-SDR-Data.txt ix-tmp/"$SERIAL"-SDR-Data.txt >> ix-tmp/SWQC/"$ORDER"-SDR-DIFF.txt

  echo "------------------------------------------------------'$SERIAL'------------------------------------------------------" >> ix-tmp/SWQC/"$ORDER"-SENSOR-DIFF.txt
  diff -y -W 200 --suppress-common-lines ix-tmp/SWQC/GOLD-SENSOR-Data.txt ix-tmp/"$SERIAL"-SENSOR-Data.txt >> ix-tmp/SWQC/"$ORDER"-SENSOR-DIFF.txt

  echo "------------------------------------------------------'$SERIAL'------------------------------------------------------" >> ix-tmp/SWQC/"$ORDER"-PARTS-DIFF.txt
  diff -y -W 200 --suppress-common-lines ix-tmp/SWQC/GOLD-PARTS-List.txt ix-tmp/SWQC/"$SERIAL"-PARTS-List.txt >> ix-tmp/SWQC/"$ORDER"-PARTS-DIFF.txt

  echo "------------------------------------------------------'$SERIAL'------------------------------------------------------" >> ix-tmp/SWQC/"$ORDER"-SDR-OK-DIFF.txt
  diff -y -W 200 --suppress-common-lines ix-tmp/SWQC/GOLD-SDR-OK.txt ix-tmp/"$SERIAL"-SDR-OK.txt >> ix-tmp/SWQC/"$ORDER"-SDR-OK-DIFF.txt

done


echo "=====================================END=====================================" >> ix-tmp/LINE-Output.txt


cp ix-tmp/SWQC/GOLD-SDR-Data.txt ix-tmp/CC
cp ix-tmp/SWQC/"$ORDER"-SDR-DIFF.txt ix-tmp/CC
mv ix-tmp/"$SERIAL"-QLOGIC-Check.txt ix-tmp/SWQC
mv ix-tmp/SWQC/MAC-ADDR-List.txt ix-tmp/SWQC/"$ORDER"-MELLANOX-LIST.txt
mv ix-tmp/"$ORDER"-REPORT.txt ix-tmp/CC
mv ix-tmp "$ORDER"-CC-CONF
rm -rf TMP/*.pdf

# Compress output file

tar cfz "$ORDER-CC-CONF.tar.gz" "$ORDER"-CC-CONF/

exit
