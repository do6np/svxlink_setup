#!/bin/bash
#
# +---------------------------------------------------------------+
# | SVXLINK Setup Script for Debian /  Raspberry Pi OS "Bookworm" |
# |              (C) 2022-2024 DF5KX & DO6NP - BETA               |
# +---------------------------------------------------------------+
#
# Changelog
# ---------
# 2024 01 13 | DO6NP | Added Raspi checks
# 2024 01 09 | DO6NP | Added LADSPA stuff for new SvxLink feature
# 2023 11 26 | DO6NP | Some bugfixes, sudo's, some new ideas
# 2023 09 29 | DF5KX | Installation order sorted
# 2023 09 22 | DF5KX | Bugfixes
# 2023 03 21 | DF5KX | Bugfixes
# 2023 03 18 | DF5KX | Created version 2.0 for downward and linux compatibility
# 2023 03 14 | DF5KX | dialout group for rs232 and wget for further inst added
# 2022 09 27 | DO6NP | Added support for uSvxCard
# 2022 09 18 | DO6NP | Added multilingual support and German messages
# 2022 04 11 | DO6NP | Created version 2.0 including many new features 
# 2022 04 09 | DO6NP | Added parameters for ICS Pi-Repeater
# 2022 02 28 | DF5KX | initial release based on NJ6N's install script
# 2022 01 02 | DF5KX | German voice Anna 16k added for installation
# 
################################################################################
#
# variables & constants
CONF=/etc/svxlink/svxlink.conf
FLAG="$HOME/.svxlink_installed"
VERSIONS=$HOME/svxlink/src/versions
IS_PI=false
IS_DEBUG=false
declare -A msgtext
declare -r SCRIPT_VERSION="2.10" # Version number in the format: n.nn
declare -r LANG=$(locale | grep LANG | cut -d= -f2 | cut -d_ -f1)
declare -r REQUIRED_OS_VER="12"
declare -r REQUIRED_OS_NAME="Bookworm"
declare -r MIN_PARTITION_SIZE=8000

################################################################################

function set_messages {
	if [[ $LANG = "de" ]]; then
		msgtext["debug_info"]="Debug-Information"
		msgtext["debug_partition_size"]="Größe Hauptpartition"
		msgtext["debug_partition_needed"]="Benötigte Mindestgröße"
		msgtext["debug_pi"]="Raspi erkannt"
		msgtext["debug_key"]="Bitte Enter zum Forsetzen drücken."
		msgtext["preparing"]="Bereite System vor"
		msgtext["no_root"]="Skript darf nicht als Benutzer 'root' ausgeführt werden."
		msgtext["no_connection"]="Internetverbindung fehlt!"
		msgtext["unsupported_os"]="Warnung! Dieses Skript ist nur unter Debian und Debian Derivaten wie Raspberry OS getestet!"
		msgtext["partition_too_small"]="Sorry, die Partition ist zu klein."
		msgtext["first_run"]="ERSTER AUFRUF"
		msgtext["deactivating_swap"]="Deaktiviere SWAP-Partition"
		msgtext["activating_ramdisk"]="Aktiviere RAM-Disk"
		msgtext["activating_logrotate"]="Aktiviere Logrotate"
		msgtext["optimizing_system"]="Optimiere einige Systemeinstellungen"
		msgtext["enter_callsign"]="Bitte Rufzeichen für Relais / Hotspot eingeben"
		msgtext["reenter_callsign"]="Bitte erneut aufrufen und ein gültiges Rufzeichen eingeben!"
		msgtext["choose_interface_1"]="Bitte wähle Dein Sound-Interface:"
		msgtext["choose_interface_2"]="Bitte 1, 2, 3 oder 0 für kein Interface eingeben?"
		msgtext["choose_interface_invalid"]="Bitte eine gültige Nummer eingeben!"
		msgtext["choose_rtlsdr"]="Möchtest Du auch einen RTL-SDR-Treiber installieren (j/n)?" 
		msgtext["wrong_answer"]="Fehlerhafte Antwort!"
		msgtext["setup_creating_groups"]="Lege Gruppen und Benutzer an"
		msgtext["setup_install_packages"]="Installiere benötigte Pakete"
		msgtext["setup_packages_error"]="Installation der Pakete fehlgeschlagen, ABBRUCH!"
		msgtext["setup_rtlsdr"]="Installiere RTL-SDR-Treiber"
		msgtext["setup_wm8960"]="Installiere WM8960-Audio-Hat-Treiber"
		msgtext["setup_git_error"]="Installation der Quellen fehlgeschlagen, ABBRUCH!"
		msgtext["setup_ics_deactivating_onboard"]="Deaktiviere Onboard-HDMI-Soundkarte"
		msgtext["setup_ics_activating_audio"]="Aktiviere Audio"
		msgtext["setup_ics_installing_i2c"]="Installiere und aktiviere I2C-Bus und I2C-Schnittstellen"
		msgtext["setup_ics_activating_ics"]="Aktiviere ICS-Controller-Intergration"
		msgtext["setup_usvx_blacklisting"]="Schalte die Soundkarte des Raspberry ab"
		msgtext["setup_usvx_installing_drivers"]="Installiere Treiber für die Seeed Voicecard Soundkarte"
		msgtext["setup_usvx_gpio_preparing"]="Bereite Konfiguration der GPIO-Ports vor"
		msgtext["setup_usvx_gpio_install"]="Installiere GPIO-Portkonfiguration für die uSvxCard"
		msgtext["install_svxlink_loading_sources"]="Lade SvxLink-Sourcecode herunter"
		msgtext["setup_update_packages"]="Lade System-Updates"
		msgtext["install_svxlink_loading_updates"]="Lade SvxLink-Update aus Repo"
		msgtext["install_svxlink_current_version"]="Aktuelle Version"
		msgtext["install_svxlink_new_version"]="Neue Version"
		msgtext["install_svxlink_compiling"]="Kompiliere SvxLink"
		msgtext["install_svxlink_cmake_error"]="cmake fehlgeschlagen, ABBRUCH!"
		msgtext["install_svxlink_installing"]="Installiere SvxLink"
		msgtext["install_svxlink_sounds_en_installing"]="Installiere englische Sounds"
		msgtext["install_svxlink_sounds_en_installerror"]="Download Englisch fehlgeschlagen, mache weiter!"
		msgtext["install_svxlink_sounds_de_installing"]="Installiere deutsche Sounds"
		msgtext["install_svxlink_sounds_de_installerror"]="Download Deutsch fehlgeschlagen, mache trotzdem weiter!"
		msgtext["setup_svxlink_backup"]="Erstelle Sicherheitskopie"
		msgtext["setup_svxlink_customizing"]="Passe SvxLink-Konfiguration an"
		msgtext["setup_svxlink_activating"]="Aktiviere SvxLink-Daemon"
		msgtext["main_done"]="Installation abgeschlossen"
	else
		msgtext["debug_info"]="DEBUG"
		msgtext["debug_partition_size"]="Size main volume"
		msgtext["debug_partition_needed"]="Size needed"
		msgtext["debug_pi"]="Raspberry Pi detected"
		msgtext["debug_key"]="Press Enter to continue."
		msgtext["preparing"]="Preparing system"
		msgtext["no_root"]="Script must not be executed as 'root'."
		msgtext["no_connection"]="Missing internet connection!"
		msgtext["unsupported_os"]="Warning! This script has been designed for Debian and derivates such as Raspberry OS!"
		msgtext["partition_too_small"]="Sorry, partition too small for installing SvxLink."
		msgtext["first_run"]="FIRST RUN"
		msgtext["deactivating_swap"]="Deactivating SWAP partition"
		msgtext["activating_ramdisk"]="Activating tempfs"
		msgtext["activating_logrotate"]="Activating logrotate"
		msgtext["optimizing_system"]="Optimizing some settings"
		msgtext["enter_callsign"]="Please enter callsing for repater / hotspot"
		msgtext["reenter_callsign"]="Please run script again and enter a valid callsign."
		msgtext["choose_interface_1"]="Please choose sound interface:"
		msgtext["choose_interface_2"]="Please enter 1, 2, 3 or 0 for none:"
		msgtext["choose_interface_invalid"]="Please enter a valid number."
		msgtext["choose_rtlsdr"]="Do you wish to install the RTL SDR driver package (y/n)?" 
		msgtext["wrong_answer"]="Wrong answer!"
		msgtext["setup_creating_groups"]="Creating groups and users"
		msgtext["setup_install_packages"]="Installing all needed packages"
		msgtext["setup_packages_error"]="Installation failed, abborting"
		msgtext["setup_rtlsdr"]="Installing RTL SDR drivers"
		msgtext["setup_wm8960"]="Installing WM8960 audio hat drivers"
		msgtext["setup_git_error"]="Error downloading sources"
		msgtext["setup_ics_deactivating_onboard"]="Deactivating onboard HDMI soundchip"
		msgtext["setup_ics_activating_audio"]="Activating audio"
		msgtext["setup_ics_installing_i2c"]="Installing and activating I2C bus and ports"
		msgtext["setup_ics_activating_ics"]="Activating ICS controller"
		msgtext["setup_usvx_blacklisting"]="Blacklist the sound card of Raspberry"
		msgtext["setup_usvx_installing_drivers"]="Installing driver for Seeed Voicecard"
		msgtext["setup_usvx_gpio_preparing"]="Preparing GPIO port configuration"
		msgtext["setup_usvx_gpio_install"]="Installing GPIO port configuration for uSvxCard"
		msgtext["install_svxlink_loading_sources"]="Loading sources from Git repo"
		msgtext["setup_update_packages"]="Loading system updates"
		msgtext["install_svxlink_loading_updates"]="Loading SvxLink updates from Git"
		msgtext["install_svxlink_current_version"]="Current version"
		msgtext["install_svxlink_new_version"]="New version"
		msgtext["install_svxlink_compiling"]="Compiling SvxLink"
		msgtext["install_svxlink_cmake_error"]="Error while running cmake"
		msgtext["install_svxlink_installing"]="Setting up SvxLink"
		msgtext["install_svxlink_sounds_en_installing"]="Installing English sound files"
		msgtext["install_svxlink_sounds_en_installerror"]="Error downloading files, continuing anyway"
		msgtext["install_svxlink_sounds_de_installing"]="Installing German sound files"
		msgtext["install_svxlink_sounds_de_installerror"]="Download Deutsch fehlgeschlagen, mache trotzdem weiter!"
		msgtext["setup_svxlink_backup"]="Creating config backup"
		msgtext["setup_svxlink_customizing"]="Customizing SvxLink config file"
		msgtext["setup_svxlink_activating"]="Activating SvxLink daemon"
		msgtext["main_done"]="Installation completed"
	fi
}

function debug_info {
	if $IS_DEBUG; then
		read -t 60 -n 1 -s -r -p "${msgtext["debug_key"]}"
		echo
	fi
}

################################################################################

# *** Some functions for start checkup ***

function check_root {
	if [[ $EUID = 0 ]]; then
		echo "`date +%T`: *** ${msgtext["no_root"]}"
		exit 1
	fi	
}

function check_os {
	if (grep -q "$REQUIRED_OS_VER." /etc/debian_version); then
		DEBIAN_VERSION="$REQUIRED_OS_VER"
	else
		DEBIAN_VERSION="UNSUPPORTED"
	fi
	if [ "$DEBIAN_VERSION" != "$REQUIRED_OS_VER" ]; then
		echo "`date +%T`: *** ${msgtext["unsupported_os"]} $REQUIRED_OS_VER (\"$REQUIRED_OS_NAME\")."
		exit 1
	fi
	if [ -e "/etc/os-release" ]; then
		OSTYPE=`grep "^NAME=" /etc/os-release | awk -F= '{print $2}'`
		if [ "$OSTYPE" = "Raspbian GNU/Linux" ]; then
			IS_PI=true
		fi
	else
		echo "`date +%T`: *** ${msgtext["unsupported_os"]} $REQUIRED_OS_VER (\"$REQUIRED_OS_NAME\")."
		exit 1
	fi
	if (uname -a | grep -q rpi); then
		IS_PI=true
	fi
	if $IS_DEBUG; then
		echo "`date +%T`: *** ${msgtext["debug_info"]}"		
		echo "`date +%T`: ${msgtext["debug_pi"]}: $IS_PI"
		cat /etc/os-release
		debug_info
	fi
}

function update_and_prepare {
	echo "`date +%T`: *** ${msgtext["preparing"]}"
	sudo apt-get -qq update
	if [ $? -ne 0 ]; then
		echo "`date +%T`: *** ${msgtext["no_connection"]}"
		exit 1
	fi
	sudo apt-get -qq -y upgrade
	if [ $? -ne 0 ]; then
		echo "`date +%T`: *** ${msgtext["no_connection"]}"
		exit 1
	fi
	sudo apt-get -qq -y dist-upgrade
	if [ $? -ne 0 ]; then
		echo "`date +%T`: *** ${msgtext["no_connection"]}"
		exit 1
	fi
	debug_info
}

function check_filesystem {
	PARTITION_SIZE=0
	PARTITION_SIZE=$(df -m | awk '$6=="/"{print$2}')
	if [ $PARTITION_SIZE -le $MIN_PARTITION_SIZE ]; then
		echo "`date +%T`: *** ${msgtext["partition_too_small"]}"
		exit -1
	fi
	if $IS_DEBUG; then
		echo "`date +%T`: *** ${msgtext["debug_info"]}"		
		echo "`date +%T`: ${msgtext["debug_partition_size"]}: $PARTITION_SIZE"
		echo "`date +%T`: ${msgtext["debug_partition_needed"]}: $MIN_PARTITION_SIZE"
		debug_info
	fi
}

################################################################################

# *** Install for the first time

function install_firstrun {
	echo "`date +%T`: *** ${msgtext["first_run"]} ***"

	if $IS_PI; then
		echo "`date +%T`: *** ${msgtext["deactivating_swap"]}"
		sudo swapoff -a
		sudo service dphys-swapfile stop
		sudo systemctl disable dphys-swapfile
		sudo apt-get -qq -y purge dphys-swapfile
		sudo systemctl disable apt-daily.service apt-daily.timer apt-daily-upgrade.service apt-daily-upgrade.timer
		echo "`date +%T`: *** ${msgtext["activating_ramdisk"]}"
		echo "tmpfs   /var/log                tmpfs   nodev,noatime,nosuid,mode=0777,size=128m        0       0"	| sudo tee -a /etc/fstab > /dev/null
		echo "tmpfs   /tmp                    tmpfs   nodev,noatime,nosuid,mode=0777,size=128m        0       0"	| sudo tee -a /etc/fstab > /dev/null
		## --- Remark in case of trubles:
		## Create /etc/tmpfiles.d/Software.conf with following content:
		## d /var/log/Software 0777 User Group - -
		sudo mount -a
		sudo systemctl daemon-reload
	fi
	
	echo "`date +%T`: *** ${msgtext["activating_logrotate"]}"
	echo "/var/log/svxlink {"	| sudo tee -a /etc/logrotate.d/svxlink > /dev/null
	echo "  daily"	| sudo tee -a /etc/logrotate.d/svxlink > /dev/null
	echo "  rotate 14"	| sudo tee -a /etc/logrotate.d/svxlink > /dev/null
	echo "  missingok"	| sudo tee -a /etc/logrotate.d/svxlink > /dev/null
	echo "  notifempty"	| sudo tee -a /etc/logrotate.d/svxlink > /dev/null
	echo "  compress"	| sudo tee -a /etc/logrotate.d/svxlink > /dev/null
	echo "  dateext"	| sudo tee -a /etc/logrotate.d/svxlink > /dev/null
	echo "}"	| sudo tee -a /etc/logrotate.d/svxlink > /dev/null
	sudo systemctl restart logrotate

	if $IS_PI; then
		echo "`date +%T`: *** ${msgtext["optimizing_system"]}"
		sudo systemctl stop ModemManager.service
		sudo systemctl disable ModemManager.service
		sudo apt-get -qq -y purge modemmanager
		sudo sed -i "s/dtoverlay=vc4-kms-v3d/dtoverlay=vc4-kms-v3d,audio=off/" /boot/config.txt
		sudo sed -i "s/camera_auto_detect=1/#camera_auto_detect=1/" /boot/config.txt
		echo "# *** Inserted by SVXLINK Setup Script"	| sudo tee -a /boot/config.txt > /dev/null
		echo "dtoverlay=disable-bt"	                  | sudo tee -a /boot/config.txt > /dev/null
		sudo systemctl stop hciuart
		sudo systemctl disable hciuart
	fi
	sudo apt-get -qq -y autoremove
	
	read -p "${msgtext["enter_callsign"]}: " CALL
	if [ "$CALL" == "" ]; then
		echo "${msgtext["reenter_callsign"]}"
		exit 1
	fi
	if $IS_PI; then
		echo "${msgtext["choose_interface_1"]}"
		echo "1) WM8960 Audio HAT"
		echo "2) PI-REPEATER board (ICS Controllers)"
		echo "3) uSvxCard (F5SWB & F8ASB)"
		echo "0) None"
		while :; do
			read -p "${msgtext["choose_interface_2"]} " AUDIO
			[[ $AUDIO =~ ^[0-3]+$ ]] || { echo "${msgtext["choose_interface_invalid"]}"; continue; }
			if ((audio >= 0 && audio <= 3)); then
				echo "Ok."
				break
			else
				echo "${msgtext["choose_interface_invalid"]}"
			fi
		done
		while true; do
			read -p "${msgtext["choose_rtlsdr"]} " YN
			case $YN in
				[JjYyZz]* ) RTLSDR=true; break;;
				[Nn]* ) RTLSDR=false; break;;
				* ) echo ${msgtext["wrong_answer"]};;
			esac
		done
	fi
	
	# Setting up the system basics
	echo "`date +%T`: ${msgtext["setup_creating_groups"]} ..."
	sudo groupadd -r svxlink
	sudo useradd -r -g svxlink -G audio,nogroup,plugdev,dialout -d /etc/svxlink -c "SvxLink daemon" svxlink
	if $IS_PI; then
		sudo usermod -aG gpio svxlink
	fi
	echo "`date +%T`: ${msgtext["setup_install_packages"]} ..."
	sudo apt-get -y --fix-missing install git wget tar vim nano logrotate \
              g++ make libsigc++-2.0-dev \
              libgsm1-dev libpopt-dev tcl-dev \
              libgcrypt-dev libspeex-dev \
              libasound2-dev libsndfile1 alsa-utils \
              sox lame libmp3lame0 vorbis-tools libogg-dev \
              cmake curl cron ntp \
              libjsoncpp-dev libopus-dev \
              libssl-dev libcurl4-openssl-dev groff doxygen graphviz \
              ladspa-sdk swh-plugins tap-plugins
	if [ $? -ne 0 ]; then
		echo "`date +%T`: *** ${msgtext["setup_packages_error"]}"
		exit -1
	fi
	if $IS_PI; then
		sudo apt-get -y --fix-missing install gpiod libgpiod-dev
		if [ $? -ne 0 ]; then
			echo "`date +%T`: *** ${msgtext["setup_packages_error"]}"
			exit -1
		fi
	fi
	debug_info
	if $RTLSDR; then
		echo "`date +%T`: ${msgtext["setup_rtlsdr"]} ..."
		sudo apt-get -y --fix-missing install librtlsdr-dev rtl-sdr python3-serial
		if [ $? -ne 0 ]; then
			echo "`date +%T`: *** ${msgtext["setup_packages_error"]}"
			exit -1
		fi
		debug_info
	fi

	# Install drivers and stuff for audio HAT's if neeeded
	if [ $AUDIO == 1 ]; then
		echo "`date +%T`: ${msgtext["setup_wm8960"]} ..."
		git clone https://github.com/waveshare/WM8960-Audio-HAT --quiet
		if [ $? -ne 0 ]; then
			echo "`date +%T`: *** ${msgtext["setup_git_error"]}"
			exit -1
		fi
		cd WM8960-Audio-HAT
		sudo ./install.sh
		debug_info
	elif [ $AUDIO == 2 ]; then
		echo "`date +%T`: ${msgtext["setup_ics_deactivating_onboard"]} ..."
		sudo sed -i "s/dtparam=audio=on/#dtparam=audio=on/" /boot/config.txt 
		echo "`date +%T`: ${msgtext["setup_ics_activating_audio"]} ..."
		sudo sed -i "s/snd-bcm2835/#snd-bcm2835/" /etc/modules
		echo "`date +%T`: ${msgtext["setup_ics_installing_i2c"]} ..."
		sudo apt-get -y --fix-missing install i2c-tools
		if [ $? -ne 0 ]; then
			echo "`date +%T`: *** ${msgtext["setup_packages_error"]}"
			exit -1
		fi
		sudo sed -i "s/#dtparam=i2c_arm=on/dtparam=i2c_arm=on/" /boot/config.txt
		echo "i2c-dev" | sudo tee -a /etc/modules > /dev/null
		echo "`date +%T`: ${msgtext["setup_ics_activating_ics"]} ..."
		echo "# *** Inserted by SvxLink setup script" | sudo tee -a /boot/config.txt > /dev/null
		echo "#Enable FE-Pi Overlay" | sudo tee -a /boot/config.txt > /dev/null
		echo "dtoverlay=fe-pi-audio" | sudo tee -a /boot/config.txt > /dev/null
		echo "dtoverlay=i2s-mmap" | sudo tee -a /boot/config.txt > /dev/null
		echo "#Enable mcp23s17 Overlay" | sudo tee -a /boot/config.txt > /dev/null
		echo "dtoverlay=mcp23017,addr=0x20,gpiopin=12" | sudo tee -a /boot/config.txt > /dev/null
		echo "#Enable mcp3008 adc overlay" | sudo tee -a /boot/config.txt > /dev/null
		echo "dtoverlay=mcp3008:spi0-0-present,spi0-0-speed=3600000" | sudo tee -a /boot/config.txt > /dev/null
		echo "# Enable UART for serial console" | sudo tee -a /boot/config.txt > /dev/null
		echo "enable_uart=1" | sudo tee -a /boot/config.txt > /dev/null
		debug_info
	elif [ $AUDIO == 3 ]; then
		echo "`date +%T`: ${msgtext["setup_usvx_blacklisting"]} ..."
		echo "blacklist snd_bcm2835" | sudo tee -a /etc/modprobe.d/raspi-blacklist.conf > /dev/null
		if [ -e "/lib/modprobe.d/snd-card.conf" ]; then
			sudo sed -i "s/options snd_usb_audio index=0/#options snd_usb_audio index=0/" /lib/modprobe.d/snd-card.conf 
			sudo sed -i "s/options snd slots=snd_usb_audio,snd-bcm2835/#options snd slots=snd_usb_audio,snd-bcm2835/" /lib/modprobe.d/snd-card.conf 
		fi
		echo "`date +%T`: ${msgtext["setup_usvx_installing_drivers"]} ..."
		git clone https://github.com/respeaker/seeed-voicecard.git --quiet
		if [ $? -ne 0 ]; then
			echo "`date +%T`: *** ${msgtext["setup_git_error"]}"
			exit -1
		fi
		cd seeed-voicecard
		sudo ./install.sh
		echo "`date +%T`: ${msgtext["setup_usvx_gpio_preparing"]} ..."
		echo "###############################################################################" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "#                                                                             #" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Configuration file for the SvxLink server GPIO Pins                         #" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Created using SvxLink setup script by DO6NP and DF5KX for uSvxCard          #" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "#                                                                             #" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "###############################################################################" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "#                                                                             #" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# *** GPIO 17: PTT                                                            #" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# *** GPIO 23: SQUELCH                                                        #"  | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# *** GPIO 24: PUSH BUTTON                                                    #"  | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "#                                                                             #"  | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "###############################################################################" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# GPIO system pin path" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "GPIO_PATH=/sys/class/gpio" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Space separated list of GPIO pins that point IN and have an" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Active HIGH state (3.3v = ON, 0v = OFF)" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "GPIO_IN_HIGH=\"gpio23 gpio24\"" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Space separated list of GPIO pins that point IN and have an" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Active LOW state (0v = ON, 3.3v = OFF)" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "GPIO_IN_LOW=\"\"" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Space separated list of GPIO pins that point OUT and have an" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Active HIGH state (3.3v = ON, 0v = OFF)" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "GPIO_OUT_HIGH=\"gpio17\"" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Space separated list of GPIO pins that point OUT and have an" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Active LOW state (0v = ON, 3.3v = OFF)" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "GPIO_OUT_LOW=\"\"" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# User that should own the GPIO device files"  | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "GPIO_USER=\"svxlink\"" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# Group for the GPIO device files"  | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "GPIO_GROUP=\"svxlink\"" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "# File access mode for the GPIO device files" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		echo "GPIO_MODE=\"0664\"" | sudo tee -a /usr/src/seeed-voicecard/svxlink_gpio.conf > /dev/null
		debug_info
	fi
	
	# Installing SvxLink for the first time
	echo "`date +%T`: ${msgtext["install_svxlink_loading_sources"]} ... "
	git clone https://github.com/sm0svx/svxlink.git --quiet
	if [ $? -ne 0 ]; then
		echo "`date +%T`: *** ${msgtext["setup_git_error"]}"
		exit -1
	fi
	mkdir $HOME/svxlink/src/build
	debug_info
}

################################################################################

# *** Install updates ***

function install_update {
	echo "`date +%T`: ${msgtext["setup_update_packages"]} ..."
	echo "`date +%T`: ${msgtext["install_svxlink_loading_updates"]} ..."
	cd $HOME/svxlink
	VERSION=`grep "SVXLINK=" $VERSIONS | awk -F= '{print $2}'`
	echo "`date +%T`: ${msgtext["install_svxlink_current_version"]}: $VERSION"
	git config pull.rebase true
	git pull --quiet
	if [ "$?" != 0 ]; then
		echo "`date +%T`: ${msgtext["setup_git_error"]}"
		exit 1
	fi
	NEWVERSION=`grep "SVXLINK=" $VERSIONS | awk -F= '{print $2}'`
	echo "`date +%T`: ${msgtext["install_svxlink_new_version"]}: $NEWVERSION"
	debug_info
}

################################################################################

# *** Compile and install SvxLink (new + update) ***

function install_svxlink {
	echo "`date +%T`: ${msgtext["install_svxlink_compiling"]} ..."
	cd $HOME/svxlink/src/build
	cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON ..
	#cmake -DUSE_QT=OFF -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DLOCAL_STATE_DIR=/var -DWITH_SYSTEMD=ON -DWITH_CONTRIB_SIP_LOGIC=ON ..
	if [ $? != 0 ];then
		echo "`date +%T`: ${msgtext["install_svxlink_cmake_error"]}"
		exit 1
	fi
	echo "`date +%T`: ${msgtext["install_svxlink_compiling"]} ..."
	make
	make doc
	echo "`date +%T`: ${msgtext["install_svxlink_installing"]} ..."
	sudo make install
	sudo ldconfig
	debug_info
}

################################################################################

# *** Install all sound files (EN + DE) ***

function install_sounds {
	echo "`date +%T`: ${msgtext["install_svxlink_sounds_en_installing"]} ..."
	cd /usr/share/svxlink/sounds
	sudo git clone https://github.com/sm0svx/svxlink-sounds-en_US-heather.git --quiet
	if [ $? -ne 0 ]; then
		echo "`date +%T`: *** ${msgtext["install_svxlink_sounds_en_installerror"]}"
	else
		sudo $HOME/svxlink/src/svxlink/scripts/filter_sounds.sh svxlink-sounds-en_US-heather en_US-heather-16k
		sudo ln -s en_US-heather-16k en_US
	fi
	if [[ $LANG == "de" ]]; then
		# Install German language pack 'Petra' by DL1HRC
		echo "`date +%T`: ${msgtext["install_svxlink_sounds_de_installing"]} ..."
		sudo git clone https://github.com/dl1hrc/svxlink-sounds-de_DE-petra.git --quiet
		if [ $? -ne 0 ]; then
			echo "`date +%T`: *** ${msgtext["install_svxlink_sounds_de_installerror"]}"
		else
			sudo ln -s svxlink-sounds-de_DE-petra de_DE
		fi
		sudo wget -q https://server42.net/svxlink/de_DE-anna-16k.tar.bz2
		if [ $? -ne 0 ]; then
			echo "`date +%T`: *** ${msgtext["install_svxlink_sounds_de_installerror"]}"
		else
			sudo tar xjf de_DE-anna-16k.tar.bz2
			#sudo ln -s de_DE-anna-16k de_DE
		fi
		sudo rm *.bz2
	fi
	sudo chown -R svxlink:svxlink /usr/share/svxlink/sounds/*
}

################################################################################

# *** Setup SvxLink (change some settings) ***

function setup_svxlink {
	echo "`date +%T`: *** ${msgtext["setup_svxlink_backup"]}"
	sudo cp -p $CONF $CONF.bak
	echo "`date +%T`: *** ${msgtext["setup_svxlink_customizing"]}"
	#sudo sed -i 's/DEEMPHASIS=0/DEEMPHASIS=1/' $CONF
	sudo sed -i "s/MYCALL/$CALL/g" $CONF
	sudo sed -i "s/DEFAULT_LANG/de_DE/g" $CONF
	sudo sed -i 's/SQL_HANGTIME=2000/SQL_HANGTIME=0/' $CONF
	sudo sed -i 's/PEAK_METER=1/PEAK_METER=0/' $CONF
	sudo sed -i -e "s/^DTMF_CTRL_PTY*=.*/DTMF_CTRL_PTY=\/tmp\/dtmf_ctrl" $CONF
	if [ -e "/usr/src/seeed-voicecard/svxlink_gpio.conf" ]; then
		echo "`date +%T`: ${msgtext["setup_usvx_gpio_install"]} ..."
		sudo cp -p /usr/src/seeed-voicecard/svxlink_gpio.conf /etc/svxlink/gpio.conf
	fi

	echo "`date +%T`: *** ${msgtext["setup_svxlink_activating"]}"
	#sudo systemctl enable svxlink_gpio_setup
	sudo systemctl enable svxlink
}

################################################################################

# *** MAIN PROGRAM ***

echo
echo "+---------------------------------------------------------------+"
echo "| SVXLINK Setup Script for Debian / Raspberry Pi OS  \"Bookworm\" |"
echo "|          V$SCRIPT_VERSION - (C) 2022-2024 DF5KX & DO6NP - BETA           |"
echo "+---------------------------------------------------------------+"
echo

# Let's get loud (even without J.Lo)
set_messages

# Use commandline option -D for debug
if [ "$1" = "-D" ]; then
	IS_DEBUG=true
fi

# Do some checkup
check_root
check_os
check_filesystem

# Update the system
update_and_prepare

# We need to start in $HOME
cd $HOME

if [ ! -f $FLAG ]; then
	# Installing for the first time.
	install_firstrun
	install_svxlink
	install_sounds
	setup_svxlink
	touch $FLAG
else
	# Running update
	install_update
	install_svxlink
fi

echo "`date +%T`: *** ${msgtext["main_done"]}"
echo

# *** EOF ***