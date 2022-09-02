#!/bin/bash

if [ "$DATABASE" = "postgres" ]
then
    printf "Waiting for postgres...\n"

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    printf "PostgreSQL started\n"
fi

if [ "$DISABLE_COLLECTSTATIC" != "1" ]
then
    printf "\nCollecting staticfiles...\n"
    if python manage.py collectstatic --noinput
    then
      printf "Collectstatic done\n"
    else
      printf "Collectstatic failed.\nTry setting DISABLE_COLLECTSTATIC to 1 in your environment\n"
    fi
else
    printf "DISABLE_COLLECTSTATIC set to 1 - skipping django collectstatic\n"
fi

if [ "$ENABLE_MAKEMIGRATIONS" == "1" ]
then
    printf "\nMaking migrations...\n"
    if python manage.py makemigrations
    then
      printf "Makemigrations done\n"
    else
      printf "Makemigrations failed.\nTry removing ENABLE_MAKEMIGRATIONS from your environment\n"
    fi
else
    printf "ENABLE_MAKEMIGRATIONS not set - skipping django makemigrations\n"
fi

if [ "$DISABLE_MIGRATE" != "1" ]
then
    printf "\nMigrating...\n"
    if python manage.py migrate --noinput
    then
      printf "Migrate done\n"
    else
      printf "Migrate failed.\nTry setting DISABLE_MIGRATE to 1 in your environment\n"
    fi
else
    printf "DISABLE_MIGRATE set to 1 - skipping django migrate\n"
fi

exec "$@"