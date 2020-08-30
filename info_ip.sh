#!/bin/bash

#################################
# Nom		: info_ip.sh	#
# Auteur 	: Antoine Even	#
# Date 		: 07/06/20	#
# Revision	: 31/08/20	#
# Version	: 0.1.5		#
#################################

EACCES=13 # Permission denied

if [ "$UID" -ne 0 ]; then # Vous êtes ROOT
  echo "Permission denied : you must be root."
  exit $EACCES
fi

############## Fonctions
function usage(){
	echo "Utilisation du script :"
	echo "-t		: affiche les temperatures."
	echo "-h		: affiche ce message."
	echo "--help		: affiche ce message."
}

############## Arguments
if [ $# -eq 1 ] && [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    usage
    exit 1
elif [ $# -eq 1 ] && [ $1 == "-t" ]
then
    TEMP=1
fi

############## Variables
GREEN='\033[0;32m'
WHITE='\033[1;37m'
RED='\033[0;91m'
BLUE='\033[0;94m'
MAGENTA='\033[0;95m'

IP=$(hostname -I | awk '{print $1}')
IP_PUB=$(curl ifconfig.me 2> /dev/null)
NAME=$(hostname)
TEMPS=$(uptime -p | awk '{for(i=2;i<=NF;++i)print $i}')
CPU=$(cat /proc/cpuinfo | grep -i "^model name" | awk -F ": " '{print $2}' | head -1 | sed 's/ \+/ /g')
NBCPU=$(nproc)
FABCPU=$(dmidecode -s processor-manufacturer)
XBITS=$(uname -m)
MEM=$(free -h | grep Mem | awk '{print $2}')
KERNEL=$(uname -a | awk '{print $3}')
GPU=$(lspci | grep VGA | awk '{for(i=5;i<=NF;++i)print $i}')
RESOLUTION=$(xrandr | grep "*" | awk '{print $1}')
CHASSIS=$(dmidecode -s chassis-type)
CHAMAN=$(dmidecode -s chassis-manufacturer)
SYSMAN=$(dmidecode -s system-manufacturer)
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    ID=$ID
fi

############### Raspberry Pi
if [ $ID == "raspbian" ]; then
    echo "TEST2"
    CHAMAN=$(cat /proc/device-tree/model  | awk '{print $1 " " $2}')
    SYSMAN=$(cat /proc/device-tree/model  | awk '{print $3 " " $4}')
    CHASSIS="Single Board Computer"
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
echo -e ${WHITE}"Environement	  : "$XDG_DESKTOP_SESSION
echo -e "Langue		  : "$LANG
echo "=================== Matériel =================="
echo -e "Fabricant	  : "$CHAMAN " / " $SYSMAN
echo -e "Type de Chassis   : "$CHASSIS
echo -e "Processeur	  : "$CPU "x "${GREEN}$NBCPU
echo -e ${WHITE}"Architecture	  : "${MAGENTA}$XBITS
echo -e ${WHITE}"Mémoire Ram	  : "$MEM
echo "Carte Graphique	  : "$GPU
echo "Resolution	  : "$RESOLUTION
echo "================== Partitions ===================" ;
df -h | grep -E '^/';

############## Temperature Disque
if [ "$TEMP" == 1 ]
then
    echo "================== Température =================="
    if [ $ID == "fedora" ] || [ $ÎD == "centos" ]; then
        hddtemp
    elif [ $ID == "raspbian" ]; then
        echo "Raspberry Pi, décomentez si vous avez des disques externes" #; hddtemp /dev/sd*
    else
        hddtemp /dev/sd*
    fi
    echo
    ############### Temperature Sensors
    if [[ -x "/usr/bin/sensors" ]]
    then
        sensors
    fi
fi

