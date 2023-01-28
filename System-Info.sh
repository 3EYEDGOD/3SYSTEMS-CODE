#!/bin/bash
# Title         :System-Info.sh
# Description   :Get PBS information & system configuration
# Author        :Juan Garcia
# Date          :10:09:2022
# Version       :2.0
#########################################################################################################
# DEPENDENCIES:
#
# psql needs to be installed: sudo apt-get install postgresql-client-common -y
# lynx needs to be installed: sudo apt-get install lynx -y
# curl needs to be installed: sudo apt-get install curl -y
# cifs-utils needs to be installed: sudo apt-get install cifs-utils -y
#########################################################################################################

# Making temp file
# This is the directory where the data we collect will go

set -x

cd /tmp

mkdir -p ix-tmp/RESULTS
touch /tmp/ix-tmp/system-output.txt

# Header for CC report

echo "------------------------------------------" >> /tmp/ix-tmp/system-output.txt
printf "SYSTEM OUTPUT\n" >> /tmp/ix-tmp/system-output.txt
echo "------------------------------------------" /tmp/ix-tmp/system-output.txt
printf "\n" >> /tmp/ix-tmp/system-output.txt
date >> /tmp/ix-tmp/system-output.txt
printf "\n------------------------------------------\n" >> /tmp/ix-tmp/system-output.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt

echo "SERIAL NUMBER:" >> /tmp/ix-tmp/system-output.txt
dmidecode -t1 | grep -i serial | cut -c17-24 >> /tmp/ix-tmp/serialnumber-output.txt

SERIAL=$( cat /tmp/ix-tmp/serialnumber-output.txt)

echo ""$SERIAL"" >> /tmp/ix-tmp/system-output.txt

echo "System-Serial is "$SERIAL""

echo ""$SERIAL"" > /tmp/ix-tmp/system-serial-output.txt

touch /tmp/ix-tmp/"$SERIAL"-PBS-output.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt

echo "PASSMARK INFO:" >> /tmp/ix-tmp/system-output.txt

# Grabbing Burn-In information from PBS logs

curl -ks https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/ | tail -3 | head -1 | cut -c10-24 > /tmp/ix-tmp/"$SERIAL"-dir.txt

if $(cat /tmp/ix-tmp/"$SERIAL"-dir.txt | cut -d '"' -f1 | sed "s,/$,," | grep -F -wqi -e "Debug"); then
  curl -ks https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/ | tail -4 | head -1 | cut -c10-24 > /tmp/ix-tmp/"$SERIAL"-dir.txt
  PBSDIRECTORY=$(cat /tmp/ix-tmp/"$SERIAL"-dir.txt)
  curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-ipmi_summary.txt

elif PBSDIRECTORY=$(cat /tmp/ix-tmp/"$SERIAL"-dir.txt); then
  echo ""$PBSDIRECTORY"" > /tmp/ix-tmp/test1.txt
  curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_summary.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-ipmi_summary.txt

fi

# Grabbing Passmark Log

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.cert.htm -o /tmp/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm
lynx --dump /tmp/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "TEST RUN" > /tmp/ix-tmp/"$SERIAL"-test-run.txt
tr -s ' ' <  /tmp/ix-tmp/"$SERIAL"-test-run.txt | cut -d ' ' -f 4 > /tmp/ix-tmp/"$SERIAL"-pf.txt

PASSFAIL=$(cat /tmp/ix-tmp/"$SERIAL"-pf.txt)

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/Passmark_Log.htm -o /tmp/ix-tmp/"$SERIAL"-PBS-Passmark_Log.htm

# CPU presence check

lynx --dump /tmp/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' > /tmp/ix-tmp/"$SERIAL"-CPU-presence.txt
if ! [ -s /tmp/ix-tmp/"$SERIAL"-CPU-presence.txt ]; then
  echo "[NO CPU TEMP DETECTED]" > /tmp/ix-tmp/"$SERIAL"-NO-CPU-presence.txt
fi

NOCPUTEMP=$(cat /tmp/ix-tmp/"$SERIAL"-NO-CPU-presence.txt)

# CPU temp check

lynx --dump /tmp/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -E -i 'CPU 0|CPU 1' > /tmp/ix-tmp/"$SERIAL"-CPU-temp.txt
cat /tmp/ix-tmp/"$SERIAL"-CPU-temp.txt | xargs | cut -d " " -f6 | cut -c 1-2 > /tmp/ix-tmp/"$SERIAL"-CPU-max.txt
read -r num < /tmp/ix-tmp/"$SERIAL"-CPU-max.txt
if [[ "$num" -gt 89 ]]; then
  echo "[CPU TEMP ABOVE THRESHOLD]" > /tmp/ix-tmp/"$SERIAL"-CPU-error.txt
else
  echo "[CPU TEMP OK]" > /tmp/ix-tmp/"$SERIAL"-CPU-error.txt
fi

CPUTEMP=$(cat /tmp/ix-tmp/"$SERIAL"-CPU-error.txt)

# Checking to ensure system ran with test disk

lynx --dump /tmp/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Disk (00)" > /tmp/ix-tmp/"$SERIAL"-disk00-pf.txt
DISK00PF=$(cat /tmp/ix-tmp/"$SERIAL"-disk00-pf.txt)

# Collects test duration

lynx --dump /tmp/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Test Duration" > /tmp/ix-tmp/"$SERIAL"-testduration-pf.txt
TESTDURATION=$(cat /tmp/ix-tmp/"$SERIAL"-testduration-pf.txt)

echo "$PASSFAIL $DISK00PF $TESTDURATION" | xargs >> /tmp/ix-tmp/system-output.txt

echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt

# Collect IPMI IP address

sed -e "s/\r//g" /tmp/ix-tmp/"$SERIAL"-PBS-ipmi_summary.txt > /tmp/ix-tmp/"$SERIAL"-ipmi-sum.txt

cat /tmp/ix-tmp/"$SERIAL"-ipmi-sum.txt | grep -E -i "IPv4 Address           : " | cut -d ":" -f2 > /tmp/ix-tmp/"$SERIAL"-ipmi-ipadddress.txt
IPMIIP=$(cat /tmp/ix-tmp/"$SERIAL"-ipmi-ipadddress.txt)
echo "IPMI IP:" >> /tmp/ix-tmp/system-output.txt
echo ""$IPMIIP""  >> /tmp/ix-tmp/system-output.txt

echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt

# Collect IPMI MAC address

cat /tmp/ix-tmp/"$SERIAL"-ipmi-sum.txt | grep -E -i "BMC MAC Address        : " > /tmp/ix-tmp/"$SERIAL"-ipmi-bmc-mac.txt
tr -s ' ' <  /tmp/ix-tmp/"$SERIAL"-ipmi-bmc-mac.txt | cut -d ' ' -f 5  > /tmp/ix-tmp/"$SERIAL"-bmc-mac.txt
IPMIMAC=$(cat /tmp/ix-tmp/"$SERIAL"-bmc-mac.txt)

# Collecting STD info

psql -h std.ixsystems.com -U std2 -d std2 -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '"$SERIAL"' order by b.system_serial, a.type_id, a.model, a.serial;" > /tmp/ix-tmp/"$SERIAL"-std-parts.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i "IPMI Password" | cut -d "|" -f2-3 | tr -d "|"  > /tmp/ix-tmp/"$SERIAL"-ipmi-password.txt
tr -s ' ' < /tmp/ix-tmp/"$SERIAL"-ipmi-password.txt | cut -d ' ' -f4 > /tmp/ix-tmp/"$SERIAL"-ipmi-pw.txt
IPMIPASSWORD=$(cat /tmp/ix-tmp/"$SERIAL"-ipmi-pw.txt)

# Checking for break-out cable

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i cable > /tmp/ix-tmp/"$SERIAL"-networkcable.txt

cat /tmp/ix-tmp/"$SERIAL"-networkcable.txt | cut -d "|" -f1 > /tmp/ix-tmp/"$SERIAL"-networkcable-cp.txt
cat /tmp/ix-tmp/"$SERIAL"-networkcable.txt | cut -d "|" -f2 > /tmp/ix-tmp/"$SERIAL"-networkcable-model.txt
cat /tmp/ix-tmp/"$SERIAL"-networkcable.txt | cut -d "|" -f3 > /tmp/ix-tmp/"$SERIAL"-networkcable-serial.txt

NETCABCP=$(cat /tmp/ix-tmp/"$SERIAL"-networkcable-cp.txt)
NETCABMODEL=$(cat /tmp/ix-tmp/"$SERIAL"-networkcable-model.txt)
NETCABSERIAL=$(cat /tmp/ix-tmp/"$SERIAL"-networkcable-serial.txt)

if $(echo $NETCABCP | grep -oh "\w*CABLE\w*" | grep -F -wqi -e CABLE); then
  echo "Network Cable $NETCABMODEL Present Check If NIC Is Configure For Break Out" >> /tmp/ix-tmp/system-output.txt
  echo "[BREAK-OUT CABLE]" > /tmp/ix-tmp/"$SERIAL"-break-out.txt
fi

BREAKOUT=$(cat /tmp/ix-tmp/"$SERIAL"-break-out.txt)

echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt

echo "MOTHERBOARD INFO:" >> /tmp/ix-tmp/system-output.txt

# Getting motherboard manufacturer info

lynx --dump /tmp/ix-tmp/"$SERIAL"-PBS-Passmark_Log.cert.htm | grep -F "Motherboard manufacturer" > /tmp/ix-tmp/"$SERIAL"-motherboard-manufacturer.txt

sed -e "s/\r//g" /tmp/ix-tmp/"$SERIAL"-motherboard-manufacturer.txt | cut -d ' ' -f 6 > /tmp/ix-tmp/"$SERIAL"-mbman.txt
MOTHERMAN=$(cat /tmp/ix-tmp/"$SERIAL"-mbman.txt)
echo "$MOTHERMAN"  >> /tmp/ix-tmp/system-output.txt

# Getting system model type

lynx --dump /tmp/ix-tmp/"$SERIAL"-PBS-Passmark_Log.htm | grep -F "System Model:" > /tmp/ix-tmp/"$SERIAL"-system-model.txt
cat /tmp/ix-tmp/"$SERIAL"-system-model.txt | cut -d " " -f19 > /tmp/ix-tmp/"$SERIAL"-model-type.txt
MODELTYPE=$(cat /tmp/ix-tmp/"$SERIAL"-model-type.txt)
echo "$MODELTYPE" >> /tmp/ix-tmp/system-output.txt

echo "=========================================================================="

# Checking for wrong memory serial for TrueNAS systems

curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/DIMM_MemoryChipData.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt
cat /tmp/ix-tmp/"$SERIAL"-PBS-DIMM_MemoryChipData.txt | grep -i 'XF' > /tmp/ix-tmp/"$SERIAL"-Mem-Check.txt
MEMSERIALCHECK=$(cat /tmp/ix-tmp/"$SERIAL"-Mem-Check.txt)
if $(echo "$MEMSERIALCHECK" | grep -F -wqi -e 'XF' ); then
    echo "[NVDIMM ERROR]" > /tmp/ix-tmp/Mem-Error.txt
else
    echo "[CORRECT NVDIMM]" > /tmp/ix-tmp/Mem-Error.txt
fi
MEMERROR=$(cat /tmp/ix-tmp/Mem-Error.txt)


# Check for presence of QLOGIC fibre card

psql -h std.ixsystems.com -U std2 -d std2 -c "select c.name, a.model, a.serial, a.rma, a.revision, a.support_number from production_part a, production_system b, production_type c, production_configuration d where a.system_id = b.id and a.type_id = c.id and b.config_name_id = d.id and b.system_serial = '"$SERIAL"' order by b.system_serial, a.type_id, a.model, a.serial;" > /tmp/ix-tmp/"$SERIAL"-std-parts.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i QLE | cut -d "|" -f2 | grep -i -o -P '.{0,0}qle.{0,0}' > /tmp/ix-tmp/"$SERIAL"-qle-output.txt

QLE=$(cat /tmp/ix-tmp/"$SERIAL"-qle-output.txt)

if $(echo "$QLE"|grep -F -wqi -e QLE ); then

echo "QLOGIC-CARD-Present-Check-TrueNAS-License" > /tmp/ix-tmp/"$SERIAL"-qlogic-check.txt
echo "[QLOGIC/FC]" > /tmp/ix-tmp/"$SERIAL"-qlogic-msg.txt
QLOGIC=$(cat /tmp/ix-tmp/"$SERIAL"-qlogic-msg.txt)

fi


echo "=========================================================================="


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ifconfig.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-ifconfig.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_powersupply_status.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-ipmi_powersupply_status.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_sel_list.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-ipmi_SEL_list.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/ipmi_temperature.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-ipmi_temperature.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/WMIC_Bios.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-WMIC_Bios.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/wmic_full_information.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-wmic_full_information.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/DiskDrive_AllInformation.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-DiskDrive_AllInformation.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/DiskDrive_SerialNumbers.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-DiskDrive_SerialNumbers.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/Enclosures.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-Enclosures.txt


curl https://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/IP_Address.txt -o /tmp/ix-tmp/"$SERIAL"-PBS-IP_Address.txt


curl http://archive.pbs.ixsystems.net/pbsv4/pbs_logs/"$SERIAL"/"$PBSDIRECTORY"/passmark_image.png -o /tmp/ix-tmp/"$SERIAL"-PBS-passmark_image.png

# Grabbing SEL, SDR, & SENSOR info

touch /tmp/ix-tmp/smb-verified.txt
touch /tmp/ix-tmp/system-output.txt


echo "=========================================================================="


# Set up non persistent cif share for CC and SWQC of systems

echo "Setting up temp cifs mount then share to swqc-output folder on sj-storage"

# Create the mount-point folder and mount the share:

mkdir /mnt/sj-storage

mount -t cifs -o username=root,password=abcd1234 //10.246.0.110/sj-storage/ /mnt/sj-storage/

# Verifying sj-storage is mounted:

cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt >> /tmp/ix-tmp/smb-verified.txt


echo "=========================================================================="


echo ""$SERIAL" "$IPMIIP" $IPMIMAC $PASSFAIL $DISK00PF $TESTDURATION $FANERROR $MEMERROR "$IPMIPASSWORD" $PWDV $MOTHERMAN $MODELTYPE $BREAKOUT $CPUTEMP $NOCPUTEMP $MINIEFANERROR $QLOGIC" | xargs > /tmp/ix-tmp/"$SERIAL"-PBS-output.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


echo "SYSTEM RELEASE INFO:"  >> /tmp/ix-tmp/system-output.txt
cat /etc/*-release >> /tmp/ix-tmp/system-output.txt
cat /etc/*-release >> /tmp/ix-tmp/release-output.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Get pretty version of Linux

echo "LINUX VERSION: " >> /tmp/ix-tmp/system-output.txt

cat /etc/os-release | grep -i pretty >> /tmp/ix-tmp/system-output.txt
cat /etc/os-release | grep -i pretty > /tmp/ix-tmp/pretty.txt

PRETTY=$(cat /tmp/ix-tmp/pretty.txt)


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Collecting BIOS version

echo "BIOS VERSION: " >> /tmp/ix-tmp/system-output.txt

dmidecode -t bios info | grep -i version >> /tmp/ix-tmp/system-output.txt
dmidecode -t bios info | grep -i version > /tmp/ix-tmp/biosver-output.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Get CPU info

echo "CPU INFO: " >> /tmp/ix-tmp/system-output.txt

dmidecode -t processor | grep -E -i 'cpu|manufacturer|serial|size|speed|core|version|manufactuer' >> /tmp/ix-tmp/system-output.txt
dmidecode -t processor | grep -E -i 'cpu|manufacturer|serial|size|speed|core|version|manufactuer' > /tmp/ix-tmp/processor.txt

for cpus in `dmidecode -t4 | awk '/Handle / {print $2}'`; do
   echo `dmidecode -t4 | sed '/Flags/,/Version/d' | grep -E -A20 "Handle ${cpus}" | grep -m 1 "Socket Designation" | grep -o '.\{0,0\}:.\{0,18\}' | tr -d '\:| '`; >> /tmp/ix-tmp/system-output.txt
   echo `dmidecode -t4 | sed '/Flags/,/Version/d' | grep -E -A20 "Handle ${cpus}" | grep -m 1 "Family" | grep -o '.\{0,0\}:.\{0,18\}' | tr -d '\:| '`; >> /tmp/ix-tmp/system-output.txt
   echo `dmidecode -t4 | sed '/Flags/,/Version/d' | grep -E -A20 "Handle ${cpus}" | grep -m 1 "Manufacturer" | grep -o '.\{0,0\}:.\{0,18\}' | tr -d '\:| '`; >> /tmp/ix-tmp/system-output.txt
   echo `dmidecode -t4 | sed '/Flags/,/Version/d' | grep -E -A20 "Handle ${cpus}" | grep -m 1 "Current Speed" | grep -o '.\{0,0\}:.\{0,18\}' | tr -d '\:| '`; >> /tmp/ix-tmp/system-output.txt
   echo `dmidecode -t4 | sed '/Flags/,/Version/d' | grep -E -A20 "Handle ${cpus}" | grep -m 1 "Voltage" | grep -o '.\{0,0\}:.\{0,18\}' | tr -d '\:| '`; >> /tmp/ix-tmp/system-output.txt
   echo `dmidecode -t4 | sed '/Flags/,/Version/d' | grep -E -A20 "Handle ${cpus}" | grep -m 1 "Core Count" | grep -o '.\{0,0\}:.\{0,18\}' | tr -d '\:| '`; >> /tmp/ix-tmp/system-output.txt
done

PROCESSOR=$(cat /tmp/ix-tmp/processor.txt)


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


echo "COLLECTING NIC CARD INFO: " >> /tmp/ix-tmp/system-output.txt

# Check NICs

dmesg | grep -E -i 'Ethernet|Network' >> /tmp/ix-tmp/system-output.txt
dmesg | grep -E -i 'Ethernet|Network' > /tmp/ix-tmp/nicinfo.txt

NICS=$(cat /tmp/ix-tmp/nicinfo.txt)

ip addr >> /tmp/ix-tmp/system-output.txt
ip addr > /tmp/ix-tmp/ipadress.txt

IPADDRESS=$(cat /tmp/ix-tmp/ipadress.txt)


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Confirm memory count

echo "MEMORY INFO: " >> /tmp/ix-tmp/system-output.txt

dmidecode -t memory | grep -E -i 'manufacturer|serial|size|speed|locator' | grep -i hynix | wc -l >> /tmp/ix-tmp/system-output.txt
dmidecode -t memory | grep -E -i 'manufacturer|serial|size|speed|locator' | grep -i hynix | wc -l > /tmp/ix-tmp/mem.txt

MEMINFO=$(cat  /tmp/ix-tmp/mem.txt)

echo "POPULATION, TYPE, SPEED, AND SIZE:" >> /tmp/ix-tmp/system-output.txt

dmidecode -t memory | grep -E "(^\s+Locator:|Speed|Manufacturer:|^\s+Volatile Size:)" | cut -d: -f2 | pr -at5 -s, >> /tmp/ix-tmp/system-output.txt
dmidecode -t memory | grep -E "(^\s+Locator:|Speed|Manufacturer:|^\s+Volatile Size:)" | cut -d: -f2 | pr -at5 -s, >> /tmp/ix-tmp/volatile-memsize.txt

VOLATILEMEMSIZE=$(cat /tmp/ix-tmp/volatile-memsize.txt)

echo "MEMORY SIZE OS: " >> /tmp/ix-tmp/system-output.txt

free | grep Mem | awk '{print $2}' >> /tmp/ix-tmp/system-output.txt
free | grep Mem | awk '{print $2}' >> /tmp/ix-tmp/MEMSIZEOS.txt

MEMSIZEOS=$(cat /tmp/ix-tmp/MEMSIZEOS.txt)

echo "Expected Output: 528232384" >> /tmp/ix-tmp/system-output.txt

echo "ECC ERRORS:" >> /tmp/ix-tmp/system-output.txt

ipmitool sel list | grep -c "Correctable ECC" >> /tmp/ix-tmp/system-output.txt
ipmitool sel list | grep -c "Correctable ECC" >> /tmp/ix-tmp/ecc-errors.txt

ECCERRORS=$(cat /tmp/ix-tmp/ecc-errors.txt)


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


echo "DIMM INFO:" >> /tmp/ix-tmp/system-output.txt

for memoryid in `dmidecode -t17 | awk '/Handle / {print $2}' | tr -d ','`; do
   populated=`dmidecode -t17 | grep -A17 "Handle ${memoryid}" | awk '/Size:/ {print $2, $3}'`;
   if [[ "$populated" != "No Module" ]]; then echo `dmidecode -t17 | grep -A17 "Handle ${memoryid}" | awk '/Locator:/ {print $2}' | head -1`;
   echo `dmidecode -t17 | grep -A17 "Handle ${memoryid}" | awk '/Size:/ {print $2, $3}'`; >> /tmp/ix-tmp/system-output.txt
   echo `dmidecode -t17 | grep -A17 "Handle ${memoryid}" | awk '/Speed:/ {print $2, $3}'`; >> /tmp/ix-tmp/system-output.txt
   echo `dmidecode -t17 | grep -A17 "Handle ${memoryid}" | awk '/Type:/ {print $2, $3}'`; >> /tmp/ix-tmp/system-output.txt
   echo `dmidecode -t17 | grep -A17 "Handle ${memoryid}" | awk '/Serial Number:/ {print $3}'`; >> /tmp/ix-tmp/system-output.txt
   echo `dmidecode -t17 | grep -A17 "Handle ${memoryid}" | awk '/Part Number:/ {print $3}'`; >> /tmp/ix-tmp/system-output.txt
   echo `/n`; >> /tmp/ix-tmp/system-output.txt
fi
done


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt

# Check SEL entries

echo "NO 3.3V SEL ENTRIES:" >> /tmp/ix-tmp/system-output.txt

ipmitool sel list | grep -E -c "Voltage #0x54" >> /tmp/ix-tmp/system-output.txt
ipmitool sel list | grep -E -c "Voltage #0x54" >> /tmp/ix-tmp/voltage-selerrors.txt

VOLTAGESEL=$(cat /tmp/ix-tmp/voltage-selerrors.txt)

echo "Expected Output Is 0" >> /tmp/ix-tmp/system-output.txt

# Check For PCIe Errors In SEL

echo "CHECK FOR PCIe ERRORS IN SEL:" >> /tmp/ix-tmp/system-output.txt

ipmitool sel list | grep -c "PCI PERR | Asserted" >> /tmp/ix-tmp/system-output.txt
ipmitool sel list | grep -c "PCI PERR | Asserted" >> /tmp/ix-tmp/pci-selerrors.txt

PCISELERRORS=$(cat /tmp/ix-tmp/pci-selerrors.txt)

echo "Expected Output Is 0" >> /tmp/ix-tmp/system-output.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Check hard drives

echo "DRIVE INFORMATION:" >> /tmp/ix-tmp/system-output.txt

lsblk >> /tmp/ix-tmp/system-output.txt
lsblk > /tmp/ix-tmp/lsblk-output.txt

DRIVEINFO=$(cat /tmp/ix-tmp/lsblk-output.txt)


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Check state of SMT

echo "CHECK THE STATE OF SMT:" >> /tmp/ix-tmp/system-output.txt

cat /sys/devices/system/cpu/smt/active # Checks if SMT (multi threading ) is enbled # Expected output is a nuber such as 1 or 2 as many as you have CPU
cat /sys/devices/system/cpu/smt/active > /tmp/ix-tmp/tmpinfo.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Check for legacy BIOW vs UEFI-Mode

echo "CHECK FOR LEGACY BIOS vs UEFI-MODE:" >> /tmp/ix-tmp/system-output.txt

# Checking from which drive you boot

df -h / >> /tmp/ix-tmp/system-output.txt # find out what disks you are booting from and if it has MBR partitioning
df -h / > /tmp/ix-tmp/mbrpart-check.txt

# Expected Output: Filesystem... /dev/nvme0n1p2

MBRPARTCHK=$(cat /tmp/ix-tmp/mbrpart-check.txt)

# Checking boot drive for DOS/MBR partitioning

echo "CHECKINING BOOT DRIVE FOR DOS/MBR PARTITIONING:" >> /tmp/ix-tmp/system-output.txt

file -s /dev/nvme0n1 >> /tmp/ix-tmp/system-output.txt
file -s /dev/nvme0n1 > /tmp/ix-tmp/partioncheck.txt

# Expected Output: /dev/nvme0n1: DOS/MBR boot sector, extended partition table (last)

PARTIONCHECK=$(cat /tmp/ix-tmp/partioncheck.txt)

# Check if linux kernel has EFI variables

echo "CHECK IF LINUX KERNEL HAS EFI VARIABLES:" >> /tmp/ix-tmp/system-output.txt

echo "Expected Output If EFI Not Enabled: no such file or directory" >> /tmp/ix-tmp/system-output.txt

ls /sys/firmware/efi >> /tmp/ix-tmp/system-output.txt
ls /sys/firmware/efi > /tmp/ix-tmp/efiinfo-out.txt # Expected Output: no such file or directory if efi not enabled

echo "Expected Output If UEFI is enabled: config_table  efivars  esrt runtime  runtime-map  systab  vars" >> /tmp/ix-tmp/system-output.txt

dmidecode | grep -i legacy >> /tmp/ix-tmp/system-output.txt # Expected Output: USB legacy is supported
dmidecode | grep -i legacy > /tmp/ix-tmp/usbleg-output.txt

USBLEG=$(cat /tmp/ix-tmp/usbleg-output.txt)


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Collecting SEL info

echo "COLLECTING SEL INFO:" >> /tmp/ix-tmp/system-output.txt

ipmitool sel list >> /tmp/ix-tmp/system-output.txt
ipmitool sel list > /tmp/ix-tmp/sel-output.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Collecting SDR info

echo "COLLECTING SDR INFO:" >> /tmp/ix-tmp/system-output.txt

ipmitool sdr list >> /tmp/ix-tmp/system-output.txt
ipmitool sdr list > /tmp/ix-tmp/sdr-output.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Collecting ipmitool sensor info

echo "COLLECTING IPMITOOL SENSOR INFO:" >> /tmp/ix-tmp/system-output.txt

ipmitool sensor list >> /tmp/ix-tmp/system-output.txt
ipmitool sensor list > /tmp/ix-tmp/sensor-output.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Collecting PSU info

echo "PSU INFO:" >> /tmp/ix-tmp/system-output.txt

ipmitool sensor list | grep '^PS' >> /tmp/ix-tmp/system-output.txt
ipmitool sensor list | grep '^PS' > /tmp/ix-tmp/psu-output.txt

# Collecting PSU status

echo "PSU STATUS:" >> /tmp/ix-tmp/system-output.txt

ipmitool sensor list | grep PSU.\*Status | cut -d\| -f1-3 >> /tmp/ix-tmp/system-output.txt
ipmitool sensor list | grep PSU.\*Status | cut -d\| -f1-3 >> /tmp/ix-tmp/psustatus.txt

PSUSTATUS=$(cat /tmp/ix-tmp/psustatus.txt)


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Collecting PMBUS status

echo "PMBUS STATUS:" >> /tmp/ix-tmp/system-output.txt

ipmitool dcmi power reading >> /tmp/ix-tmp/system-output.txt
ipmitool dcmi power reading | grep state | cut -d: -f2 >> /tmp/ix-tmp/pmbus-state.txt

PMBUSSTATE=$(cat /tmp/ix-tmp/pmbus-state.txt)


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Collecting BMC firmware

echo "COLLECTING BMC FIRMWARE:" >> /tmp/ix-tmp/system-output.txt

ipmitool bmc info | grep -i firmware >> /tmp/ix-tmp/system-output.txt
ipmitool bmc info | grep -i firmware > /tmp/ix-tmp/bmc-firmware.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Lists harware and arranges it using sed for a more user friendly view

printf "COLLECTING HARDWARE TYPE/VENDOR:\n\n\n" > /tmp/ix-tmp/"$SERIAL"-HARDWARE.txt

lshw | grep -A2 description | sed 's/-//g' | xargs -0 | sed 's/^ *//g' | sed 's/^$/----------------------------------------------/g' | sed 's/description/DESCRIPTION/g' | sed 's/^/\n\n/g' >> /tmp/ix-tmp/"$SERIAL"-HARDWARE.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Item Breakdown and count

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i motherboard >> /tmp/ix-tmp/STD-"$SERIAL"-motherboard.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i motherboard | wc -l >> /tmp/ix-tmp/STD-"$SERIAL"-motherboard-count.txt
MBCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-motherboard-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i cpu  >> /tmp/ix-tmp/STD-"$SERIAL"-cpu.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i cpu |wc -l  >> /tmp/ix-tmp/STD-"$SERIAL"-cpu-count.txt
CPUCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-cpu-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i memory >> /tmp/ix-tmp/STD-"$SERIAL"-memory.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i memory | cut -d "|" -f6 | tr -d 'PCS' >> /tmp/ix-tmp/STD-"$SERIAL"-memory-count.txt
MEMCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-memory-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i NIC >> /tmp/ix-tmp/STD-"$SERIAL"-addon-nic.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i NIC | wc -l >> /tmp/ix-tmp/STD-"$SERIAL"-addon-nic-count.txt
NICCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-addon-nic-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i SFP >> /tmp/ix-tmp/STD-"$SERIAL"-sfp.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i SFP| wc -l >> /tmp/ix-tmp/STD-"$SERIAL"-sfp-count.txt
SFPCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-sfp-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i HBA >> /tmp/ix-tmp/STD-"$SERIAL"-hba.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i HBA| wc -l >>  /tmp/ix-tmp/STD-"$SERIAL"-hba-count.txt
HBACOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-hba-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i NTB >> /tmp/ix-tmp/STD-"$SERIAL"-ntb.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i NTB| wc -l >>  /tmp/ix-tmp/STD-"$SERIAL"-ntb-count.txt
NTBCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-ntb-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i SSD  >> /tmp/ix-tmp/STD-"$SERIAL"-ssd.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt | grep -i SSD | wc -l >> /tmp/ix-tmp/STD-"$SERIAL"-ssd-count.txt
SSDCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-ssd-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt |grep -i "power supply" >> /tmp/ix-tmp/STD-"$SERIAL"-pws.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt |grep -i "power supply" | wc -l  >> /tmp/ix-tmp/STD-"$SERIAL"-pws-count.txt
PWSCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-pws-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt |grep -i "SataDom" >> /tmp/ix-tmp/STD-"$SERIAL"-SataDom.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt |grep -i "SataDom" | wc -l  >> /tmp/ix-tmp/STD-"$SERIAL"-SataDom-count.txt
SATADOMCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-SataDom-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt |grep -i HD >> /tmp/ix-tmp/STD-"$SERIAL"-HD.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt |grep -i HD | wc -l  >> /tmp/ix-tmp/STD-"$SERIAL"-HD-count.txt
HDCOUNT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-HD-count.txt)

cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt |grep -i CacheVault >> /tmp/ix-tmp/STD-"$SERIAL"-CacheVault.txt
cat /tmp/ix-tmp/"$SERIAL"-std-parts.txt |grep -i CacheVault | wc -l  >> /tmp/ix-tmp/STD-"$SERIAL"-CacheVault-count.txt
CACHEVAULT=$(cat /tmp/ix-tmp/STD-"$SERIAL"-CacheVault-count.txt)

touch /tmp/ix-tmp/"$SERIAL"-STD.txt

echo "STD Parts List" > /tmp/ix-tmp/STD-"$SERIAL"-list.txt
printf "Motherboard count\n$MBCOUNT\nCPU Count\n$CPUCOUNT\nMEM Count\n$MEMCOUNT\nNIC Count\n $NICCOUNT\nSFP Count\n$SFPCOUNT\nHBA Count\n$HBACOUNT\nNTB Count\n$NTBCOUNT\nSSD Count\n$SSDCOUNT\nPWS Count\n$PWSCOUNT\nSATA DOM Count\n$SATADOMCOUNT\nHD Count\n$HDCOUNT\nCacheVault\n$CACHEVAULT" | xargs -0 | sed 's/^ *//g' >> /tmp/ix-tmp/"$SERIAL"-STD.txt

echo "Motherboard count : $MBCOUNT : CPU Count : $CPUCOUNT : MEM Count : $MEMCOUNT : NIC Count :  $NICCOUNT : SFP Count : $SFPCOUNT : HBA Count : $HBACOUNT : NTB Count : $NTBCOUNT : SSD Count : $SSDCOUNT : PWS Count : $PWSCOUNT : SATA DOM Count : $SATADOMCOUNT : HD Count : $HDCOUNT : CacheVault : $CACHEVAULT" >> /tmp/ix-tmp/"$SERIAL"-STD-straight.txt


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Compress output file ix-tmp SCP it to megabeast

DATETIME=$(date '+%m%d%Y%I%M%p')

cd /tmp

mv /tmp/ix-tmp/system-output.txt /tmp/ix-tmp/"$SERIAL"-SYSTEM-OUTPUT-$DATETIME.txt
cp /tmp/ix-tmp/"$SERIAL"-SYSTEM-OUTPUT-$DATETIME.txt /tmp/ix-tmp/RESULTS/"$SERIAL"-SYSTEM-OUTPUT-$DATETIME.txt
cp /tmp/ix-tmp/"$SERIAL"-HARDWARE.txt /tmp/ix-tmp/RESULTS/"$SERIAL"-HARDWARE-$DATETIME.txt
cp /tmp/ix-tmp/"$SERIAL"-STD.txt /tmp/ix-tmp/RESULTS/"$SERIAL"-STD-$DATETIME.txt


tar cfz ""$SERIAL"-SYSTEM-INFO-$DATETIME.tar.gz" ix-tmp


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


echo "Copying tar.gz file To swqc-output On sj-storage"

cd /tmp

cp *.tar.gz /mnt/sj-storage/swqc-output/


echo "Finished Copying tar.gz File To swqc-output On sj-storage"


echo "==========================================================================" >> /tmp/ix-tmp/system-output.txt


# Removing files

rm -rf /tmp/ix-tmp
rm -rf "$SERIAL"-SYSTEM-INFO-$DATETIME.tar.gz

exit
