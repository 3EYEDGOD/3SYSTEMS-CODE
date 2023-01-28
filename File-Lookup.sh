#! /bin/bash



echo "Enter Order Number"
read ORDER 

echo "Enter Serial Number"
read SERIAL

#dialog --inputbox "Enter Order Number" 10 60 2> ix-tmp/ORDER-Num.txt
#ORDER=$(cat ix-tmp/ORDER-Num.txt)

#dialog --inputbox "Enter Serial Number" 10 60 2> ix-tmp/SERIAL-Num.txt
#SERIAL=$(cat ix-tmp/SERIAL-Num.txt)

#echo "setting up for mounting of sj storage"

#mkdir /mnt/sj-storage
mount -t cifs -o vers=3,username=root,password=abcd1234 '//10.246.0.110/sj-storage/' /mnt/sj-storage/ 2>/dev/null
#cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt >> ix-tmp/swqc-output.txt
#cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt > ix-tmp/smb-verified.txt
#echo "SJ Storage mounted" 

mkdir ~/$ORDER-FILE

cp -r /mnt/sj-storage/Production/TrueNAS_Configuration/2019/$ORDER/ ~/$ORDER-FILE/$ORDER-2019 2>/dev/null
cp -r /mnt/sj-storage/Production/TrueNAS_Configuration/2020/$ORDER/ ~/$ORDER-FILE/$ORDER-2020 2>/dev/null
cp -r /mnt/sj-storage/Production/TrueNAS_Configuration/2021/$ORDER/ ~/$ORDER-FILE/$ORDER-2021 2>/dev/null
cp -r /mnt/sj-storage/Production/TrueNAS_Configuration/2022/$ORDER/ ~/$ORDER-FILE/$ORDER-2022 2>/dev/null
cp -r /mnt/sj-storage/Production/TrueNAS_Configuration/2023/$ORDER/ ~/$ORDER-FILE/$ORDER-2023 2>/dev/null

cp -r /mnt/sj-storage/"MFG Quality Photos"/"SWQC Screenshots Servers and Mini"/"Serial #"/$SERIAL.tar.gz ~/$ORDER-FILE/$SERIAL 2>/dev/null

exit
