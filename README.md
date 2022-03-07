# Allgemeines
Alarmdisplay mit Divera247.com

## Nutzen der Software
Mit diesem Script ist es möglich ein Alarmdisplay für Fahrzeughallen bei Feuerwehren, THW und anderen HiOrgs mit einem Raspberry Pi und Divera247 umzusetzen.

Getestet und betrieben wird dieser Code mit einem Raspberry Pi 3B+. 

## Installation
Es wird ein frisch aufgesetzter Raspberry Pi mit Internetverbindung vorausgesetzt!
Am besten greifen Sie per SSH auf den RPi zu.

Das install.sh-Script führt folgende Anweisungen durchgeführt:
- **Installation der benötigten Programme:** jq, unclutter, cec-utils, xdotool, wkhtmltopdf und firefox-esr
- **Anlegen der Ordner:** Ad4Divera und in diesem Archiv
- **Erstellen der Programm-Dateien:** ad4divera.conf, ad4divera.sh und maps.html
- **Editieren der Autostartdatei** /etc/xdg/lxsession/LXDE-pi/autostart
- **Abfrage der API-KEYs**
- **und Grundkonfiguration**

## SSH
Wenn Sie im Home-Verzeichnis Ihres RPi´s sind geben Sie den Befehl
`wget https://github.com/juergen-u/Ad4Divera/blob/main/install.sh`
ein um das Installations-Script zu laden.

Mit dem Befehl `sudo chmod +x install.sh` wird die Datei ausführbar gemacht. Nun mit `./install.sh`ausführen und den Anweisungen folgen.
