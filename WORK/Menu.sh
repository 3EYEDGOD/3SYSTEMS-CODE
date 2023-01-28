#!/bin/bash
# Title					:Menu.sh
# Description		:Menu For Scripts
# Author				:Juan Garcia
# Date					:04:11:2022
# Version				:2.0
#########################################################################################################
# DEPENDENCIES:
#
# dialog needs to be installed: sudo apt-get install dialog -y
#########################################################################################################

# Store menu options selected by the user

INPUT=/tmp/menu.sh.$$

# Purpose - Run CC-Config.sh

function Run_Script_1(){
	./CC-Config.sh
}

# Purpose - TrueNAS-Validation.sh

function Run_Script_2(){
	./TrueNAS-Validation.sh
}

# Purpose - Run R50BM-SCPsh

function Run_Script_3(){
	./R50BM-SCP.sh
}

# Purpose - Run CM6-Validation.sh

function Run_Script_4(){
	./CM6-Validation.sh
}

# Purpose - Run BIOS-Default.sh

function Run_Script_5(){
	./BIOS-Default.sh
}

# Purpose - Run Sum-Validation.sh

function Run_Script_6(){
	./SUM-Validation.sh
}

# Purpose - Run Redfish-Disable.sh

function Run_Script_7(){
	./Run-Redfish-Disable.sh
}

# Purpose - Run CC-Config-ARM.sh

function Run_Script_8(){
	./CC-Config-ARM.sh
}

# Set infinite loop

while true
do

### display main menu ###

dialog --clear --backtitle "IXSYSTEMS INC. CLIENT CONFIGURATION SCRIPTS" \
--title "[ M A I N - M E N U ]" \
--ok-label "SELECT" \
--no-cancel \
--menu "--------------------------------CHOOSE AN OPTION---------------------------------" 0 0 0 \
CC-Config "Grab PBS Log Info & Configure Basic Settings  [S]" \
CC-Config-ARM "Grab PBS Log Info & Configure Basic Settings  [S]" \
TrueNAS-Validation "Verifies TrueNAS Configuration  (TRUENAS-ONLY)  [SG]" \
R50BM-Flashing "Flashes R50BM W/ AOC-SLG3-4E2P.sh  (TRUENAS-ONLY)  [G]" \
CM6-Flash "Flash CM6 NVME Drives  (TRUENAS-ONLY)  [G]" \
BIOS-Default "Set BIOS To Default Settings  (SUM-KEY)  [S]" \
SUM-Validation "Grabs System Info & Configs  (NON-TRUENAS)  (SUM-KEY)  [SIUP]" \
R30-Redfish-Disable "Disables the default Redfish user  [SIPG]" \
Exit "Exit To The Shell" 2>"${INPUT}"

CHOICE=$(<"${INPUT}")

# make decsion

case $CHOICE in
	CC-Config) Run_Script_1;;
	CC-Config-ARM) Run_Script_8;;
	TrueNAS-Validation) Run_Script_2;;
	R50BM-Flashing) Run_Script_3;;
	CM6-Flash) Run_Script_4;;
	BIOS-Default) Run_Script_5;;
	SUM-Validation) Run_Script_6;;
	R30-Redfish-Disable) Run_Script_7;;
	Exit) echo "Bye $USER"; break;;
esac

done

# if temp files found, delete em

[ -f $INPUT ] && rm $INPUT
