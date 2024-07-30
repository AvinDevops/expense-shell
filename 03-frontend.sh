#!/bin/bash

#Fetching userid, timestamp, scriptname, logfile.
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

#Assigning color values to variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#Checking root user or not
if [ $USERID -ne 0 ]
then
    echo "you don't have root access, please access with root user"
    exit 0
else
    echo "you have root user access"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 .... is $R FAILED $N"
        exit 0
    else
        echo -e "$2 .... is $G SUCCESS $N"
    fi
}

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginx service"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/*

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code zip file"

cp /home/ec2-user/expense-shell/expense.conf /etc/nginx/default.d/expense.conf