#!/bin/bash
printf "Restore database.\n"
read -p "Enter the database user (default root):" db_user
[ -z "$db_user" ] && db_user="root"
printf "\n"
read -p "Restore from full backup? (y/n):" full
printf "\n"
if [ "$full" == "y" ]; then
    mkdir -p backups/restore
    printf "if you have a local backup file, copy or move it to the backups/restore directory.\n"
    printf "if your backup file was made here, you can continue now\n"
    read -p "Press any key to continue..." -n1 -s
    dir = "backups/db/full"
    printf "Listing backups...\n"
    for file in $dir; do
        echo "$file"
    done
    read -p "Enter the backup file name:" backup_file
    printf "\n"
    extension="${backup_file##*.}"
    new_file=backups/restore/backup.$extension
    cp $dir/$backup_file $new_file
    printf "Restoring $backup_file...\n"
    docker exec -t postgres bash -c "psql -f $new_file -v ON_ERROR_STOP=1"
    printf "Database restored from $backup_file.\n"
    rm -r backups/restore
    exit 0
else
    printf "listing databases...\n"
    docker exec -it postgres bash -c "psql -U $db_user -l" 
    read -p "Enter the database name:" db_name
    printf "\n"
    dir = "backups/db/$db_name"
    printf "Listing backups...\n"
    for file in $dir; do
        echo "$file"
    done
    read -p "Enter the backup file name:" backup_file
    printf "\n"
    extension="${backup_file##*.}"
    new_file=backups/restore/backup.$extension
    cp $dir/$backup_file backups/restore
    printf "Restoring $backup_file...\n"
    mkdir -p backups/restore
    docker exec -t postgres bash -c "psql -U $db_user -d $db_name $new_file < $new_file"
    printf "$db_name restored from $backup_file.\n"
    rm -r backups/restore
    exit 0
fi