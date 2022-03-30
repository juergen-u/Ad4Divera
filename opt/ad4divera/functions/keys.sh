#!/bin/bash
#Funktion KEYS
#Vers=2.0
#Autor=Jürgen Unfall

#Standard Werte.
STD_MOTION=0
STD_TIME=10

source /etc/ad4divera/colored_output.txt

function main(){
if [[ "$1" = @("-?"|"-h"|"--help") ]]; then fn_help;
elif [[ $1 = "-c" ]] && [[ -f $2 ]] && [[ $3 = "-f" ]] && [[ $4 = @(uebersicht|konfigurieren|web) ]]; then
    #Konfigurationsdatei Einbinden
    KONFIGURATIONSDATEI=$2
    AD4CONFIG=$(fn_parameter_auslesen 'AD4CONFIG')
    AD4FUNCTION=$(fn_parameter_auslesen 'AD4FUNCTION')
    ACCESSKEY=$(fn_parameter_auslesen 'ACCESSKEY')
    AUTOLOGINANZEIGE=$(fn_parameter_auslesen 'AUTOLOGINANZEIGE')
    AUTOLOGINAUSDRUCK=$(fn_parameter_auslesen 'AUTOLOGINAUSDRUCK')
else
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo ""
    fn_help
    exit 1
fi
case $4 in
    uebersicht)     fn_keys_uebersicht ;;
    konfigurieren)  fn_keys_konfigurieren ;;
    web)            fn_keys_web ;;
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

if [[ -n $(grep -oP '(?<=<'$1'>).*?(?=</'$1'>)' $KONFIGURATIONSDATEI) ]]; then
        grep -oP '(?<=<'$1'>).*?(?=</'$1'>)' $KONFIGURATIONSDATEI
    else
        eval echo \${$STD_$1}
    fi

#    sed -n s/^$1=//p "$KONFIGURATIONSDATEI"
}

function fn_keys_konfiguration_lesen() {
  case $1 in
    Accesskey) 		echo $ACCESSKEY;;
    Autologinanzeige)   echo $AUTOLOGINANZEIGE;;
    Autologinausdruck)	echo $AUTOLOGINAUSDRUCK;;
    esac
}

function fn_keys_konfiguration_schreiben() {
  case $1 in
    Accesskey) sed -i '/<\/ACCESSKEY>/ s/.*/<ACCESSKEY>'$ACCESSKEY'<\/ACCESSKEY>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Acesskey geändert." >> /var/log/ad4divera.log;;
    Autologinanzeige) sed -i '/<\/AUTOLOGINANZEIGE>/ s/.*/<AUTOLOGINANZEIGE>'$AUTOLOGINANZEIGE'<\/AUTOLOGINANZEIGE>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Autologin-Key Anzeige geändert." >> /var/log/ad4divera.log;;
    Autologinausdruck) sed -i '/<\/AUTOLOGINAUSDRUCK>/ s/.*/<AUTOLOGINAUSDRUCK>'$AUTOLOGINAUSDRUCK'<\/AUTOLOGINAUSDRUCK>/' "$KONFIGURATIONSDATEI"; echo -e "$(date +"%Y-%m-%d--%H-%M-%S") ${LIGHT_CYAN}*EINSTELLUNG GEÄNDERT*${NORMAL_COLOR} Autologin-Key Ausdruck geändert" >> /var/log/ad4divera.log;;
    Web) sed -i s/autologin.*$/autologin=$AUTOLOGINAUSDRUCK/ $AD4FUNCTION/maps.html;;
  esac
}
function fn_keys_web() {
#  fn_keys_konfiguration_lesen Accesskey
#  fn_keys_konfiguration_schreiben Accesskey $ACCESSKEY
#  fn_keys_konfiguration_lesen Autologinanzeige
#  fn_keys_konfiguration_schreiben Autologinanzeige $AUTOLOGINANZEIGE
  fn_keys_konfiguration_lesen Autologinausdruck
  fn_keys_konfiguration_schreiben Web $AUTOLOGINAUSDRUCK
}
function fn_keys_uebersicht() {
  echo -n "Divera-Access-Key:         "
  fn_keys_konfiguration_lesen Accesskey
  echo -n "Autologin-Key Anzeige:     "
  fn_keys_konfiguration_lesen Autologinanzeige
  echo -n "Autologin-Key Ausdruck:    "
  fn_keys_konfiguration_lesen Autologinausdruck
}

function fn_keys_konfigurieren() {
  clear
  for ((i = 0 ; i < 5 ; i++));do
  echo "Keys ändern"
  echo "------------------------------------------------------------------------------"
  echo -n "Divera-Access-Key:         "
  fn_keys_konfiguration_lesen Accesskey
  echo -n "Autologin-Key Anzeige:     "
  fn_keys_konfiguration_lesen Autologinanzeige
  echo -n "Autologin-Key Ausdruck:    "
  fn_keys_konfiguration_lesen Autologinausdruck
  echo " "
  echo "Welchen Key möchten Sie ändern?"
  echo "(access|anzeige|ausdruck)"
  echo " "
  echo -n "Bitte wählen: "
  read KEYS
  case $KEYS in
    access)
      echo -n "Geben Sie den Divera-Access-Key ein: "
      read ACCESSKEY
      fn_keys_konfiguration_schreiben Accesskey $ACCESSKEY
      echo "------------------------------------------------------------------------------"
      sleep 1
      break
    ;;

    anzeige)
      echo -n "Geben Sie den Autologin-Key Anzeige ein: "
      read AUTOLOGINANZEIGE
      fn_keys_konfiguration_schreiben Autologinanzeige $AUTOLOGINANZEIGE
      echo "------------------------------------------------------------------------------"
      sleep 1
      break
    ;;

    ausdruck)
      echo -n "Geben Sie den Autologin-Key Ausdruck ein: "
      read AUTOLOGINAUSDRUCK
      fn_keys_konfiguration_schreiben Autologinausdruck $AUTOLOGINAUSDRUCK
      echo "------------------------------------------------------------------------------"
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
