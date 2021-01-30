# Jar Executor Scanner
- [Jar Executor Scanner](#jar-executor-scanner)
  - [Introduction](#introduction)
  - [Install project](#install-project)
  - [Folders](#folders)
  - [Example](#example)
      - [Example with docker](#example-with-docker)
      - [Restart application inside docker](#restart-application-inside-docker)
  - [Contributing](#contributing)
## Introduction

This simple application scans the "exec" directory to execute *.jar or *.war files.<br>

The application remains on watch inside "exec" directory and when new file with war o jar extension is added to it, automatically will run java command with parameters took from files inside "env" directory.<br>
Inside "logs" directory will writes output logs result of the execution process.<br>

I have created this application for managing spring boot application's instances, I prefer using it with docker container whom is configured with ngnix and mysql database.

## Install project

```bash
$ git clone https://github.com/lucianogrippa/jar-executor-scanner.git
```
or download zip file from github

move inside project directory

```bash
$ cd jar-executor-scanner
```

The project is made with bash script so you need to install the terminal or use a "Linux like" distribution as Ubuntu or Debian or in alternative you can use the docker container provided in the project.

Another dependency is java and you need install it and put into the system path.
It is obvious that if you use the container, you not need to install either bash terminal or java.  Just run

```bash
$ docker-compose up # -d if run with detached mode
```
Otherwise for starting watching directory just run

```bash
$ ./scanner-jar.sh 
```
The only ways to stop watching directory is to kill the process or by CTRL+C key combination.

if you have in execution a spring boot application and want to restart it you just run

```bash
$ ./jar-restart [applicanionname]
```
otherwise if you want stop it run

```bash
$ ./jar-stop [applicanionname]
```

## Folders

- **/configurations**: Put here the configuration files. 
- **/env**: Put here the files "*.env" that contains the parameters for java command.
  The file "app.env" contains the parameters to apply for all jars. 
  Also you can use "[application name].env" file to include parameters specifically for the application only.
- **/exec**: Put here java executable file (war or jar).
- **/mysql**: This directory contains configuration for the mysql service provided  by docker container. You can put inside dump.sql file your database structure, it will be used as a model when we builds the container.
- **/ngnix**: This directory contains only "app.conf", represents the configuration file for ngnix server.

## Example

**Note**: We assume that the scanner-jar.sh application is running.

In this example will run the simple spring boot application named mywebwallet.
For this application we have the two files:

- **mywebwallet-prod.yml**: application configuration file
- **mywebwallet.jar**: java executable file

We can navigate to application at http://localhost:1250/mywebwallet

Now we need to create application parameters for apply to java command:

```bash
$ cd env
$ touch mywebwallet.env
### set the application profile
$ echo "-Dspring.profiles.active=prod" >> mywebwallet.env
### set the logs dir
$ echo "-Dlog.dir=./logs" >> mywebwallet.env
### set the configuration directory
$ echo "-Dspring.config.location=file:./configurations/mywebwallet/" >> mywebwallet.env
### set the configuration directory
$ echo "-Dspring.config.name=mywebwallet" >> mywebwallet.env
### set the configuration name
$ echo "-Dserver.servlet.context-path=/mywebwallet" >> mywebwallet.env
```

Now just put "mywebwallet.jar" inside "exec" folder, if you look inside this directory will appears the mywebwallet.run file, this means that the java - jar command has been executed. 
Now you can open (/logs/my-web-walletapp.log) file for monitoring application execution.

Probably the application will not start because it need a database. In this case comes to help us the example with docker.

so kill process scanner-jar.sh

```bash
$ kill -9 $(pgrep -f scanner-jar.sh)
```
#### Example with docker

The starting base is the above example, so we keep the files.
Before starting docker container we need to know how it is configured.
We have two services and one network:

- **Network (jarscannerappnetwork)**: mode bridge and subnet 172.22.10.0/24
- **services-> jarscannerapp**: ip 172.22.10.3 , nat ports 80 ,443, 1250
  the port 1250 need for the application.
  volumes:
      - ./configurations:/root/app/configurations
      - ./env:/root/app/env
      - ./exec:/root/app/exec
      - ./logs:/root/app/logs
      - ./nginx/app.conf:/etc/nginx/conf.d/app.conf
  - **database mysql service-> appmyserverdb**: ip 172.22.10.4 port 3006

The goal of this example is to setup application for navigating at this url : http://172.22.10.3/mywebwallet

For this reason we need to modify the app.conf file in the ngnix directory.

first we set the upstream for simulate load balancer, in real application you should setup each instance of the application

```ini
upstream mywebwallet {
    least_conn;
    server 127.0.0.1:1250 weight=3;
    server 127.0.0.2:1250;
    server 127.0.0.3:1250;
}
```
now setup  proxy pass 

```ini
location /mywebwallet {
    proxy_pass http://mywebwallet;
}
```

finally just run 

```bash
$ docker-compose up
```

That's all you can navigate to http://172.22.10.3/mywebwallet

#### Restart application inside docker

You can restart application in this way:
enter in bash console of container:
```bash

$ docker exec -it jarscannerapp  bash

## this command restart application
bash-5.0# ./jar-restart.sh mywebwallet

## or this command stop application
bash-5.0# ./jar-stop.sh mywebwallet
```
## Contributing

I appreciate any contributing you're willing to give, fixing bugs, improving documentation, or suggesting new features. 
You can contact me using github or my social account [twitter](https://twitter.com/lgrippa75) , [facebook](https://www.facebook.com/luciano.grippa).

