#!/bin/bash

source /etc/ad4divera/ad4divera.conf
source /etc/ad4divera/colored_output.txt

clear
for ((i = 0 ; i < 5; i++));do
echo "Aktuelle Einstellungen"
echo " "
echo -n "Divera-Access-Key:         "
echo -e "${LIGHT_CYAN}$ACCESSKEY${NORMAL_COLOR}"
echo -n "Autologin-Key Anzeige:     "
echo -e "${LIGHT_CYAN}$AUTOLOGINANZEIGE${NORMAL_COLOR}"
$AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f uebersicht
$AD4FUNCTION/pdf.sh -c $AD4CONFIG -f uebersicht
$AD4FUNCTION/karte.sh -c $AD4CONFIG -f uebersicht
$AD4FUNCTION/motion.sh -c $AD4CONFIG -f uebersicht
echo "------------------------------------------------------------------------------"
echo "Was möchten Sie bearbeiten?"
echo " "
echo "   1 = Divera Access-Key"
echo "   2 = Autologin-Key Monitor"
echo "   3 = Betriebsart & Anzeigegerät"
echo "   4 = Einsatzdepesche Ausdruck"
echo "   5 = Einsatzkarte Ausdruck"
echo "   6 = Webcamsteuerung"
echo "   9 = Beenden"
echo " "
echo -n "Bitte wählen:  "
read AUSWAHL
case $AUSWAHL in

  # Einstellung des Divera Access-Key
  1)
  	clear
    	echo "Divera Access-Key ändern"
  	echo "------------------------------------------------------------------------------"
  	echo -e "Derzeit ist der Access-Key ${LIGHT_CYAN}$ACCESSKEY${NORMAL_COLOR} eingestellt"
  	echo ""
	echo -e "${YELLOW}Den Access-Key ihrer Einheit finden Sie unter Verwaltung > Schnittstellen${NORMAL_COLOR}"
	echo ""
	echo -n "Neuen Access-Key eingeben: "
  	read ACCESSKEY
  	sed -i "s/ACCESSKEY.*$/ACCESSKEY=$ACCESSKEY/" $AD4CONFIG
  	echo "------------------------------------------------------------------------------"
  	echo -e "Der Access-Key wurde auf ${LIGHT_CYAN}$ACCESSKEY${NORMAL_COLOR} geändert."
  	sleep 1
  ;;

  # Einstellung des Divera Autologin-Key für die Anzeige
  2)
    	clear
   	echo "Autologin-Key des Monitor ändern"
    	echo "------------------------------------------------------------------------------"
    	echo -e "Derzeit ist die Autologin-Key ${LIGHT_CYAN}$AUTOLOGINANZEIGE${NORMAL_COLOR} eingestellt"
    	echo ""
	echo -e "${YELLOW}Den Autologin-Key ihres Monitors finden Sie unter Verwaltung > Setup${NORMAL_COLOR}"
        echo ""
    	echo -n "Neuen Autologin-Key eingeben: "
    	read AUTOLOGINANZEIGE
    	sed -i "s/AUTOLOGINANZEIGE.*$/AUTOLOGINANZEIGE=$AUTOLOGINANZEIGE/" $AD4CONFIG
    	echo "------------------------------------------------------------------------------"
    	echo -e "Der Autologin-Key wurde auf ${LIGHT_CYAN}$AUTOLOGINANZEIGE${NORMAL_COLOR} geändert."
    	sleep 1
  ;;

  # Einstellung der Betriebsart & Anzeigegerät
  3) $AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f konfigurieren;;

  # Einstellung der Einsatzdepesche Ausdrucke
  4) $AD4FUNCTION/pdf.sh -c $AD4CONFIG -f konfigurieren;;

  # Einstellung der Einsatzkarten Ausdrucke
  5) $AD4FUNCTION/karte.sh -c $AD4CONFIG -f konfigurieren;;

  # Einstellung der Webcamsteuerung
  6) $AD4FUNCTION/motion.sh -c $AD4CONFIG -f konfigurieren;;

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
    echo -e "Gültige Eingabe: ${YELLOW}1 - 6 ${NORMAL_COLOR}oder ${YELLOW}9${NORMAL_COLOR}"
    echo ""
  ;;

esac
done
