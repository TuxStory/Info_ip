#!/bin/bash

#################################
# Nom		: info_ip.sh	#
# Auteur 	: Antoine Even	#
# Date 		: 07/06/20	#
# Revision	: 07/08/20	#
# Version	: 0.0.7		#
#################################

EACCES=13 # Permission denied

if [ "$UID" -ne 0 ]; then # Vous êtes ROOT
  echo "Permission denied : you must be root."
  exit $EACCES
fi

############## variables
GREEN='\033[0;32m'
WHITE='\033[1;37m'
RED='\033[0;31m'
BLUE='\033[0;34m'

IP=$(hostname -I | awk '{print $1}')
IP_PUB=$(curl ifconfig.me 2> /dev/null)
NAME=$(hostname)
TEMPS=$(uptime -p | awk '{for(i=2;i<=NF;++i)print $i}')
CPU=$(cat /proc/cpuinfo | grep -i "^model name" | awk -F ": " '{print $2}' | head -1 | sed 's/ \+/ /g')
MEM=$(free -h | grep Mem | awk '{print $2}')
KERNEL=$(uname -a | awk '{print $3}')
GPU=$(lspci | grep VGA | awk '{for(i=5;i<=NF;++i)print $i}')

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    ID=$ID
fi

############### Programme
clear
echo -e ${WHITE}"==================== IP ===================="
echo -e ${WHITE}"IP locale         : "${GREEN}$IP
echo -e ${WHITE}"IP Publique       : "${GREEN}$IP_PUB
echo -e ${WHITE}"=================== Infos =================="
echo -e ${WHITE}"Distribution 	  : "$OS
echo "Version		  : "$VER
echo -e "Version du Noyau  : "${BLUE}$KERNEL
echo -e ${WHITE}"Hostname    	  : "$HOSTNAME
echo -e "En Fonction 	  : "${RED}$TEMPS
echo -e ${WHITE}"Environement	  : "$DESKTOP_SESSION
echo "=================== Matériel =================="
echo "Processeur	  : "$CPU
echo "Mémoire Ram	  : "$MEM
echo "Carte Graphique	  : "$GPU
echo "Disques : " ; df -h | grep sd
echo "================== Température =================="

############## Temperature Disque
if [ $ID == "fedora" ] || [ $ÎD == "centos" ]; then
	echo "Temperature disques :" ; hddtemp
elif [ $ID == "raspbian" ]; then
	echo "Raspberry Pi, décomentez si vous avez des disques externes" #; hddtemp /dev/sd*
else
	echo "Temperature disques :" ; hddtemp /dev/sd*
fi

############### Temperature Sensors
echo
if [[ -x "/usr/bin/sensors" ]]
then
    sensors
fi
