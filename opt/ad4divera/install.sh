#!/bin/bash

clear
echo "------------------------------------------------------------------------------"
echo "Wir installieren nun alle benötigten Programme, "
echo "dies kann ein paar Minuten dauern."
echo "------------------------------------------------------------------------------"
sleep 1
sudo apt install jq unclutter cec-utils xdotool wkhtmltopdf wget motion apache2 php php-xml -y
sudo apt install --no-install-recommends firefox-esr -y
sudo chmod +x ~/Ad4Divera/ad4divera.sh
sudo chmod +x ~/Ad4Divera/einstellungen.sh
sudo rm /etc/xdg/lxsession/LXDE-pi/autostart
cat > autostart << EOF
@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
#@xscreensaver -no-splash

@unclutter -display :0 -noevents - grab

@xset s off
@xset s noblank
@xset -dpms

./Ad4Divera/ad4divera.sh
EOF
sudo mv autostart /etc/xdg/lxsession/LXDE-pi/
sleep 1
clear
echo "------------------------------------------------------------------------------"
echo "Die Installation der Programme ist abgeschlossen."
echo "Es geht in 5 Sekunden weiter zu den Einstellungen."
echo "------------------------------------------------------------------------------"
sleep 5
sudo rm ~/Ad4Divera/install.sh
./einstellungen.sh
