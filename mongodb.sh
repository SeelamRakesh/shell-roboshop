#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/$PWD"
LOG_FOLDER="$LOG_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $USER_ID -ne 0 ]; then
 echo "Run the script as Root User"
 exit 1
fi

VALIDATE() {
  if [ $1 -ne 0 ]; then
   echo -e "$2 $R Failure $N"
  else 
   echo -e "$2 $G Success $N"
  fi
}

cp $PWD/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying Mongo repo"

dnf install mongodb-org -y
VALIDATE $? "installing mongodb" 

systemctl enable mongod 
systemctl start mongod 
VALIDATE $? "Enabling and Starting mongodb" 

sed 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "restarting mongodb" 