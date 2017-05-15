#!/bin/sh

S=60

DIR=/usr/local/shakecast/sc_va

BIN=$DIR/rc.d

process() {
    ps axww | grep -v 
}

start() {
    logger "sc-watcher starting $1"
    $BIN/sc-$1.sh start
    sleep 2
}

logger "begin sc-watcher"

while true; do
  procs=`process`
#  logger "sc-watcher =$procs="
  (echo $procs | grep -q $DIR/bin/dispd.pl) || start dispd
#  (echo $procs | grep -q $DIR/bin/polld.pl) || start polld
  (echo $procs | grep -q $DIR/bin/notify.pl) || start notify
  (echo $procs | grep -q $DIR/bin/notifyqueue.pl) || start notifyqueue
#  (echo $procs | grep -q $DIR/bin/rssd.pl) || start rssd
  sleep $S
done


