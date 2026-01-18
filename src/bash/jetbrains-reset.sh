#!/usr/bin/env bash
set -e

apps=("CLion" "DataGrip" "GoLand" "IntelliJIdea" "PhpStorm" "PyCharm" "Rider" "WebStorm")


for app in "${apps[@]}"
do
    config_dirs=$(find "$HOME/.config/JetBrains/" -iname "$app*" -type d)

    for dir in $config_dirs
    do
        echo -n "Found: $(basename "$dir"). Clearing... "

        rm -rf "$dir/eval"
        # rm -rf "$dir/options/usage.statistics.xml"
        rm -rf "$dir/options/other.xml"
        # rm -rf "$dir/options/recentProjects.xml"
        # rm -rf "$dir/options/updates.xml"

        echo "OK"
    done
done

rm -rf "$HOME/.java/.userPrefs/jetbrains" "$HOME/.java/.userPrefs/prefs.xml"

exit 0
