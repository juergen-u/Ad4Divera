#!/bin/bash

AD4CONFIG="/etc/ad4divera/ad4divera.xml"
AD4FUNCTION="/opt/ad4divera/functions"
source /etc/ad4divera/colored_output.txt

clear
for ((i = 0 ; i < 5; i++));do
echo "Aktuelle Einstellungen"
echo " "
$AD4FUNCTION/keys.sh -c $AD4CONFIG -f uebersicht
$AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f uebersicht
$AD4FUNCTION/pdf.sh -c $AD4CONFIG -f uebersicht
$AD4FUNCTION/karte.sh -c $AD4CONFIG -f uebersicht
$AD4FUNCTION/motion.sh -c $AD4CONFIG -f uebersicht
echo "------------------------------------------------------------------------------"
echo "Was möchten Sie bearbeiten?"
echo " "
echo "   1 = Divera Access-Key und Autologin-Keys"
echo "   2 = Betriebsart & Anzeigegerät"
echo "   3 = Einsatzdepesche Ausdruck"
echo "   4 = Einsatzkarte Ausdruck"
echo "   5 = Webcamsteuerung"
echo "   9 = Beenden"
echo " "
echo -n "Bitte wählen:  "
read AUSWAHL
case $AUSWAHL in

  # Einstellung aller Divera Keys
  1) $AD4FUNCTION/keys.sh -c $AD4CONFIG -f konfigurieren
     let "i--"
  ;;

  # Einstellung der Betriebsart & Anzeigegerät
  2) $AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f konfigurieren
     let "i--"
  ;;

  # Einstellung der Einsatzdepesche Ausdrucke
  3) $AD4FUNCTION/pdf.sh -c $AD4CONFIG -f konfigurieren
     let "i--"
  ;;

  # Einstellung der Einsatzkarten Ausdrucke
  4) $AD4FUNCTION/karte.sh -c $AD4CONFIG -f konfigurieren
     let "i--"
  ;;

  # Einstellung der Webcamsteuerung
  5) $AD4FUNCTION/motion.sh -c $AD4CONFIG -f konfigurieren
     let "i--"
  ;;

  # Einstellungen beenden
  9)
    clear
    echo "------------------------------------------------------------------------------"
    echo "Programm wird beendet."
    sleep 2
    clear
    break
  ;;

  *)
    clear
    echo "------------------------------------------------------------------------------"
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo -e "Gültige Eingabe: ${YELLOW}1 - 5 ${NORMAL_COLOR}oder ${YELLOW}9${NORMAL_COLOR}"
    echo ""
  ;;

esac
done
