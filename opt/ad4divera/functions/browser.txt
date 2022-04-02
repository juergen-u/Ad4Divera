#!/bin/bash
#Funktion BROWSER
#Vers=2.0
#Autor=Jürgen Unfall

source /etc/ad4divera/colored_output.txt

function main(){
if [[ "$1" = @("-?"|"-h"|"--help") ]]; then fn_help;
elif [[ $1 = "-c" ]] && [[ -f $2 ]] && [[ $3 = "-f" ]] && [[ $4 = @(open) ]]; then
    #Konfigurationsdatei Einbinden
    KONFIGURATIONSDATEI=$2
    AD4CONFIG=$(fn_parameter_auslesen 'AD4CONFIG')
    AD4FUNCTION=$(fn_parameter_auslesen 'AD4FUNCTION')
    AUTOLOGINANZEIGE=$(fn_parameter_auslesen 'AUTOLOGINANZEIGE')
else
    echo -e "${LIGHT_RED}Ungültige Eingabe${NORMAL_COLOR}"
    echo ""
    fn_help
    exit 1
fi
case $4 in
    open)          fn_browser_open ;;
esac
exit 0
}

function fn_help() {
    echo "Beim Aufruf des Sktripts muss die Konfigurationsdatei übergeben werden"
    echo -e "Beispiel: ${YELLOW}anzeige.sh -c /etc/ad4divera/ad4divera.conf${NORMAL_COLOR}"
    echo "Zur Verfügung stehende Funktionen:"
    echo -e "- ${LIGHT_BLUE}open${NORMAL_COLOR} : Ein Ausdruck der Alarmkarte wird erstellt."
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

function fn_browser_open() {
	firefox-esr --display=:0 --private-window --kiosk https://app.divera247.com/monitor/1.html?autologin=${AUTOLOGINANZEIGE}
	exit 0
}
main $@
