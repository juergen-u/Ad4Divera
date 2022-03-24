#!/bin/bash
sleep 15

# CONFIG- U. FUNKTIONS-DATEI EINBINDEN
source /etc/ad4divera/ad4divera.conf
source /etc/ad4divera/colored_output.txt

# MAUS NACH RECHTS BEWEGEN UM SICHER ZU STELLEN DAS SIE NICHT IM WEG IST
export DISPLAY=":0"
export XAUTHORITY=/home/pi/.Xauthority
xdotool mousemove 20000 500

# ZUGRIFF AUF DIE DIVERA247-EINHEIT
API_URL="https://www.divera247.com/api/last-alarm?accesskey=${ACCESSKEY}"
IS_MONITOR_ACTIVE=true

# PROGRAMM STARTEN
$AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f no_alarm &
$AD4FUNCTION/browser.sh -c $AD4CONFIG -f open &
echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${PURPLE}*AD4DIVERA WIRD GESTARTET*${NORMAL_COLOR}" >> /var/log/ad4divera.log

while true; do
	HAS_ALARM=`curl -s ${API_URL} | jq -r -j '.success'`

	if [ $HAS_ALARM = true ] && [ $IS_MONITOR_ACTIVE = false ]; then
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_RED}..::EINSATZ::..${NORMAL_COLOR}" >> /var/log/ad4divera.log
		sed -i s/^ALARM.*$/ALARM=$HAS_ALARM/ $AD4CONFIG

		## MONITOR/TV EINSCHALTEN
		$AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f alarm

      		## EINSATZDEPESCHE DOWNLOADEN, AUSDRUCKEN, ARCHIVIEREN
      		$AD4FUNCTION/pdf.sh -c $AD4CONFIG -f alarm

      		## KARTE DOWNLOADEN, AUSDRUCKEN, ARCHIVIEREN
      		$AD4FUNCTION/karte.sh -c $AD4CONFIG -f alarm

      		IS_MONITOR_ACTIVE=true

    	elif [ $HAS_ALARM = false ] && [ $IS_MONITOR_ACTIVE = true ]; then
		sed -i s/^ALARM.*$/ALARM=$HAS_ALARM/ $AD4CONFIG

		$AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f no_alarm

      		IS_MONITOR_ACTIVE=false

    	fi
sleep 20
done
