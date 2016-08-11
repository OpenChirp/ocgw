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
read -p "Please specify the gateway's number for generating the hostname(2 would mean ${HOSTNAME_PREFIX}2): " gwnumber
hostname="${HOSTNAME_PREFIX}${gwnumber}"
echo Hostname will be \"$hostname\"

# Set new password for TARGET_USER - root show not have a password
echo "# Please set the new password for user \"$TARGET_USER\" - root shall not have a password"
passwd $TARGET_USER

echo "# Change default ~/.vimrc to have syntax on, numbers on side, and mouse click enabled"
cat > /home/$TARGET_USER <<-EOF
	syntax on
	set number
	set mouse=a
EOF

# Upgrade to later Raspbian release
release_original=$(lsb_release -c|awk '//{print $2}')
echo "# Upgrading to Rasp/Debian $TARGET_DEBIAN_RELEASE"
$ROOT_CMD sed -i "s/${release_original}/${TARGET_DEBIAN_RELEASE}/g" /etc/apt/source.list
$ROOT_CMD apt-get update
$ROOT_CMD apt-get upgrade
$ROOT_CMD apt-get dist-upgrade

# Install the payload packages
echo "# Installing the yodelgw packages form the payload"
$ROOT_CMD dpkg -i $PAYLOAD_DIR/*.deb
$ROOT_CMD apt-get install -f

# Change hostname
hostname_original=`hostname`
echo "# Changing hostname $hostname_original to $hostname in hosts and hostname files"
$ROOT_CMD sed -i "s/${hostname_original}/${hostname}/g" /etc/hostname
$ROOT_CMD sed -i "s/${hostname_original}/${hostname}/g" /etc/hosts

echo "## Showing final settings ##"
echo
echo "Hostname: $hostname"
echo
$ROOT_CMD ifconfig

echo
echo "# Please reboot the gateway to allow changes to take effect"

exit 0

