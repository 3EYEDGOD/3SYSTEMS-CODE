#! /bin/bash
# Title         :Redfish-Disable.sh
# Description   :Designed To Disable Redfish user
# Author	:Juan Garcia
# Date          :1-19-23
# Version       :1.0
#########################################################################################################

cd /tmp
mkdir /tmp/ix-tmp


# Grabbing serial number

dmidecode -t1 | grep -E -o -i "A1-.{0,6}" > ix-tmp/System-Serial.txt
SERIAL=$(cat ix-tmp/System-Serial.txt)


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


echo 'ipmi=IPMIIP
pw='IPMIPASSWD'
curl -v -k -u "admin:${pw}" \
        --request PATCH "https://${ipmi}/redfish/v1/AccountService/Accounts/1" \
        --header 'If-None-Match: W/"WHITENOISE"' \
        --header 'Content-Type: application/json' \
        --data-raw "{\"Enabled\": false  }" ' > ix-tmp/Redfish-Disable.txt


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


ipmi=IPMIIP
pw='IPMIPASSWD'
curl -v -k -u "admin:${pw}" \
        --request PATCH "https://${ipmi}/redfish/v1/AccountService/Accounts/1" \
        --header 'If-None-Match: W/"WHITENOISE"' \
        --header 'Content-Type: application/json' \
        --data-raw "{\"Enabled\": false  }" &>> ix-tmp/Redfish-Disable.txt


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


echo 'ipmi=IPMIIP
pw='IPMIPASSWD'
curl -v -s -k -u "admin:${pw}" --request GET "https://${ipmi}/redfish/v1/AccountService/Accounts/1" | jq .Enabled' > ix-tmp/Redfish-Check.txt


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


ipmi=IPMIIP
pw='IPMIPASSWD'
curl -v -s -k -u "admin:${pw}" --request GET "https://${ipmi}/redfish/v1/AccountService/Accounts/1" | jq .Enabled &>> ix-tmp/Redfish-Check.txt


echo "==========================================================================" >> ix-tmp/LINE-Output.txt


# Compress output file

tar -czvf "$SERIAL-Redfish-Disable.tar.gz" ix-tmp/

echo "==========================================================================" >> ix-tmp/LINE-Output.txt


echo "setting up for mounting sj storage"

mkdir /mnt/sj-storage
mount -t cifs -o vers=3,username=root,password=abcd1234 '//10.246.0.110/sj-storage/' /mnt/sj-storage/
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt >> ix-tmp/swqc-output.txt
cat /mnt/sj-storage/swqc-output/smbconnection-verified.txt > ix-tmp/smb-verified.txt
echo "SJ Storage mounted" 


echo "==========================================================================" >> ix-tmp/LINE-Output.txt

echo "Copying tar.gz file to swqc-output on sj-storage"

cd /tmp

cp *.tar.gz /mnt/sj-storage/swqc-output/

echo "Finished copying tar.gz file to swqc-output on sj-storage"


echo "==========================================================================" >> ix-tmp/LINE-Output.txt

rm -rf ix-tmp/
rm -rf  *.tar.gz ix-tmp/

exit
