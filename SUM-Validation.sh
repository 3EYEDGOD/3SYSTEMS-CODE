#!/bin/bash
# Title         :SUM-Validation.sh
# Description   :Grabs Current BIOS Configuration & Various Systems Info
# Author        :Juan Garcia
# Date          :04:27:2022
# Version       :0.1
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
# ipmitool needs to be installed: sudo apt-get install ipmitool -y
# Supermicro SUM tool (Linux version) needs to be installed with script running in the SUM tool directory
#########################################################################################################
# TROUBLESHOOTING IF SCRIPT DOES NOT WORK:
#
# 1. Check IP ensure it's correct.
# 2. Ensure IP is pingable.
# 3. Reboot the sytsem you are on and try again.
# 4. Try from different system.
# 5. If script uses ssh try to manualy ssh into the system the IP may have an old key in the system that the script is running from. You may need to get rid of that ssh key.
# 6. The byte order mark (BOM) may be set. Vi File.txt after entering your information you will see an ^M. Uncheck byte order mark in your txt editor. Re-enter info.
# 7. In your txt editor go to tools and change End of line to Unix.
# 8. When inputing serials on ip.txt leave a blank line at end of document otherwise last line won't be read.
#########################################################################################################


#set -x

# Removing previous temp folder

rm -rf val-tmp/

# This is the directory where the data we collect will go

mkdir val-tmp

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2> val-tmp/cc-person.txt

# Collecting order number

dialog --inputbox "Enter Order Number" 10 60 2> val-tmp/ordertemp.txt
ORDER=$(cat val-tmp/ordertemp.txt)

# Removing previous files

rm -rf "$ORDER"-SUM-VAL.tar.gz "$ORDER"-SUM-VAL/


echo "==========================================================================" >> val-tmp/LINE-Output.txt


mkdir val-tmp/bios-files
mkdir val-tmp/event-logs
touch val-tmp/field1-output.txt
touch val-tmp/field2-output.txt
touch val-tmp/field3-output.txt
touch val-tmp/field4-output.txt

FILE=File.txt
SERIAL=""
IP=""
USER=""
PASSWORD=""
exec 3<&0
exec 0<$FILE
while read -r line
do
SERIAL=$(echo "$line" | cut -d " " -f 1)
IP=$(echo "$line" | cut -d " " -f 2)
USER=$(echo "$line" | cut -d " " -f 3)
PASSWORD=$(echo "$line" | cut -d " " -f 4)

echo "$IP" > val-tmp/field1-output.txt
echo "IP is $IP"
echo "$USER" > val-tmp/field2-output.txt
echo "USER is $USER"
echo "$PASSWORD" > val-tmp/field3-output.txt
echo "PASSWORD is $PASSWORD"
echo "$SERIAL" > val-tmp/field4-output.txt
echo "SERIAL is $SERIAL"

# Grabbing system BIOS configuration & event logs


echo "==========================================================================" >> val-tmp/LINE-Output.txt


printf "\nRetreiving BIOS Configuration\n"
echo -e "------------------------------\n\n"

./sum -i "$IP" -u "$USER" -p "$PASSWORD" -c GetCurrentBiosCfg --file "bioscfg-$ORDER-$SERIAL-$IP"
mv -i bioscfg-"$ORDER"-"$SERIAL"-"$IP" val-tmp/bios-files

printf "\nRetreiving Event Logs\n"
echo -e "----------------------\n\n"

./sum -i "$IP" -u "$USER" -p "$PASSWORD" -c GetEventLog --file "eventlog-$ORDER-$SERIAL-$IP"
mv -i eventlog-"$ORDER"-"$SERIAL"-"$IP" val-tmp/event-logs

printf "\nFinished Collecting Event Log And BIOS Configs\n"
printf "-----------------------------------------------\n"


echo "==========================================================================" >> val-tmp/LINE-Output.txt


printf "\n--------"
echo -e "$SERIAL"
printf "--------\n\n"

# Gathering system information & boot to BIOS

ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" power cycle

yes | pv -SpeL1 -s 45 > /dev/null


./sum -i "$IP" -u "$USER" -p "$PASSWORD" -C GetDmiInfo  > val-tmp/"$ORDER"-DMI-Info-Data-"$SERIAL"-"$IP".txt
printf "\nCollected DMI Info\n"
echo -e "--------------------"
ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" raw 0x30 0x03
printf "Reset Chassis Intrusion\n"
echo -e "------------------------\n"
ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" sdr list > val-tmp/"$ORDER"-Sensor-Via-IPMI-Data-"$SERIAL"-"$IP".txt
printf "Collected SDR List Info\n"
echo -e "------------------------\n"
./sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckSensorData > val-tmp/"$ORDER"-Sensor-Data-"$SERIAL"-"$IP".txt
printf "Collected Sensor Data\n"
echo -e "----------------------\n"
./sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckAssetInfo > val-tmp/"$ORDER"-CheckAssetInfo-Data-"$SERIAL"-"$IP".txt
printf "Checked Asset Info\n"
echo -e "-------------------\n"
ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" bmc info > val-tmp/"$ORDER"-BMC-Via-ipmitool-Data-"$SERIAL"-"$IP".txt
printf "Gathered BMC Info\n"
echo -e "------------------\n"
./sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckAssetInfo | grep -E -i 'MAC Address' > val-tmp/"$ORDER"-MAC-Address-Data-"$SERIAL"-"$IP".txt
printf "Retrieved MAC Address\n"
echo -e "----------------------\n"
./sum -i "$IP" -u "$USER" -p "$PASSWORD" -C QueryProductKey > val-tmp/"$ORDER"-Query-Product-Key-Data-"$SERIAL"-"$IP".txt
printf "Getting Product Key\n"
echo -e "--------------------\n"
ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" sdr type 'Power Supply' > val-tmp/"$ORDER"-SDR-Type-Power-Supply-Data-"$SERIAL"-"$IP".txt
printf "Looked At Power Supply\n"
echo -e "-----------------------\n"
./sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckOOBSupport  > val-tmp/"$ORDER"-OOB-Support-Check-Data-"$SERIAL"-"$IP".txt
printf "Checked OOB Support\n"
echo -e "--------------------\n"
ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" sel list > val-tmp/"$ORDER"-SEL-List-Data-"$SERIAL"-"$IP".txt
printf "Retreived SEL List\n"
echo -e "-------------------\n"
ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" sensor list | grep -i 'FAN[1458]' > val-tmp/"$ORDER"-FAN-REMOVAL-Fan-Check-Via-IPMI-Data-"$SERIAL"-"$IP".txt
printf "Checked 'FAN[1458]'\n"
echo -e "--------------------\n"

# OOB/DCMS license check

{ printf "==========================================================================\n\n";
echo -e "Verifying OOB/DCMS Keys For $SERIAL \n\n";
./sum -i "$IP" -u "$USER" -p "$PASSWORD" -C QueryProductKey;
printf "\n\n--------------------------------------------------------------------------\n\n";
./sum -i "$IP" -u "$USER" -p "$PASSWORD" -C CheckOOBSupport;
printf "\n\n==========================================================================\n\n";
} >> val-tmp/"$ORDER"-OOB-DCMS-LICENSE.txt
printf "\nClearing SEL List\n"
echo -e "------------------\n\n"
ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" sel clear
printf "\nPower Cycle System\n"
echo -e "-------------------\n\n"
ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" chassis power cycle
printf "\nBoot To BIOS\n"
echo -e "-------------\n\n"
ipmitool -H "$IP" -U "$USER" -P "$PASSWORD" chassis bootparam set bootflag force_bios
printf "\n\n"

done

mv val-tmp "$ORDER"-SUM-VAL

# Compress output file

tar cfz "$ORDER-SUM-VAL.tar.gz" "$ORDER"-SUM-VAL/

exit

