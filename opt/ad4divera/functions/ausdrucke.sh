#!/bin/bash
#Funktion AUSDRUCKE
#Vers=2.0
#Autor=Jürgen Unfall

#Standard Werte.
STD_DOWNLOAD=0
STD_ANZAHLPDF=1
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
    AD4LOG=$(fn_parameter_auslesen 'AD4LOG')
    AD4FUNCTION=$(fn_parameter_auslesen 'AD4FUNCTION')
    AD4ARCHIV=$(fn_parameter_auslesen 'AD4ARCHIV')
    DOWNLOAD=$(fn_parameter_auslesen 'DOWNLOAD')
    ANZAHLPDF=$(fn_parameter_auslesen 'ANZAHLPDF')
    ACCESSKEY=$(fn_parameter_auslesen 'ACCESSKEY')
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
    alarm)          fn_ausdrucke_alarm ;;
    no_alarm)       fn_ausdrucke_no_alarm ;;
    uebersicht)     fn_ausdrucke_uebersicht ;;
    konfigurieren)  fn_ausdrucke_konfigurieren ;;
esac
exit 0
}

function fn_help() {
    echo "Beim Aufruf des Sktripts muss die Konfigurationsdatei übergeben werden"
    echo -e "Beispiel: ${YELLOW}ausdrucke.sh -c /etc/ad4divera/ad4divera.xml -f {Funktion}${NORMAL_COLOR}"
    echo "Zur Verfügung stehende Funktionen:"
    echo -e "- ${LIGHT_BLUE}alarm${NORMAL_COLOR} : Ein Ausdruck der Einsatzdepesche wird erstellt."
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

function fn_ausdrucke_alarm() {
	if [ $DOWNLOAD = 1 ]; then
    		PDFNAME=$(date +"%Y-%m-%d--%H-%M-%S")
		HAS_ID=`curl -s "https://www.divera247.com/api/last-alarm?accesskey=${ACCESSKEY}" | jq -r -j '.data .id'`
        	DOWNLOAD_URL="https://www.divera247.com/api/v2/alarms/download/"${HAS_ID}"?accesskey=${ACCESSKEY}"
        	wget $DOWNLOAD_URL -O $AD4ARCHIV/$PDFNAME.pdf
		lp -o media=A4 -n $ANZAHLPDF -o fit-to-page $AD4ARCHIV/$PDFNAME.pdf
    		if [ $? -ne 0 ]; then
      			echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_RED}*FEHLER*${NORMAL_COLOR} Ausdruck Einsatzdepesche: Es konnte kein Ausdruck erstellt werden" >> $AD4LOG
    		else
      			echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Ausdruck Einsatzdepesche: Es wurden $ANZAHLPDF Ausdruck(e) erstellt" >> $AD4LOG
    		fi
	fi
	if [ $KARTE = 1 ]; then
    		BILDNAME=$(date +"%Y-%m-%d--%H-%M-%S")
		wkhtmltoimage --width 1920 --height 1280 --javascript-delay 30000 /var/www/html/ad4divera/maps.html $AD4ARCHIV/$BILDNAME.jpg
		lp -o media=A4 -n $ANZAHLKARTE -o fit-to-page $AD4ARCHIV/$BILDNAME.jpg
    		if [ $? -ne 0 ]; then
      			echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_RED}*FEHLER*${NORMAL_COLOR} Ausdruck Einsatzkarte: Es konnte kein Ausdruck erstellt werden" >> $AD4LOG
    		else
      			echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Ausdruck Einsatzkarte: Es wurden $ANZAHLKARTE Ausdruck(e) erstellt" >> $AD4LOG
    		fi
	fi
}

function fn_ausdrucke_konfiguration_lesen() {
  case $1 in
    PDF-Ausdruck)
	    case $(fn_parameter_auslesen DOWNLOAD) in
        0)  echo -e "${LIGHT_RED}Nein${NORMAL_COLOR}";;
        1)  echo -e "${LIGHT_GREEN}Ja${NORMAL_COLOR}";;
        *)  echo -e "${LIGHT_RED}Ungültiger Wert!${NORMAL_COLOR}"; fn_ausdrucke_konfiguration_schreiben PDF-Ausdruck 0; echo "Der Wert wurde auf ${LIGHT_RED}Nein${NORMAL_COLOR} gesetzt";;
      esac
      ;;
    Anzahl-Ausdruck)    echo $ANZAHLPDF;;
    Karten-Ausdruck)
	    case $(fn_parameter_auslesen KARTE) in
        0)  echo -e "${LIGHT_RED}Nein${NORMAL_COLOR}";;
        1)  echo -e "${LIGHT_GREEN}Ja${NORMAL_COLOR}";;
        *)  echo -e "${LIGHT_RED}Ungültiger Wert!${NORMAL_COLOR}"; fn_ausdrucke_konfiguration_schreiben Karten-Ausdruck 0; echo "Der Wert wurde auf 'nein' gesetzt";;
      esac
      ;;
    Anzahl-Ausdruck)    echo $ANZAHLKARTE;;
    Login-Key)  echo $AUTOLOGINAUSDRUCK;;
    esac
}

function fn_ausdrucke_konfiguration_schreiben() {
  case $1 in
    PDF-Ausdruck)    sed -i '/<\/DOWNLOAD>/ s/.*/<DOWNLOAD>'$2'<\/DOWNLOAD>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Ausdruck Einsatzdepesche: Wurde auf $(fn_ausdrucke_konfiguration_lesen PDF-Ausdruck) eingestellt." >> $AD4LOG;;
    Anzahl-Ausdruck)    sed -i '/<\/ANZAHLPDF>/ s/.*/<ANZAHLPDF>'$2'<\/ANZAHLPDF>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Ausdruck Einsatzdepesche: Es werden $(fn_ausdrucke_konfiguration_lesen Anzahl-Ausdruck) Ausdrucke erstellt." >> $AD4LOG;;
    Karten-Ausdruck)    sed -i '/<\/KARTE>/ s/.*/<KARTE>'$2'<\/KARTE>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Ausdruck Einsatzkarte: Wurde auf $(fn_ausdrucke_konfiguration_lesen Karten-Ausdruck) eingestellt." >> $AD4LOG;;
    Anzahl-Ausdruck)    sed -i '/<\/ANZAHLKARTE>/ s/.*/<ANZAHLKARTE>'$2'<\/ANZAHLKARTE>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Ausdruck Einsatzkarte: Es werden $(fn_ausdrucke_konfiguration_lesen Anzahl-Ausdruck) Ausdrucke erstellt." >> $AD4LOG;;
    Login-Key) sed -i '/<\/AUTOLOGINAUSDRUCK>/ s/.*/<AUTOLOGINAUSDRUCK>'$AUTOLOGINAUSDRUCK'<\/AUTOLOGINAUSDRUCK>/' "$KONFIGURATIONSDATEI";
               sudo sed -i s/autologin\=.*$/autologin=$AUTOLOGINAUSDRUCK/  /var/www/html/ad4divera/maps.html
    ;;
  esac
}

function fn_ausdrucke_no_alarm() {
	exit 0
}

function fn_ausdrucke_uebersicht() {
  echo -n "Ausdruck Einsatzdepesche:  "
  fn_ausdrucke_konfiguration_lesen PDF-Ausdruck
  if [ $DOWNLOAD = 1 ]; then
      echo -n "Anzahl Ausdrucke:          "
      fn_ausdrucke_konfiguration_lesen Anzahl-Ausdruck
  fi
  echo -n "Ausdruck Einsatzkarte:     "
  fn_ausdrucke_konfiguration_lesen Karten-Ausdruck
  if [ $KARTE = 1 ]; then
      echo -n "Anzahl Ausdrucke:          "
      fn_ausdrucke_konfiguration_lesen Anzahl-Ausdruck
  fi
}

function fn_ausdrucke_konfigurieren() {
  clear
  for ((i = 0 ; i < 5 ; i++));do
  echo "Was möchten Sie ändern?"
  echo "------------------------------------------------------------------------------"
  echo ""
  echo "Welcher Ausdruck soll geändert werden?"
  echo "(depesche|karte)"
  echo ""
  echo -n "Bitte wählen: "
  read auswahl
  case $auswahl in
    depesche)
    for ((i = 0 ; i < 5 ; i++));do
    echo "Ausdruck Einsatzdepesche ändern"
    echo "------------------------------------------------------------------------------"
    echo -n "Derzeit ist der PDF-Ausdruck eingestellt auf "
    fn_ausdrucke_konfiguration_lesen PDF-Ausdruck
    echo " "
    echo "Soll der Divera-PDF-Download als Einsatzdepesche geladen und ausgedruckt "
    echo "werden? (ja|nein)"
    echo " "
    echo -n "Bitte wählen: "
    read DOWNLOAD
    case $DOWNLOAD in
      ja)
        fn_ausdrucke_konfiguration_schreiben PDF-Ausdruck 1
        echo ""
        echo -n "Der PDF-Ausdruck steht jetzt auf: "
        fn_ausdrucke_konfiguration_lesen PDF-Ausdruck
        echo "------------------------------------------------------------------------------"
        echo -n "Wieviele Exemplare sollen gedruckt werden? "
        read ANZAHLPDF
        fn_ausdrucke_konfiguration_schreiben Anzahl-Ausdruck $ANZAHLPDF
        echo "------------------------------------------------------------------------------"
        echo "Es werden $ANZAHLPDF ausgedruckt."
        sleep 1
        break
      ;;

      nein)
        fn_ausdrucke_konfiguration_schreiben PDF-Ausdruck 0
        echo "------------------------------------------------------------------------------"
        echo -n "Der PDF-Ausdruck wurde geändert auf: "
        fn_ausdrucke_konfiguration_lesen PDF-Ausdruck
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
    break
    ;;

    karte)
    for ((i = 0 ; i < 5 ; i++));do
    echo "Ausdruck Einsatzkarte ändern"
    echo "------------------------------------------------------------------------------"
    echo -n "Derzeit ist der Karten-Ausdruck eingestellt auf "
    fn_ausdrucke_konfiguration_lesen Karten-Ausdruck
    echo " "
    echo "Soll die Kartenansicht des zweiten Divera-Monitor geladen und ausgedruckt "
    echo "werden? (ja|nein)"
    echo " "
    echo -n "Bitte wählen: "
    read KARTE
    case $KARTE in
      ja)
        fn_ausdrucke_konfiguration_schreiben Karten-Ausdruck 1
        echo ""
        echo -n "Der Karten-Ausdruck steht jetzt auf: "
        fn_ausdrucke_konfiguration_lesen Karten-Ausdruck
        echo "------------------------------------------------------------------------------"
        echo -n "Geben Sie den Autologin-Key des Karten-Monitors ein: "
        read AUTOLOGINAUSDRUCK
        fn_ausdrucke_konfiguration_schreiben Login-Key $AUTOLOGINAUSDRUCK
        echo "------------------------------------------------------------------------------"
        echo -n "Wieviele Exemplare sollen gedruckt werden? "
        read ANZAHLKARTE
        fn_ausdrucke_konfiguration_schreiben Anzahl-Ausdruck $ANZAHLKARTE
        echo "------------------------------------------------------------------------------"
        echo "Es werden $ANZAHLKARTE ausgedruckt."
        sleep 1
        break
      ;;

      nein)
        fn_ausdrucke_konfiguration_schreiben Karten-Ausdruck 0
        echo "------------------------------------------------------------------------------"
        echo -n "Der Karten-Ausdruck wurde geändert auf: "
        fn_ausdrucke_konfiguration_lesen Karten-Ausdruck
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
    ;;

    *)
	clear
        echo "------------------------------------------------------------------------------"
        echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
        echo -e "Gültige Eingabe: ${YELLOW}betriebsart ${NORMAL_COLOR}oder ${YELLOW}anzeigegerät${NORMAL_COLOR}"
        echo ""
   ;;
   esac
   done
   break
}
main $@
