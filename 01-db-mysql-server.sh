#!/bin/bash

#Fetching userid, Timestamp, Scriptname, Logfile.
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

#Entering password through prompt
# echo "please enter password:"
# read mysql_root_password

#Assigning colors values to variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2.... is $R FAILED $N"
        exit 0
    else
        echo -e "$2.... is $G SUCCESS $N"
    fi
}

#Checking root user or not
if [ $USERID -ne 0 ]
then    
    echo -e "$R you are not root user, please access with root user $N"
    exit 0
else
    echo -e "you are root user"
fi 


dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysql service"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysql service"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting password for root"

# mysql -h 172.31.36.19 -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
# if [ $? -ne 0 ]
# then
#     mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#     VALIDATE $? "Setting password for root"
# else
#     echo -e "Root password is already set... $Y SKIPPING $N"
# fi
    
