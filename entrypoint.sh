#! /bin/bash

MYINDEX='/app/index'

# set up index/ dir
if [ -d "$MYINDEX" ] ; then
    if [ -z "$(ls -A $MYINDEX)" ] ; then
        cp -r /app/Kustvakt/sample-index/* /app/index/ ;
    fi
else
    cp -r /app/Kustvakt/sample-index /app/index
fi

# activate custom perl
source ~/perl5/perlbrew/etc/bashrc

# # frontend
cd /app/Kalamar
MOJO_MODE=hnc KALAMAR_API='http://localhost:5556/api/' hypnotoad script/kalamar

# backend
cd /app/Kustvakt/lite/target/
java -jar Kustvakt-lite-0.62.2.jar
