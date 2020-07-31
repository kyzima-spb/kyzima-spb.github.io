#!/usr/bin/env bash
set -e


PIPFILES_PATH=${PIPFILES_PATH:-"Pipfile /Pipfile"}
REQUIREMENTS_PATH=${REQUIREMENTS_PATH:-"requirements.txt /requirements.txt"}


for path in $PIPFILES_PATH
do
    if [[ -f "$path" ]]
    then
        if [ "$(type -t pipenv)" = "" ]
        then
            echo "You have to install pipenv manually." >&2
            exit 1
        fi
        
        pushd $(dirname "$path")
            echo "Found Pipfile. Installation of dependencies..."
            pipenv install --system --deploy --ignore-pipfile
        popd
        exit 0
    fi
done


for path in $REQUIREMENTS_PATH
do
    if [[ -f "$path" ]]
    then
        pushd $(dirname "$path")
            echo "Found requirements.txt. Installation of dependencies..."
            pip install --no-cache-dir --disable-pip-version-check -q -r "$path"
        popd
        exit 0
    fi
done


if [[ -f "setup.py" ]]
then
    echo "Found setup.py. Installation this package as is..."
    pip install --no-cache-dir --disable-pip-version-check -q .
    exit 0
fi


echo "Not found package." >&2
exit 1
