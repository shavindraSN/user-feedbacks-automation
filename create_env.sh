#!/bin/bash

# Parameter Description
# $1 - RDS Endpoint
# $2 - Repository URL
# $3 - Application Name

db_host=`echo $1 | cut -d: -f1`;
rm -rf $3
git clone $2;
cp ./configs/.env user-feedbacks/
echo "\nDB_HOST=$db_host" >> ./user-feedbacks/.env;

cd user-feedbacks;
zip -rq user-feedbacks.zip .
mv user-feedbacks.zip ../