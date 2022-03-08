#!/bin/bash

clear
echo "------------------------------------------------------------------------------"
echo "Wir installieren nun alle benötigten Programme, "
echo "dies kann ein paar Minuten dauern."
echo "------------------------------------------------------------------------------"
sleep 1
sudo apt install jq unclutter cec-utils xdotool wkhtmltopdf wget -y
sudo apt install --no-install-recommends firefox-esr -y
mkdir ~/Ad4Divera
mkdir ~/Ad4Divera/Archiv
clear
echo "Allgemeine Konfiguration-Datei erstellen, Eingaben immer mit ENTER bestätigen"
echo "WICHTIG: Auf Groß/Klein-Schreibung achten!"
sleep 1
echo "------------------------------------------------------------------------------"
echo " "
echo "Bitte den Divera Access-Key aus Verwaltung > Schnittstellen eintragen."
echo " "
read ACCESSKEY
echo "------------------------------------------------------------------------------"
sleep 1
echo " "
echo "Bitte den Autologin-Key des Monitorbenutzers aus "
echo "Verwaltung > Setup > Monitore eintragen."
echo " "
read AUTOLOGIN
echo "------------------------------------------------------------------------------"
sleep 1
echo " "
echo "Soll der Monitor/Fernseher immer an sein oder nur wenn ein Einsatz ist?"
echo "  1. Ja, immer an"
echo "  2. Nein, nur bei Einsatz"
echo " "
echo "bitte wählen: "
read DAUERBETRIEB
echo "------------------------------------------------------------------------------"
sleep 1
echo " "
echo "Wird ein PC-Monitor oder TV (per CEC steuerbar) zur Anzeige verwendet?"
echo "  1. Monitor"
echo "  2. TV"
echo " "
echo "bitte wählen: "
read OUTPUT
echo "------------------------------------------------------------------------------"
sleep 1
echo " "
echo "Soll der Divera-PDF-Download als Einsatzdepesche geladen und "
echo "ausgedruckt werden?"
echo "  1. Ja"
echo "  2. Nein"
echo " "
echo "bitte wählen: "
read DOWNLOAD
echo "------------------------------------------------------------------------------"
sleep 1
echo " "
echo "Wie oft soll die Einsatzdepesche gedruckt werden?"
echo " "
read ANZAHLPDF
echo "------------------------------------------------------------------------------"
sleep 1
echo " "
echo "Soll eine Kartenansicht aus einem zweiten Divera-Monitor geladen und"
echo "ausgedruckt werden?"
echo "  1. Ja"
echo "  2. Nein"
echo " "
echo "bitte wählen: "
read KARTE
echo "------------------------------------------------------------------------------"
sleep 1
echo " "
echo "Wie oft soll die Karte gedruckt werden?"
echo " "
read ANZAHLKARTE
echo "------------------------------------------------------------------------------"
sleep 1
echo " "
echo "Wenn Sie eine Karte ausdrucken möchten bitte den Autologin-Key des"
echo "Monitorbenutzers aus Verwaltung > Setup > Monitore für den zweiten Monitor"
echo "eintragen."
echo "Ansonsten einfach mit ENTER weiter gehen."
echo " "
read KARTELOGIN
echo "------------------------------------------------------------------------------"
echo "Die Datei ad4divera.conf wurde erstellt."
echo "Diese kann jederzeit mit dem Befehl sudo nano Ad4Divera/ad4divera.conf"
echo "editiert werden."
sleep 5
cat > ~/Ad4Divera/ad4divera.conf << EOF
# Allgemeine Config
#
# Werden hier Aenderungen durchgeführt muss nach dem speichern ein reboot durchgeführt werden!
#
# Bitte den Divera Access-Key aus Verwaltung > Schnittstellen eintragen.
ACCESSKEY="$ACCESSKEY"
#
# Bitte den Autologin-Key des Monitorbenutzers aus
# Verwaltung > Setup > Monitore eintragen.
AUTOLOGIN="$AUTOLOGIN"
#
# Soll der Monitor/Fernseher immer an sein oder nur wenn ein Einsatz ist?
#  1. Ja, immer an
#  2. Nein, nur bei Einsatz
#
# bitte wählen:
DAUERBETRIEB="$DAUERBETRIEB"
#
# Wird ein PC-Monitor oder TV (per CEC steuerbar) zur Anzeige verwendet?
#   1. Monitor
#   2. TV
#
# bitte wählen:
OUTPUT="$OUTPUT"
#
# Soll der Divera-PDF-Download als Einsatzdepesche geladen und ausgedruckt werden?
#   1. Ja
#   2. Nein
#
# bitte wählen:
DOWNLOAD="$DOWNLOAD"
#
# Soll eine Kartenansicht aus einem zweiten Divera-Monitor geladen und
# ausgedruckt werden?
#   1. Ja
#   2. Nein
#
# bitte wählen:
KARTE="$KARTE"
#
# Soll in der Zeit in der kein Einsatz anliegt der Monitor/TV per Webcam gesteuert werden?
#   1. Ja
#   2. Nein
#
# bitte wählen:
MOTION="2"
#
# Mit STRG+O speichern und mit STRG+X den Editor schließen.
EOF
cat > ~/Ad4Divera/maps.html << EOF
<!DOCTYPE html>
<html>
<body>

<iframe src="https://app.divera247.com/monitor/1.html?autologin=$KARTELOGIN" width="1920" height="1200" style="border:none;">
</iframe>

</body>
</html>
EOF
cat > ~/Ad4Divera/ad4divera.sh << \EOF
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
        lp -d ALARMDRUCKER -o media=A4 -n 1 -o fit-to-page $HOME/akt_einsatz.pdf
      fi

      ## KARTE AUSDRUCKEN
      if [ $KARTE = 1 ]; then
        wkhtmltoimage --width 1920 --height 1280 --javascript-delay 30000 $HOME/Ad4Divera/maps.html $HOME/akt_route.jpg
        lp -d ALARMDRUCKER -o media=A4 -n 1 -o fit-to-page $HOME/akt_route.jpg
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
EOF
sudo chmod +x ~/Ad4Divera/ad4divera.sh
sudo rm /etc/xdg/lxsession/LXDE-pi/autostart
cat > autostart << EOF
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
#@xscreensaver -no-splash

@unclutter -display :0 -noevents - grab

@xset s off
@xset s noblank
@xset -dpms

./Ad4Divera/ad4divera.sh
EOF
sudo mv autostart /etc/xdg/lxsession/LXDE-pi/
sleep 1
clear
echo "------------------------------------------------------------------------------"
echo "Die Installation der Programme und der Config-Datei ist abgeschlossen!"
echo " "
echo "Wenn alles abgeschlossen und gespeichert ist starten Sie den RPI neu"
echo " "
echo "     sudo reboot"
echo " "
echo "Hat alles geklappt sollte, je nach Einstellung des Dauerbetriebes,"
echo "nun der Monitor im Vollbild angezeigt werden oder bei einem Einsatz an gehen."
echo "------------------------------------------------------------------------------"
sudo rm install-ad4divera.sh
