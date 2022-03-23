#!/bin/bash
#Funktion Anzeige
#Vers=2.0
#Autor=Jürgen Unfall
#Test
#Standard Werte.
STD_BETRIEBSART=1
STD_OUTPUT=1

source /etc/ad4divera/colored_output.txt

function main(){
if [[ "$1" = @("-?"|"-h"|"--help") ]]; then fn_help;
elif [[ $1 = "-c" ]] && [[ -f $2 ]] && [[ $3 = "-f" ]] && [[ $4 = @(alarm|no_alarm|motion|uebersicht|konfigurieren) ]]; then
    #Konfigurationsdatei Einbinden
    KONFIGURATIONSDATEI=$2
    AD4CONFIG=$(fn_parameter_auslesen 'AD4CONFIG')
    AD4FUNCTION=$(fn_parameter_auslesen 'AD4FUNCTION')
    BETRIEBSART=$(fn_parameter_auslesen 'BETRIEBSART')
    OUTPUT=$(fn_parameter_auslesen 'OUTPUT')
    ALARM=$(fn_parameter_auslesen 'ALARM')
    TIME=$(fn_parameter_auslesen 'TIME')
    MOTION=$(fn_parameter_auslesen 'MOTION')
else
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo ""
    fn_help
    exit 1
fi
case $4 in
    alarm)          fn_anzeige_alarm ;;
    no_alarm)       fn_anzeige_no_alarm ;;
    motion)         fn_anzeige_motion ;;
    uebersicht)     fn_anzeige_uebersicht ;;
    konfigurieren)  fn_anzeige_konfigurieren ;;
esac
exit 0
}

function fn_help() {
    echo "Beim Aufruf des Sktripts muss die Konfigurationsdatei übergeben werden"
    echo -e "Beispiel: ${YELLOW}anzeige.sh -c /etc/ad4divera/ad4divera.conf -f {Funktion}${NORMAL_COLOR}"
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

function fn_anzeige_motion() {
	if [ $BETRIEBSART = 0 ] && [ $OUTPUT = 1 ] && [ $MOTION = 1 ] && [ $ALARM = false ]; then
                vcgencmd display_power 1
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Monitor eingeschaltet, Bewegung." >> /var/log/ad4divera.log
		sleep $TIME
		vcgencmd display_power 0
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Monitor ausgeschaltet, Bewegung." >> /var/log/ad4divera.log
	elif [ $BETRIEBSART = 0 ] && [ $OUTPUT = 0 ] && [ $MOTION = 1 ] && [ $ALARM = false ]; then
                echo 'on 0' | cec-client -s -d 1
                echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} TV eingeschaltet, Bewegung." >> /var/log/ad4divera.log
		sleep $TIME
		echo 'standby 0' | cec-client -s -d 1
                echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} TV ausgeschaltet, Bewegung." >> /var/log/ad4divera.log
	elif [ $BETRIEBSART = 1 ] && [ $OUTPUT = 1 ] && [ $ALARM = false ]; then
                vcgencmd display_power 1
                echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Monitor eingeschaltet." >> /var/log/ad4divera.log
        elif [ $BETRIEBSART = 1 ] && [ $OUTPUT = 0 ] && [ $ALARM = false ]; then
                echo 'on 0' | cec-client -s -d 1
                echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} TV eingeschaltet." >> /var/log/ad4divera.log
	fi
}

function fn_anzeige_no_alarm() {
	if [ $BETRIEBSART = 1 ] && [ $OUTPUT = 1 ] && [ $ALARM = false ]; then
                vcgencmd display_power 1
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Monitor eingeschaltet." >> /var/log/ad4divera.log
        elif [ $BETRIEBSART = 1 ] && [ $OUTPUT = 0 ] && [ $ALARM = false ]; then
                echo 'on 0' | cec-client -s -d 1
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} TV eingeschaltet." >> /var/log/ad4divera.log
	elif [ $BETRIEBSART = 0 ] && [ $OUTPUT = 1 ] && [ $ALARM = false ]; then
                vcgencmd display_power 0
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Monitor ausgeschaltet." >> /var/log/ad4divera.log
        elif [ $BETRIEBSART = 0 ] && [ $OUTPUT = 0 ] && [ $ALARM = false ]; then
                echo 'standby 0' | cec-client -s -d 1
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} TV ausgeschaltet." >> /var/log/ad4divera.log
        fi
}

function fn_anzeige_alarm() {
	if [ $BETRIEBSART = 0 ] && [ $OUTPUT = 1 ]; then
        	vcgencmd display_power 1
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} Monitor eingeschaltet, Einsatz." >> /var/log/ad4divera.log
	elif [ $BETRIEBSART = 0 ] && [ $OUTPUT = 0 ]; then
		echo 'on 0' | cec-client -s -d 1
		echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_GREEN}*FUNKTION*${NORMAL_COLOR} TV eingeschaltet, Einsatz." >> /var/log/ad4divera.log
	fi
}

function fn_anzeige_konfiguration_lesen() {
  case $1 in
    Betriebsart)
	    case $(fn_parameter_auslesen BETRIEBSART) in
        0)  echo -e "${LIGHT_RED}Nur bei Einsatz${NORMAL_COLOR}";;
        1)  echo -e "${LIGHT_GREEN}Immer an${NORMAL_COLOR}";;
        *)  echo -e "${LIGHT_RED}Ungültiger Wert!${NORMAL_COLOR}"; fn_anzeige_konfiguration_schreiben Betriebsart 1; echo "Der Wert wurde auf 'immer an' gesetzt";;
      esac
      ;;
    Anzeigegeraet)
            case $(fn_parameter_auslesen OUTPUT) in
        0)  echo -e "${LIGHT_RED}TV${NORMAL_COLOR}";;
        1)  echo -e "${LIGHT_GREEN}Monitor${NORMAL_COLOR}";;
        *)  echo -e "${LIGHT_RED}Ungültiger Wert!${NORMAL_COLOR}"; fn_anzeige_konfiguration_schreiben Anzeigegeraet 1; echo "Der Wert wurde auf 'Monitor' gesetzt";;
      esac
      ;;
    esac
}

function fn_anzeige_konfiguration_schreiben() {
  case $1 in
    Betriebsart)    sed -i s/^BETRIEBSART.*$/BETRIEBSART=$2/ "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Betriebsart wurde auf $(fn_anzeige_konfiguration_lesen Betriebsart) geändert" >> /var/log/ad4divera.log;;
    Anzeigegeraet)    sed -i s/^OUTPUT.*$/OUTPUT=$2/ "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Anzeigegerät wurde auf $(fn_anzeige_konfiguration_lesen Anzeigegeraet) geändert" >> /var/log/ad4divera.log;;
  esac
}

function fn_anzeige_uebersicht() {
  echo -n "Betriebsart:               "
  fn_anzeige_konfiguration_lesen Betriebsart
  echo -n "Anzeigegerät:              "
  fn_anzeige_konfiguration_lesen Anzeigegeraet
}

function fn_anzeige_konfigurieren() {
  clear
  for ((i = 0 ; i < 5 ; i++));do
  echo "Was möchten Sie ändern?"
  echo "------------------------------------------------------------------------------"
  echo ""
  echo "Soll die Betriebsart oder das Anzeigegerät geändert werden?"
  echo "(betriebsart|anzeigegerät)"
  echo ""
  echo -n "Bitte wählen: "
  read auswahl
  case $auswahl in
    betriebsart)
	for ((i = 0 ; i < 5 ; i++));do
	echo "Betriebsart ändern"
	echo "------------------------------------------------------------------------------"
	echo -n "Derzeit eingestellt auf "
	fn_anzeige_konfiguration_lesen Betriebsart
	echo " "
	echo "Soll der Monitor/Fernseher immer an sein oder nur wenn ein Einsatz ist?"
	echo "(immer|einsatz)"
	echo " "
	echo -n "Bitte wählen: "
	read BETRIEBSART
	case $BETRIEBSART in
	  immer)
	  fn_anzeige_konfiguration_schreiben Betriebsart 1
	  echo "------------------------------------------------------------------------------"
	  echo -n "Die Betriebsart steht jetzt auf: "
	  fn_anzeige_konfiguration_lesen Betriebsart
	  sleep 1
	  $AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f no_alarm
	  break
	;;

	  einsatz)
	  fn_anzeige_konfiguration_schreiben Betriebsart 0
	  echo "------------------------------------------------------------------------------"
	  echo -n "Die Betriebsart steht jetzt auf: "
	  fn_anzeige_konfiguration_lesen Betriebsart
	  sleep 1
	  $AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f no_alarm
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
	done
   break
   ;;

   anzeigegerät)
	for ((i = 0 ; i < 5 ; i++));do
	echo "Anzeigegerät ändern"
	echo "------------------------------------------------------------------------------"
	echo -n "Derzeit eingestellt auf "
	fn_anzeige_konfiguration_lesen Anzeigegeraet
	echo " "
	echo "Wird ein PC-Monitor oder TV (per CEC steuerbar) zur Anzeige verwendet?"
	echo "(monitor|tv)"
	echo " "
	echo -n "Bitte wählen: "
	read OUTPUT
	case $OUTPUT in
	  monitor)
	  fn_anzeige_konfiguration_schreiben Anzeigegeraet 1
	  echo "------------------------------------------------------------------------------"
	  echo -n "Das Anzeigegerät steht jetzt auf: "
	  fn_anzeige_konfiguration_lesen Anzeigegeraet
	  sleep 1
	  $AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f no_alarm
	  break
	;;

	  tv)
	  fn_anzeige_konfiguration_schreiben Anzeigegeraet 0
	  echo "------------------------------------------------------------------------------"
	  echo -n "Das Anzeigegerät steht jetzt auf: "
	  fn_anzeige_konfiguration_lesen Anzeigegeraet
	  sleep 1
	  $AD4FUNCTION/anzeige.sh -c $AD4CONFIG -f no_alarm
	  break
	;;

	  *)
	  clear
	  echo "------------------------------------------------------------------------------"
	  echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
	  echo -e "Gültige Eingabe: ${YELLOW}monitor ${NORMAL_COLOR}oder ${YELLOW}tv${NORMAL_COLOR}"
	  echo ""
	;;
	esac
	done
   break
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
}
main $@

