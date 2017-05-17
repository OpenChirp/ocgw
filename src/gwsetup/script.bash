#!/bin/bash
# Craig Hesling <craig@hesling.com>
# August 11, 2016
#
# Although no one likes script that contain payloads, we provide
# this payloaded script to ease the setup of new gateways.
# Rest assured that we do no do any black magic non-package controlled
# file thrashing. You can observer the debug output to get a feel for
# what this script is doing. It is also easy enough to just read through it.
#
# This script should be run from the pi user
#
# Usage: gwsetup [-t]
# -t: Shows content of payload and then exits

ROOT_CMD=sudo
TARGET_USER=pi
HOSTNAME_PREFIX=yodelgw
TARGET_DEBIAN_RELEASE=stretch

PAYLOAD_DIR=`mktemp -d /tmp/gwsetup_payload.XXX`

PKTFWD_LOCAL_CONF_FILE=/etc/packet-forwarder/local_conf.json
BRIDGE_ENV_FILE=/etc/lora-gateway-bridge.env

function unpack_payload()
{
	local match_line=$(grep --text --line-number '^PAYLOAD:$' $0 | cut -d ':' -f 1)
	local payload_start_line=$((match_line + 1))

	if [ $# -gt 0 ]; then
		echo "# Showing content of payload"
		tail -n +$payload_start_line $0 | base64 -d | tar -tzv
		exit $?
	else
		echo "# Unpacking the payload into $PAYLOAD_DIR"
		tail -n +$payload_start_line $0 | base64 -d | tar -xzv -C $PAYLOAD_DIR
		return $?
	fi
}

# Look for help
case $1 in
	-h|--help)
		echo "Sets up a yodel gateway"
		echo "Usage: gwsetup [-t] [-h]"
		echo "-t: Prints the payload contents and exits"
		echo "-h: Prints this help message"
		exit 0
		;;
esac

# Unpack the payload
if ! unpack_payload $@; then
	echo "Failed to unpack embedded payload" >&2
	exit 1
fi

# Check user
if [ ! "$(whoami)" = "$TARGET_USER" ]; then
	echo "This script should be run under the user $TARGET_USER" >&2
	exit 1
fi

# Get hostname of this gateway
echo
read -p "Please specify the gateway's number for generating the hostname(2 would mean ${HOSTNAME_PREFIX}2): " gwnumber
hostname="${HOSTNAME_PREFIX}${gwnumber}"
echo Hostname will be \"$hostname\"


# Ask for gateway's MQTT server username
echo
read -p "Please specify the gateway's mqtt username: " mqtt_username

# Ask for gateway's MQTT server password
echo
read -p "Please specify the gateway's mqtt password: " mqtt_password

# Set new password for TARGET_USER - root show not have a password
echo
echo "# Please set the new password for user \"$TARGET_USER\" - root shall not have a password"
passwd $TARGET_USER

# Enable SPI using raspi-config
echo
echo "# Please enable SPI using the raspi-config GUI tool. We will launch it after you press enter."
read -p "Press enter to continue " input
$ROOT_CMD raspi-config

# Change timezone tzdata
echo
echo "# Please set the proper time zone information using the reconfigure GUI. We will launch after you press enter"
read -p "Press enter to continue" input
$ROOT_CMD dpkg-reconfigure tzdata

echo
echo "# Change default ~/.vimrc to have syntax on, numbers on side, and mouse click enabled"
cat > /home/$TARGET_USER/.vimrc <<-EOF
	syntax on
	set number
	set mouse=a
EOF

# Add .bash_aliases
echo
if [ ! -e /home/$TARGET_USER/.bash_aliases ]; then
	echo "# Adding standard bash aliases to ~/.bash_aliases"
	cat > /home/$TARGET_USER/.bash_aliases <<EOF
# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

if [ -d "\$HOME/go" ]; then
	export GOPATH="\$HOME/go"

	if [ -d "\$GOPATH/bin" ]; then
		export PATH="\$GOPATH/bin:$PATH"
	fi
fi
EOF
else
	echo "# ~/.bash_aliases already exists. We will not touch it."
fi

# Upgrade to later Raspbian release
echo
release_original=$(lsb_release -c|awk '//{print $2}')
echo "# Upgrading to Rasp/Debian $TARGET_DEBIAN_RELEASE"
$ROOT_CMD sed -i "s/${release_original}/${TARGET_DEBIAN_RELEASE}/g" /etc/apt/sources.list
$ROOT_CMD apt-get update
$ROOT_CMD apt-get upgrade
$ROOT_CMD apt-get dist-upgrade

# Install the payload packages
echo
echo "# Installing the yodelgw packages form the payload"
$ROOT_CMD dpkg -i $PAYLOAD_DIR/pkgs/builds/*.deb
$ROOT_CMD apt-get install -f

# Since the yodelgw package installs an apt preferences
# config that calls for a downgrade of a wireless package, 
# we need to do an additional upgrade to trigger the downgrade.
# The priority of the preference is high enough to force it
# during normal upgrade.
#
# We do a full update, upgrade, and dist-upgrade to allow future
# preferences and source modifications.
$ROOT_CMD apt-get update
$ROOT_CMD apt-get upgrade
$ROOT_CMD apt-get dist-upgrade

# TODO - Make it so that this script can clone the repo from the private git server
# Clone the main yodelgw repo in home directory
#echo
#echo "# Cloning the main yodelgw repository in home directory. This is for receiving updates."
#if [ ! -e /home/$TARGET_USER/yodelgw ]; then
#	git clone git@git.wise.ece.cmu.edu:lpwan/yodelgw.git /home/$TARGET_USER/yodelgw
#fi

# Configure LoRa gateway ID
echo
gatewayid=D00D8BADF00D$(printf "%4.4d" ${gwnumber})
echo "# Configure LoRa gateway ID to ${gatewayid}"
$ROOT_CMD sed -i "s/D00D8BADF00D0000/${gatewayid}/g" $PKTFWD_LOCAL_CONF_FILE

# Configure gateway MQTT user/pass
echo
echo "# Configure MQTT credentials to \"${mqtt_username}\" : \"${mqtt_password}\""
$ROOT_CMD sed -i "s/someusername/\"${mqtt_username}\"/g" $BRIDGE_ENV_FILE
mqtt_password_escaped=$(sed 's/[&/\]/\\&/g' <<<"$mqtt_password")
$ROOT_CMD sed -i "s/somepassword/\"${mqtt_password_escaped}\"/g" $BRIDGE_ENV_FILE

# Force NTP to sync
echo
echo "# Adjusting the time from the NTP server"
#$ROOT_CMD service ntp stop
#$ROOT_CMD ntpd -gq
#$ROOT_CMD service ntp start
$ROOT_CMD timedatectl set-ntp yes

# Change hostname
echo
hostname_original=`hostname`
echo "# Changing hostname $hostname_original to $hostname in hosts and hostname files"
$ROOT_CMD sed -i "s/${hostname_original}/${hostname}/g" /etc/hostname
$ROOT_CMD sed -i "s/${hostname_original}/${hostname}/g" /etc/hosts


echo
echo "## Showing final settings ##"
echo
echo "Hostname: $hostname"
echo
$ROOT_CMD ifconfig

echo
echo "# Please reboot the gateway to allow changes to take effect"

exit 0

