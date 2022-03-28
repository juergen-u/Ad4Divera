#!/bin/bash
# Kommentar
# Erfasse Aktuelles Verzeichns
VERZEICHNIS=$(pwd)
# Ändere das Verzeichnis
cd /etc/ad4divera
source colored_output.txt

# Funktionen werden initalisert
FUNKTION=(`ls -1 functions | awk -F"[.]+" '/.sh/{print $1}'`)

function main(){
if [[ "$1" = @("-?"|"-h"|"--help") ]]; then fn_help; exit 1;
elif [[ $1 = "-c" ]] && [[ -f $2 ]]; then
    #Konfigurationsdatei Einbinden
    KONFIGURATIONSDATEI=$2
else
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo ""
    fn_help
    exit 1
fi
clear
for ((i = 0 ; i < 5; i++));do
echo "Aktuelle Einstellungen"
echo " "
for (( j = 0 ; j < ${#FUNKTION[@]}; j++)); do functions/${FUNKTION[$j]}.sh -c $KONFIGURATIONSDATEI -f uebersicht; done
echo " "
echo "------------------------------------------------------------------------------"
echo "Was möchten Sie bearbeiten?"
echo " "
#Dynamisches Menü mit der Option "Beenden"
for (( k = 1 ; k <=  "${#FUNKTION[@]}"; k++)); do
  echo $k. ${FUNKTION[$k-1]}
done
echo $k. Beenden
echo " "
echo -n "Bitte wählen (1-$k):  "
read AUSWAHL
if [[ $AUSWAHL =~ [1-9] ]] && [[ $AUSWAHL =~ ? ]]; then
  if [[ $AUSWAHL -eq $k ]]; then
    # Einstellungen beenden
    clear
    echo "------------------------------------------------------------------------------"
    echo "Programm wird beendet."
    sleep 2
    clear
    exit 0;
  elif [[ $AUSWAHL -lt $k  ]]; then
    echo Konfiguration ${FUNKTION[$AUSWAHL-1]} wird aufgerufen
    sleep 2
    functions/${FUNKTION[$AUSWAHL-1]}.sh -c $KONFIGURATIONSDATEI -f konfigurieren
  fi
else
    clear
    echo "------------------------------------------------------------------------------"
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo -e "Gültige Eingabe: ${YELLOW}1 - $k ${NORMAL_COLOR}"
    echo " "
fi
done
}

function fn_help() {
    echo "Beim Aufruf des Sktripts muss die Konfigurationsdatei übergeben werden"
    echo -e "Beispiel: ${YELLOW}anzeige.sh -c /etc/ad4divera/ad4divera.conf -f {Funktion}${NORMAL_COLOR}"
    echo "Zur Verfügung stehende Funktionen:"
    echo -e "- ${LIGHT_BLUE}alarm${NORMAL_COLOR} : Ein Ausdruck der Alarmkarte wird erstellt."
    echo -e "- ${LIGHT_BLUE}uebersicht${NORMAL_COLOR} : Die in der Konfiguration hinterlegten Parameter werden ausgegeben"
    echo -e "- ${LIGHT_BLUE}konfigurieren${NORMAL_COLOR} : Die Kartenfunktion kann vollständig konfiguriert werden"
}
main $@
cd $VERZEICHNIS
exit 0
