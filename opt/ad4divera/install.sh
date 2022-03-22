#!/bin/bash

clear
echo "------------------------------------------------------------------------------"
echo "Wir installieren nun alle benötigten Programme, "
echo "dies kann ein paar Minuten dauern."
echo "------------------------------------------------------------------------------"
sleep 1
sudo apt install jq unclutter cec-utils xdotool wkhtmltopdf wget motion -y
sudo apt install --no-install-recommends firefox-esr -y
sleep 1
clear
echo "------------------------------------------------------------------------------"
echo "Die Installation der Programme ist abgeschlossen."
echo "Es geht in 5 Sekunden weiter zu den Einstellungen."
echo "------------------------------------------------------------------------------"
sleep 5

