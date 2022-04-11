#!/bin/bash

#################################
# Nom		: info_ip.sh	#
# Auteur 	: Antoine Even	#
# Date 		: 07/06/20	#
# Revision	: 11/04/22	#
# Version	: 0.2.5		#
#################################

EACCES=13 # Permission denied
VERSION=0.2.4

if [ "$UID" -ne 0 ]; then # Vous êtes ROOT
  echo "Permission denied : you must be root."
  exit $EACCES
fi

if [ ! -x /usr/sbin/hddtemp ]; then
    echo "Hddtemp n'est pas installé !"
    exit $EACCES
elif [ ! -x /usr/bin/curl ]; then
    echo "Curl n'est pas installé !"
    exit $EACCES
fi

############## Fonctions
function usage(){
	echo "Utilisation du script :"
	echo "-t		: affiche les temperatures."
	echo "-h		: affiche ce message."
	echo "-v		: affiche la version."
	echo "--help		: affiche ce message."
	echo "--version	: afficher la version."
}

function version(){
	echo "Info ip (C) 2020-2021 Antoine Even"
	echo "Version : "$VERSION
	echo "Licence : MIT License"
	exit $EACCES
}

############## Arguments
if [ $# -eq 1 ] && [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
    usage
    exit 1
elif [ $# -eq 1 ] && [ $1 == "-t" ]
then
    TEMP=1
elif [ $# -eq 1 ] && [ $1 == "--version" ] || [ "$1" == "-v" ]
then
    version
fi

############### OS Release
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    ID=$ID
    VARIANT=$VARIANT
fi

############## Variables
GREEN='\033[0;32m'
WHITE='\033[1;0m' #real white \033[1;37m
RED='\033[0;91m'
BLUE='\033[0;94m'
MAGENTA='\033[0;95m'

IP=$(hostname -I 2> /dev/null | awk '{print $1}')
IP_PUB=$(curl ifconfig.me 2> /dev/null)
NAME=$(hostname)
TEMPS=$(uptime -p | awk '{for(i=2;i<=NF;++i)print $i}')
CPU=$(cat /proc/cpuinfo | grep -i "^model name" | awk -F ": " '{print $2}' | head -1 | sed 's/ \+/ /g')
NBCPU=$(nproc)
FABCPU=$(dmidecode -s processor-manufacturer)
XBITS=$(uname -m)
MEM=$(free -h | grep Mem | awk '{print $2}')
USEDMEM=$(awk '/^Mem/ {print $3}' <(free -h))
PMEM=$(awk '/^Mem/ {printf("%u%%", 100*$3/$2);}' <(free -m))
KERNEL=$(uname -a | awk '{print $3}')
GPU=$(lspci | grep VGA | awk '{for(i=5;i<=NF;++i)print $i}')
GPUMEMORY=$(glxinfo | grep "Video memory" | awk '{print $3}')
RESOLUTION=$(xrandr | grep "*" | awk '{print $1}')
CAUDIO=$(lspci | grep -i audio |  awk -F ": " '{print $2}') #Before lspci -v
CHASSIS=$(dmidecode -s chassis-type)
CHAMAN=$(dmidecode -s chassis-manufacturer)
SYSMAN=$(dmidecode -s system-manufacturer)
FUSEAUH=$(timedatectl show | grep  Timezone | cut -d "=" -f2)
HEURE=$(date +"%H:%M %d/%m/%Y")
SHELLO=$(echo $SHELL | awk -F "/" '{print $3}')
#SHELLO=$(echo $SHELL | cut -d "/" -f3)

############### Debian
if [ $ID == "debian" ]; then
    VER=$(cat /etc/debian_version )
fi

############### Manjaro
if [ $ID == "manjaro" ]; then
    IP=$(hostname -i )
fi

############### Raspberry Pi
if [ $ID == "raspbian" ]; then
    echo "TEST2"
    CHAMAN=$(cat /proc/device-tree/model  | awk '{print $1 " " $2}')
    SYSMAN=$(cat /proc/device-tree/model  | awk '{print $3 " " $4}')
    CHASSIS="Single Board Computer"
fi

############### OpenSuse
if [ $ID == "opensuse-leap" ]; then
    TEMPS=$(uptime | awk '{print $3}')
fi

############### Programme
clear
echo -e ${WHITE}"=================== IP ====================="
echo -e ${WHITE}"IP locale         : "${GREEN}$IP
echo -e ${WHITE}"IP Publique       : "${GREEN}$IP_PUB
echo -e ${WHITE}"=================== Infos =================="
echo -e ${WHITE}"Distribution 	  : "$OS
if [ ! $ID == "manjaro" ] || [ ! $ID == "arch" ]; then
    echo -e "Version		  : "$VER
fi

if [ $ID == "fedora" ]; then #CentOs n'a pas cette option
    echo -e "Variante          : "$VARIANT
fi
echo -e "Version du Noyau  : "${BLUE}$KERNEL
echo -e ${WHITE}"Hostname    	  : "$HOSTNAME
echo -e "En Fonction 	  : "${RED}$TEMPS
echo -e ${WHITE}"Shell		  : "$SHELLO
echo -e ${WHITE}"Langue		  : "$LANG
echo -e "Fuseau Horaire    : "$FUSEAUH
echo -e "Heure - Date	  : "$HEURE
echo "=================== Matériel =================="
echo -e "Fabricant	  : "$CHAMAN " / " $SYSMAN
echo -e "Type de Chassis   : "$CHASSIS
echo -e "Processeur	  : "$CPU "x "${GREEN}$NBCPU
echo -e ${WHITE}"Architecture	  : "${MAGENTA}$XBITS
echo -e ${WHITE}"Mémoire Ram	  : "$MEM
echo -e "Mémoire used	  : "$USEDMEM " ($PMEM)"
echo "Carte Graphique	  : "$GPU
if [ $ID != "debian" ]; then
    echo "Mémoire video	  : "$GPUMEMORY
    echo "Resolution	  : "$RESOLUTION
    # Solution via sudo username / car root (debian) ne peut pas lancer glxinfo ou xrandr.
fi
echo "Carte audio	  : "$CAUDIO
echo "=================== Partitions ===================" ;
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
    else
        echo "[*] ln-sensors n'est pas installé."
    fi
fi
