# Allgemeines
Alarmdisplay für Divera247.com

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

### install-ad4divera.sh
Das install.sh-Script führt folgende Anweisungen/Aktionen durchgeführt:
- **Installation der benötigten Programme:** jq, unclutter, cec-utils, xdotool, wkhtmltopdf und firefox-esr
- **Anlegen der Ordner:** /Ad4Divera und in diesem /Archiv
- **Erstellen der Programm-Dateien:** ad4divera.conf, ad4divera.sh und maps.html
- **Editieren der Autostartdatei** /etc/xdg/lxsession/LXDE-pi/autostart
- **Abfrage der API-KEYs:** für die Einheit und den Autologin des/der Monitorbenutzer aus Divera247.com
- **Grundkonfiguration:** z.B. ob Monitor oder TV benutzt wird, ob dieser immer an sein soll oder nur bei einem Einsatz, usw.

### Dauerbetrieb

# Installation

## per SSH-Verbindung oder direkt auf dem RPi im Terminal
Wenn Sie im Home-Verzeichnis Ihres RPi´s sind geben Sie den Befehl `git clone https://github.com/juergen-u/Ad4Divera.git` ein um das Installations-Script zu laden.

Nun mit `cd Ad4Divera` in den Ordner wechseln.
Mit dem Befehl `sudo chmod +x install-ad4divera.sh` wird die Datei ausführbar gemacht. Nun mit `./install-ad4divera.sh`ausführen und den Anweisungen folgen.

# Änderungen der Konfiguration

## ad4divera.conf
Wechseln Sie wieder in das Verzeichnis /Ad4Divera mit `cd Ad4Divera`.
Mit `sudo nano ad4divera.conf` können Sie diese bearbeiten und Änderungen vornehmen.
Um die Änderungen zu speichern drücken Sie `STRG + O`, mit ENTER bestätigen. Mit `STRG + X` verlassen sie den Editor.

## Kartenausdruck
Wenn Sie nachträglich noch einen Kartenausdruck möchten müssen Sie die Datei /Ad4Divera/maps.html anpassen.
Wechseln Sie wieder in da Verzeichnis und öffnen Sie mit `sudo nano maps.html` den Editor.
Hier müssen Sie den Autologin des Monitorbenutzers an das Ende von `https://app.divera247.com/monitor/1.html?autologin=` eintragen und die Datei wie gewohnt speichern.
