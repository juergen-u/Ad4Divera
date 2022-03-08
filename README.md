# Allgemeines
Alarmdisplay für Divera247.com

## Nutzen der Software
Mit diesem Script ist es möglich ein Alarmdisplay für Fahrzeughallen bei Feuerwehren, THW und anderen HiOrgs mit einem Raspberry Pi und Divera247 umzusetzen.

Getestet und betrieben wird dieser Code mit einem Raspberry Pi 3B+, ein kurzer Test mit einem RPi 4 brachte die gleichen Ergebnisse.

## Voraussetzung und Hinweise
Es wird ein frisch aufgesetzter Raspberry Pi mit Internetverbindung vorausgesetzt!
Am besten greifen Sie per SSH auf den RPi zu.

### Voraussetzungen bei Divera247.com: 
- eine Einheit ist angelegt,
- einen Monitor ist eingerichtet,
- ein Monitorbenutzer mit Auto-Login ist für den Monitor angelegt!

**Noch ein Tipp zu den Monitoren:** Ich habe die besten Ergebnisse bekommen wenn die Anzeige-Höhe bei der Zusammensetzung der Inhalte (Elemente auswählen und anorden) nicht auf *Automatisch* sondern auf *Prozent* eingestellt ist und hier dann auf **99%** (bei mehreren Zeilen sollte die Summer 99% ergeben).
Dadurch wird der gesammte Inhalt ohne Scrollbalken dargestellt!

### Dauerbetrieb
Mit der Auswahl des Dauerbetriebes kann man die Lebensdauer des Monitors/TVs entschieden verbessern. Wenn diese nicht permanden an sind sondern nur wenn sie benötigt werden spart es zudem noch Energie. Deshalb ist die Option so aufgebaut das der Monitor/TV nur bei einem Einsatz aus dem Standby erwacht. 
In den Divera247-Einstellungen kann die Zeit wie lange ein Einsatz aktiv ist (Zeit bis automatisch abgeschlossen) z.B. auf eine Stunde eingestellt werden. Somit ist die Anzeige für diese Zeit aktiv, nach Ablauf der Zeit geht der Monitor/TV wieder in Standby.

### Ausdrucke
Um die Einsatzdepesche und/oder die Karte auszudrucken muss ein Drucker auf dem RPi eingerichtet sein mit dem Namen `ALARMDRUCKER` (alles in Großbuchstaben)!
Dabei ist es egal ob der Drucker per USB oder LAN angeschlossen ist. Bei der Installation wird abgefragt wieviele Ausdrucke der Einsatzdepesche und/oder Karte erzeugt werden sollen.

### install-ad4divera.sh
Das install-ad4divera.sh-Script führt folgende Anweisungen/Aktionen durchgeführt:
- **Installation der benötigten Programme:** jq, unclutter, cec-utils, xdotool, wkhtmltopdf und firefox-esr
- **Anlegen der Ordner:** /Ad4Divera und in diesem /Archiv
- **Erstellen der Programm-Dateien:** ad4divera.conf, ad4divera.sh und maps.html
- **Editieren der Autostartdatei** /etc/xdg/lxsession/LXDE-pi/autostart
- **Abfrage der API-KEYs:** für die Einheit und den Autologin des/der Monitorbenutzer aus Divera247.com
- **Grundkonfiguration:** z.B. ob Monitor oder TV benutzt wird, ob dieser immer an sein soll oder nur bei einem Einsatz, usw.
#

# Installation

## per SSH-Verbindung oder direkt auf dem RPi im Terminal
Wenn Sie im Home-Verzeichnis Ihres RPi´s sind geben Sie den Befehl 

`git clone https://github.com/juergen-u/Ad4Divera.git` ein um das Installations-Script zu laden.

Nun mit `cd Ad4Divera` in den Ordner wechseln.
Mit dem Befehl `sudo chmod +x install-ad4divera.sh` wird die Datei ausführbar gemacht. Nun mit `./install-ad4divera.sh`ausführen und den Anweisungen folgen.

# Änderungen der Konfiguration

## ad4divera.conf
Wechseln Sie wieder in das Verzeichnis /Ad4Divera mit `cd Ad4Divera`.
Mit `sudo nano ad4divera.conf` können Sie diese bearbeiten und Änderungen vornehmen.
Um die Änderungen zu speichern drücken Sie `STRG + O`, mit ENTER bestätigen. Mit `STRG + X` verlassen sie den Editor.

## Kartenausdruck
Wenn Sie nachträglich noch einen Kartenausdruck möchten müssen Sie die Datei /Ad4Divera/maps.html anpassen.
Wechseln Sie wieder in das Verzeichnis und öffnen Sie mit `sudo nano maps.html` den Editor.
Hier müssen Sie den Autologin-Key des Monitorbenutzers an das Ende von `https://app.divera247.com/monitor/1.html?autologin=` eintragen und die Datei wie gewohnt speichern.
Anschließend wieder die `ad4divera.conf` anpassen.
#

# Erweiterung mit Bewegungserkennung

## per Webcam
Wir schalten unseren Monitor für 60 Sekunden in der Fahrzeughalle ein wenn jemand vorbeigeht. In der Standby-Ansicht sind bei uns die Wetterdaten des DWD, Termine und Mitteilungen zu lesen. Dafür verwenden wir eine Webcam, diese ist so konfiguriert das sie weder Bilder noch Videos speichert. Das Programm *Motion* ist so eingerichtet das es bei einer Änderung von xx-Pixel dies als Bewegung ergennt und ein Event startet. Nach 60 Sekunden wird das Event beendet und der Monitor geht wieder in Standby. Bei einem Einsatz wird Motion deaktiviert so das der Monitor dann wieder an bleibt.

Installiert wird Motion mit dem Befehl `sudo apt install motion`. Anschließend muss mit `sudo nano /etc/motion/motion.conf` diese angepasst werden.
Anleitungen gibt es im Internet dazu reichlich.
Wichtig ist hier die Anpassung der Befehle `; on_event_start value` und `; on_event-end value`!
## wie folgt anpassen:
**Monitor** `on_event_start vcgencmd display_power 1` und `on_event_end display_power 0`

**TV** `on_event_start echo 'on 0' | cec-client -s -d 1` und `on_event_end echo 'standby 0' | cec-client -s -d 1`

**WICHTIG** das `;` am Anfang der Zeile entfernen!

## per Bewegungsmelder
Wurde noch nicht durchgeführt.
# 

# Automatischer Neustart des RPi
Ich würde den RPi ein oder zweimal am Tag neu starten lassen um zu verhindern das er sich aufhängt.

Dafür mit `sudo crontab -e` einen Job erstellen.
Nach der auswahl des Editors am Ende die Zeile

`0 0 * * * sudo reboot`

einfügen und speichern. Dadurch wird um 0 Uhr ein Neustart automatisch durchgeführt.
