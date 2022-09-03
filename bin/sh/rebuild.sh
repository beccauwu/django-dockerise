#!/bin/bash
to = head -1 .env/.prod.env
arrTo = (${to//=/ })
printf "Rebuilding web services...\n"
docker compose -f docker-compose.prod.yml up -d --build web nginx
printf "Web services rebuilt.\n"
printf "Done.\n"
printf "\n"
read -r firstline<.env/.prod.env
echo "Your app is now available at:"
echo $firstline | cut -d "=" -f 2
exit 0
