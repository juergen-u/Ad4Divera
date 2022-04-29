#!/bin/bash
#Funktion Karte
#Vers=1.0
#Autor=Jürgen Unfall

#Standard Werte.
STD_KARTE=0
STD_ANZAHLKARTE=1
STD_AUTOLOGINAUSDRUCK="unbekannt"

source /opt/ad4divera/functions/colored_output.txt

function main(){
if [[ "$1" = @("-?"|"-h"|"--help") ]]; then fn_help;
elif [[ $1 = "-c" ]] && [[ -f $2 ]] && [[ $3 = "-f" ]] && [[ $4 = @(alarm|no_alarm|uebersicht|konfigurieren) ]]; then
    #Konfigurationsdatei Einbinden
    KONFIGURATIONSDATEI=$2
    AD4CONFIG=$(fn_parameter_auslesen 'AD4CONFIG')
    AD4FUNCTION=$(fn_parameter_auslesen 'AD4FUNCTION')
    AD4ARCHIV=$(fn_parameter_auslesen 'AD4ARCHIV')
    KARTE=$(fn_parameter_auslesen 'KARTE')
    ANZAHLKARTE=$(fn_parameter_auslesen 'ANZAHLKARTE')
    AUTOLOGINAUSDRUCK=$(fn_parameter_auslesen 'AUTOLOGINAUSDRUCK')
else
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo ""
    fn_help
    exit 1
fi
case $4 in
    alarm)          fn_karte_alarm ;;
    no_alarm)       fn_karte_no_alarm ;;
    uebersicht)     fn_karte_uebersicht ;;
    konfigurieren)  fn_karte_konfigurieren ;;
esac
exit 0
}

function fn_help() {
    echo "Beim Aufruf des Sktripts muss die Konfigurationsdatei übergeben werden"
    echo -e "Beispiel: ${YELLOW}karte.sh -c /etc/ad4divera/ad4divera.xml -f {Funktion}${NORMAL_COLOR}"
    echo "Zur Verfügung stehende Funktionen:"
    echo -e "- ${LIGHT_BLUE}alarm${NORMAL_COLOR} : Ein Ausdruck der Alarmkarte wird erstellt."
    echo -e "- ${LIGHT_BLUE}no_alarm${NORMAL_COLOR} : Das Programm bleibt in Grundstellung."
    echo -e "- ${LIGHT_BLUE}uebersicht${NORMAL_COLOR} : Die in der Konfiguration hinterlegten Parameter werden ausgegeben"
    echo -e "- ${LIGHT_BLUE}konfigurieren${NORMAL_COLOR} : Die Kartenfunktion kann vollständig konfiguriert werden"
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

function fn_karte_alarm() {
	if [ $KARTE = 1 ]; then
    		BILDNAME=$(date +"%Y-%m-%d--%H-%M-%S")
		wkhtmltoimage --width 1920 --height 1280 --javascript-delay 30000 /var/www/html/ad4divera/maps.html $AD4ARCHIV/$BILDNAME.jpg
		lp -o media=A4 -n $ANZAHLKARTE -o fit-to-page $AD4ARCHIV/$BILDNAME.jpg
    		if [ $? -ne 0 ]; then
      			echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_RED}*FEHLER*${NORMAL_COLOR} Ausdruck Einsatzkarte: Es konnte kein Ausdruck erstellt werden" >> /var/log/ad4divera.log
    		else
      			echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Ausdruck Einsatzdepesche: Es wurden $ANZAHLKARTE Ausdruck(e) erstellt" >> $AD4LOG
    		fi
	fi
}

function fn_karte_konfiguration_lesen() {
  case $1 in
    Karten-Ausdruck)
	    case $(fn_parameter_auslesen KARTE) in
        0)  echo -e "${LIGHT_RED}Nein${NORMAL_COLOR}";;
        1)  echo -e "${LIGHT_GREEN}Ja${NORMAL_COLOR}";;
        *)  echo -e "${LIGHT_RED}Ungültiger Wert!${NORMAL_COLOR}"; fn_karte_konfiguration_schreiben Karten-Ausdruck 0; echo "Der Wert wurde auf 'nein' gesetzt";;
      esac
      ;;
    Anzahl-Ausdruck)    echo $ANZAHLKARTE;;
    Login-Key)  echo $AUTOLOGINAUSDRUCK;;
    esac
}

function fn_karte_konfiguration_schreiben() {
  case $1 in
    Karten-Ausdruck)    sed -i '/<\/KARTE>/ s/.*/<KARTE>'$2'<\/KARTE>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Ausdruck Einsatzkarte: Wurde auf $(fn_karte_konfiguration_lesen Karten-Ausdruck) eingestellt." >> $AD4LOG;;
    Anzahl-Ausdruck)    sed -i '/<\/ANZAHLKARTE>/ s/.*/<ANZAHLKARTE>'$2'<\/ANZAHLKARTE>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Ausdruck Einsatzkarte: Es werden $(fn_karte_konfiguration_lesen Anzahl-Ausdruck) Ausdrucke erstellt." >> $AD4LOG;;
    Login-Key) sed -i '/<\/AUTOLOGINAUSDRUCK>/ s/.*/<AUTOLOGINAUSDRUCK>'$AUTOLOGINAUSDRUCK'<\/AUTOLOGINAUSDRUCK>/' "$KONFIGURATIONSDATEI";
               sudo sed -i s/autologin\=.*$/autologin=$AUTOLOGINAUSDRUCK/  /var/www/html/ad4divera/maps.html
    ;;
  esac
}

function fn_karte_no_alarm() {
	exit 0
}

function fn_karte_uebersicht() {
  echo -n "Ausdruck Einsatzkarte:     "
  fn_karte_konfiguration_lesen Karten-Ausdruck
  if [ $KARTE = 1 ]; then
      echo -n "Anzahl Ausdrucke:          "
      fn_karte_konfiguration_lesen Anzahl-Ausdruck
  fi
}

function fn_karte_konfigurieren() {
  clear
  for ((i = 0 ; i < 5 ; i++));do
  echo "Ausdruck Einsatzkarte ändern"
  echo "------------------------------------------------------------------------------"
  echo -n "Derzeit ist der Karten-Ausdruck eingestellt auf "
  fn_karte_konfiguration_lesen Karten-Ausdruck
  echo " "
  echo "Soll die Kartenansicht des zweiten Divera-Monitor geladen und ausgedruckt "
  echo "werden? (ja|nein)"
  echo " "
  echo -n "Bitte wählen: "
  read KARTE
  case $KARTE in
    ja)
      fn_karte_konfiguration_schreiben Karten-Ausdruck 1
      echo ""
      echo -n "Der Karten-Ausdruck steht jetzt auf: "
      fn_karte_konfiguration_lesen Karten-Ausdruck
      echo "------------------------------------------------------------------------------"
      echo -n "Geben Sie den Autologin-Key des Karten-Monitors ein: "
      read AUTOLOGINAUSDRUCK
      fn_karte_konfiguration_schreiben Login-Key $AUTOLOGINAUSDRUCK
      echo "------------------------------------------------------------------------------"
      echo -n "Wieviele Exemplare sollen gedruckt werden? "
      read ANZAHLKARTE
      fn_karte_konfiguration_schreiben Anzahl-Ausdruck $ANZAHLKARTE
      echo "------------------------------------------------------------------------------"
      echo "Es werden $ANZAHLKARTE ausgedruckt."
      sleep 1
      break
    ;;

    nein)
      fn_karte_konfiguration_schreiben Karten-Ausdruck 0
      echo "------------------------------------------------------------------------------"
      echo -n "Der Karten-Ausdruck wurde geändert auf: "
      fn_karte_konfiguration_lesen Karten-Ausdruck
      sleep 1
      break
    ;;

    *)
      clear
      echo "------------------------------------------------------------------------------"
      echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
      echo -e "Gültige Eingabe: ${YELLOW}ja ${NORMAL_COLOR}oder ${YELLOW}nein${NORMAL_COLOR}"
      echo ""
    ;;
  esac
  done
}
main $@
