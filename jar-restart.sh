#!/bin/bash
servicename=$1
execDir=$2

if [ -z "$execDir" ]; then
    execDir="./exec"
fi;

echo "service $servicename"
echo "exec dir $execDir"

echo "stopping.... $servicename"

touch "$execDir/$servicename.stop"

sleep 5

ls  -l $execDir/$servicename.*

echo "$servicename stopped"

rm -rf "$execDir/$servicename.run"
rm -rf "$execDir/$servicename.stop"
rm -rf "$execDir/$servicename.stop.stopped"

ls -l  $execDir/$servicename.*

echo "$servicename restarted"

exit 0
