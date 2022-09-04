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
        . bin/sh/build.sh
        ;;
    2)
        echo "running rebuild..."
        . bin/sh/rebuild.sh
        ;;
    3)
        echo "running config..."
        python bin/py/config.py && printf "Production environment configuration complete.\n\n"
        read -p "Do you want to build the production environment now? (y/n):" build_now
        if [ "$build_now" == "y" ] || [ "$build_now" == "Y" ]
        then
            . bin/sh/build.sh
        else
            printf "\n"
            printf "Build the production environment by running run.sh again and choosing build\n"
        fi
        ;;
    4)
        echo "running backup database..."
        . bin/sh/db_backup.sh
        ;;
    5)
        echo "running restore database..."
        . bin/sh/db_restore.sh
        ;;
esac
