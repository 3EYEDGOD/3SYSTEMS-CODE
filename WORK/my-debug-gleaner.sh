#!/bin/sh
# title			:mytest.sh
# description		:SWQC check of systems using sum and ipmi
# author		:Jason Browne
# date			:07:30:2021
# version		: 0.1
################################################################################
# 
################################################################################
#
# Dependencies:
# unbuntu dialog needs to be installed sudo apt-get install -y dialog
# Supermicro SUM tool needs to be installed with script running in the sum tool directory
# 
#
# Making temp file for swqc check txt
# This is directory where the data we collect will go
#
mkdir swqc-tmp 
touch swqc-tmp/warning.txt
touch swqc-tmp/smart-test-output.txt
touch swqc-tmp/productname.txt
touch swqc-tmp/diff-comp.txt
touch swqc-tmp/order-breakdown.txt
touch swqc-tmp/swqc-output.txt
#
#
#
#Collecting Name of Person performing SWQC
#
dialog --inputbox "Enter The Name of the Person Performing SWQC here" 10 60 2>swqc-tmp/swqc-person.txt
#
SWQCPERSON=$( cat swqc-tmp/swqc-person.txt) 
#
# echo "Hello $SWQCPERSON"
#
#
#
# Collecting Order Number for MINI
#
#
# echo “Enter Order Number”
#
dialog --inputbox "Enter Order Number" 10 60 2>swqc-tmp/ordertemp.txt
#
ORDER=$( cat swqc-tmp/ordertemp.txt ) 
#
# cat swqc-tmp/ordertemp.txt >> swqc-tmp/swqc-output.txt
#
#
# echo “Your entered $ORDER”
#
#
#
echo "-------------------------------------------" >> swqc-tmp/swqc-output.txt
#
#
echo "Order information for TrueNAS System" >> swqc-tmp/swqc-output.txt
#
echo "Order Number: $ORDER" >> swqc-tmp/swqc-output.txt
#
#
# 
tar -xf debug*
ls *.txz > buglist.txt
 mkdir a b
mv ixdiagnose a
mv *1.txz a
mv *a.txz a
mv *A.txz a
mv *pri.txz a
mv  *01.txz a
mv *s.txz a
mv *3.txz a
mv *C1*.txz a
mv *2.txz b
mv *b.txz b
mv *B.txz b
mv *sec.txz b
mv *02.txz b
mv *b.txz b
mv *4.txz b
mv *C2*.txz b
cd a
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
echo "nodea checkpont 1" > nodea-checkpoint1.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
touch nodea-diffme.txt
echo "Diff Sheet" >> nodea-diffme.txt
tar -xf *.txz
cat ixdiagnose/dmidecode| grep -iA2 "System information" | grep -i "Product Name" > nodea-productname.txt
cat ixdiagnose/dmidecode| grep -iA2 "System information" | grep -i "Product Name" > ../swqc-tmp/productname.txt
echo "Product Name"  >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -iA2 "System information" | grep -i "Product Name"  >> nodea-diffme.txt
echo "Product Version"  >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -iA3 "System information" | grep -i version| cut -d " " -f2  >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -iA3 "System information" | grep -i version| cut -d " " -f2 > nodea-productversion.txt
cat ixdiagnose/sysctl_hw | grep -i hw.physmem: > nodea-sys-physmem.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Physical Memory:" > nodea-hw-physmem.txt
cat ixdiagnose/fndebug/ZFS/dump.txt |awk '/zpool status /,/debug finished/' > bootpool-nodea.txt
cat ixdiagnose/fndebug/System/dump.txt |awk '/Alert System @/,/seconds for Alert System/' > nodea-alert.txts
cat ixdiagnose/log/messages |grep -iC6 MCA | grep -i error > nodea-mca-errors.txt
cat ixdiagnose/version > nodea-version.txt
echo "TrueNAS Version" >> nodea-diffme.txt
cat nodea-version.txt >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -iA2 "Bios Information" | grep -i version > nodea-bios-version.txt
cat ixdiagnose/fndebug/IPMI/dump.txt| grep -i "firmware Revision" > nodea-ipmi-firmware.txt   
cat ixdiagnose/fndebug/SMART/dump.txt | grep -iB1 revision > nodea-disk-info.txt
cat ixdiagnose/fndebug/SMART/dump.txt|grep -i temperature | grep -i current > nodea-drivetemp-output.txt
cat ixdiagnose/syslog/failover.log >> failnodea-output.txt
#cat ixdiagnose/fndebug/Geom/dump.txt | awk '/gpart status @/,/debug finished/' | egrep -iv "glabel|----|name|debug|pmem*|*p3|*p2" | wc -l > nodea-diskcount.txt
cat ixdiagnose/fndebug/Geom/dump.txt | awk '/gpart status @/,/debug finished/'| egrep -iv "glabel|----|name|debug|pmem*|*p3|*p2"  | grep -iv gpart | wc -l > nodea-diskcount.txt
cat ixdiagnose/fndebug/Geom/dump.txt | awk '/glabel status @/,/debug finished/' | egrep -iv "glabel|----|name|debug|pmem*" > nodea-disks.txt
echo "drive count"  >> nodea-diffme.txt
cat nodea-diskcount.txt  >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt | egrep -i 'Enclosure Name|Enclosure ID|Enclosure Status' > nodea-enclousre.txt
cat ixdiagnose/fndebug/System/dump.txt |awk '/License @/,/Illuminated License/' > nodea-license.txt
echo "TrueNAS License" >> nodea-diffme.txt
cat ixdiagnose/fndebug/System/dump.txt |awk '/License @/,/Illuminated License/' | grep -i "License @" | wc -l >> nodea-diffme.txt
echo "Workorder shows the following support level" >> nodea-diffme.txt
pdfgrep 'SUP-' ../*.pdf | cut -d "-" -f3-4 >> nodea-diffme.txt

cat ixdiagnose/fndebug/SMART/dump.txt| egrep -i 'vendor:|Product:|Revision:|Number:|Status:|Current:|grown defect list:' > nodea-drivestatantmp.txt
echo "SMART Health Status" >> nodea-diffme.txt
cat nodea-drivestatantmp.txt| grep -i "SMART Health Status:" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/SMART/dump.txt | egrep -i read: | tr -s ' ' | cut -d " " -f 8 > nodea-uncor-write-drive-errors.txt
cat ixdiagnose/fndebug/SMART/dump.txt | egrep -i write: | tr -s ' ' | cut -d " " -f 8 > nodea-uncor-read-drive-errors.txt
cat ixdiagnose/fndebug/Network/dump.txt |awk '/ Interfaces @/,/debug finished in/' > nodea-interfaces.txt
cat ixdiagnose/fndebug/Network/dump.txt |awk '/ Interfaces marked critical for failover @/,/debug finished in/' > nodea-crit4fail.txt

cat nodea-interfaces.txt | grep -iv "+*+" | egrep -iv "lo0|pflog0|debug|ntb0|ue0|0.0.0.0" | sed 's/[ \t].*//;/^$/d'| wc -l > nodea-portcount.txt
cat nodea-interfaces.txt | grep -iv "+*+" | egrep -iv "lo0|pflog0|debug|ntb0|ue0|0.0.0.0" | sed 's/[ \t].*//;/^$/d' > nodea-ports.txt
echo "Port count" >> nodea-diffme.txt
cat nodea-interfaces.txt | grep -iv "+*+" | egrep -iv "lo0|pflog0|debug|ntb0|ue0|0.0.0.0" | sed 's/[ \t].*//;/^$/d'|wc -l >> nodea-diffme.txt
NODEAPC=$(cat nodea-portcount.txt)
NABIOV=$(cat nodea-bios-version.txt)
NABMCINFO=$(cat nodea-ipmi-firmware.txt)
PRODUCTNA=$(cat nodea-productname.txt)
NAC4F=$(cat nodea-crit4fail.txt)
#
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
echo "nodea checkpont 2" > nodea-checkpoint2.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
##
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(echo "$NABIOV" | grep -oh "\w*1.3.V1\w*"| fgrep -wqi -e 1.3.V1); then
echo "BIOS Version for Product Name: TRUENAS-MINI-3.0-XL+ is correctly showing as $NABIOV it should be  1.3.V1" > nodea-Mini-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be  1.3.V1" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(echo "$NABIOV" | grep -oh "\1.3.V1\w*" != 1.3.V1); then
#
echo "BIOS Version for Product Name: TRUENAS-MINI-3.0-XL+ is showing as $NABIOV it should be  1.3.V1" > nodea-MINI-bios-version.txt
echo "BIOS Version for Product Name: TRUENAS-MINI-3.0-XL+ is showing as $NABIOV it should be  1.3.V1" >> swqc-tmp/warning.txt
echo "BIOS Version for Product Name: TRUENAS-MINI-3.0-XL+ is showing as $NABIOV it should be  1.3.V1" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  1.3.V1" >> nodea-diffme.txt
#
fi
#
#
#

#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && (echo "$NABMCINFO" | grep -oh "\w*3.60\w*"| fgrep -wqi -e 3.60); then
echo "BMC firmware for Product Name: TRUENAS-MINI-3.0-XL+ is correctly showing as $NABMCINFO it should be 1.71" > nodea-MINI-bmc.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "Correctly showing as $NABMCINFO it should be 3.60" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(echo "$NABMCINFO" | grep -oh "\1.71\w*" != 1.71); then
#
echo "BMC firmware for Product Name: TRUENAS-MINI-3.0-XL+ is showing as $NABMCINFO it should be 3.60" > nodea-MINI-bmc.txt
echo "BMC firmware for Product Name: TRUENAS-MINI-3.0-XL+ is showing as $NABMCINFO it should be 3.60" >> swqc-tmp/warning.txt
echo "BMC firmware for Product Name: TRUENAS-MINI-3.0-XL+ is showing as $NABMCINFO it should be 3.60" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware is $NABMCINFO it should be 3.60" >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ); then
#
echo "Memory count TrueNAS MINI" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A2K40BB1-CRC | wc -l > nodea-r20_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A2K40BB1-CRC | wc -l >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ); then
#
echo "Fan Check" >> nodea-diffme.txt
cat ixdiagnose/fndebug/IPMI/dump.txt| awk '/ ipmitool sel elist && ipmitool sdr elist @/,/Chassis Intru  /' |  egrep -i "FAN[123A]" > nodea-MINI_fancheck.txt
cat ixdiagnose/fndebug/IPMI/dump.txt| awk '/ ipmitool sel elist && ipmitool sdr elist @/,/Chassis Intru  /' |  egrep -i "FAN[123A]" >> nodea-diffme.txt
echo "FAN Thresholds" >> nodea-diffme.txt
cat ixdiagnose/fndebug/IPMI/dump.txt| awk '/ipmitool sensor @/,/debug finished in /' |  egrep -i "FAN[123A]" > MINIXLPLUS-fanthreshold.txt 
cat MINIXLPLUS-fanthreshold.txt | cut -d "|" -f1-7 >> nodea-diffme.txt
#
#
#| egrep -iv "glabel|----|name|debug|pmem*" 
fi
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i  X553/x557 | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO count" >> nodea-diffme.txt
#
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" )&& $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*QLE2692-SR-CK\w*"| fgrep -wqi -e QLE2692-SR-CK); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "QLE2692-SR-CK" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*X710\w*"| fgrep -wqi -e X710); then
echo "Add on nic card X710T4BLK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "X710" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| grep -oh "\w*SFP-10GSR-85\w*"| fgrep -wqi -e SFP-10GSR-85); then
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10GSR-85 >> nodea-10g-sfpcount.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| grep -oh "\w*SM10G-SR\w*"| fgrep -wqi -e SM10G-SR); then
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfpcount.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | grep -i 25GBASE-SR | grep -iv media| grep -oh "\w*25GBASE-SR\w*"| fgrep -wqi -e 25GBASE-SR); then
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i 25GBASE-SR | grep -iv media >> nodea-25g-sfpcount.txt
cat nodea-25g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "Product Name: TRUENAS-MINI-3.0-XL+" ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*Power Supply State:\w*"| fgrep -wqi -e "Power Supply State:"); then
echo "Power supply State" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" >> nodea-powersupply-list.txt
#
#
fi
#
#
#
#
#
#
################################################
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA| fgrep -wqi -e X4F16QG8BNTDME-7-CA); then
#
echo "Memory count TrueNAS X10-HA" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA | wc -l > nodea-X10_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA > nodea-X10_memory_list.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA | wc -l >> nodea-diffme.txt
echo "Physical Memory" >> nodea-diffme.txt
grep "Physical Memory" < nodea-hw-physmem.txt | awk '{print $3, $4}' >> nodea-diffme.txt
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA1| fgrep -wqi -e X4F16QG8BNTDME-7-CA1); then
#
echo "Memory count TrueNAS X10-HA" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA1 | wc -l > nodea-X10_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA1 > nodea-X10_memory_list.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA1 | wc -l >> nodea-diffme.txt
echo "Physical Memory" >> nodea-diffme.txt
grep "Physical Memory" < nodea-hw-physmem.txt | awk '{print $3, $4}' >> nodea-diffme.txt
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt| grep -oh "\w*I210\w*"| fgrep -wqi -e I210); then
echo "1G Onboard Nic Count" >> nodea-diffme.txt 
touch nodea-onboard-1gb-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt | grep -i I210 | wc -l  >> nodea-onboard-1gb-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt | grep -i I210  >> nodea-onboard-1gb-nic-list.txt
cat nodea-onboard-1gb-nic-count.txt >> nodea-diffme.txt
NODEAONB1GBNIC=$(cat nodea-onboard-1gb-nic-count.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*I350\w*"| fgrep -wqi -e I350); then
echo "Add on nic card I350 count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "I350" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "I350" | wc -l >> nodea-1g-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "I350" >> nodea-1g-nic-list.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-25g-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" >> nodea-25g-nic-list.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/Ethernet/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/Network/dump.txt| grep -oh "\w*SM10G-SR\w*"| fgrep -wqi -e SM10G-SR); then
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l  >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR  >> nodea-10g-sfplist.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*16.0 GB\w*" | fgrep -wqi -e "16.0 GB"); then
#
echo "Write Cache" >> nodea-diffme.txt
echo "Write Cache OP to 16GB" >> nodea-diffme.txt
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*800 GB\w*" | fgrep -wqi -e "800 GB"); then
#
echo "Read Cache" >> nodea-diffme.txt
echo "Read Cache 800 GB" >> nodea-diffme.txt
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*400 GB\w*" | fgrep -wqi -e "400 GB"); then
#
echo "Read Cache" >> nodea-diffme.txt
echo "Read Cache 400 GB" >> nodea-diffme.txt
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-S ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*Power Supply State:\w*"| fgrep -wqi -e Power Supply State:); then
echo "Power supply State" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" >> nodea-powersupply-list.txt
#
#
fi
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA| fgrep -wqi -e X4F16QG8BNTDME-7-CA); then
#
echo "Memory count TrueNAS X10-HA" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA | wc -l > nodea-X10_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA > nodea-X10_memory_list.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA | wc -l >> nodea-diffme.txt
echo "Physical Memory" >> nodea-diffme.txt
grep "Physical Memory" < nodea-hw-physmem.txt | awk '{print $3, $4}' >> nodea-diffme.txt
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA1| fgrep -wqi -e X4F16QG8BNTDME-7-CA1); then
#
echo "Memory count TrueNAS X10-HA" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA1 | wc -l > nodea-X10_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA1 > nodea-X10_memory_list.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA1 | wc -l >> nodea-diffme.txt
echo "Physical Memory" >> nodea-diffme.txt
grep "Physical Memory" < nodea-hw-physmem.txt | awk '{print $3, $4}' >> nodea-diffme.txt
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt| grep -oh "\w*I210\w*"| fgrep -wqi -e I210); then
echo "1G Onboard Nic Count" >> nodea-diffme.txt 
touch nodea-onboard-1gb-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt | grep -i I210 | wc -l  >> nodea-onboard-1gb-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt | grep -i I210  >> nodea-onboard-1gb-nic-list.txt
cat nodea-onboard-1gb-nic-count.txt >> nodea-diffme.txt
NODEAONB1GBNIC=$(cat nodea-onboard-1gb-nic-count.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*I350\w*"| fgrep -wqi -e I350); then
echo "Add on nic card I350 count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "I350" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "I350" | wc -l >> nodea-1g-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "I350" >> nodea-1g-nic-list.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l > nodea-X10_25G_SFP_count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" > nodea-X10_25G_SFP_list.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA  ) && $(cat ixdiagnose/fndebug/Network/dump.txt| grep -oh "\w*SM10G-SR\w*"| fgrep -wqi -e SM10G-SR); then
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l  >> nodea-10g-sfplist.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G| wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G > nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 | wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-list.txt
cat nodea-25g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l  >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*16.0 GB\w*" | fgrep -wqi -e "16.0 GB"); then
#
echo "Write Cache" >> nodea-diffme.txt
echo "Write Cache OP to 16GB" >> nodea-diffme.txt
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*400 GB\w*" | fgrep -wqi -e "400 GB"); then
#
echo "Read Cache" >> nodea-diffme.txt
echo "Read Cache 400 GB" >> nodea-diffme.txt
fi
#
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*800 GB\w*" | fgrep -wqi -e "800 GB"); then
#
echo "Read Cache" >> nodea-diffme.txt
echo "Read Cache 800 GB" >> nodea-diffme.txt
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*Power Supply State:\w*"| fgrep -wqi -e Power Supply State:); then
echo "Power supply State" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" >> nodea-powersupply-list.txt
#
#
fi
#
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
echo "nodea checkpont 3" > nodea-checkpoint3.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-X20-S" ) && $(echo "$NABIOV" | grep -oh "\w*IXS.1.00.14\w*"| fgrep -wqi -e IXS.1.00.14); then
echo "BIOS Version for TRUENAS-X20-HA is correctly showing as $NABIOV it should be  IXS.1.00.14" > nodea-X20-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is correctly showing as $NABIOV it should be  IXS.1.00.14" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-X20-S" ) && $(echo "$NABIOV" | grep -oh "\IXS.1.00.14\w*" != IXS.1.00.14); then
#
echo "BIOS Version for TRUENAS-X20-HA is showing as $NABIOV it should be  IXS.1.00.14" > nodea-X20-bios-version.txt
echo "BIOS Version for TRUENAS-X20-HA is showing as $NABIOV it should be  IXS.1.00.14" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-X20-HA is showing as $NABIOV it should be  IXS.1.00.14" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  IXS.1.00.14" >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-S ); then
#
echo "Memory count TrueNAS X20-S" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA | wc -l > nodea-X20_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA | wc -l >> nodea-diffme.txt
echo "Physical Memory" >> nodea-diffme.txt
grep "Physical Memory" < nodea-hw-physmem.txt | awk '{print $3, $4}' >> nodea-diffme.txt
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-S ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-S ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-S ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfpcount.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-S ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfpcount.txt
cat nodea-25g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-S ) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*16.0 GB\w*" | fgrep -wqi -e "16.0 GB"); then
#
echo "Write Cache" >> nodea-diffme.txt
echo "Write Cache OP to 16GB" >> nodea-diffme.txt
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-S ) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*800 GB\w*" | fgrep -wqi -e "800 GB"); then
#
echo "Read Cache" >> nodea-diffme.txt
echo "Read Cache 800 GB" >> nodea-diffme.txt
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-S ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*Power Supply State:\w*"| fgrep -wqi -e Power Supply State:); then
echo "Power supply State" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" >> nodea-powersupply-list.txt
#
#
fi
#
#
#
#
#
###############################################
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-X20-HA" ) && $(echo "$NABIOV" | grep -oh "\w*IXS.1.00.14\w*"| fgrep -wqi -e IXS.1.00.14); then
echo "BIOS Version for TRUENAS-X20-HA is correctly showing as $NABIOV it should be  IXS.1.00.14" > nodea-X20-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is correctly showing as $NABIOV it should be  IXS.1.00.14" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-X20-HA" ) && $(echo "$NABIOV" | grep -oh "\IXS.1.00.14\w*" != IXS.1.00.14); then
#
echo "BIOS Version for TRUENAS-X20-HA is showing as $NABIOV it should be  IXS.1.00.14" > nodea-X20-bios-version.txt
echo "BIOS Version for TRUENAS-X20-HA is showing as $NABIOV it should be  IXS.1.00.14" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-X20-HA is showing as $NABIOV it should be  IXS.1.00.14" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  IXS.1.00.14" >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-HA ); then
#
echo "Memory count TrueNAS X20-HA" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA | wc -l > nodea-X20_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i X4F16QG8BNTDME-7-CA | wc -l >> nodea-diffme.txt
echo "Physical Memory" >> nodea-diffme.txt
grep "Physical Memory" < nodea-hw-physmem.txt | awk '{print $3, $4}' >> nodea-diffme.txt
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfpcount.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfpcount.txt
cat nodea-25g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-HA ) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*16.0 GB\w*" | fgrep -wqi -e "16.0 GB"); then
#
echo "Write Cache" >> nodea-diffme.txt
echo "Write Cache OP to 16GB" >> nodea-diffme.txt
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-HA) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*800 GB\w*" | fgrep -wqi -e "800 GB"); then
#
echo "Read Cache" >> nodea-diffme.txt
echo "Read Cache 800 GB" >> nodea-diffme.txt
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-X20-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*Power Supply State:\w*"| fgrep -wqi -e Power Supply State:); then
echo "Power supply State" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State:" >> nodea-powersupply-list.txt
#
#
fi
#
#
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
echo "nodea checkpont 4" > nodea-checkpoint4.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R20B" ) && $(echo "$NABIOV" | grep -oh "\w*3.3.V6\w*"| fgrep -wqi -e 3.3.V6); then
echo "BIOS Version for TRUENAS-R20B is correctly showing as $NABIOV it should be  3.3.V6" > nodea-R20-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R20B" ) && $(echo "$NABIOV" | grep -oh "\3.3.V6\w*" != 3.3.V6); then
#
echo "BIOS Version for TRUENAS-R20B is showing as $NABIOV it should be  3.3.V6" > nodea-R20-bios-version.txt
echo "BIOS Version for TRUENAS-R20B is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-R20B is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
fi
#
#
#

#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R20B" ) && (echo "$NABMCINFO" | grep -oh "\w*1.71\w*"| fgrep -wqi -e 1.71); then
echo "BMC firmware for TRUENAS-R20B is correctly showing as $NABMCINFO it should be 1.71" > nodea-R20B-bmc.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "Correctly showing as $NABMCINFO it should be 1.71" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R20B" ) && $(echo "$NABMCINFO" | grep -oh "\1.71\w*" != 1.71); then
#
echo "BMC firmware for TRUENAS-R20B is showing as $NABMCINFO it should be 1.71" > nodea-R20B-bmc.txt
echo "BMC firmware for TRUENAS-R20B is showing as $NABMCINFO it should be 1.71" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-R20B is showing as $NABMCINFO it should be 1.71" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware is $NABMCINFO it should be 1.71" >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B ); then
#
echo "Memory count TrueNAS R20B" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A2K40BB1-CRC | wc -l > nodea-r20_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A2K40BB1-CRC | wc -l >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B ); then
#
echo "Fan Check" >> nodea-diffme.txt
# cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[2345AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 > nodea-r20_fancheck.txt
# cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[2345AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 >> nodea-diffme.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[2345AB]" | grep -iv lower > nodea-r20_fancheck.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[2345AB]" | grep -iv lower >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B  ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i  X722 | wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*QLE2692-SR-CK\w*"| fgrep -wqi -e QLE2692-SR-CK); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "QLE2692-SR-CK" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*X710\w*"| fgrep -wqi -e X710); then
echo "Add on nic card X710T4BLK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "X710" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B ) && $(cat ixdiagnose/fndebug/Network/dump.txt| grep -oh "\w*SFP-10GSR-85\w*"| fgrep -wqi -e SFP-10GSR-85); then
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10GSR-85 >> nodea-10g-sfpcount.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B ) && $(cat ixdiagnose/fndebug/Network/dump.txt| grep -oh "\w*SM10G-SR\w*"| fgrep -wqi -e SM10G-SR); then
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfpcount.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B ) && $(cat ixdiagnose/fndebug/Network/dump.txt | grep -i 25GBASE-SR | grep -iv media| grep -oh "\w*25GBASE-SR\w*"| fgrep -wqi -e 25GBASE-SR); then
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i 25GBASE-SR | grep -iv media >> nodea-25g-sfpcount.txt
cat nodea-25g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B  ) && $(cat ixdiagnose/fndebug/SMART/dump.txt | fgrep -oh MTFDDAK960TDS| fgrep -wqi -e MTFDDAK960TDS); then
cat ixdiagnose/fndebug/SMART/dump.txt | grep -iC6 Micron_5300_MTFDDAK960TDS >> MTFDDAK960TDS.txt
cat MTFDDAK960TDS.txt | grep -oh "\w*16.0 GB\w*" >> 16GB-MTFDDAK960TDS.txt
cat MTFDDAK960TDS.txt | grep -oh "\w*800 GB\w*" >> 800GB-MTFDDAK960TDS.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R20B" ) && (cat 16GB-MTFDDAK960TDS.txt | grep -oh "\w*16.0\w*"| fgrep -wqi -e 16.0); then
#
echo "16GB Write Cache Present" >> nodea-diffme.txt 
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R20B" ) && (cat 800GB-MTFDDAK960TDS.txt | grep -oh "\w*800\w*"| fgrep -wqi -e 800); then
#
echo "800 GB Read Cache Present" >> nodea-diffme.txt 
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R20B  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*R1CA2801A\w*"| grep -wqi -e R1CA2801A); then
echo "Power supply count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "R1CA2801A" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "R1CA2801A" >> nodea-powersupply-list.txt
#
#
fi
#
#
#
###############################################
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R40" ) && (echo "$NABIOV" | grep -oh "\w*3.3\w*"| fgrep -wqi -e 3.3); then
echo "BIOS Version for TRUENAS-R40 is correctly showing as $NABIOV it should be 3.3" > nodea-R40-bios-version.txt
echo "BIOS Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be 3.3" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R40" ) && $(echo "$NABIOV" | grep -oh "\3.3.V6\w*" != 3.3); then
#
echo "BIOS Version for TRUENAS-R40 is showing as $NABIOV it should be  3.3" > nodea-R40-bios-version.txt
echo "BIOS Version for TRUENAS-R40 is showing as $NABIOV it should be  3.3" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-R40 is showing as $NABIOV it should be  3.3" >> swqc-tmp/swqc-output.txt
echo "BIOS Version" >> nodea-diffme.txt
echo "BIOS Version is $NABIOV it should be 3.3" >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R40" ) && (echo "$NABMCINFO" | grep -oh "\w*1.71\w*"| fgrep -wqi -e 1.71); then
echo "BMC firmware for TRUENAS-R40 is correctly showing as $NABMCINFO it should be 1.71" > nodea-R40-bmc.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "Correctly showing as $NABMCINFO it should be 1.71" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R40" ) && $(echo "$NABMCINFO" | grep -oh "\1.71\w*" != 1.71); then
#
echo "BMC firmware for TRUENAS-R40 is showing as $NABMCINFO it should be 1.71" > nodea-R40-bmc.txt
echo "BMC firmware for TRUENAS-R40 is showing as $NABMCINFO it should be 1.71" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-R40 is showing as $NABMCINFO it should be 1.71" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware is $NABMCINFO it should be 1.71" >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R40 ) && $(cat cat ixdiagnose/dmidecode | fgrep -wqi -e 36ASF4G72PZ-2G9E2); then 
#
echo "Memory count TrueNAS R40" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i 36ASF4G72PZ-2G9E2 | wc -l > nodea-R40_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i 36ASF4G72PZ-2G9E2 | wc -l >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R40 ) && $(cat cat ixdiagnose/dmidecode | fgrep -wqi -e M393A2K40BB1-CRC); then 
#
echo "Memory count TrueNAS R40" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A2K40BB1-CRC | wc -l > nodea-R40_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A2K40BB1-CRC | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R40"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*X722\w*"| fgrep -wqi -e X722); then
echo "On Board Nic Card" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "X722" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R40"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R40 ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10GSR-85); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfpcount.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R40"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R40"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R40"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R40 ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodea-diffme.txt
NODEB10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R40" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
##
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R40" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R40" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt  >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R40" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodea-diffme.txt 
touch nodea-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodea-40g-sfpcount.txt
cat nodea-40g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA40GSFP=$(cat nodea-40g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R40  ) && $(cat ixdiagnose/fndebug/SMART/dump.txt | fgrep -oh MTFDDAK960TDS| fgrep -wqi -e MTFDDAK960TDS); then
cat ixdiagnose/fndebug/SMART/dump.txt | grep -iC6 Micron_5300_MTFDDAK960TDS >> MTFDDAK960TDS.txt
cat MTFDDAK960TDS.txt | grep -oh "\w*16.0 GB\w*" >> 16GB-MTFDDAK960TDS.txt
cat MTFDDAK960TDS.txt | grep -oh "\w*800 GB\w*" >> 800GB-MTFDDAK960TDS.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R40" ) && (cat 16GB-MTFDDAK960TDS.txt | grep -oh "\w*16.0\w*"| fgrep -wqi -e 16.0); then
#
echo "16GB Write Cache Present" >> nodea-diffme.txt 
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R40" ) && (cat 800GB-MTFDDAK960TDS.txt | grep -oh "\w*800\w*"| fgrep -wqi -e 800); then
#
echo "800 GB Read Cache Present" >> nodea-diffme.txt 
#
fi
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
echo "nodea checkpont 5" > nodea-checkpoint5.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
###############################################
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R50B" ) && (echo "$NABIOV" | grep -oh "\w*3.3.V6\w*"| fgrep -wqi -e 3.3.V6); then
echo "BIOS Version for TRUENAS-R50B is correctly showing as $NABIOV it should be 3.3.V6" > nodea-R50B-bios-version.txt
echo "BIOS Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be 3.3.V6" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R50B" ) && $(echo "$NABIOV" | grep -oh "\3.3.V6\w*" != 3.3.V6); then
#
echo "BIOS Version for TRUENAS-R50B is showing as $NABIOV it should be  3.3.V6" > nodea-R50B-bios-version.txt
echo "BIOS Version for TRUENAS-R50B is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-R50B is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "BIOS Version" >> nodea-diffme.txt
echo "BIOS Version is $NABIOV it should be 3.3.V6" >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R50B" ) && (echo "$NABMCINFO" | grep -oh "\w*1.71\w*"| fgrep -wqi -e 1.71); then
echo "BMC firmware for TRUENAS-R50B is correctly showing as $NABMCINFO it should be 1.71" > nodea-R50B-bmc.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "Correctly showing as $NABMCINFO it should be 1.71" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R50B" ) && $(echo "$NABMCINFO" | grep -oh "\1.71\w*" != 1.71); then
#
echo "BMC firmware for TRUENAS-R50B is showing as $NABMCINFO it should be 1.71" > nodea-R50B-bmc.txt
echo "BMC firmware for TRUENAS-R50B is showing as $NABMCINFO it should be 1.71" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-R50B is showing as $NABMCINFO it should be 1.71" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware is $NABMCINFO it should be 1.71" >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R50B ) && $(cat cat ixdiagnose/dmidecode | fgrep -wqi -e 36ASF4G72PZ-2G9E2); then 
#
echo "Memory count TrueNAS R50B" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i 36ASF4G72PZ-2G9E2 | wc -l > nodea-r50_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i 36ASF4G72PZ-2G9E2 | wc -l >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R50B ) && $(cat cat ixdiagnose/dmidecode | fgrep -wqi -e M393A2K40BB1-CRC); then 
#
echo "Memory count TrueNAS R50B" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A2K40BB1-CRC | wc -l > nodea-r50_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A2K40BB1-CRC | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R50B"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*X722\w*"| fgrep -wqi -e X722); then
echo "On Board Nic Card" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "X722" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R50B"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R50B ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10GSR-85); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfpcount.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R50B"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R50B"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R50B"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R50B ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodea-diffme.txt
NODEB10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R50B" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
##
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R50B" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R50B" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt  >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-R50B" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodea-diffme.txt 
touch nodea-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodea-40g-sfpcount.txt
cat nodea-40g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA40GSFP=$(cat nodea-40g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R50B  ) && $(cat ixdiagnose/fndebug/SMART/dump.txt | fgrep -oh MTFDDAK960TDS| fgrep -wqi -e MTFDDAK960TDS); then
cat ixdiagnose/fndebug/SMART/dump.txt | grep -iC6 Micron_5300_MTFDDAK960TDS >> MTFDDAK960TDS.txt
cat MTFDDAK960TDS.txt | grep -oh "\w*16.0 GB\w*" >> 16GB-MTFDDAK960TDS.txt
cat MTFDDAK960TDS.txt | grep -oh "\w*800 GB\w*" >> 800GB-MTFDDAK960TDS.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-R50  ) && $(cat ixdiagnose/fndebug/SMART/dump.txt | fgrep -oh MTFDDAK960TDS| fgrep -wqi -e MTFDDAK960TDS); then
cat ixdiagnose/fndebug/SMART/dump.txt | grep -iC6 Micron_5300_MTFDDAK960TDS >> MTFDDAK960TDS.txt
cat MTFDDAK960TDS.txt | grep -oh "\w*16.0 GB\w*" >> 16GB-MTFDDAK960TDS.txt
cat MTFDDAK960TDS.txt | grep -oh "\w*800 GB\w*" >> 800GB-MTFDDAK960TDS.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R50B" ) && (cat 16GB-MTFDDAK960TDS.txt | grep -oh "\w*16.0\w*"| fgrep -wqi -e 16.0); then
#
echo "16GB Write Cache Present" >> nodea-diffme.txt 
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R50B" ) && (cat 800GB-MTFDDAK960TDS.txt | grep -oh "\w*800\w*"| fgrep -wqi -e 800); then
#
echo "800 GB Read Cache Present" >> nodea-diffme.txt 
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R50" ) && (cat 16GB-MTFDDAK960TDS.txt | grep -oh "\w*16.0\w*"| fgrep -wqi -e 16.0); then
#
echo "16GB Write Cache Present" >> nodea-diffme.txt 
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-R50" ) && (cat 800GB-MTFDDAK960TDS.txt | grep -oh "\w*800\w*"| fgrep -wqi -e 800); then
#
echo "800 GB Read Cache Present" >> nodea-diffme.txt 
#
fi
#
#
#
#
#
###############################################
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M30-S ); then
#
echo "TrueNAS M30 Specific Checks" >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M30-S" ) && $(echo "$NABIOV" | grep -oh "\w*3.3.V6\w*"| fgrep -wqi -e 3.3.V6); then
echo "BIOS Version for TRUENAS-M30 is correctly showing as $NABIOV it should be 3.3.V6" > nodea-M30-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M30-S" ) && $(echo "$NABIOV" | grep -oh "\3.3.V6\w*" != 3.3.V6); then
#
echo "BIOS Version for TRUENAS-M30 is showing as $NABIOV it should be  3.3.V6" > nodea-M30-bios-version.txt
echo "BIOS Version for TRUENAS-M30 is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M30 is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M30-HA" ) && $(echo "$NABIOV" | grep -oh "\w*3.3.V6\w*"| fgrep -wqi -e 3.3.V6); then
echo "BIOS Version for TRUENAS-M30 is correctly showing as $NABIOV it should be  3.3aV3" > nodea-M30-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M30-S" ) && $(echo "$NABIOV" | grep -oh "\3.3.V6\w*" != 3.3.V6); then
#
echo "BIOS Version for TRUENAS-M30 is showing as $NABIOV it should be  3.3.V6" > nodea-M30-bios-version.txt
echo "BIOS Version for TRUENAS-M30 is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M30 is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M30-HA" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.71\w*"| fgrep -wqi -e 6.71); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M30-HA is correctly showing as $NABMCINFO it should be  6.71" > nodea-M30-bmc.txt
echo "Correctly showing as $NABMCINFO it should be  6.71" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M30-HA" ) && $(echo "$NABMCINFO" | grep -oh "\6.71\w*" != 6.71); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M30-HA is showing as $NABMCINFO it should be  6.71" > nodea-M30-bmc.txt
echo "BMC firmware for TRUENAS-M30-HA is showing as $NABMCINFO it should be  6.71" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M30-HA is showing as $NABMCINFO it should be  6.71" >> swqc-tmp/swqc-output.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.71" >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M30-S" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.71\w*"| fgrep -wqi -e 6.71); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M30-HA is correctly showing as $NABMCINFO it should be  6.71" > nodea-M30-bmc.txt
echo "Correctly showing as $NABMCINFO it should be  6.71" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M30-HA" ) && $(echo "$NABMCINFO" | grep -oh "\6.71\w*" != 6.71); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M30-HA is showing as $NABMCINFO it should be  6.71" > nodea-M30-bmc.txt
echo "BMC firmware for TRUENAS-M30-HA is showing as $NABMCINFO it should be  6.71" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M30-HA is showing as $NABMCINFO it should be  6.71" >> swqc-tmp/swqc-output.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.71" >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M30-S ); then
#
echo "Memory Count TrueNAS M30-S " >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l > nodea-M30_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA" ); then
#
echo "Memory Count TrueNAS M30 HA " >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA82GR7AFR8N-UH|wc -l > nodea-M30_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA82GR7AFR8N-UH|wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M30-S ); then
#
echo "NVDIMM Count TrueNAS M30-S" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l > nodea-M30_nvdimm_count.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA"  ); then
#
echo "NVDIMM Count TrueNAS M30 HA " >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l > nodea-M30_nvdimm_count.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M30-S  ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i X722 | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA" ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i  X722 | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M30-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodea-diffme.txt
NODEB10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
##
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt  >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M30-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodea-diffme.txt 
touch nodea-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodea-40g-sfpcount.txt
cat nodea-40g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA40GSFP=$(cat nodea-40g-sfpcount.txt)
#
fi
#
#
###############################################
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M40-S" ) && $(echo "$NABIOV" | grep -oh "\w*3.3.V6\w*"| fgrep -wqi -e 3.3.V6); then
echo "BIOS Version for TRUENAS-M40-S is correctly showing as $NABIOV it should be  3.3.V6" > nodea-M40-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is correctly showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M40-S" ) && $(echo "$NABIOV" | grep -oh "\3.3.V6\w*" != 3.3.V6); then
#
echo "BIOS Version for TRUENAS-M40-S is showing as $NABIOV it should be  3.3.V6" > nodea-M40-bios-version.txt
echo "BIOS Version for TRUENAS-M40-S is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M40-S is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M40-S" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.71\w*"| fgrep -wqi -e 6.71); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M40-S is correctly showing as $NABMCINFO it should be  6.71" > nodea-M40-bmc.txt
echo "Correctly showing as $NABMCINFO it should be  6.71" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M40-S" ) && $(echo "$NABMCINFO" | grep -oh "\6.71\w*" != 6.71); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M40-S is showing as $NABMCINFO it should be  6.71" > nodea-M40-bmc.txt
echo "BMC firmware for TRUENAS-M40-S is showing as $NABMCINFO it should be  6.71" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M40-S is showing as $NABMCINFO it should be  6.71" >> swqc-tmp/swqc-output.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.71" >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-S ); then
#
echo "Memory Count TrueNAS M40-S " >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l > nodea-m40_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-S ); then
#
echo "NVDIMM Count TrueNAS M40-S" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l > nodea-m40_nvdimm_count.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-S ); then
#
echo "Memory Count TrueNAS M40 HA " >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l > nodea-M40_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK > nodea-M40_memory_list.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-S ); then
#
echo "Fan Check" >> nodea-diffme.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[34AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 > nodea-M40_fancheck.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[34AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-S  ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i X722 | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-S) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*X710\w*"| fgrep -wqi -e X710); then
echo "Add on nic card X710T4BLK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "X710" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-S ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodea-diffme.txt
NODEB10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
##
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt  >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodea-diffme.txt 
touch nodea-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodea-40g-sfpcount.txt
cat nodea-40g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA40GSFP=$(cat nodea-40g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e T62100-LP-CR); then 
echo "Add on card 100G nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" >> node_100G_niclist
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e 6225-SO-CR); then 
echo "Add on card 25G nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" >> node_25G_niclist.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-S" ); then
#
echo "Power Supply State " >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State" > nodea-power-supply-state.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State">> nodea-diffme.txt
#
#
fi
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
echo "nodea checkpont 6" > nodea-checkpoint6.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M40-HA" ) && $(echo "$NABIOV" | grep -oh "\w*3.3.V6\w*"| fgrep -wqi -e 3.3.V6); then
echo "BIOS Version for TRUENAS-M40-HA is correctly showing as $NABIOV it should be  3.3.V6" > nodea-M40-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is correctly showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M40-HA" ) && $(echo "$NABIOV" | grep -oh "\3.3.V6\w*" != 3.3.V6); then
#
echo "BIOS Version for TRUENAS-M40-HA is showing as $NABIOV it should be  3.3.V6" > nodea-M40-bios-version.txt
echo "BIOS Version for TRUENAS-M40-HA is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M40-HA is showing as $NABIOV it should be  3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3.V6" >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M40-HA" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.71\w*"| fgrep -wqi -e 6.71); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M40-HA is correctly showing as $NABMCINFO it should be  6.71" > nodea-M40-bmc.txt
echo "Correctly showing as $NABMCINFO it should be  6.71" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M40-HA" ) && $(echo "$NABMCINFO" | grep -oh "\6.71\w*" != 6.71); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M40-HA is showing as $NABMCINFO it should be  6.71" > nodea-M40-bmc.txt
echo "BMC firmware for TRUENAS-M40-HA is showing as $NABMCINFO it should be  6.71" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M40-HA is showing as $NABMCINFO it should be  6.71" >> swqc-tmp/swqc-output.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.71" >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-HA ); then
#
echo "Fan Check" >> nodea-diffme.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[34AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 > nodea-M40_fancheck.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[34AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA"  ); then
#
echo "NVDIMM Count TrueNAS M40 HA " >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l > nodea-m40_nvdimm_count.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-HA ); then
#
echo "Memory Count TrueNAS M40 HA " >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l > nodea-M40_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK > nodea-M40_memory_list.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA" ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i  X722 | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA") && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*X710\w*"| fgrep -wqi -e X710); then
echo "Add on nic card X710T4BLK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "X710" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodea-diffme.txt
NODEB10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
##
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt  >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodea-diffme.txt 
touch nodea-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodea-40g-sfpcount.txt
cat nodea-40g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA40GSFP=$(cat nodea-40g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e T62100-LP-CR); then 
echo "Add on card 100G nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" >> node_100G_niclist
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e 6225-SO-CR); then 
echo "Add on card 25G nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" >> node_25G_niclist.txt
#
#
fi
#
#
#
#
#
#
#

#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M40-HA  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*R1CA2801A\w*"| fgrep -wqi -e R1CA2801A); then
echo "Power supply count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "R1CA2801A" | wc -l >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "R1CA2801A" >> nodea-powersupply-list.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA" ); then
#
echo "Power Supply State " >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State" > nodea-power-supply-state.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State">> nodea-diffme.txt
#
#
fi
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
echo "nodea checkpont 7" > nodea-checkpoint7.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#
#cat ixdiagnose/fndebug/Geom/dump.txt | awk '/glabel status @/,/debug finished/' | egrep -iv "glabel|----|name|debug|pmem*" 
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M50-HA ); then
#
echo "Memory Count TrueNAS M50 HA " >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l > nodea-m50_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK > nodea-m50_memory_list.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l >> nodea-diffme.txt
#
echo "TRUENAS M SLOG count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l > nodea-m50_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M50-S ); then
echo "test" > test.txt
echo "Memory count TrueNAS M50-HA" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7AFR4N-VK | wc -l > nodea-m50_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7AFR4N-VK > nodea-m50_memory_list.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7AFR4N-VK  >> nodea-diffme.txt
#
echo "TRUENAS M SLOG count NVDIMM " >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l > nodea-m50_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M50-HA ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i x722 | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M50-S ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i X722 | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M50-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M50-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M50-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M50-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodea-diffme.txt
NODEB10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M50-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
##
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M50-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M50-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt  >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M50-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodea-diffme.txt 
touch nodea-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodea-40g-sfpcount.txt
cat nodea-40g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA40GSFP=$(cat nodea-40g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M50-S ); then
echo "Add on card nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
echo "nodea checkpont 8" > nodea-checkpoint8.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
cd ..
echo "--------------NodeA smart settings--------------" >> swqc-tmp/smart-test-output.txt 
echo 'select * from tasks_smarttest' | sqlite3 *.db >> swqc-tmp/smart-test-output.txt # Check TrueNAS config for SMART tests
#
#
cd a
UNCORWRTNA=nodea-uncor-write-drive-errors.txt
UWENA=""
exec 3<&0
exec 0<$UNCORWRTNA
while read line
do
UWENA=$(echo $line | cut -d " " -f 1)
echo "$UWENA" > field1-output.txt
echo " nodea-drive-errors.txt field1 is $DERROR"
#
done
#
# 
if ["$UWENA" -gt 1]; then
echo "warning from nodea smart error for disk excedes 1" >> swqc/warning.txt
#
fi
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#x#
echo "nodea checkpont 9" > nodea-checkpoint9.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx##
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M50-S" ) && $(echo "$NABIOV" | grep -oh "\w*3.3aV3\w*"| fgrep -wqi -e 3.3aV3); then
echo "BIOS Version for TRUENAS-M50 is correctly showing as $NABIOV it should be  3.3aV3" > nodea-M50-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M50-S" ) && $(echo "$NABIOV" | grep -oh "\3.3aV3\w*" != 3.3aV3); then
#
echo "BIOS Version for TRUENAS-M50 is showing as $NABIOV it should be  3.3aV3" > nodea-M50-bios-version.txt
echo "BIOS Version for TRUENAS-M50 is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M50 is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M50-HA" ) && $(echo "$NABIOV" | grep -oh "\w*3.3aV3\w*"| fgrep -wqi -e 3.3aV3); then
echo "BIOS Version for TRUENAS-M50-HA is correctly showing as $NABIOV it should be  3.3aV3" > nodea-M50-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is correctly showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M50-HA" ) && $(echo "$NABIOV" | grep -oh "\3.3aV3\w*" != 3.3aV3); then
#
echo "BIOS Version for TRUENAS-M50-HA is showing as $NABIOV it should be  3.3aV3" > nodea-M50-bios-version.txt
echo "BIOS Version for TRUENAS-M50-HA is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M50-HA is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M50-HA" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.73\w*"| fgrep -wqi -e 6.73); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M50-HA is correctly showing as $NABMCINFO it should be  6.73" > nodea-M50-bmc.txt
echo "Correctly showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M50-HA" ) && $(echo "$NABMCINFO" | grep -oh "\6.73\w*" != 6.73); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M50-HA is showing as $NABMCINFO it should be  6.73" > nodea-M50-bmc.txt
echo "BMC firmware for TRUENAS-M50-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M50-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
fi
#
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#x#
echo "nodea checkpont 10" > nodea-checkpoint10.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx##
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M50-S" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.73\w*"| fgrep -wqi -e 6.73); then
echo "BMC firmware for TRUENAS-M50-HA is correctly showing as $NABMCINFO it should be  6.73" > nodea-M50-bmc.txt
echo "BMC firmware for TRUENAS-M50-HA is correctly showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M50-S" ) && $(echo "$NABMCINFO" | grep -oh "\6.73\w*" != 6.73); then
#
echo "BMC firmware for TRUENAS-M50-HA is showing as $NABMCINFO it should be  6.73" > nodea-M50-bmc.txt
echo "BMC firmware for TRUENAS-M50-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M50-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
fi
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#x#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx##
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(echo "$NABIOV" | grep -oh "\w*3.3aV3\w*"| fgrep -wqi -e 3.3aV3); then
echo "BIOS Version for TRUENAS-M60 is correctly showing as $NABIOV it should be  3.3aV3" > nodea-M60-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(echo "$NABIOV" | grep -oh "\3.3aV3\w*" != 3.3aV3); then
#
echo "BIOS Version for TRUENAS-M60 is showing as $NABIOV it should be  3.3aV3" > nodea-M60-bios-version.txt
echo "BIOS Version for TRUENAS-M60 is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M60 is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NABIOV" | grep -oh "\w*3.3aV3\w*"| fgrep -wqi -e 3.3aV3); then
echo "BIOS Version for TRUENAS-M60-HA is correctly showing as $NABIOV it should be  3.3aV3" > nodea-M60-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is correctly showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NABIOV" | grep -oh "\3.3aV3\w*" != 3.3aV3); then
#
echo "BIOS Version for TRUENAS-M60-HA is showing as $NABIOV it should be  3.3aV3" > nodea-M60-bios-version.txt
echo "BIOS Version for TRUENAS-M60-HA is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M60-HA is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.73\w*"| fgrep -wqi -e 6.73); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M60-HA is correctly showing as $NABMCINFO it should be  6.73" > nodea-M60-bmc.txt
echo "Correctly showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NABMCINFO" | grep -oh "\6.73\w*" != 6.73); then
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" > nodea-M60-bmc.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
fi
#

#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.73\w*"| fgrep -wqi -e 6.73); then
echo "BMC firmware for TRUENAS-M60-HA is correctly showing as $NABMCINFO it should be  6.73" > nodea-M60-bmc.txt
echo "BMC firmware for TRUENAS-M60-HA is correctly showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(echo "$NABMCINFO" | grep -oh "\6.73\w*" != 6.73); then
#
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" > nodea-M60-bmc.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/dmidecode| grep -i 6226R| grep -oh "\w*6226R\w*"| fgrep -wqi -e 6226R); then
echo "CPU Count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i 6226R | wc -l > nodea-m60_cpu_count.txt
cat ixdiagnose/dmidecode| grep -i 6226R  > nodea-m60_cpu_list.txt
cat ixdiagnose/dmidecode| grep -i 6226R| wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i M393A8G40MB2-CVF| grep -oh "\w*M393A8G40MB2-CVF\w*"| fgrep -wqi -e M393A8G40MB2-CVF); then
echo "Memory Count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A8G40MB2-CVF | wc -l > nodeb-m60_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A8G40MB2-CVF| wc -l >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7CJR4N-VK| grep -oh "\w*HMA84GR7CJR4N-VK\w*"| fgrep -wqi -e HMA84GR7CJR4N-VK); then
echo "Memory Count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7CJR4N-VK | wc -l > nodeb-m60_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7CJR4N-VK | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-032ACA| grep -oh "\w*AGIGA8811-032ACA\w*"| fgrep -wqi -e AGIGA8811-032ACA); then
echo "TRUENAS M SLOG count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-032ACA | wc -l > nodea-m60_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-032ACA | wc -l >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA| grep -oh "\w*AGIGA8811-016ACA\w*"| fgrep -wqi -e AGIGA8811-016ACA); then
echo "TRUENAS M SLOG count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l > nodea-m60_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60| grep -oh "\w*KCM6DVUL1T60\w*"| fgrep -wqi -e KCM6DVUL1T60); then
echo "M60 Read Cach" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60| wc -l > nodeb-m60_Read_Cach_count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60 > nodeb-m60_Read_Cach_list.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60 | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M60-S ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i x722 | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M60-S ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-S"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-S"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-S"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M56-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M60-S ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodea-diffme.txt
NODEB10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP28); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28 | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28 >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
##
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt  >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-S" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodea-diffme.txt 
touch nodea-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodea-40g-sfpcount.txt
cat nodea-40g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA40GSFP=$(cat nodea-40g-sfpcount.txt)
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i 6226R| grep -oh "\w*6226R\w*"| fgrep -wqi -e 6226R); then
echo "CPU Count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i 6226R | wc -l > nodea-m60_cpu_count.txt
cat ixdiagnose/dmidecode| grep -i 6226R  > nodea-m60_cpu_list.txt
cat ixdiagnose/dmidecode| grep -i 6226R| wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i M393A8G40MB2-CVF| grep -oh "\w*M393A8G40MB2-CVF\w*"| fgrep -wqi -e M393A8G40MB2-CVF); then
echo "Memory Count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A8G40MB2-CVF | wc -l > nodeb-m60_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A8G40MB2-CVF| wc -l >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7CJR4N-VK| grep -oh "\w*HMA84GR7CJR4N-VK\w*"| fgrep -wqi -e HMA84GR7CJR4N-VK); then
echo "Memory Count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7CJR4N-VK | wc -l > nodeb-m60_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7CJR4N-VK | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-032ACA| grep -oh "\w*AGIGA8811-032ACA\w*"| fgrep -wqi -e AGIGA8811-032ACA); then
echo "TRUENAS M SLOG count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-032ACA | wc -l > nodea-m60_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-032ACA | wc -l >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA| grep -oh "\w*AGIGA8811-016ACA\w*"| fgrep -wqi -e AGIGA8811-016ACA); then
echo "TRUENAS M SLOG count" >> nodea-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l > nodea-m60_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60| grep -oh "\w*KCM6DVUL1T60\w*"| fgrep -wqi -e KCM6DVUL1T60); then
echo "M60 Read Cach" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60| wc -l > nodeb-m60_Read_Cach_count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60 > nodeb-m60_Read_Cach_list.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60  | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M60-HA ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i x722 | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M56-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodea-diffme.txt
NODEB10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
##
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP28); then 
echo "10G SFP Count" >> nodea-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28 | wc -l >> nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28 >> nodea-10g-sfp-list.txt
cat nodea-10g-sfpcount.txt >> nodea-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodea-diffme.txt 
touch nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85| wc -l >> nodea-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodea-25g-sfp-list.txt
cat nodea-25g-sfpcount.txt  >> nodea-diffme.txt
NODEA25GSFP=$(cat nodea-25g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodea-diffme.txt 
touch nodea-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodea-40g-sfpcount.txt
cat nodea-40g-sfpcount.txt | wc -l >> nodea-diffme.txt
NODEA40GSFP=$(cat nodea-40g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M60-HA" ); then
#
#
echo "Fan Check" >> nodea-diffme.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[345AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 > nodea-m60_fancheck.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[345AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M60$ ); then
echo "Onboard nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i X722 | wc -l >> nodea-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M60-S ); then
echo "Add on card nic count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodea-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e TRUENAS-M60-S ); then
#
#
echo "Fan Check" >> nodea-diffme.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[345AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 > nodea-m60_fancheck.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[345AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 >> nodea-diffme.txt
#
fi
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#x#
echo "nodea checkpont 11" > nodea-checkpoint11.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx##
#
#
cd ..
echo "--------------NodeA smart settings--------------" >> swqc-tmp/smart-test-output.txt 
echo 'select * from tasks_smarttest' | sqlite3 *.db >> swqc-tmp/smart-test-output.txt # Check TrueNAS config for SMART tests
#
#
cd a
UNCORWRTNA=nodea-uncor-write-drive-errors.txt
UWENA=""
exec 3<&0
exec 0<$UNCORWRTNA
while read line
do
UWENA=$(echo $line | cut -d " " -f 1)
echo "$UWENA" > field1-output.txt
echo " nodea-drive-errors.txt field1 is $DERROR"
#
done
#
# 
if ["$UWENA" -gt 1]; then
echo"warning from nodea smart error for disk excedes 1" >> swqc/warning.txt
#
fi
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#x#
echo "nodea checkpont 12" > nodea-checkpoint12.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx##
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60$" ) && $(echo "$NABIOV" | grep -oh "\w*3.3aV3\w*"| fgrep -wqi -e 3.3aV3); then
echo "BIOS Version for TRUENAS-M60 is correctly showing as $NABIOV it should be  3.3aV3" > nodea-M60-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60$" ) && $(echo "$NABIOV" | grep -oh "\3.3aV3\w*" != 3.3aV3); then
#
echo "BIOS Version for TRUENAS-M60 is showing as $NABIOV it should be  3.3aV3" > nodea-M60-bios-version.txt
echo "BIOS Version for TRUENAS-M60 is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M60 is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NABIOV" | grep -oh "\w*3.3aV3\w*"| fgrep -wqi -e 3.3aV3); then
echo "BIOS Version for TRUENAS-M60-HA is correctly showing as $NABIOV it should be  3.3aV3" > nodea-M60-bios-version.txt
echo "Bios Version" >> nodea-diffme.txt
echo "Correctly showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NABIOV" | grep -oh "\3.3aV3\w*" != 3.3aV3); then
#
echo "BIOS Version for TRUENAS-M60-HA is showing as $NABIOV it should be  3.3aV3" > nodea-M60-bios-version.txt
echo "BIOS Version for TRUENAS-M60-HA is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-M60-HA is showing as $NABIOV it should be  3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodea-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  3.3aV3" >> nodea-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.73\w*"| fgrep -wqi -e 6.73); then
echo "BMC firmware for TRUENAS-M60-HA is correctly showing as $NABMCINFO it should be  6.73" > nodea-M60-bmc.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "Correctly showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NABMCINFO" | grep -oh "\6.73\w*" != 6.73); then
#
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" > nodea-M60-bmc.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware" >> nodea-diffme.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
fi
#
#
#
#
#
echo "nodea checkpont 3" > nodea-checkpoint3.txt
#
#
#
if $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M60$" ) && $(echo "$NABMCINFO" | grep -oh "\w*6.73\w*"| fgrep -wqi -e 6.73); then
echo "BMC firmware for TRUENAS-M60-HA is correctly showing as $NABMCINFO it should be  6.73" > nodea-M60-bmc.txt
echo "Correctly showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
elif $(echo "$PRODUCTNA" | fgrep -wqi -e "TRUENAS-M50-S" ) && $(echo "$NABMCINFO" | grep -oh "\6.73\w*" != 6.73); then
#
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" > nodea-M60-bmc.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NABMCINFO it should be  6.73" >> swqc-tmp/swqc-output.txt
echo "BMC firmware is showing as $NABMCINFO it should be  6.73" >> nodea-diffme.txt
#
fi
#
#
#
#
#
echo "Boot Pool Status" >> swqc-tmp/swqc-output.txt
cat ixdiagnose/fndebug/ZFS/dump.txt| grep -iC8 " pool: boot-pool" | egrep -i "state:|errors:" >> swqc-tmp/swqc-output.txt
echo "Boot Pool Status" >> nodea-diffme.txt
cat ixdiagnose/fndebug/ZFS/dump.txt| grep -iC8 " pool: boot-pool" | egrep -i "state:|errors:" >> nodea-diffme.txt
#
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
echo "nodea checkpont Final Check Point" > nodea-Final-checkpoint.txt
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
echo "-------------------------------------------------"  >> ../swqc-tmp/smart-test-output.txt
#
cd ../b
echo "nodeb checkpont 1" > nodeb-checkpoint1.txt
touch nodeb-diffme.txt
echo "Diff Sheet" >> nodeb-diffme.txt
tar -xf *.txz 
cat ixdiagnose/dmidecode| grep -iA2 "System information" | grep -i "Product Name" > nodeb-productname.txt
echo "Product Name"  >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -iA2 "System information" | grep -i "Product Name"  >> nodeb-diffme.txt
echo "Product Version"  >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -iA3 "System information" | grep -i version| cut -d " " -f2  >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -iA3 "System information" | grep -i version| cut -d " " -f2 > nodeb-productversion.txt
cat ixdiagnose/sysctl_hw | grep -i hw.physmem:> nodeb-sys-physmem.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Physical Memory:" > nodeb-hw-physmem.txt
cat ixdiagnose/fndebug/ZFS/dump.txt |awk '/zpool status /,/debug finished/' > bootpool-nodeb.txt
cat ixdiagnose/fndebug/System/dump.txt |awk '/Alert System @/,/seconds for Alert System/' > nodeb-alert.txt
cat ixdiagnose/log/messages |grep -iC6 MCA | grep -i error > nodeb-mca-errors.txt
cat ixdiagnose/version > nodeb-version.txt
echo "TrueNAS Version" >> nodeb-diffme.txt
cat nodeb-version.txt >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -iA2 "Bios Information" | grep -i version > nodeb-bios-version.txt
cat ixdiagnose/fndebug/IPMI/dump.txt| grep -i "firmware Revision" > nodeb-ipmi-firmware.txt 
cat ixdiagnose/fndebug/SMART/dump.txt | grep -iB1 revision > nodeb-disk-info.txt
cat ixdiagnose/fndebug/SMART/dump.txt|grep -i temperature | grep -i current > nodeb-drivetemp-output.txt
cat ixdiagnose/syslog/failover.log >> failnodeb-output.txt
#cat ixdiagnose/fndebug/Geom/dump.txt | awk '/glabel status @/,/debug finished/' | egrep -iv "glabel|----|name|debug|pmem*|*p3|*p3" | wc -l > nodeb-diskcount.txt
cat ixdiagnose/fndebug/Geom/dump.txt | awk '/gpart status @/,/debug finished/'| egrep -iv "glabel|----|name|debug|pmem*|*p3|*p2"  | grep -iv gpart | wc -l > nodeb-diskcount.txt
cat ixdiagnose/fndebug/Geom/dump.txt | awk '/glabel status @/,/debug finished/' | egrep -iv "glabel|----|name|debug|pmem*" > nodeb-disks.txt
cat ixdiagnose/fndebug/Hardware/dump.txt | egrep -i 'Enclosure Name|Enclosure ID|Enclosure Status' > nodeb-enclousre.txt
cat ixdiagnose/fndebug/System/dump.txt |awk '/License @/,/Illuminated License/' > nodeb-license.txt
echo "TrueNAS License" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/System/dump.txt |awk '/License @/,/Illuminated License/' | grep -i "License @" | wc -l >> nodeb-diffme.txt
echo "Workorder shows the following support level">> nodeb-diffme.txt
pdfgrep 'SUP-' ../*.pdf | cut -d "-" -f3-4 >> nodeb-diffme.txt
cat ixdiagnose/fndebug/SMART/dump.txt| egrep -i 'vendor:|Product:|Revision:|Number:|Status:|Current:|grown defect list:' > nodeb-drivestatantmp.txt
echo " SMART Health Status" >> nodeb-diffme.txt
cat nodeb-drivestatantmp.txt| grep -i "SMART Health Status:" | wc -l >> nodeb-diffme.txt
cat ixdiagnose/fndebug/SMART/dump.txt | egrep -i read: | tr -s ' ' | cut -d " " -f 8 > nodeb-uncor-write-drive-errors.txt
cat ixdiagnose/fndebug/SMART/dump.txt | egrep -i write: | tr -s ' ' | cut -d " " -f 8 > nodeb-uncor-read-drive-errors.txt
cat ixdiagnose/fndebug/Network/dump.txt |awk '/ Interfaces @/,/debug finished in/' > nodeb-interfaces.txt
cat ixdiagnose/fndebug/Network/dump.txt |awk '/ Interfaces marked critical for failover @/,/debug finished in/' > nodeb-crit4fail.txt
cat nodeb-interfaces.txt | grep -iv "+*+" | egrep -iv "lo0|pflog0|debug|ntb0" | sed 's/[ \t].*//;/^$/d' | wc -l > nodeb-portcount.txt
cat nodeb-interfaces.txt | grep -iv "+*+" | egrep -iv "lo0|pflog0|debug|ntb0" | sed 's/[ \t].*//;/^$/d' > nodeb-ports.txt
echo "drive count" >> nodeb-diffme.txt
cat nodeb-diskcount.txt  >> nodeb-diffme.txt
echo "Port count" >> nodeb-diffme.txt 
cat nodeb-interfaces.txt | grep -iv "+*+" | egrep -iv "lo0|pflog0|debug|ntb0" | sed 's/[ \t].*//;/^$/d'|wc -l >> nodeb-diffme.txt
NODEBPC=$(cat nodeb-portcount.txt)
NBBIOV=$(cat nodeb-bios-version.txt)
NBBMCINFO=$(cat nodeb-ipmi-firmware.txt)
PRODUCTNB=$(cat nodeb-productname.txt)
NBC4F=$(cat nodeb-crit4fail.txt)
echo "nodeb checkpont 2" > nodeb-checkpoint2.txt
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA ); then
#
echo "Memory count TrueNAS X10-HA" >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep X4F16QG8BNTDME-7-CA|wc -l > nodeb-X10_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep X4F16QG8BNTDME-7-CA|wc -l >> nodeb-diffme.txt
echo "Physical Memory" >> nodeb-diffme.txt
grep "Physical Memory" < nodeb-hw-physmem.txt | awk '{print $3, $4}' >> nodeb-diffme.txt
NODEA10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt| grep -oh "\w*I210\w*"| fgrep -wqi -e I210); then
echo "1G Onboard Nic Count" >> nodeb-diffme.txt 
touch nodeb-onboard-1gb-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt | grep -i I210 | wc -l  >> nodeb-onboard-1gb-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt | grep -i I210  >> nodea-onboard-1gb-nic-list.txt
cat nodeb-onboard-1gb-nic-count.txt >> nodeb-diffme.txt
NODEAONB1GBNIC=$(cat nodeb-onboard-1gb-nic-count.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*I350\w*"| fgrep -wqi -e I350); then
echo "Add on nic card I350 count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "I350" | wc -l >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "I350" | wc -l >> nodeb-1g-nic-count.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "I350" >> nodeb-1g-nic-list.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*" | fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodeb-10g-sfpcount.txt
cat nodeb-10g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| grep -oh "\w*SM10G-SR\w*"| fgrep -wqi -e SM10G-SR); then
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodeb-10g-sfpcount.txt
cat nodeb-10g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEA10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodeb-diffme.txt 
touch nodeb-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodeb-25g-sfpcount.txt
cat nodeb-25g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-25g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*16.0 GB\w*" | fgrep -wqi -e "16.0 GB"); then
#
echo "Write Cache" >> nodeb-diffme.txt
echo "Write Cache OP to 16GB" >> nodeb-diffme.txt
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*400 GB\w*" | fgrep -wqi -e "400 GB"); then
#
echo "Read Cache" >> nodeb-diffme.txt
echo "Read Cache 400 GB" >> nodeb-diffme.txt
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X10-HA) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*800 GB\w*" | fgrep -wqi -e "800 GB"); then
#
echo "Read Cache" >> nodeb-diffme.txt
echo "Read Cache 800 GB" >> nodeb-diffme.txt
fi
#
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-X20-HA" ) && $(echo "$NABIOV" | grep -oh "\w*IXS.1.00.14\w*"| fgrep -wqi -e IXS.1.00.14); then
echo "BIOS Version for TRUENAS-X20-HA is correctly showing as $NABIOV it should be  IXS.1.00.14" > nodeb-X20-bios-version.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "BIOS Version is correctly showing as $NABIOV it should be  IXS.1.00.14" >> nodeb-diffme.txt
#
elif $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-X20-HA" ) && $(echo "$NABIOV" | grep -oh "\IXS.1.00.14\w*" != IXS.1.00.14); then
#
echo "BIOS Version for TRUENAS-X20-HA is showing as $NABIOV it should be  IXS.1.00.14" > nodeb-X20-bios-version.txt
echo "BIOS Version for TRUENAS-X20-HA is showing as $NABIOV it should be  IXS.1.00.14" >> swqc-tmp/warning.txt
echo "BIOS Version for TRUENAS-X20-HA is showing as $NABIOV it should be  IXS.1.00.14" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "BIOS Version is showing as $NABIOV it should be  IXS.1.00.14" >> nodeb-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X20-HA ); then
#
echo "Memory count TrueNAS X20-HA" >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep X4F16QG8BNTDME-7-CA|wc -l > nodeb-X20_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep X4F16QG8BNTDME-7-CA|wc -l >> nodeb-diffme.txt
echo "Physical Memory" >> nodeb-diffme.txt
grep "Physical Memory" < nodeb-hw-physmem.txt | awk '{print $3, $4}' >> nodeb-diffme.txt
NODEBPHYSMEMC=$(cat nodeb-X20_memory_count.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X20-HA  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*" | fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X20-HA  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*" | fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X20-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodea-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodea-10g-sfpcount.txt
cat nodea-10g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEA10GSFP=$(cat nodea-10g-sfpcount.txt)
#
fi
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X20-HA  ) && $(cat ixdiagnose/fndebug/Network/dump.txt| grep -oh "\w*SM10G-SR\w*"| fgrep -wqi -e SM10G-SR); then
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodeb-10g-sfpcount.txt
cat nodeb-10g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEA10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X20-HA  ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodeb-diffme.txt 
touch nodeb-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodeb-25g-sfpcount.txt
cat nodeb-25g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-25g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X20-HA) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*16.0 GB\w*" | fgrep -wqi -e "16.0 GB"); then
#
echo "Write Cache" >> nodeb-diffme.txt
echo "Write Cache OP to 16GB" >> nodeb-diffme.txt
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-X20-HA) && $(cat ixdiagnose/fndebug/SMART/dump.txt| fgrep -iA3 KPM6VRUG960G | grep -oh "\w*800 GB\w*" | fgrep -wqi -e "800 GB"); then
#
echo "Read Cache" >> nodeb-diffme.txt
echo "Read Cache 800 GB" >> nodeb-diffme.txt
fi
#
#
#
#
#
#
###############################################
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ); then
#
echo "TrueNAS M30 Specific Checks" >> nodeb-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M30-HA" ) && $(echo "$NBBIOV" | grep -oh "\w*3.3.V6\w*"| fgrep -wqi -e 3.3.V6); then
echo "Bios Version for TRUENAS-M30-HA is correctly showing as $NBBIOV it should be 3.3aV3" > nodeb-M30-bios.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "Correctly showing as $NBBIOV it should be 3.3.V6" >> nodeb-diffme.txt
#
elif $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M30-HA" ) && $(echo "$NBBIOV" | grep -oh "\w*3.3.V6\w*" != 3.3.V6); then
#
echo "Bios Version for TRUENAS-M30-HA is showing as $NBBIOV it should be 3.3.V6" > nodeb-M30-bios.txt
echo "Bios Version for TRUENAS-M30-HA is showing as $NBBIOV it should be 3.3.V6" >> swqc-tmp/warning.txt
echo "Bios Version for TRUENAS-M30-HA is showing as $NBBIOV it should be 3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "Bios Version is showing as $NBBIOV it should be 3.3.V6" >> nodeb-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M30-HA" ) && $(echo "$NBBMCINFO" | grep -oh "\w*6.71\w*"| fgrep -wqi -e 6.71); then
echo "BMC firmware for TRUENAS-M30-HA is correctly showing as $NBBMCINFO it should be 6.71" > nodeb-M30-bmc.txt
echo "BMC Firmware" >> nodeb-diffme.txt
echo "Correctly showing as $NBBMCINFO it should be 6.71" >> nodeb-diffme.txt
#
elif $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M30-HA" ) && $(echo "$NBBMCINFO" | grep -oh "\w*6.71\w*" != 6.71); then
#
echo "BMC firmware for TRUENAS-M30-HA is showing as $NBBMCINFO it should be 6.71" > nodeb-M30-bmc.txt
echo "BMC firmware for TRUENAS-M30-HA is showing as $NBBMCINFO it should be 6.71" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M30-HA is showing as $NBBMCINFO it should be 6.71" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware" >> nodeb-diffme.txt
echo "BMC firmware is showing as $NBBMCINFO it should be 6.71" >> nodeb-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ); then
#
echo "Memory Count TrueNAS M30 HA " >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA82GR7AFR8N-UH|wc -l > nodeb-M30_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA82GR7AFR8N-UH|wc -l >> nodeb-diffme.txt
#
#
fi
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ); then
#
echo "NVDIMM Count TrueNAS M30 HA " >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l > nodeb-M30_nvdimm_count.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ); then
echo "Onboard nic count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i  X722 | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodeb-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l  >> nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodeb-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodeb-diffme.txt 
touch nodeb-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodeb-25g-sfpcount.txt
cat nodeb-25g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-25g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M30-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodeb-diffme.txt 
touch nodeb-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodeb-40g-sfpcount.txt
cat nodeb-40g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-40g-sfpcount.txt)
#
fi
#
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M40-HA" ) && $(echo "$NBBIOV" | grep -oh "\w*3.3.V6\w*"| fgrep -wqi -e 3.3.V6); then
echo "Bios Version for TRUENAS-M40-HA is correctly showing as $NBBIOV it should be 3.3aV3" > nodeb-M40-bios.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "Correctly showing as $NBBIOV it should be 3.3.V6" >> nodeb-diffme.txt
#
elif $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M40-HA" ) && $(echo "$NBBIOV" | grep -oh "\w*3.3.V6\w*" != 3.3.V6); then
#
echo "Bios Version for TRUENAS-M40-HA is showing as $NBBIOV it should be 3.3.V6" > nodeb-M40-bios.txt
echo "Bios Version for TRUENAS-M40-HA is showing as $NBBIOV it should be 3.3.V6" >> swqc-tmp/warning.txt
echo "Bios Version for TRUENAS-M40-HA is showing as $NBBIOV it should be 3.3.V6" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "Bios Version is showing as $NBBIOV it should be 3.3.V6" >> nodeb-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M40-HA" ) && $(echo "$NBBMCINFO" | grep -oh "\w*6.71\w*"| fgrep -wqi -e 6.71); then
echo "BMC firmware for TRUENAS-M40-HA is correctly showing as $NBBMCINFO it should be 6.71" > nodeb-M40-bmc.txt
echo "BMC Firmware" >> nodeb-diffme.txt
echo "Correctly showing as $NBBMCINFO it should be 6.71" >> nodeb-diffme.txt
#
elif $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M40-HA" ) && $(echo "$NBBMCINFO" | grep -oh "\w*6.71\w*" != 6.71); then
#
echo "BMC firmware for TRUENAS-M40-HA is showing as $NBBMCINFO it should be 6.71" > nodeb-M40-bmc.txt
echo "BMC firmware for TRUENAS-M40-HA is showing as $NBBMCINFO it should be 6.71" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M40-HA is showing as $NBBMCINFO it should be 6.71" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware" >> nodeb-diffme.txt
echo "BMC firmware is showing as $NBBMCINFO it should be 6.71" >> nodeb-diffme.txt
#
fi
#
#
###############################################
###############################################
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ); then
#
echo "Memory Count TrueNAS M40 HA " >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l > nodeb-m40_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l >> nodeb-diffme.txt
#
#
fi
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ); then
#
echo "NVDIMM Count TrueNAS M40 HA " >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l > nodeb-m40_nvdimm_count.txt
cat ixdiagnose/dmidecode| grep Part|grep AGIGA8811-016ACA|wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ); then
#
echo "Memory Count TrueNAS M40 HA " >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l > nodeb-M40_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK > nodeb-M40_memory_list.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l >> nodeb-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ); then
#
echo "Fan Check" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[34AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 > nodeb-M40_fancheck.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[34AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 >> nodeb-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ); then
echo "Onboard nic count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i  X722 | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e "TRUENAS-M40-HA") && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*X710\w*"| fgrep -wqi -e X710); then
echo "Add on nic card X710T4BLK count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "X710" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNA"|fgrep -wqi -e "TRUENAS-M40-HA"  ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodea-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodea-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodeb-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l  >> nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodeb-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodeb-diffme.txt 
touch nodeb-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodeb-25g-sfpcount.txt
cat nodeb-25g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-25g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M40-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodeb-diffme.txt 
touch nodeb-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodeb-40g-sfpcount.txt
cat nodeb-40g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-40g-sfpcount.txt)
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e "TRUENAS-M40-HA" ); then
#
echo "Power Supply State " >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State" > nodeb-power-supply-state.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "Power Supply State">> nodeb-diffme.txt
#
#
fi
#
#
#
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#
#
#
#cat ixdiagnose/fndebug/Geom/dump.txt | awk '/glabel status @/,/debug finished/' | egrep -iv "glabel|----|name|debug|pmem*" 
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ); then
#
echo "Memory Count TrueNAS M50 HA " >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l > nodeb-m50_memory_count.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK > nodeb-m50_memory_list.txt
cat ixdiagnose/dmidecode| grep Part|grep HMA84GR7AFR4N-VK|wc -l >> nodeb-diffme.txt
#
echo "TRUENAS M SLOG count" >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l > nodeb-m50_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l >> nodeb-diffme.txt
#
fi
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ); then
echo "Onboard nic count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i x722 | wc -l >> nodeb-diffme.txt
#
echo "TRUENAS M SLOG count" >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l > nodeb-m50_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l >> nodeb-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ); then
echo "Onboard nic count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i x722 | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodeb-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l  >> nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodeb-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodeb-diffme.txt 
touch nodeb-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodeb-25g-sfpcount.txt
cat nodeb-25g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-25g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M50-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodeb-diffme.txt 
touch nodeb-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodeb-40g-sfpcount.txt
cat nodeb-40g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-40g-sfpcount.txt)
#
fi
#
#
#
echo "nodeb checkpont 3" > nodeb-checkpoint3.txt
cd ..
echo "--------------NodeB smart settings--------------"  >> swqc-tmp/smart-test-output.txt 
echo 'select * from tasks_smarttest' | sqlite3 *.db >> swqc-tmp/smart-test-output.txt # CheckTrueNAS config for SMART tests
cd b
UNCORWRTNB=nodeb-uncor-write-drive-errors.txt
UWENB=””
exec 3<&0
exec 0<$UNCORWRTNB
while read line
do
UWENB=$(echo $line | cut -d " " -f 1)
echo "$UWENB" > field1-output.txt
echo " nodea-drive-errors.txt field1 is $UNCORWRTNB"
#
#
done
#
if ["$UWENB" -gt 1]; then
echo "warning from nodeb smart error for disk excedes 1" >> swqc/warning.txt
#
fi
# Ensure that smart tests are set for hard drives
#cd ..
#echo 'select * from tasks_smarttest' | sqlite3 *.db >> swqc-tmp/smart-test-output.txt
cd ../swqc-tmp
PRODUCT=$(cat productname.txt)
#
cd ../b
if $(echo "$PRODUCTNB" | grep -oh "\w*HA\w*")  && $(echo "$NODEAPC" | fgrep -wqi -e "$NODEBPC"); then
echo "port count for nodea is "$NODEAPC" which matches port count for nodeb which is "$NODEBPC””  >> swqc-tmp/swqc-output.txt
echo "port count for nodea is "$NODEAPC" which matches port count for nodeb which is "$NODEBPC”” > swqc/abportcount.txt
elif $(echo "$PRODUCTNB" | grep -oh "\w*HA\w*")  && $(echo "$NODEAPC" | != "$NODEBPC"); then
#
cd ../b
echo "port count for nodea is "$NODEAPC" does not match port count for nodeb which is "$NODEBPC””  >> swqc-tmp/swqc-output.txt
echo "port count for nodea is "$NODEAPC" does not match port count for nodeb which is "$NODEBPC”” > swqc/abportcount.txt
echo "port count for nodea is "$NODEAPC" does not match port count for nodeb which is "$NODEBPC”” >> swqc-tmp/warning.txt
#
#
cd ..
ABPC=$(swqc/abportcount.txt)
#
#
fi
#
cd ../b
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M50-HA" ) && $(echo "$NBBIOV" | grep -oh "\w*3.3aV3\w*"| fgrep -wqi -e 3.3aV3); then
echo "Bios Version for TRUENAS-M50-HA is correctly showing as $NBBIOV it should be 3.3aV3" > nodeb-M50-bios.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "Correctly showing as $NBBIOV it should be 3.3aV3" >> nodeb-diffme.txt
#
elif $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M50-HA" ) && $(echo "$NBBIOV" | grep -oh "\w*3.3aV3\w*" != 3.3aV3); then
#
echo "Bios Version for TRUENAS-M50-HA is showing as $NBBIOV it should be 3.3aV3" > nodeb-M50-bios.txt
echo "Bios Version for TRUENAS-M50-HA is showing as $NBBIOV it should be 3.3aV3" >> swqc-tmp/warning.txt
echo "Bios Version for TRUENAS-M50-HA is showing as $NBBIOV it should be 3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "Bios Version is showing as $NBBIOV it should be 3.3aV3" >> nodeb-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M50-HA" ) && $(echo "$NBBMCINFO" | grep -oh "\w*6.73\w*"| fgrep -wqi -e 6.73); then
echo "BMC firmware for TRUENAS-M50-HA is correctly showing as $NBBMCINFO it should be 6.73" > nodeb-M50-bmc.txt
echo "BMC Firmware" >> nodeb-diffme.txt
echo "Correctly showing as $NBBMCINFO it should be 6.73" >> nodeb-diffme.txt
#
elif $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M50-HA" ) && $(echo "$NBBMCINFO" | grep -oh "\w*6.73\w*" != 6.73); then
#
echo "BMC firmware for TRUENAS-M50-HA is showing as $NBBMCINFO it should be 6.73" > nodeb-M50-bmc.txt
echo "BMC firmware for TRUENAS-M50-HA is showing as $NBBMCINFO it should be 6.73" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M50-HA is showing as $NBBMCINFO it should be 6.73" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware" >> nodeb-diffme.txt
echo "BMC firmware is showing as $NBBMCINFO it should be 6.73" >> nodeb-diffme.txt
#
fi
#
#
###############################################
###############################################
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i 6226R| grep -oh "\w*6226R\w*"| fgrep -wqi -e 6226R); then
echo "CPU Count" >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -i 6226R | wc -l > nodeb-m60_cpu_count.txt
cat ixdiagnose/dmidecode| grep -i 6226R  > nodeb-m60_cpu_list.txt
cat ixdiagnose/dmidecode| grep -i 6226R| wc -l >> nodeb-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i M393A8G40MB2-CVF| grep -oh "\w*M393A8G40MB2-CVF\w*"| fgrep -wqi -e M393A8G40MB2-CVF); then
echo "Memory Count" >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A8G40MB2-CVF | wc -l > nodeb-m60_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i M393A8G40MB2-CVF| wc -l >> nodeb-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7CJR4N-VK| grep -oh "\w*HMA84GR7CJR4N-VK\w*"| fgrep -wqi -e HMA84GR7CJR4N-VK); then
echo "Memory Count" >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7CJR4N-VK | wc -l > nodeb-m60_memory_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i HMA84GR7CJR4N-VK | wc -l >> nodeb-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-032ACA| grep -oh "\w*AGIGA8811-032ACA\w*"| fgrep -wqi -e AGIGA8811-032ACA); then
echo "TRUENAS M SLOG count" >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-032ACA | wc -l > nodea-m60_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-032ACA | wc -l >> nodeb-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA| grep -oh "\w*AGIGA8811-016ACA\w*"| fgrep -wqi -e AGIGA8811-016ACA); then
echo "TRUENAS M SLOG count" >> nodeb-diffme.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l > nodea-m60_mslog_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i AGIGA8811-016ACA | wc -l >> nodeb-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60| grep -oh "\w*KCM6DVUL1T60\w*"| fgrep -wqi -e KCM6DVUL1T60); then
echo "M60 Read Cach" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i KCM6DVUL1T60| wc -l > nodeb-m60_Read_Cach_count.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i KCM6DVUL1T60 > nodeb-m60_Read_Cach_list.txt
cat ixdiagnose/dmidecode| grep -i part | grep -i KCM6DVUL1T60  | wc -l >> nodeb-diffme.txt
#
fi
#
#
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ); then
echo "Onboard nic count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i x722 | wc -l >> nodeb-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60$ ); then
echo "Onboard nic count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i x722 | wc -l >> nodeb-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T520-SO\w*"| fgrep -wqi -e T520-SO); then
echo "Add on nic card T520-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T520-SO" | wc -l >> nodeb-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T580-LP-CR\w*"| fgrep -wqi -e T580-LP-CR); then
echo "Add on nic card T580-LP-CR 40G count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T580-LP-CR" | wc -l >> nodeb-diffme.txt
#
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T62100-LP-CR\w*"| fgrep -wqi -e T62100-LP-CR); then
echo "Add on nic card T62100-LP-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T62100-LP-CR" | wc -l >> nodeb-diffme.txt
#
fi
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*T6225-SO-CR\w*"| fgrep -wqi -e T6225-SO-CR); then
echo "Add on nic card T6225-SO-CR count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "T6225-SO-CR" | wc -l >> nodeb-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Hardware/dump.txt | grep -oh "\w*ISP2722\w*"| fgrep -wqi -e ISP2722); then
echo "Add on nic card QLE2692-SR-CK count" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/Hardware/dump.txt| grep -i "ISP2722" | wc -l >> nodeb-diffme.txt
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP-10G); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G | wc -l >> nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP-10G >> nodeb-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SFP28); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28 | wc -l  >> nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28 >> nodeb-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt | fgrep -wqi -e SM10G-SR); then 
echo "10G SFP Count" >> nodeb-diffme.txt 
touch nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR | wc -l  >> nodeb-10g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SM10G-SR >> nodeb-10g-sfp-list.txt
cat nodeb-10g-sfpcount.txt >> nodeb-diffme.txt
NODEB10GSFP=$(cat nodeb-10g-sfpcount.txt)
#
fi
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e SFP28-25GSR-85); then 
echo "25G SFP Count" >> nodeb-diffme.txt 
touch nodeb-25g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i SFP28-25GSR-85 >> nodeb-25g-sfpcount.txt
cat nodeb-25g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-25g-sfpcount.txt)
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e TRUENAS-M60-HA ) && $(cat ixdiagnose/fndebug/Network/dump.txt| fgrep -wqi -e QSFP-SR4-40G); then 
echo "40G SFP Count" >> nodeb-diffme.txt 
touch nodeb-40g-sfpcount.txt
cat ixdiagnose/fndebug/Network/dump.txt | grep -i QSFP-SR4-40G >> nodeb-40g-sfpcount.txt
cat nodeb-40g-sfpcount.txt | wc -l >> nodeb-diffme.txt
NODEB25GSFP=$(cat nodeb-40g-sfpcount.txt)
#
fi
#
#
if $(echo "$PRODUCTNB"|fgrep -wqi -e "TRUENAS-M60-HA" ); then
#
#
echo "Fan Check" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[345AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 > nodeb-m60_fancheck.txt
cat ixdiagnose/fndebug/IPMI/dump.txt | egrep -i "FAN[345AB]" | egrep -iv "(42|43|44|47|48|45)" | cut -d\| -f1,4 >> nodeb-diffme.txt
#
fi
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NBBIOV" | grep -oh "\w*3.3aV3\w*"| fgrep -wqi -e 3.3aV3); then
echo "Bios Version for TRUENAS-M60-HA is correctly showing as $NBBIOV it should be 3.3aV3" > nodeb-M60-bios.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "Correctly showing as $NBBIOV it should be 3.3aV3" >> nodeb-diffme.txt
#
elif $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NBBIOV" | grep -oh "\w*3.3aV3\w*" != 3.3aV3); then
#
echo "Bios Version for TRUENAS-M60-HA is showing as $NBBIOV it should be 3.3aV3" > nodeb-M60-bios.txt
echo "Bios Version for TRUENAS-M60-HA is showing as $NBBIOV it should be 3.3aV3" >> swqc-tmp/warning.txt
echo "Bios Version for TRUENAS-M60-HA is showing as $NBBIOV it should be 3.3aV3" >> swqc-tmp/swqc-output.txt
echo "Bios Version" >> nodeb-diffme.txt
echo "Bios Version is showing as $NBBIOV it should be 3.3aV3" >> nodeb-diffme.txt
#
fi
#
#
#
#
#
if $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M60-HA" ) && $(echo "$NBBMCINFO" | grep -oh "\w*6.73\w*"| fgrep -wqi -e 6.73); then
echo "BMC firmware for TRUENAS-M60-HA is correctly showing as $NBBMCINFO it should be 6.73" > nodeb-M60-bmc.txt
echo "BMC Firmware" >> nodeb-diffme.txt
echo "Correctly showing as $NBBMCINFO it should be 6.73" >> nodeb-diffme.txt
#
elif $(echo "$PRODUCTNB" | fgrep -wqi -e "TRUENAS-M50-HA" ) && $(echo "$NBBMCINFO" | grep -oh "\w*6.73\w*" != 6.73); then
#
echo "BMC firmware for TRUENAS-M60-HA is showing as $NBBMCINFO it should be 6.73" > nodeb-M60-bmc.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NBBMCINFO it should be 6.73" >> swqc-tmp/warning.txt
echo "BMC firmware for TRUENAS-M60-HA is showing as $NBBMCINFO it should be 6.73" >> swqc-tmp/swqc-output.txt
echo "BMC Firmware" >> nodeb-diffme.txt
echo "BMC firmware is showing as $NBBMCINFO it should be 6.73" >> nodeb-diffme.txt
#
fi
#
#
#
#
echo "Boot Pool Status" >> swqc-tmp/swqc-output.txt
cat ixdiagnose/fndebug/ZFS/dump.txt| grep -iC8 " pool: boot-pool" | egrep -i "state:|errors:" >> swqc-tmp/swqc-output.txt
echo "Boot Pool Status" >> nodeb-diffme.txt
cat ixdiagnose/fndebug/ZFS/dump.txt| grep -iC8 " pool: boot-pool" | egrep -i "state:|errors:" >> nodeb-diffme.txt
#
#
#
#
echo "nodeb Final Check Point" > nodeb-final-checkpoint.txt
###############################################
#
#
#
# if $(echo "$PRODUCT" | grep -oh "\w*HA\w*"| fgrep -wqi -e HA ); then
cd ..
echo "Diff section" >> swqc-tmp/swqc-output.txt
diff -y -W 200 --suppress-common-lines a/nodea-diffme.txt b/nodeb-diffme.txt >> swqc-tmp/diff-comp.txt
#
###############################################
#               Order breakdown               #
###############################################
#
#
#
echo "Product Name" >> swqc-tmp/order-breakdown.txt
#
pdfgrep -i "CONFIGURATION*" *.pdf |grep -iv notes | cut -d "#" -f2 | cut -d " " -f2,3  >> swqc-tmp/order-breakdown.txt
#
echo "Product Version" >> swqc-tmp/order-breakdown.txt
#
#
echo "Hard drive count" >> swqc-tmp/order-breakdown.txt
pdfgrep -i "HD-" *.pdf | egrep -iv 'exp|IX' >> swqc-tmp/order-breakdown.txt
#
#
echo "Write Cache" >> swqc-tmp/order-breakdown.txt
pdfgrep -i "Write Cache" *.pdf  >> swqc-tmp/order-breakdown.txt
#
#
#
echo "Read Cache" >> swqc-tmp/order-breakdown.txt
pdfgrep -i "Read Cache" *.pdf >> swqc-tmp/order-breakdown.txt
#
#
echo "TrueNAS License" >> swqc-tmp/order-breakdown.txt
pdfgrep -i "TrueNAS License" *.pdf >> swqc-tmp/order-breakdown.txt
#
#
#
echo "Onboard nic count" >> swqc-tmp/order-breakdown.txt
#
 pdfgrep -i "NI-" *.pdf >> order-Onboard-nix.txt
cat order-Onboard-nix.txt | wc -l >> order-Onboard-nix.txt
#
echo "Add on nic card" >> swqc-tmp/order-breakdown.txt
pdfgrep -i "TRUENAS-NIC-*" *.pdf >> order-addon-nic.txt 
cat order-addon-nic.txt| wc -l >> swqc-tmp/order-breakdown.txt
#
echo "Add on nic card" >> swqc-tmp/order-breakdown.txt
pdfgrep -i "SFP-" *.pdf >> swqc-tmp/order-breakdown.txt
#
###############################################
#
echo "SFP Check" >> Final-checkpoint.txt
#
#
#
exit
done
