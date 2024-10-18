#!/bin/sh
#Used to easily copy sftp user mounts that we use on some servers. These users are bind mounted so this will not work for most use cases. Also you will find it requires a special wrapper script at the bottom to do the actual user add. That script will stay proprietary. 
cur_path="."

get_files()
{
read -p "What server are you copying sftp users from:  " origin_host
scp root@"$origin_host":/etc/\{shadow,passwd,group,gshadow} "$cur_path"/backup/
sftpgroupid=$(ssh $origin_host grep sftpusers /etc/group | awk -F ':' '{print $3}')
ssh $origin_host grep $sftpgroupid /etc/passwd > "$cur_path"/sftppass.log
}

sync_list()
{
rsync -axSv root@"$origin_host":/etc/sftpuser* /etc/
}

breakoutusers()
{
userlist=$(cat "$cur_path"sftppass.log | awk -F ':' '{print $1}')
printf "$userlist" "%c\n" >> "$cur_path"users.log
}

get_files
breakoutusers
sync_list



USERLIST=$(awk -F ":" '{print $1'} sftppass.log)
declare -a USERS
USERS=($USERLIST)

UIDS=$(awk -F ":" '{print $3'} sftppass.log)
declare -a UIDS
uid_array=($UIDS)

GETHASH=$(for i in $(awk -F ":" '{print $1}' sftppass.log); do grep "$i" backup/shadow |awk -F ':' '{print $2}'; done)
declare -a GETHASH
hash_array=($GETHASH)

#printf "${uid_array[2]}"
#printf "${USERS[2]}"
#printf "${hash_array[1]}\n"

#/usr/local/sbin/create-sftp-user -u ${uid_array[0]} ${USERS[0]} 
#usermod -p "${hash_array[0]}" "${USERS[0]}"

print_arr()
{
for i in "${!USERS[@]}"; do
    printf "User %s will have uid %s with password hash %s\n" "${USERS[i]}" "${uid_array[i]}" "${hash_array[i]}"
done
}

run_wrapper()
{
for i in "${!USERS[@]}"; do
        /usr/local/sbin/create-sftp-user -u "${uid_array[i]}" "${USERS[i]}"
done
}

add_hash()
{
for i in "${!USERS[@]}"; do
        echo the following is being performed: usermod -p "${hash_array[i]}" "${USERS[i]}"
        usermod -p "${hash_array[i]}" "${USERS[i]}"
done
}


print_arr
run_wrapper
add_hash
