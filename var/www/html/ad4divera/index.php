<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Ubuntu:ital,wght@0,400;0,500;1,400&display=swap" rel="stylesheet">
  <link rel="icon" type="image/png" href="img/favicon.png">
  <link rel="stylesheet" href="style.css">
  <link href="img/apple-touch-icon.png" rel="apple-touch-icon" />
  <link href="img/apple-touch-icon-152x152.png" rel="apple-touch-icon" sizes="152x152" />
  <link href="img/apple-touch-icon-167x167.png" rel="apple-touch-icon" sizes="167x167" />
  <link href="img/apple-touch-icon-180x180.png" rel="apple-touch-icon" sizes="180x180" />
  <link href="img/icon-hires.png" rel="icon" sizes="192x192" />
  <link href="img/icon-normal.png" rel="icon" sizes="128x128" />
  <title>Ad4Divera Konfiguration</title>

</head>
<body>
<?php
session_start();

if ( isset($_POST['benutzername']) and $_POST['benutzername'] != "" and isset($_POST['kennwort']) and $_POST['kennwort'] != ""  ) {
    if (pam_auth($_POST['benutzername'], $_POST['kennwort'], $error, false)) {
        $_SESSION['benutzername'] = $_POST['benutzername'];
        $_SESSION['eingeloggt'] = true;
    } else {
        echo "<font color=\"#fa0019\"><b>ungültige Eingabe</b></font>";
        $_SESSION['eingeloggt'] = false;
    }
}

if ( isset($_SESSION['eingeloggt']) and $_SESSION['eingeloggt'] == true ) {
    // Benutzer begruessen
} else {
    // Einloggformular anzeigen
    echo '<h1>Ad4Divera</h1>';
    echo '<h4>Das Alarmdisplay für DIVERA24/7</h4>';
    echo '<div id="modul">';
    echo '<hr>';
    echo '<p>Um Änderungen an der Konfiguration vorzunehmen müssen Sie sich mit den RPi-Zugangsdaten erst einloggen!</p>';
    echo '<br>';
    $url = $_SERVER['SCRIPT_NAME'];
    echo '<form action="'. $url .'" method="POST">';
    echo '<p>Benutzername:<br>';
    echo '<input type="text" name="benutzername" value="">';
    echo '<p>Kennwort:<br>';
    echo '<input type="password" name="kennwort" value="">';
    echo '<p><input type="Submit" id="button1" value="einloggen">';
    echo '</form>';
    echo "</div>";
    exit;
}
?>
<?php
 if(isset($_POST['sendpw'])) {
  $passwort = $_POST['newPW'];
  $passwort2 = $_POST['newPW2'];

 if($passwort != $passwort2) {
  echo "<font color=\"#fa0019\"><b>Bitte identische Passwörter eingeben</b></font>";
 } else {
  pam_chpass($_SESSION['benutzername'], $_POST['kennwort'], $_POST['newPW'], $error);
  echo $error;
  echo "<font color=\"#fa0019\"><b>Passwort geändert</b></font>";
 }
}
?>
<?php
$xml=simplexml_load_file("/etc/ad4divera/ad4divera.xml") or die("Error: Cannot create object");
$heute = date("Y-m-d--H-i-s");

$tempcpu = exec('vcgencmd measure_temp');
$tempcpu = str_replace('temp=','',$tempcpu);
$tempcpu = str_replace('\'C','',$tempcpu);
$tempcpu = round($tempcpu, 1);

$voltcpu = exec('vcgencmd measure_volts core');
$voltcpu = str_replace('volt=','',$voltcpu);
$voltcpu = str_replace('V','',$voltcpu);
$voltcpu = round($voltcpu, 2);

$clockcpu = exec('vcgencmd measure_clock arm');
$clockcpu = str_replace('frequency(48)=','',$clockcpu);
$freqcpu = $clockcpu / 1000000000;
$freqcpu = round($freqcpu, 1);

if(isset($_POST['update'])){
  $accesskey2xml = $_POST['accesskey2xml'];
  $autologinanzeige2xml = $_POST['autologinanzeige2xml'];
  $autologinausdruck2xml = $_POST['autologinausdruck2xml'];
  $betriebsart2xml = $_POST['betriebsart2xml'];
    if ($betriebsart2xml == on) {
        $betriebsart2xml = 1;
        } else {
        $betriebsart2xml = 0;
        }
  $anzeigegeraet2xml = $_POST['anzeigegeraet2xml'];
    if ($anzeigegeraet2xml == on) {
        $anzeigegeraet2xml = 1;
        } else {
        $anzeigegeraet2xml = 0;
        }
  $pdf2xml = $_POST['pdf2xml'];
    if ($pdf2xml == on) {
        $pdf2xml = 1;
        } else {
        $pdf2xml = 0;
        }
  $anzahlpdf2xml = $_POST['anzahlpdf2xml'];
  $karte2xml = $_POST['karte2xml'];
    if ($karte2xml == on) {
        $karte2xml = 1;
        } else {
        $karte2xml = 0;
        }
  $anzahlkarte2xml = $_POST['anzahlkarte2xml'];
  $motion2xml = $_POST['motion2xml'];
    if ($motion2xml == on) {
        $motion2xml = 1;
	$betriebsart2xml = 0;
        } else {
        $motion2xml = 0;
        }
  $time2xml = $_POST['time2xml'];
  $xml->ACCESSKEY = $accesskey2xml;
  $xml->AUTOLOGINANZEIGE = $autologinanzeige2xml;
  $xml->AUTOLOGINAUSDRUCK = $autologinausdruck2xml;
  $xml->BETRIEBSART = $betriebsart2xml;
  $xml->OUTPUT = $anzeigegeraet2xml;
  $xml->DOWNLOAD = $pdf2xml;
  $xml->ANZAHLPDF = $anzahlpdf2xml;
  $xml->KARTE = $karte2xml;
  $xml->ANZAHLKARTE = $anzahlkarte2xml;
  $xml->MOTION = $motion2xml;
  $xml->TIME = $time2xml;
  file_put_contents('/etc/ad4divera/ad4divera.xml', $xml->asXML());
  error_log("$heute *WEB-FRONTEND* Einstellungen wurde geändert. \n", 3, "/var/log/ad4divera.log");
  $myfile = fopen("maps.html", "w") or die("Unable to open file!");
  $autologin = $xml->AUTOLOGINAUSDRUCK;
  $maps1 = "<!DOCTYPE html>\n<html>\n<body>\n<iframe src='https://app.divera247.com/monitor/1.html?autologin=";
  $maps2 = "'\n width='1920' height='1200' style='border:none'></iframe>\n</body>\n</html>\n";
  $ready = $maps1 . $autologin . $maps2;
  fwrite($myfile, $ready);
  fclose($myfile);
  shell_exec('/opt/ad4divera/functions/anzeige.sh -c /etc/ad4divera/ad4divera.xml -f no_alarm');
}
?>
<h1>Ad4Divera</h1>
<h4>Das Alarmdisplay für DIVERA24/7</h4>
<form method="post">
  <div id="modul">
    <hr>
    <p>Um Änderungen an der Konfiguration zu speicher immer auf Update klicken!</p>
    <br>
    <div id="modul-button">
    <input type="submit" id="button1" name="update" value="Update">
</div>
</div>
<div id="moduls">
  <hr class="outline">
  <p class="outline">Verbindungs-Keys von Divera24/7</p>
  <ul>
    <li>
      <div class="ov">
        <h2>Accesskey</h2>
	<hr class="inline">
        <textarea name="accesskey2xml" rows="3" cols="28"><?php echo $xml->ACCESSKEY; ?></textarea>
        <hr class="inline">
        <p><b>Hinweis:</b> zu finden unter <em>Verwaltung > Schnittstellen</em>.</p>
      </div>
    </li>
    <li>
      <div class="ov">
        <h2>Autologin-anzeige</h2>
        <hr class="inline">
        <textarea name="autologinanzeige2xml" rows="3" cols="28"><?php echo $xml->AUTOLOGINANZEIGE; ?></textarea>
        <hr class="inline">
        <p><b>Hinweis:</b> zu finden unter <em>Verwaltung > Setup > Monitore</em>.</p>
      </div>
    </li>
    <li>
      <div class="ov">
        <h2>Autologin-ausdruck</h2>
        <hr class="inline">
	<textarea name="autologinausdruck2xml" rows="3" cols="28"><?php echo $xml->AUTOLOGINAUSDRUCK; ?></textarea>
        <hr class="inline">
        <p><b>Hinweis:</b> wird nur benötigt wenn eine Karte gedruckt werden soll.</p>
      </div>
    </li>
  </ul>
</div>
<div id="moduls">
  <hr class="outline">
  <p class="outline">Ausgabegerät und Verhalten</p>
  <ul>
    <li>
      <div class="ov">
        <h2>Betriebsart</h2>
        <hr class="inline">
        <p>Soll der Monitor/TV<br>
          <font color="#fa0019"><b>Nur bei Einsatz</b></font><br>
          oder<br>
          <font color="#2ab934"><b>Immer an</b></font><br>
          sein?</p>
          <br>
          <label class="switch">
            <input type="checkbox" name="betriebsart2xml" id="togBtn" <?php if($xml->BETRIEBSART == '1') echo 'checked'; ?>>
            <div class="slider round">
              <!--ADDED HTML -->
              <span class="on">Immer</span>
              <span class="off">Einsatz</span>
              <!--END-->
            </div>
          </label>
          <br>
      </div>
    </li>
    <li>
      <div class="ov">
        <h2>Anzeigegerät</h2>
        <hr class="inline">
        <p>Ist der RPi an einem<br>
          <font color="#fa0019"><b>TV</b></font>
          oder
          <font color="#2ab934"><b>Monitor</b></font>
          angeschlossen?</p>
          <br>
          <br>
	  <br>
          <label class="switch">
            <input type="checkbox" name="anzeigegeraet2xml" id="togBtn" <?php if($xml->OUTPUT == '1') echo 'checked'; ?>>
            <div class="slider round">
              <!--ADDED HTML -->
              <span class="on">Monitor</span>
              <span class="off">TV</span>
              <!--END-->
            </div>
          </label>
          <br>
      </div>
    </li>
    <li>
      <div class="ov">
        <h2>Bewegungserkennung</h2>
        <hr class="inline">
        <p>Soll der Monitor/TV bei Bewegung an gehen?</p>
          <br>
          <br>
          <label for="time2xml">Sekunden:</label>
          <input type="text" name="time2xml" size="4" value="<?php echo $xml->TIME ?>">
          <br>
          <br>
          <label class="switch">
            <input type="checkbox" name="motion2xml" id="togBtn" <?php if($xml->MOTION == '1') echo 'checked'; ?>>
            <div class="slider round">
              <!--ADDED HTML -->
              <span class="on">JA</span>
              <span class="off">NEIN</span>
              <!--END-->
            </div>
          </label>
          <br>
      </div>
    </li>
  </ul>
</div>
<div id="moduls">
  <hr class="outline">
  <p class="outline">Ausdrucke</p>
  <ul>
    <li>
      <div class="ov">
        <h2>Einsatzdepesche</h2>
        <hr class="inline">
        <p>Soll das Divera Einsatzprotokoll ausgedruckt werden?</p>
          <br>
	  <br>
          <label for="anzahlpdf2xml">Anzahl Ausdrucke:</label>
          <input type="text" name="anzahlpdf2xml" size="4" value="<?php echo $xml->ANZAHLPDF ?>">
          <br>
          <br>
          <label class="switch">
            <input type="checkbox" name="pdf2xml" id="togBtn" <?php if($xml->DOWNLOAD == '1') echo 'checked'; ?>>
            <div class="slider round">
              <!--ADDED HTML -->
              <span class="on">JA</span>
              <span class="off">NEIN</span>
              <!--END-->
            </div>
          </label>
          <br>
      </div>
    </li>
    <li>
      <div class="ov">
        <h2>Einsatzkarte</h2>
        <hr class="inline">
        <p>Soll die Einsatzkarte (zweiter Divera-Monitor) ausgedruckt werden?</p>
          <br>
          <label for="anzahlkarte2xml">Anzahl Ausdrucke:</label>
          <input type="text" name="anzahlkarte2xml" size="4" value="<?php echo $xml->ANZAHLKARTE ?>">
          <br>
          <br>
          <label class="switch">
            <input type="checkbox" name="karte2xml" id="togBtn" <?php if($xml->KARTE == '1') echo 'checked'; ?>>
            <div class="slider round">
              <!--ADDED HTML -->
              <span class="on">JA</span>
              <span class="off">NEIN</span>
              <!--END-->
            </div>
          </label>
          <br>
      </div>
    </li>
  </ul>
</div>
<div id="moduls">
  <hr class="outline">
  <p class="outline">Sonstiges</p>
  <ul>
    <li>
      <div class="ov">
        <h2>Passwort ändern</h2>
        <hr class="inline">
          <form method="post">
	  <p>Altes Passwort:</p>
          <input type="password" name="kennwort" size="25" placeholder="altes Passwort">
          <p>Neues Passwort:</p>
          <input type="password" name="newPW" size="25" placeholder="neues Passwort">
          <p>Bestätigen:</p>
          <input type="password" name="newPW2" size="25" placeholder="Bestätigen">
          <br>
          <br>
            <input type="submit" id="button2" name="sendpw" value="Senden">
          <br>
          </form>
      </div>
    </li>
    <li>
      <div class="ov">
        <h2>RPi Werte</h2>
        <hr class="inline">
          <?php
          if($tempcpu > 70) {
                echo "<p>CPU Temperatur:<font color=\"#fa0019\"><b> $tempcpu</b></font> °C</p>";
          } else if($tempcpu > 60) {
                echo "<p>CPU Temperatur:<font color=\"#ffbf00\"><b> $tempcpu</b></font> °C</p>";
          } else {
                echo "<p>CPU Temperatur:<b> $tempcpu</b> °C</p>";
          }
          ?>
          <br>
          <p>CPU Spannung:<b> <?php echo $voltcpu ?></b> V</p>
          <br>
          <p>CPU Frequenz:<b> <?php echo $freqcpu ?></b> GHz</p>
      </div>
    </li>
  </ul>
</div>
</form>
</body>
</html>

