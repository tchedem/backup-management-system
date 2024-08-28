#!/bin/bash

# Here, you can customize your backup folder path
BASE_PATH=$HOME

BACKUP_RELATIVE_PATH=app_backups

APP_BACKUP_RELATIVE_FOLDER=agrosurvey_api/mysql

BACKUP_DIR=$BASE_PATH/$BACKUP_RELATIVE_PATH/$APP_BACKUP_RELATIVE_FOLDER

database_name=agrosfer_api_prod
database_user=luc
database_password=root
# database_final_name=$(date +%Y_%m_%d_%H_%M_%S_%N)$zip_file_extention
database_final_name=$(date +%Y_%m_%d_%H_%M)$zip_file_extention
zip_file_extention='.zip'

# you can send this value from the command line as option in the command
# and it should always be less than the number of max
max_number_of_backups=${1:-8}

mkdir -p $BACKUP_DIR
cd $BACKUP_DIR

echo "Exporting MySQL database..."

mysqldump -u $database_user -p$database_password $database_name > $database_name

zip -r $database_final_name ./$database_name

rm ./"$database_name"

total_current_backups=$(ls -1 *.zip | wc -l)

if [ $total_current_backups -gt $max_number_of_backups ]; then
    # echo 'h'
    number_of_backups_to_remove=$(( $total_current_backups-$max_number_of_backups ));

    backup_files_to_remove=$( ls -p . | grep -v / | head -n $number_of_backups_to_remove )

    # Loop through the files and delete them
    echo "$backup_files_to_remove" | while IFS= read -r backup_file; do
        if [ -f "$backup_file" ]; then
            echo "Suppression de : $backup_file"
            rm -f "$backup_file"
        else
            echo "File not found: $backup_file"
        fi
    done
    
    # # remove old elements
    # for backup_file in $backup_files_to_remove; do
    #     if [ -f $backup_file ]; then
    #         echo "Suppression de : $backup_file"
    #         rm -f "$backup_file"
    #     fi
    # done

fi

exit 0