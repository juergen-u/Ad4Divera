#!/bin/bash
#Funktion MOTION
#Vers=2.0
#Autor=Jürgen Unfall

#Standard Werte.
STD_MOTION=0
STD_TIME=10

source /etc/ad4divera/colored_output.txt

function main(){
if [[ "$1" = @("-?"|"-h"|"--help") ]]; then fn_help;
elif [[ $1 = "-c" ]] && [[ -f $2 ]] && [[ $3 = "-f" ]] && [[ $4 = @(uebersicht|konfigurieren) ]]; then
    #Konfigurationsdatei Einbinden
    KONFIGURATIONSDATEI=$2
    AD4CONFIG=$(fn_parameter_auslesen 'AD4CONFIG')
    AD4FUNCTION=$(fn_parameter_auslesen 'AD4FUNCTION')
    BETRIEBSART=$(fn_parameter_auslesen 'BETRIEBSART')
    MOTION=$(fn_parameter_auslesen 'MOTION')
    TIME=$(fn_parameter_auslesen 'TIME')
else
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo ""
    fn_help
    exit 1
fi
case $4 in
    uebersicht)     fn_motion_uebersicht ;;
    konfigurieren)  fn_motion_konfigurieren ;;
esac
exit 0
}

function fn_help() {
    echo "Beim Aufruf des Sktripts muss die Konfigurationsdatei übergeben werden"
    echo -e "Beispiel: ${YELLOW}motion.sh -c /etc/ad4divera/ad4divera.conf -f {Funktion}${NORMAL_COLOR}"
    echo "Zur Verfügung stehende Funktionen:"
    echo -e "- ${LIGHT_BLUE}alarm${NORMAL_COLOR} : Ein Ausdruck der Alarmkarte wird erstellt."
    echo -e "- ${LIGHT_BLUE}uebersicht${NORMAL_COLOR} : Die in der Konfiguration hinterlegten Parameter werden ausgegeben"
    echo -e "- ${LIGHT_BLUE}konfigurieren${NORMAL_COLOR} : Die Kartenfunktion kann vollständig konfiguriert werden"
}

function fn_parameter_auslesen(){
#Funktion zum Setzen eines Standard Wertes muss noch implementiert werden.

if [[ -n $(sed -n s/^$1=//p "$KONFIGURATIONSDATEI") ]]; then
        sed -n s/^$1=//p "$KONFIGURATIONSDATEI"
    else
        eval echo \${$STD_$1}
    fi

#    sed -n s/^$1=//p "$KONFIGURATIONSDATEI"
}

function fn_motion_konfiguration_lesen() {
  case $1 in
    Motion)
	    case $(fn_parameter_auslesen MOTION) in
        0)  echo -e "${LIGHT_RED}Nein${NORMAL_COLOR}";;
        1)  echo -e "${LIGHT_GREEN}Ja${NORMAL_COLOR}";;
        *)  echo -e "${LIGHT_RED}Ungültiger Wert!${NORMAL_COLOR}"; fn_motion_konfiguration_schreiben Motion 0; echo "Der Wert wurde auf 'nein' gesetzt";;
      esac
      ;;
    Zeit)    echo $TIME;;
    Betriebsart)
            case $(fn_parameter_auslesen BETRIEBSART) in
        0)  echo -e "${LIGHT_RED}Nur bei Einsatz${NORMAL_COLOR}";;
        1)  echo -e "${LIGHT_GREEN}Immer an${NORMAL_COLOR}";;
        *)  echo -e "${LIGHT_RED}Ungültiger Wert!${NORMAL_COLOR}"; fn_motion_konfiguration_schreiben Betriebsart 1; echo "Der Wert wurde auf 'immer an' gesetzt";;
      esac
    esac
}

function fn_motion_konfiguration_schreiben() {
  case $1 in
    Motion)    sed -i s/^MOTION.*$/MOTION=$2/ "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Bewegungserkennung: Wurde auf $(fn_motion_konfiguration_lesen Motion) eingestellt." >> /var/log/ad4divera.log;;
    Zeit)    sed -i s/^TIME.*$/TIME=$2/ "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Bewegungserkennung: Die Zeit wurde auf $(fn_motion_konfiguration_lesen Zeit) Sekunden eingestellt." >> /var/log/ad4divera.log;;
    Betriebsart)    sed -i s/^BETRIEBSART.*$/BETRIEBSART=$2/ "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Betriebsart wurde auf $(fn_motion_konfiguration_lesen Betriebsart) geändert" >> /var/log/ad4divera.log;;
  esac
}

function fn_motion_uebersicht() {
  echo -n "Bewegungeserkennung aktiv: "
  fn_motion_konfiguration_lesen Motion
  if [ $MOTION = 1 ]; then
      echo -n "für Sekunden:              "
      fn_motion_konfiguration_lesen Zeit
  fi
}

function fn_motion_konfigurieren() {
  clear
  for ((i = 0 ; i < 5 ; i++));do
  echo "Motion ändern"
  echo "------------------------------------------------------------------------------"
  echo -n "Derzeit ist die Bewegungserkennung eingestellt auf "
  fn_motion_konfiguration_lesen Motion
  echo " "
  echo "Soll die Bewegungserkennung per Webcam aktiviert "
  echo "werden? (ja|nein)"
  echo ""
  echo -e "${YELLOW}HINWEIS"
  echo -e "Wird die Bewegungserkennung aktiviert ändert dies automatisch die Betriebsart"
  echo -e "auf ${LIGHT_RED}Nur bei Einsatz${YELLOW}, da sonst der Monitor/TV immer an wäre!${NORMAL_COLOR}"
  echo " "
  echo -n "Bitte wählen: "
  read MOTION
  case $MOTION in
    ja)
      fn_motion_konfiguration_schreiben Motion 1
      fn_motion_konfiguration_schreiben Betriebsart 0
      sudo sed -i 's/^; on_event_start value/on_event_start \/opt\/ad4divera\/functions\/anzeige.sh -c \/etc\/ad4divera\/ad4divera.conf -f motion/' /etc/motion/motion.conf
      sudo systemctl restart motion.service
      echo ""
      echo -n "Die Bewegungserkennung steht jetzt auf: "
      fn_motion_konfiguration_lesen Motion
      echo "------------------------------------------------------------------------------"
      echo "Wie lange soll der Monitor/TV in Sekunden an sein? "
      echo -n "Empfehlung: mindestens 60 Sekunden "
      read TIME
      fn_motion_konfiguration_schreiben Zeit $TIME
      echo "------------------------------------------------------------------------------"
      echo "Die Anzeige wird für $TIME eingeschaltet."
      sleep 1
      break
    ;;

    nein)
      fn_motion_konfiguration_schreiben Motion 0
      sudo sed -i 's/^on_event_start \/opt\/ad4divera\/functions\/anzeige.sh -c \/etc\/ad4divera\/ad4divera.conf -f motion/; on_event_start value/' /etc/motion/motion.conf
      sudo systemctl restart motion.service
      echo "------------------------------------------------------------------------------"
      echo -n "Die Bewegungserkennung wurde geändert auf: "
      fn_motion_konfiguration_lesen Motion
      echo ""
      echo -e "Soll die Betriebsart wieder auf ${LIGHT_GREEN}Immer an${NORMAL_COLOR} gestellt werden"
      echo -e "oder auf ${LIGHT_RED}Nur im Einsatz${NORMAL_COLOR} bleiben?"
      echo "(immer|einsatz)"
      echo ""
      echo -n "Bitte wählen: "
      read BETRIEBSART
      case $BETRIEBSART in
	  immer)
	  fn_motion_konfiguration_schreiben Betriebsart 1
	  echo "------------------------------------------------------------------------------"
	  echo -n "Die Betriebsart steht jetzt auf: "
	  fn_motion_konfiguration_lesen Betriebsart
	  sleep 1
	  $AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f no_alarm
	  clear
	  break
	;;

	  einsatz)
	  fn_motion_konfiguration_schreiben Betriebsart 0
	  echo "------------------------------------------------------------------------------"
	  echo -n "Die Betriebsart steht jetzt auf: "
	  fn_motion_konfiguration_lesen Betriebsart
	  sleep 1
	  $AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f no_alarm
	  clear
	  break
	;;

	  *)
	  clear
	  echo "------------------------------------------------------------------------------"
	  echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
	  echo -e "Gültige Eingabe: ${YELLOW}immer ${NORMAL_COLOR}oder ${YELLOW}einsatz${NORMAL_COLOR}"
	  echo ""
	;;
	esac
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
