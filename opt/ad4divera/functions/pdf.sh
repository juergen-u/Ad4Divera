#!/bin/bash
#Funktion PDF
#Vers=1.0
#Autor=Jürgen Unfall

#Standard Werte.
STD_DOWNLOAD=0
STD_ANZAHLPDF=1

source /etc/ad4divera/colored_output.txt

function main(){
if [[ "$1" = @("-?"|"-h"|"--help") ]]; then fn_help;
elif [[ $1 = "-c" ]] && [[ -f $2 ]] && [[ $3 = "-f" ]] && [[ $4 = @(alarm|uebersicht|konfigurieren) ]]; then
    #Konfigurationsdatei Einbinden
    KONFIGURATIONSDATEI=$2
    AD4CONFIG=$(fn_parameter_auslesen 'AD4CONFIG')
    AD4FUNCTION=$(fn_parameter_auslesen 'AD4FUNCTION')
    AD4ARCHIV=$(fn_parameter_auslesen 'AD4ARCHIV')
    DOWNLOAD=$(fn_parameter_auslesen 'DOWNLOAD')
    ANZAHLPDF=$(fn_parameter_auslesen 'ANZAHLPDF')
    ACCESSKEY=$(fn_parameter_auslesen 'ACCESSKEY')
else
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo ""
    fn_help
    exit 1
fi
case $4 in
    alarm)          fn_pdf_alarm ;;
    uebersicht)     fn_pdf_uebersicht ;;
    konfigurieren)  fn_pdf_konfigurieren ;;
esac
exit 0
}

function fn_help() {
    echo "Beim Aufruf des Sktripts muss die Konfigurationsdatei übergeben werden"
    echo -e "Beispiel: ${YELLOW}pdf.sh -c /etc/ad4divera/ad4divera.conf -f {Funktion}${NORMAL_COLOR}"
    echo "Zur Verfügung stehende Funktionen:"
    echo -e "- ${LIGHT_BLUE}alarm${NORMAL_COLOR} : Ein Ausdruck der Alarmkarte wird erstellt."
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

function fn_pdf_alarm() {
	if [ $DOWNLOAD = 1 ]; then
    		PDFNAME=$(date +"%Y-%m-%d--%H-%M-%S")
		HAS_ID=`curl -s "https://www.divera247.com/api/last-alarm?accesskey=${ACCESSKEY}" | jq -r -j '.data .id'`
        	DOWNLOAD_URL="https://www.divera247.com/api/v2/alarms/download/"${HAS_ID}"?accesskey=${ACCESSKEY}"
        	wget $DOWNLOAD_URL -O $AD4ARCHIV/$PDFNAME.pdf
		lp -o media=A4 -n $ANZAHLPDF -o fit-to-page $AD4ARCHIV/$PDFNAME.pdf
    		if [ $? -ne 0 ]; then
      			echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_RED}*FEHLER*${NORMAL_COLOR} Ausdruck Einsatzdepesche: Es konnte kein Ausdruck erstellt werden" >> /var/log/ad4divera.log
    		else
      			echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Ausdruck Einsatzdepesche: Es wurden $ANZAHLKARTE Ausdruck(e) erstellt" >> /var/log/ad4divera.log
    		fi
	fi
}

function fn_pdf_konfiguration_lesen() {
  case $1 in
    PDF-Ausdruck)
	    case $(fn_parameter_auslesen DOWNLOAD) in
        0)  echo -e "${LIGHT_RED}Nein${NORMAL_COLOR}";;
        1)  echo -e "${LIGHT_GREEN}Ja${NORMAL_COLOR}";;
        *)  echo -e "${LIGHT_RED}Ungültiger Wert!${NORMAL_COLOR}"; fn_pdf_konfiguration_schreiben PDF-Ausdruck 0; echo "Der Wert wurde auf ${LIGHT_RED}Nein${NORMAL_COLOR} gesetzt";;
      esac
      ;;
    Anzahl-Ausdruck)    echo $ANZAHLPDF;;
    esac
}

function fn_pdf_konfiguration_schreiben() {
  case $1 in
    PDF-Ausdruck)    sed -i '/<\/DOWNLOAD>/ s/.*/<DOWNLOAD>'$2'<\/DOWNLOAD>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Ausdruck Einsatzdepesche: Wurde auf $(fn_pdf_konfiguration_lesen PDF-Ausdruck) eingestellt." >> /var/log/ad4divera.log;;
    Anzahl-Ausdruck)    sed -i '/<\/ANZAHLPDF>/ s/.*/<ANZAHLPDF>'$2'<\/ANZAHLPDF>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Ausdruck Einsatzdepesche: Es werden $(fn_pdf_konfiguration_lesen Anzahl-Ausdruck) Ausdrucke erstellt." >> /var/log/ad4divera.log;;
  esac
}

function fn_pdf_uebersicht() {
  echo -n "Ausdruck Einsatzdepesche:  "
  fn_pdf_konfiguration_lesen PDF-Ausdruck
  if [ $DOWNLOAD = 1 ]; then
      echo -n "Anzahl Ausdrucke:          "
      fn_pdf_konfiguration_lesen Anzahl-Ausdruck
  fi
}

function fn_pdf_konfigurieren() {
  clear
  for ((i = 0 ; i < 5 ; i++));do
  echo "Ausdruck Einsatzdepesche ändern"
  echo "------------------------------------------------------------------------------"
  echo -n "Derzeit ist der PDF-Ausdruck eingestellt auf "
  fn_pdf_konfiguration_lesen PDF-Ausdruck
  echo " "
  echo "Soll der Divera-PDF-Download als Einsatzdepesche geladen und ausgedruckt "
  echo "werden? (ja|nein)"
  echo " "
  echo -n "Bitte wählen: "
  read DOWNLOAD
  case $DOWNLOAD in
    ja)
      fn_pdf_konfiguration_schreiben PDF-Ausdruck 1
      echo ""
      echo -n "Der PDF-Ausdruck steht jetzt auf: "
      fn_pdf_konfiguration_lesen PDF-Ausdruck
      echo "------------------------------------------------------------------------------"
      echo -n "Wieviele Exemplare sollen gedruckt werden? "
      read ANZAHLPDF
      fn_pdf_konfiguration_schreiben Anzahl-Ausdruck $ANZAHLPDF
      echo "------------------------------------------------------------------------------"
      echo "Es werden $ANZAHLPDF ausgedruckt."
      sleep 1
      break
    ;;

    nein)
      fn_pdf_konfiguration_schreiben PDF-Ausdruck 0
      echo "------------------------------------------------------------------------------"
      echo -n "Der PDF-Ausdruck wurde geändert auf: "
      fn_pdf_konfiguration_lesen PDF-Ausdruck
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
