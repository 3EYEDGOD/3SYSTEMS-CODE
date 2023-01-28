#!/bin/bash -x
# Title         :BIOS.Default.sh
# Description   :Set BIOS to Default settings
# Author        :Juan Garcia
# Date          :04:20:2022
# Version       :0.1
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
# psql needs to be installed: sudo apt-get install postgresql-client-common -y
# lynx needs to be installed: sudo apt-get install lynx -y
# curl needs to be installed: sudo apt-get install curl -y
# Supermicro SUM tool (Linux version) needs to be installed with script running in the SUM tool directory
#
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

# Removing previous temp folder

rm -rf bios-tmp/

# This is the directory where the data we collect will go

mkdir bios-tmp

# Collecting name of person performing CC

dialog --inputbox "Enter The Name Of The Person Performing CC Here" 10 60 2>bios-tmp/CC-Person.txt

# Collecting order number for HRT systems

dialog --inputbox "Enter Order Number" 10 60 2>bios-tmp/ORDER-Num.txt

ORDER=$( cat bios-tmp/ORDER-Num.txt)

# Removing previous files

rm -rf "$ORDER"-BIOS-DEFAULT.tar.gz "$ORDER"-BIOS-DEFAULT/


{ echo "==========================================================================";
echo "ORDER INFORMATION";
echo "Order Number: $ORDER";
echo "==========================================================================";
} >> bios-tmp/LINE-Output.txt

clear

FILE=IP.txt
SERIAL=""
exec 3<&0
exec 0<$FILE
while read -r line
do
SERIAL=$(echo "$line" | cut -d " " -f 1)

echo "$IP" >> bios-tmp/LINE-Output.txt

echo "IP.txt field1 is $SERIAL"
echo "$SERIAL" > bios-tmp/LINE-Output.txt


echo "==========================================================================" >> bios-tmp/LINE-Output.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.cert.htm -o bios-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm

curl -ks https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/ | tail -3 | head -1 | cut -c10-24 > bios-tmp/"$SERIAL"-DIR.txt
if bios-tmp/"$SERIAL"-DIR.txt | cut -d '"' -f1 | sed "s,/$,," | grep -F -wqi -e "Debug"; then
  curl -ks https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/ | tail -4 | head -1 | cut -c10-24 > bios-tmp/"$SERIAL"-DIR.txt
  PBSDIRECTORY=$(cat bios-tmp/"$SERIAL"-DIR.txt)

  curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o bios-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

elif PBSDIRECTORY=$(cat bios-tmp/"$SERIAL"-DIR.txt); then
  echo "$PBSDIRECTORY" > bios-tmp/"$SERIAL"-DIR-CHECK.txt
  curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o bios-tmp/"$SERIAL"-PBS-IPMI_Summary.txt

fi


# Collect IPMI IP address

sed -e "s/\r//g" bios-tmp/"$SERIAL"-PBS-IPMI_Summary.txt > bios-tmp/"$SERIAL"-IPMI-SUM.txt

bios-tmp/"$SERIAL"-IPMI-SUM.txt| grep -E -i "IPv4 Address           : "|cut -d ":" -f2 > bios-tmp/"$SERIAL"-IPMI-IP-ADDR.txt
IPMIIP=$(bios-tmp/"$SERIAL"-IPMI-IP-ADDR.txt | xargs)

# Collecting STD info

psql -h std.ixsystems.com -U std2 -d std2 -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '$SERIAL' order by b.system_serial, a.type_id, a.model, a.serial;" > bios-tmp/"$SERIAL"-STD-Parts.txt
bios-tmp/"$SERIAL"-STD-Parts.txt | grep -i "IPMI Password"| cut -d "|" -f2-3 | tr -d "|"  > bios-tmp/"$SERIAL"-IPMI-Password.txt
tr -s ' ' < bios-tmp/"$SERIAL"-IPMI-Password.txt | cut -d ' ' -f4 > bios-tmp/"$SERIAL"-IPMI-PWD.txt
IPMIPASSWORD=$(cat bios-tmp/"$SERIAL"-IPMI-PWD.txt)

# Reseting BIOS to optimized defaults

./sum  -i "$IPMIIP" -u ADMIN -p "$IPMIPASSWORD" -C LoadDefaultBiosCfg > bios-tmp/"$SERIAL"-BIOS-Default.txt

# Check BIOS change completed

tr -s ' ' < bios-tmp/"$SERIAL"-BIOS-Default.txt | grep -i loaded > bios-tmp/"$SERIAL"-BIOS-Reset.txt
BIOSDEFAULT=$(bios-tmp/"$SERIAL"-BIOS-Reset.txt)


# Verify BIOS changed

if echo "$BIOSDEFAULT" | grep -oh "\w*loaded\w*"| grep -F -wqi -e "loaded"; then
  echo "BIOS Reset Successful" > bios-tmp/BIOS-Verified.txt
  BIOSV=$(cat bios-tmp/BIOS-Verified.txt)

fi


# Dumping data to consolidated output file

echo "$SERIAL $IPMIIP $BIOSV" | xargs >> bios-tmp/"$ORDER"-BIOS-Output.txt

done

mv bios-tmp "$ORDER"-BIOS-DEFAULT

# Compress output file

tar cfz "$ORDER-BIOS-DEFAULT.tar.gz" "$ORDER"-BIOS-DEFAULT/

exit
