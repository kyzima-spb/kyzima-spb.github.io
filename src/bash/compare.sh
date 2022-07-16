#!/usr/bin/env bash
set -ue


makeHash() {
	find "$1" -type f -exec md5sum -b {} + | awk '{print $1}' | LC_ALL=C sort | md5sum | awk '{print $1}'
}


compare() {
	local lastHash=""
	
	for p in $@; do
		local newHash=$(makeHash "$p")
		
		if [[ "$lastHash" != "" ]] && [[ "$lastHash" != "$newHash" ]]; then
			return 1
		fi

		lastHash="$newHash"
	done

	echo "$lastHash"

	return 0
}


if [[ $# < 1 ]]; then
	echo "One or more arguments required." >&2
	exit 1
fi

compare $@

