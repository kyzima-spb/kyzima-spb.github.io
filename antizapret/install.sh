#!/usr/bin/env bash
set -e

# AntiZapret VPN for Debian based OS installation script
# 
# See https://bitbucket.org/anticensority/antizapret-vpn-container/ for the installation steps.
# 
# wget -qO- http://192.168.88.200:8000/install.sh | sudo bash


commandExists() {
	command -v "$1" > /dev/null 2>&1
}


SERVICE_NAME="antizapret-vpn"
IMAGE_URL="https://antizapret.prostovpn.org/container-images/az-vpn/rootfs.tar.xz"


if [ "$(whoami)" != "root" ]; then
	echo "You have no permission to run $0 as non-root user. Use sudo" >&2
	exit 1
fi


needReqs=""


if ! commandExists machinectl; then
	needReqs="$needReqs systemd-container"
fi


if ! commandExists gpg; then
	needReqs="$needReqs dirmngr"
fi


if [[ ! -z $needReqs ]]; then
	apt update -qq && apt install -qq -y $needReqs
fi


gnupgDir="/root/.gnupg/"

if [[ ! -d "$gnupgDir" ]]; then
	mkdir -p "$gnupgDir"
	chmod 700 "$gnupgDir"
fi

systemctl enable --now systemd-networkd.service


if ! machinectl show-image "${SERVICE_NAME}" > /dev/null 2>&1; then
	gpg \
		--no-default-keyring \
		--keyring /etc/systemd/import-pubring.gpg \
		--keyserver hkps://keyserver.ubuntu.com \
		--receive-keys 0xEF2E2223D08B38D4B51FFB9E7135A006B28E1285
	machinectl pull-tar "$IMAGE_URL" "$SERVICE_NAME"
fi


if ! machinectl show "$SERVICE_NAME" > /dev/null 2>&1; then
	cnfPath="/etc/systemd/nspawn/antizapret-vpn.nspawn"
	
	if [[ ! -f $cnfPath ]]; then
		mkdir -p "$(dirname "$cnfPath")"
		cat > "$cnfPath" <<- EOF
			[Exec]
			NotifyReady=yes

			[Network]
			VirtualEthernet=yes
			Port=tcp:1194:1194
			Port=udp:1194:1194
		EOF
	fi
	
	machinectl enable "$SERVICE_NAME"
	machinectl start "$SERVICE_NAME"
	
	srcOvpnFile="/root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-tcp.ovpn"
	destOvpnFile=$(basename "$srcOvpnFile")
	
	echo -n "Wait creation OVPN config file..."
	sleep 10
	machinectl copy-from "$SERVICE_NAME" "$srcOvpnFile" "$destOvpnFile"
	echo "[OK]"
	
	chown $SUDO_UID:$SUDO_GID "$destOvpnFile"
fi
