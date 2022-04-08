#!/bin/bash

# Erfasse Aktuelles Verzeichns
VERZEICHNIS=$(pwd)
# Ändere das Verzeichnis
cd /opt/ad4divera

sleep 15

# CONFIG- U. FUNKTIONS-DATEI EINBINDEN
source /opt/ad4divera/functions/colored_output.txt

# Funktionen werden initalisert
FUNKTION=(`ls -1 functions | awk -F"[.]+" '/.sh/{print $1}'`)

# MAUS NACH RECHTS BEWEGEN UM SICHER ZU STELLEN DAS SIE NICHT IM WEG IST
export DISPLAY=":0"
export XAUTHORITY=/home/pi/.Xauthority
xdotool mousemove 20000 500

function main(){
if [[ "$1" = @("-?"|"-h"|"--help") ]]; then fn_help;
elif [[ $1 = "-c" ]] && [[ -f $2 ]] && [[ $3 = "-f" ]] && [[ $4 = @(start) ]]; then
    #Konfigurationsdatei Einbinden
    KONFIGURATIONSDATEI=$2
    AD4CONFIG=$(fn_parameter_auslesen 'AD4CONFIG')
    AD4FUNCTION=$(fn_parameter_auslesen 'AD4FUNCTION')
    ACCESSKEY=$(fn_parameter_auslesen 'ACCESSKEY')
    AUTOLOGINANZEIGE=$(fn_parameter_auslesen 'AUTOLOGINANZEIGE')
else
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo ""
    fn_help
    exit 1
fi
case $4 in
    start)     fn_ad4divera_start ;;
esac
exit 0
}

function fn_help() {
    echo "Beim Aufruf des Sktripts muss die Konfigurationsdatei übergeben werden"
    echo -e "Beispiel: ${YELLOW}ad4divera.sh -c /etc/ad4divera/ad4divera.xml -f {Funktion}${NORMAL_COLOR}"
    echo "Zur Verfügung stehende Funktionen:"
    echo -e "- ${LIGHT_BLUE}start${NORMAL_COLOR} : Startet alle Programmteile von Ad4Divera."
}

function fn_parameter_auslesen(){
#Funktion zum Setzen eines Standard Wertes muss noch implementiert werden.

if [[ -n $(grep -oP '(?<=<'$1'>).*?(?=</'$1'>)' $KONFIGURATIONSDATEI) ]]; then
        grep -oP '(?<=<'$1'>).*?(?=</'$1'>)' $KONFIGURATIONSDATEI
    else
        eval echo \${$STD_$1}
    fi

#    sed -n s/^$1=//p "$KONFIGURATIONSDATEI"
}

function fn_ad4divera_start() {


# ZUGRIFF AUF DIE DIVERA247-EINHEIT
API_URL="https://www.divera247.com/api/last-alarm?accesskey=${ACCESSKEY}"
IS_MONITOR_ACTIVE=true

# PROGRAMM STARTEN
$AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f no_alarm &
firefox-esr --display=:0 --private-window --kiosk https://app.divera247.com/monitor/1.html?autologin=${AUTOLOGINANZEIGE} &
echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${PURPLE}*AD4DIVERA WIRD GESTARTET*${NORMAL_COLOR}" >> /var/log/ad4divera.log

while true; do
	HAS_ALARM=`curl -s ${API_URL} | jq -r -j '.success'`
	HAS_ID_NOW=`curl -s ${API_URL} | jq -r -j '.data .id'`

	if [ $HAS_ALARM = true ] && [ $IS_MONITOR_ACTIVE = false ]; then
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_RED}..::EINSATZ::..${NORMAL_COLOR}" >> /var/log/ad4divera.log
		sed -i '/<\/ALARM>/ s/.*/<ALARM>'$HAS_ALARM'<\/ALARM>/' "$KONFIGURATIONSDATEI"

		for (( j = 0 ; j < ${#FUNKTION[@]}; j++)); do functions/${FUNKTION[$j]}.sh -c $KONFIGURATIONSDATEI -f alarm; done

		CURRENT_ID=`curl -s ${API_URL} | jq -r -j '.data .id'`
      		IS_MONITOR_ACTIVE=true

    	elif [ $HAS_ALARM = true ] && [ $HAS_ID_NOW != $CURRENT_ID ];then
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_RED}..::NEUER EINSATZ::..${NORMAL_COLOR}" >> /var/log/ad4divera.log

		for (( j = 0 ; j < ${#FUNKTION[@]}; j++)); do functions/${FUNKTION[$j]}.sh -c $KONFIGURATIONSDATEI -f alarm; done

	elif [ $HAS_ALARM = false ] && [ $IS_MONITOR_ACTIVE = true ]; then
		sed -i '/<\/ALARM>/ s/.*/<ALARM>'$HAS_ALARM'<\/ALARM>/' "$KONFIGURATIONSDATEI"

		for (( j = 0 ; j < ${#FUNKTION[@]}; j++)); do functions/${FUNKTION[$j]}.sh -c $KONFIGURATIONSDATEI -f no_alarm; done

      		IS_MONITOR_ACTIVE=false

    	fi
sleep 20
done
}
main $@
