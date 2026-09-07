#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/shell-roboshop"
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $LOG_FOLDER

if [ $USER_ID -ne 0 ]; then
   echo -e "$R Run this script as root user $N" | tee -a $LOG_FILE
   exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
      echo -e "$2: $R FAILURE $N" | tee -a $LOG_FILE
      exit 1
    else
      echo -e "$2: $G Success $N" | tee -a $LOG_FILE
    fi
}

dnf module disable redis -y &>> $LOG_FILE
dnf module enable redis:7 -y
VALIDATE $? "Enabling redis"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Installing redis"

sed -i -e 's/127.0.0.1/0.0.0.0/' -e 's/protected-mode yes/ c protected-mode no/' /etc/redis/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis 
systemctl start redis 
VALIDATE $? "starting redis"

