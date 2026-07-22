#!/bin/bash

set -e

cd /var/Pending || exit

git pull origin main

npm install

cd frontend || exit
npm install
npm run build

rm -rf /var/www/html/*
cp -r dist/* /var/www/html/

cd /var/Pending || exit
pm2 restart express-server
