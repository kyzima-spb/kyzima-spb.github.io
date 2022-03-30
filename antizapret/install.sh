#!/usr/bin/env bash
set -e

# AntiZapret VPN for Debian based OS installation script
# 
# See https://bitbucket.org/anticensority/antizapret-vpn-container/ for the installation steps.
# 

commandExists() {
    command -v "$1" > /dev/null 2>&1
}

containerFileExists() {
    dir=$(dirname $1)
    filename=$(basename $1)
    machinectl -q shell antizapret-vpn /usr/bin/find "$dir" -type f -name "$filename"
}


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


if [[ ! -d /root/.gnupg/ ]]; then
    mkdir -p /root/.gnupg/
fi

systemctl enable --now systemd-networkd.service


if ! machinectl show-image antizapret-vpn > /dev/null 2>&1; then
    gpg \
        --no-default-keyring \
        --keyring /etc/systemd/import-pubring.gpg \
        --keyserver hkps://keyserver.ubuntu.com \
        --receive-keys 0xEF2E2223D08B38D4B51FFB9E7135A006B28E1285
    
    machinectl pull-tar https://antizapret.prostovpn.org/container-images/az-vpn/rootfs.tar.xz antizapret-vpn
    
    cnfPath="/etc/systemd/nspawn/antizapret-vpn.nspawn"
    
    if [[ ! -f $cnfPath ]]; then
        mkdir -p "$(dirname "$cnfPath")"
        echo -e "[Network]\nVirtualEthernet=yes\nPort=tcp:1194:1194\nPort=udp:1194:1194" > "$cnfPath"
    fi
    
    machinectl enable antizapret-vpn
    machinectl start antizapret-vpn
    
    ovpnFile="/root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-tcp.ovpn"

    while [[ -z $(containerFileExists "$ovpnFile") ]]; do
        echo "File not exists"
        sleep 1
        break
    done

    machinectl copy-from antizapret-vpn "$ovpnFile" $(basename "$ovpnFile")
fi
