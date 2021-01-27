#!/bin/bash

function cleanup {
  	echo "###### clean up application  ######"
	rm -rf ./exec/*.run
	rm -rf ./exec/*.stop
	rm -rf ./exec/*.stop.stopped
}

trap cleanup EXIT

cleanup

# run every interval in seconds
timeinterval=5;
echo "time intervall: $timeinterval"

jarfolder='./exec'
envfolder='./env'
logfolder='./logs'

echo "####################################"
echo "#  JAR / WAR STARTER              ##"
echo "####################################"

echo "Folder to deploy=\"$jarfolder\""
echo "Folder envfolder=\"$envfolder\""

echo "#####################################"
echo "#  JAVA RUN  PROPERTIES            ##"
echo "#####################################"
if [ -f $envfolder/app.env ]; then
	appEnv=($(< "$envfolder/app.env"))
else
	echo "the file $envfolder/app.env do not exists. You should create it before start app"
	exit 0
fi

printf -v app_env ' %s' "${appEnv[@]}" 
app_env=${app_env:1}
echo $app_env

echo "#####################################"
echo "#  WATCH FOLDER JAVA APP    		##"
echo "#####################################"
#chksum1="${chksum1:-new instance}"
filename=""
while [[ true ]]; do
    chksum2=`find $jarfolder -type f -printf "%T@ %p\n" | md5sum | cut -d " " -f 1`;
    #echo $chksum2
	if [[ $chksum1 != $chksum2 ]] ; then 
		
		chksum1=$chksum2
		echo "chksum2 = $chksum2  chksum1 =$chksum1"
		
       	for entry in "$jarfolder"/*
		do

		  fullFileName=$(basename $entry)

		  ext="${fullFileName##*.}"
		  #echo "estensione: $ext"
		  fbname=${fullFileName%.*}
		 
		  
		  runfile="$jarfolder/$fbname.run"
		  stopfile="$jarfolder/$fbname.stop"
		  stoppedfile="$jarfolder/$fbname.stop.stopped"
		  

		  if [[ (${entry: -4} == ".war" || ${entry: -4} == ".jar") && (! -f $runfile) && (! -f $stoppedfile) ]]; then
			  commandToExec="java -jar $app_env"

			  
			  fileEnv="./$envfolder/$fbname.env"

			  echo "###################################"
	
			  echo "search for env file $fileEnv"
	
			  echo "###################################"
			  if [ -f $fileEnv ] ; then
					app1Env=($(< $fileEnv))
	
					printf -v app1_env ' %s' "${app1Env[@]}"
					app1_env=${app1_env:1}
					
					echo $app1_env
			
	                commandToExec="${commandToExec} ${app1_env}"
					#echo $commandToExec
			  fi
	 		  echo "###################################"
			  baseNameWar=`basename $entry`
			  
			 # prima di eseguire controlla la directory dei log
			  
			  printf -v date '%(%Y-%m-%d.%H%M%S)T' -1 
			  echo "current execution date:  $date"
			  logFile="${logfolder}/${fbname}.${date}.log"
			 
			  exec $commandToExec $entry > $logFile&
			  touch $runfile > $runfile
			  echo "e' stato eseguito il comando: $commandToExec"
			
			 
		fi
		 ##########################################################
		 # ESEGUE LO STOP DEL JAR / WAR se viene rileavto il file 
		 # [nomejar].stop
		 ##########################################################
		 if [ -f $stopfile ]; then
			echo "stopping file $fullFileName ........."
			## esegui stop del war
			kill -9 $(pgrep -f $fullFileName)

			mv  $stopfile  $stopfile.stopped
			echo "stopping file $fbname ......... stopped"
		fi
		done

		echo "### wait for next entry ###"
    fi
    #echo "chksum2 = $chksum2  chksum1 =$chksum1";
    sleep $timeinterval;
done