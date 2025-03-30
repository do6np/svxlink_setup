# SvxLink Setup by DF5KX & DO6NP

Für eine deutsche Erklärung siehe weiter unten.

# English

## Purpose

The SvxLink Server is a general purpose voice services system which, when connected to a transceiver, can act as both an advanced repeater system and can also operate on a simplex channel.

The SvxLink setup script arose from the requirement to establish a simple solution for the local NordWestLink network in order to provide all repeaters with the same current version of SvxLink. Chris, DF5KX, wrote the first lines of bash code based on an idea of NJ6N. Nils, DO6NP, added some more lines and that's how the storry goes. :-) The small script has meanwhile become a comprehensive setup solution for SvxLink.

## Features

The script offers the following features:

* Installing SvxLink on a Raspberry Pi or Debian “Bookworm”
* Always installing the latest “master” branch
* Setting up various HATs for connecting to repeaters including installation of all required drivers and setup of all needed GPIO ports (RPi only)
* Getting all the content you need right from Git
* Compiling from the most recent Trunks
* Importing SvxLink sound files
* Otimizing various system parameters (Rpi only)
* Messages shown optionally in English or German

## Supported HATs

The following Raspberry Pi HAT's are currently supported:

1. WM8960 Audio HAT
2. PI REPEATER board by ICS Controllers
3. uSvxCard by F5SWB & F8ASB including Seeed VoiceCard
4. ELENATa boards from SkyAndy aka DK1LO
5. More to come?

## Installation

We assume that we are dealing with a freshly installed Raspberry Pi with the current Raspbian / Raspberry Pi OS or Debian 11 “Bookworm” installed.

To run the script, please do the following:

1. First, update the system and download the current version of the script:
```
$ sudo apt-get update 
$ sudo apt-get upgrade
$ sudo apt-get install git
$ git clone https://github.com/do6np/svxlink_setup.git
```

2. Change directory and make the script executable:
```
$ cd svxlink_setup
$ chmod +x svxlink_setup.sh
```

3. Run script:
```
$ sudo ./svxlink_setup.sh
```

Or, if you realy like to write a debug log (development only):
```
$ sudo ./svxlink_setup.sh -D
```

4. Answer all questions and enter credentials.

5. Enjoy!

## Important notes

This script can only be a tool to help you quickly install SvxLink on your computer. It in no way replaces the need to familiarize yourself intensively with the concept and setup of SvxLink. Especially if you plan to run SvxLink as a repeater controller, you should know exactly what you are doing and how everything works together. Tobias, SM0SVX, instructions explain all the components and settings in detail. Help is also available on the [corresponding forum](https://groups.io/g/svxlink).

Please also note that SvxLink is constantly being developed. You should therefore also pay attention to the information in the [changelog](https://github.com/sm0svx/svxlink/blob/master/src/svxlink/ChangeLog).

## Further development

We have to admit, neither of us is a pro in Bash. We just put our kitchen knowledge together and tried to make the best of it. So there are definitely things that need to be improved. Perhaps you have some completely new ideas that we haven't even thought of yet? Feel free to use Git and send us your commits. We are always happy to receive your suggestions!

# German / Deutsch

## Zweck

SvxLink ist ein multifunktionaler Server für den Einsatz im Amateurfunk, mit dem sich sowohl ein erweitertes Relais-System als auch ein Simplex-Node umsetzen lässt. SvxLink wird von Tobias Blomberg, SM0SVX, entwickelt und kostenfrei als Open-Source-Lösung auf Github bereitgestellt.

Dieses Setup-Skript entstand aus dem Wunsch, eine einfache Lösung für das [NordWestLink](https://nordwestlink.net)-Netzwerk zu schaffen, um alle Relais mit der gleichen aktuellen Version von SvxLink auszustatten. Chris, DF5KX, schrieb die ersten Zeilen des Bash-Codes, basierend auf einer Idee von NJ6N. Nils, DO6NP, fügte noch ein paar Zeilen hinzu und ... aus dem kleinen Skript ist inzwischen eine umfassende Setup-Lösung für SvxLink geworden.

## Eigenschaften

Das Skript bietet die folgenden Funktionen:

* Installation von SvxLink auf einem Raspberry Pi oder Debian "Bookworm"
* Installation des jeweils neuesten "Master"-Zweigs
* Einrichten verschiedener HATs für den Anschluss an Repeater, einschließlich der Installation aller benötigten Treiber und der Einrichtung der GPIO-Ports (nur RPi)
* Bezug aller Inhalte direkt von Github
* Kompilieren der aktuellsten Trunks
* Importieren von SvxLink-Sounddateien (Deutsch + Englisch)
* Optimierung verschiedener Systemparameter (nur Rpi)
* Anzeige der Meldungen wahlweise in Englisch oder Deutsch
* Eintragen der wichtigsten Parameter in die SvxLink-Konfigurationsdateien

## Unterstützte HATs

Die folgenden Raspberry-Pi-Aufsätze werden derzeit unterstützt:1. WM8960 Audio HAT

1. WM8960 Audio HAT
2. PI REPEATER Karte von ICS Controllers, USA
3. uSvxCard von F5SWB und F8ASB einschließlich Seeed VoiceCard
4. ELENATa-Boards von DK1LO alias SkyAndy
5. Mehr in Zukunft?

## Installation

Das Skript geht davon aus, dass wir es mit einem frisch installierten Raspberry Pi oder PC zu tun haben, auf dem das aktuelle Raspbian oder Debian 11 "Bookworm" installiert ist. 

Um das Skript auszuführen, gehe bitte wie folgt vor:

1. Aktualisiere Dein System und lade anschließend die aktuelle Version des Skripts herunter:
```
$ sudo apt-get update 
$ sudo apt-get upgrade
$ sudo apt-get install git
$ git clone https://github.com/do6np/svxlink_setup.git
```

2. Wechsle das Verzeichnis und mache das Skript ausführbar:
```
$ cd svxlink_setup
$ chmod +x svxlink_setup.sh
```

3. Führe es aus:
```
$ sudo ./svxlink_setup.sh
```

Oder, falls Du ein Debug-Log schreiben möchtest (benötigen eigentlich nur Entwickler):
```
$ sudo ./svxlink_setup.sh -D
```

4. Beantworte alle Fragen und trage die erforderlichen Daten ein.

5. Fahre mit der Einrichtung von SvxLink fort.

## Wichtige Hinweise

Dieses Skript kann nur ein Hilfswerkzeug sein, um die Basis für SvxLink möglichst schnell auf Deinem Computer einzurichten. Es ersetzt jedoch keinesfalls die Notwendigkeit, Dich intensiv mit dem Konzept sowie der Einrichtung von SvxLink auseinanderzusetzen. Insbesondere dann, wenn Du SvxLink als Relais-Steuerung einsetzen möchtest, solltest Du genau wissen, was Du tust und wie alles funktioniert und miteinander zusammenhängt. Die Anleitungen von Tobias Blomberg, SM0SVX, erklären alle Bestandteile und Einstellungen im Detail. Hilfe gibt es auch im zugehörigen [Forum](https://groups.io/g/svxlink).

Bitte beachte auch, dass SvxLink ständig weiterentwickelt wird. Du solltest daher unbedingt auch die Informationen im [Changelog](https://github.com/sm0svx/svxlink/blob/master/src/svxlink/ChangeLog) beachten. Ehrlicherweise müssen wir allerdings darauf hinweisen, dass zur Beschäftigung mit SvxLink Kenntnisse der englischen Sprache unerlässlich sind, da nur wenige aktuelle Informationen in deutscher Sprache vorliegen und die Entwicklung in einer weltweiten Gemeinschaft stattfindet.

## Weiterentwicklung und Verbesserungen

Wir geben es gern zu, wir sind beide keine Bash-Profis. Wir haben nur unser Amateur(funk)wissen zusammengeworfen und versucht, das Beste daraus zu machen. Daher gibt es bestimmt Dinge, die an diesem Setup noch verbessert werden können. Vielleicht hast Du auch noch ganz neue Ideen, auf die wir bislang gar nicht gekommen sind? Nutze gerne Git und sende uns Deine Commits. Wir freuen uns immer sehr über konstruktive Vorschläge!

# Contact / Kontakt

* **E-Mail:** Nils, <do6np@darc.de>
* **Mastodon:** @DO6NP@social.darc.de