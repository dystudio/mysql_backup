#!/bin/bash
# mysql_backup.sh: backup mysql databases and keep newest 5 days backup.  
#  
# ${db_user} is mysql username  
# ${db_password} is mysql password  
# ${db_host} is mysql host   
# ！！！！！！！！！�C  
#/root/mysql_backup.sh
# everyday 3:00 AM execute database backup
# 0 3 * * * /root/mysql_backup.sh
#/etc/cron.daily

db_user="backup"
db_password="8H2QQQBEypp"
db_host="localhost"
# the directory for story your backup file.  #
backup_dir="/home/backup/mysql/"
# 勣姥芸議方象垂兆 #
#all_db="$(${mysql} -u ${db_user} -h ${db_host} -p${db_password} -Bse 'show databases')" #
all_db="dbname"

# 勣隠藻議姥芸爺方 #
backup_day=10

#方象垂姥芸晩崗猟周贋刈議揃抄
logfile="/var/log/mysql_backup.log"

###ssh極笥催###
ssh_port=1204
###協吶ssh auto key議猟周###
id_rsa=/root/auth_key/id_rsa_153.141.rsa
###協吶ssh auto username###
id_rsa_user=rsync
###協吶勣揖化議垓殻捲暦匂議朕村揃抄�┗慚詈脳�斤揃抄��###
clientPath="/home/backup/mysql"
###協吶勣承�餤脹承慘勅�朕村揃抄 坿捲暦匂�┗慚詈脳�斤揃抄��###
serverPath=${backup_dir}
###協吶伏恢桟廠議ip###
web_ip="192.168.0.2"

# date format for backup file (dd-mm-yyyy)  #
time="$(date +"%Y-%m-%d")"

# mysql, ${mysqldump} and some other bin's path  #
mysql="/usr/local/mysql-5.5.33/bin/mysql"
mysqldump="/usr/local/mysql-5.5.33/bin/mysqldump"

# the directory for story the newest backup  #
test ! -d ${backup_dir} && mkdir -p ${backup_dir}

#姥芸方象垂痕方#
mysql_backup()
{
    # 函侭嗤議方象垂兆 #
    for db in ${all_db}
    do
        backname=${db}.${time}
        dumpfile=${backup_dir}${backname}
        
        #繍姥芸議扮寂、方象垂兆贋秘晩崗
        echo "------"$(date +'%Y-%m-%d %T')" Beginning database "${db}" backup--------" >>${logfile}
        ${mysqldump} -F -u${db_user} -h${db_host} -p${db_password} ${db} > ${dumpfile}.sql 2>>${logfile} 2>&1
        
        #蝕兵繍儿抹方象晩崗亟秘log
        echo $(date +'%Y-%m-%d %T')" Beginning zip ${dumpfile}.sql" >>${logfile}
        #繍姥芸方象垂猟周垂儿撹ZIP猟周��旺評茅枠念議SQL猟周. #
        tar -czvf ${backname}.tar.gz ${backname}.sql 2>&1 && rm ${dumpfile}.sql 2>>${logfile} 2>&1 
        
        #繍儿抹朔議猟周兆贋秘晩崗。
        echo "backup file name:"${dumpfile}".tar.gz" >>${logfile}
        echo -e "-------"$(date +'%Y-%m-%d %T')" Ending database "${db}" backup-------\n" >>${logfile}    
    done
}

delete_old_backup()
{    
    echo "delete backup file:" >>${logfile}
    # 評茅症議姥芸 臥孀竃輝念朕村和鈍爺念伏撹議猟周��旺繍岻評茅
    find ${backup_dir} -type f -mtime +${backup_day} | tee delete_list.log | xargs rm -rf
    cat delete_list.log >>${logfile}
}

rsync_mysql_backup()
{
    # rsync 揖化欺凪麿Server嶄 #
    for j in ${web_ip}
    do                
        echo "mysql_backup_rsync to ${j} begin at "$(date +'%Y-%m-%d %T') >>${logfile}
        ### 揖化 ###
        rsync -avz --progress --delete $serverPath -e "ssh -p "${ssh_port}" -i "${id_rsa} ${id_rsa_user}@${j}:$clientPath >>${logfile} 2>&1 
        echo "mysql_backup_rsync to ${j} done at "$(date +'%Y-%m-%d %T') >>${logfile}
    done
}

#序秘方象垂姥芸猟周朕村
cd ${backup_dir}

mysql_backup
delete_old_backup
rsync_mysql_backup

echo -e "========================mysql backup && rsync done at "$(date +'%Y-%m-%d %T')"============================\n\n">>${logfile}
cat ${logfile}
