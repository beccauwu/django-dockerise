#!/bin/bash
db_file=".db.env"
pgadmin_file=".pgadmin.env"
prod_file=".prod.env"
printf "First, let's configure the database.\n\n"
while true; do
    read -p "Enter desired root username (default root):" db_user
    [ -z "$db_user" ] && db_user="root"
    while true; do
        printf "\n"
        read -s -p "Enter desired password (default root):" db_password
        [ -z "$db_password" ] && db_password="root" && break
        printf "\n"
        read -s -p "Confirm password:" db_password_confirm
        [ "$db_password" == "$db_password_confirm" ] && break
        printf "Passwords do not match. Please try again.\n"
        continue
    done
    printf "\n"
    read -p "Enter the database name (default postgres):" db_name
    printf "\n"
    [ -z "$db_name" ] && db_name="postgres"
    break
done
cat <<EOF > $db_file
DB_USER=$db_user
DB_PASSWORD=$db_password
DB_NAME=$db_name
EOF
printf "Database configuration complete.\n\n"
printf "Now, let's configure pgAdmin.\n\n"
while true; do
    while true; do
        read -p "Enter email address for pgAdmin:" pg_email
        printf "\n"
        [ -z "$pg_email" ] && printf "Please enter an email address.\n" && continue
        [[ $pg_email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]] && break
        printf "Invalid email address. Please try again.\n"
        continue
    done
    while true; do
        read -s -p "Enter password for pgAdmin (default root):" pg_password
        printf "\n"
        [ -z "$pg_password" ] && pg_password="root" && break
        read -s -p "Confirm password:" pg_password_confirm
        printf "\n"
        [ "$pg_password" == "$pg_password_confirm" ] && break
        printf "Passwords do not match. Please try again.\n"
        continue
    done
    break
done
cat <<EOF > $pgadmin_file
PGADMIN_DEFAULT_EMAIL=$pg_email
PGADMIN_DEFAULT_PASSWORD=$pg_password
EOF
printf "pgAdmin configuration complete.\n\n"
printf "Now, let's configure the production environment.\n\n"
while true; do
    read -p "Enter the domain name for the production environment (e.g. site.example.com):" prod_domain
    printf "\n"
    [ -n "$prod_domain" ] && break
    printf "Domain name is required. Please try again.\n"
    continue
done
cat <<EOF > $prod_file
SQL_USER=$db_user
SQL_PASSWORD=$db_password
SQL_DATABASE=$db_name
SQL_HOST=db
SQL_PORT=5432
DATABASE=postgres
DJANGO_ALLOWED_HOSTS=$prod_domain
DJANGO_TRUSTED_ORIGINS=https://$prod_domain
EOF

printf "Production environment configuration complete.\n\n"
read -p "Do you want to build the production environment now? (y/n):" build_now
if [ "$build_now" == "y" ] || [ "$build_now" == "Y" ]
then
    source bin/sh/build.sh
else
    printf "\n"
    printf "Build the production environment by running ./build.sh\n"
fi
