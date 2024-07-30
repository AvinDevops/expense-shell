#!/bin/bash

#Fetching userid, Scriptname, Timestamp, Logfile name.

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

#Assigning colors to variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#Checking root user or not!
if [ $USERID -ne 0 ]
then
    echo  -e "$R you don't have root access, please access with root user $N"
    exit 0
else
    echo -e " $G you have root access $N"
fi

#Creating Validate function
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2... is $R FAILED $N"
        exit 1
    else
        echo -e "$2... is $G SUCCESS $N"
    fi
}


dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling nodejs current version"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs latest version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "Creating expense user"
else
    echo -e "Already expense user added...$Y SKIPPNG $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app

rm -rf /app/*

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Unzipping backend file"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copying backend.service file"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reloading"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backed service"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h db.avinexpense.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Loading schema"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend service"
