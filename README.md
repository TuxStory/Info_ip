## Info_ip
 
Nom : Info_ip  
Version : 0.3.5  
Auteur : Antoine Even 

Il s'agit d'un script Bash qui permet d'avoir plusieurs types d'informations sur le système
dont l'ip publique et l'ip locale.  
Requiert les droits d'administrations.  
Les dépendances suivantes doivent être installés :  
- ln-sensors
- curl
- hddterm
- geoip-bin  

Debian :  
`sudo apt install lm-sensors curl hddtemp geoip-bin`

Fedora :  
`sudo dnf install lm_sensors curl hddtemp perl-GeoIP2`

### Utilisation :
Utilisateur :
`sudo ./info_ip.sh`  

En root : 
`./info_ip.sh`

option du script :  
-t		: affiche les temperatures.  
-h		: affiche ce message.  
-v		: affiche la version.  
--help		: affiche ce message.  
--version	: affiche la version.  
