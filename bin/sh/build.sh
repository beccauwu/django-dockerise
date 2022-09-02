#!/bin/bash

df=src/app/Dockerfile.prod
dc=src/docker-compose.yml
ep=src/app/entrypoint.prod.sh
ng=src/nginx/nginx.conf
nd=src/nginx/Dockerfile

function ea { read -p "Edit another file? (y/n):" result; }

function roe {
    if [ -f $1 ]
    then
        vim $1
    else
        echo "File not found."
    fi
}

read -p "Have you already configured your .env files? (y/n):" result
if ! [ $result == "y" ] && ! [ $result == "Y" ]
then
    read -p "Configure now? (y/n):" result
    if [ $result == "y" ]
    then
        source bin/sh/config.sh
    fi
fi

if ! [ -x "$(command -v docker)" ]; then
    read -p "Docker is not installed. Would you like to install it now? (y/n):" install_docker
    if [ "$install_docker" == "y" ]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
    else
        printf "Docker is required to build the production environment. Please install it and try again.\n"
        exit 1
    fi
fi

read -p "Would you like to read or edit a configuration file now? (y/n):" read_config
if [ "$read_config" == "y" ]; then
    while true; do
        printf "> 1: Dockerfile.prod\n"
        printf "> 2: docker-compose.yml\n"
        printf "> 3: entrypoint.prod.sh\n"
        printf "> 4: nginx.conf\n"
        printf "> 5: continue without reading\n"
        read -p "Choose the file number:\n" file_num
        case $file_num in
        1)
            nano $df
            ea && [ "$result" == "y" ] && continue
            break
            ;;
        2)
            nano $dc
            ea && [ "$result" == "y" ] && continue
            break
            ;;
        3)
            nano $ep
            ea && [ "$result" == "y" ] && continue
            break
            ;;
        4)
            nano $ng
            ea && [ "$result" == "y" ] && continue
            break
            ;;
        5)
            break
            ;;
        *)
            printf "Invalid choice. Please try again.\n"
            continue
            ;;
        esac
    done
    
fi

read -p "Do you want to continue with build? (y/n):" continue_build
if [ "$continue_build" == "y" ]; then
    read -p "App root folder (default is app) - this is where manage.py is located:" app_folder
    [ -z "$app_folder" ] && app_folder="app"
    printf "\n"
    printf "Copying files...\n"
    echo -ne "#                     (0%)\r"
    cp $df $app_folder/Dockerfile.prod
    echo -ne "####                  (20%)\r"
    cp $ep $app_folder/entrypoint.prod.sh
    echo -ne "########              (40%)\r"
    cp $dc docker-compose.yml
    echo -ne "############          (60%)\r"
    mkdir -p nginx
    cp $ng nginx/nginx.conf
    echo -ne "################      (80%)\r"
    cp $nd nginx/Dockerfile
    echo -ne "####################  (100%)\r"
    printf "\n"
    printf "Done.\n"
    printf "Building the production environment...\n"
    docker compose -f docker-compose.prod.yml up -d --build
    printf "Done.\n"
    printf "Now please forward your domain to this server in your DNS settings\n"
    printf "It is highly advisable to do this through a proxy.\n"
    printf "You can find instructions on how to do this here:\n"
    printf "https://github.com/beccauwu/docker-production-automated\n"
    read -p "Remove source files? (y/n):" remove_source
    if [ "$remove_source" == "y" ]; then
        printf "Removing source files...\n"
        rm -r src
        printf "Done.\n"
    fi
    read -p "Press any key to exit..."
    exit 0
else
    printf "\n"
    printf "Build cancelled.\n\n"
    exit 1
fi
