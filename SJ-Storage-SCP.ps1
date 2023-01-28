 
$ORDER = Read-Host -Prompt 'Enter Order Number'

ssh filefetcher@10.213.2.22 ./File-Lookup.sh

scp -r filefetcher@10.213.2.22:~/$ORDER-FILE/ C:\Users\$env:UserName\Desktop\SCP-Files\

ssh filefetcher@10.213.2.22 ./File-Cleanup.sh

exit
