#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USERID -ne 0 ]
then
    echo -e "$R you are not root user, please access with root user $N"
    exit 0
else
    echo -e "$G you are root user $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$Y $2.... is $N $R FAILED $N"
        exit 1
    else
        echo -e "$Y $2... is $N $R SUCCESS $N"
    fi
}

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysql-server service"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysql server service"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
VALIDATE $? "Setting root password for mysql server"