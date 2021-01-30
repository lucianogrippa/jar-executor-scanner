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

ls -l $execDir/$servicename.*



rm -rf "$execDir/$servicename.run"
rm -rf "$execDir/$servicename.stop"

ls $execDir -l  $execDir/$servicename.*


echo "$servicename stopped"

exit 0