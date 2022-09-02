#!/bin/bash
echo "choose a number"
echo "> 1: build"
echo "> 2: maintenance"
echo "> 3: configure environment"
echo "> 4: restore database"
read num
case $num in
    1)
        echo "running build..."
        source bin/sh/build.sh
        ;;
    2)
        echo "running maintenance..."
        source bin/sh/maintenance.sh
        ;;
    3)
        echo "running config..."
        source bin/sh/config.sh
        ;;
    4)
        echo "running restore database..."
        source bin/sh/db_restore.sh
        ;;
esac
