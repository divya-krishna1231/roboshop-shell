#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33mm"
N="\e[0m"
MONGODB_HOST=172.31.95.84

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
      echo -e "$2 ... $R FAILED $N"
      exit 1
    else
      echo -e "$2 ... $G success $N" 
    fi   
}
if [ $ID -ne 0 ]
then
   echo  -e "$R ERROR:: please run this script with root access $N"
     exit 1
else
     echo "yoy are root user"
fi
dnf module disable nodejs -y 
VALIDATE $? "Disabling current NodeJS" &>> $LOGFILE
dnf module enable nodejs:18 -y 
VALIDATE $? "Enabling NodeJS:18 " &>> $LOGFILE
dnf install nodejs -y
VALIDATE $? "Imstalling NodeJS:18 " &>> $LOGFILE
useradd roboshop
VALIDATE $? "creating roboshop user " &>> $LOGFILE
mkdir /app
VALIDATE $? "creating app directory " &>> $LOGFILE
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
 
VALIDATE $? "Downloading catalogue application " &>> $LOGFILE
cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "unzipping catalogue"
npm install 
VALIDATE $? "Installing dependencies " 
cp  /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copying catalogue service file " &>> $LOGFILE
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "catalogue daemon reload"
systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enable catalogue"
systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue"
cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo"
dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Installing MongoDB client"
mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalouge data into MongoDB"
