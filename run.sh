#!/bin/bash
echo "choose a number"
echo "> 1: build"
echo "> 2: rebuild app"
echo "> 3: configure environment"
echo "> 4: backup database"
echo "> 5: restore database"
read num
case $num in
    1)
        echo "running build..."
        source bin/sh/build.sh
        ;;
    2)
        echo "running rebuild..."
        source bin/sh/rebuild.sh
        ;;
    3)
        echo "running config..."
        source bin/sh/config.sh
        ;;
    4)
        echo "running backup database..."
        source bin/sh/db_backup.sh
        ;;
    5)
        echo "running restore database..."
        source bin/sh/db_restore.sh
        ;;
esac
