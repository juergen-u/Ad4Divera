#!/bin/bash

# INFORMATIONEN AUS DER CONFIG-DATEI LADEN
CONFIG="$HOME/Ad4Divera/ad4divera.conf"
. $CONFIG

# FIREFOX IM VOLLBILD MIT AUTO-LOGIN STARTEN
firefox-esr --display=:0 --private-window --kiosk https://app.divera247.com/monitor/1.html?autologin=${AUTOLOGIN} &

# MAUS NACH RECHTS BEWEGEN UM SICHER ZU STELLEN DAS SIE NICHT IM WEG IST
export DISPLAY=":0"
export XAUTHORITY=/home/pi/.Xauthority
xdotool mousemove 20000 500

# ZUGRIFF AUF DIE DIVERA247-EINHEIT
API_URL="https://www.divera247.com/api/last-alarm?accesskey=${ACCESSKEY}"
IS_MONITOR_ACTIVE=true

while true; do
  HAS_ALARM=`curl -s ${API_URL} | jq -r -j '.success'`
    if [ $HAS_ALARM = true ] && [ $IS_MONITOR_ACTIVE = false ]; then

      ## Webcam-Steuerung
      if [ $MOTION = 1 ]; then
        sudo systemctl stop motion
      fi

      ## Monitor/TV ansteuern
      if [ $DAUERBETRIEB = 2 ] && [ $OUTPUT = 1 ]; then
        vcgencmd display_power 1
      elif [ $DAUERBETRIEB = 2 ] && [ $OUTPUT = 2 ]; then
        echo 'on 0' | cec-client -s -d 1
      fi

      ## PDF DOWNLOADEN UND AUSDRUCKEN
      if [ $DOWNLOAD = 1 ]; then
        HAS_ID=`curl -s ${API_URL} | jq -r -j '.data .id'`
        DOWNLOAD_URL="https://www.divera247.com/api/v2/alarms/download/"${HAS_ID}"?accesskey=${ACCESSKEY}"
        wget $DOWNLOAD_URL -O $HOME/akt_einsatz.pdf
        lp -d ALARMDRUCKER -o media=A4 -n $ANZAHLPDF -o fit-to-page $HOME/akt_einsatz.pdf
      fi

      ## KARTE AUSDRUCKEN
      if [ $KARTE = 1 ]; then
        wkhtmltoimage --width 1920 --height 1280 --javascript-delay 30000 $HOME/Ad4Divera/maps.html $HOME/akt_route.jpg
        lp -d ALARMDRUCKER -o media=A4 -n $ANZAHLKARTE -o fit-to-page $HOME/akt_route.jpg
      fi

      ## ARCHIVIEREN UND AUSDRUCKE WIEDER LOESCHEN
      if [ $DOWNLOAD = 1 ]; then
        sudo cp $HOME/akt_einsatz.pdf $HOME/Ad4Divera/Archiv/$(date +"%Y-%m-%d--%H-%M-%S").pdf
	      sudo rm $HOME/akt_einsatz.pdf
      fi

      if [ $KARTE = 1 ]; then
        sudo cp $HOME/akt_route.jpg $HOME/Ad4Divera/Archiv/$(date +"%Y-%m-%d--%H-%M-%S").jpg
	      sudo rm $HOME/akt_route.jpg
      fi

      IS_MONITOR_ACTIVE=true

    elif [ $HAS_ALARM = false ] && [ $IS_MONITOR_ACTIVE = true ]; then

      ## Webcam-Steuerung
      if [ $MOTION = 1 ]; then
        sudo systemctl start motion
      fi

      ## Monitor/TV ansteuern
      if [ $DAUERBETRIEB = 2 ] && [ $OUTPUT = 1 ]; then
        vcgencmd display_power 0
      elif [ $DAUERBETRIEB = 2 ] && [ $OUTPUT = 2 ]; then
        echo 'standby 0' | cec-client -s -d 1
      fi

      IS_MONITOR_ACTIVE=false

    fi

sleep 20
done
