#!/bin/bash
read -p "Do you want to continue with build? (y/n):" continue_build
if [ "$continue_build" == "y" ]; then
    docker compose -f docker-compose.prod.yml up -d --build
    printf "Done.\n"
    read -r firstline<.env/.prod.env
    echo "Your app will now be available at:"
    echo $firstline | cut -d "=" -f 2
    printf "\n"
    printf "Now please forward your domain to this server in your DNS settings\n"
    printf "It is highly advisable to do this through a proxy.\n"
    printf "You can find instructions on how to do this here:\n"
    printf "https://github.com/beccauwu/django-dockerise\n"
    exit 0
else
    printf "\n"
    printf "Build cancelled.\n\n"
    exit 1
fi