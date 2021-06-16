#!/usr/bin/env bash
set -e

declare -a apps=(
    "DataGrip"
    "CLion"
    "Rider"
    "WebStorm"
    "GoLand"
    "PyCharm"
)

for app in "${apps[@]}"; do
    configDirs=$(find "$HOME/.config/JetBrains/" -iname "$app*" -type d)

    for dir in $configDirs; do
        echo -n "Found: $(basename "$dir"). Clearing... "
        rm -rf "$dir/eval"
        rm -rf "$dir/options/usage.statistics.xml"
#        rm -rf "$dir/options/other.xml"
#        rm -rf "$dir/options/recentProjects.xml"
        rm -rf "$dir/options/updates.xml"
        rm -rf "$dir/options/usage.statistics.xml"
        echo "OK"
    done
done
