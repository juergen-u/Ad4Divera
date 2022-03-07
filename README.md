# Allgemeines
Alarmdisplay mit Divera247.com

## Nutzen der Software
Mit diesem Script ist es möglich ein Alarmdisplay für Fahrzeughallen bei Feuerwehren, THW und anderen HiOrgs mit einem Raspberry Pi und Divera247 umzusetzen.

Getestet und betrieben wird dieser Code mit einem Raspberry Pi 3B+. 

## Voraussetzung und Hinweise
Es wird ein frisch aufgesetzter Raspberry Pi mit Internetverbindung vorausgesetzt!
Am besten greifen Sie per SSH auf den RPi zu.

### Voraussetzungen bei Divera247.com: 
- eine Einheit ist angelegt,
- einen Monitor ist eingerichtet,
- ein Monitorbenutzer mit Auto-Login ist für den Monitor angelegt!

**Noch ein Tipp zu den Monitoren:** Ich habe die besten Ergebnisse bekommen wenn die Anzeige-Höhe bei der Zusammensetzung der Inhalte nicht auf *automatisch* sondern auf *prozent* eingestellt war und hier dann auf **99%**.
Dadurch wird der gesammte Inhalt ohne Scrollbalken dargestellt!

### install.sh
Das install.sh-Script führt folgende Anweisungen/Aktionen durchgeführt:
- **Installation der benötigten Programme:** jq, unclutter, cec-utils, xdotool, wkhtmltopdf und firefox-esr
- **Anlegen der Ordner:** Ad4Divera und in diesem Archiv
- **Erstellen der Programm-Dateien:** ad4divera.conf, ad4divera.sh und maps.html
- **Editieren der Autostartdatei** /etc/xdg/lxsession/LXDE-pi/autostart
- **Abfrage der API-KEYs:** für die Einheit und den Autologin des/der Monitorbenutzer aus Divera247.com
- **Grundkonfiguration:** z.B. ob Monitor oder TV benutzt wird, ob dieser immer an sein soll oder nur bei einem Einsatz, usw.

# Installation

## per SSH-Verbindung zum RPi
Wenn Sie im Home-Verzeichnis Ihres RPi´s sind geben Sie den Befehl
`wget https://github.com/juergen-u/Ad4Divera/blob/main/install.sh`
ein um das Installations-Script zu laden.

Mit dem Befehl `sudo chmod +x install.sh` wird die Datei ausführbar gemacht. Nun mit `./install.sh`ausführen und den Anweisungen folgen.
