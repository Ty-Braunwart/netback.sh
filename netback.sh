#!/bin/bash
#Author: Ty Braunwart
#version: 2.5
#date 7/2/12
#this script is for backing up the network devices.
#the script will send a email or a text to you letting you know it is done.
#the script will also give you a list of completed backups and failed backups

############################## functions needed to run ##########################

objectFile=/opt/netbackup/objects
logFile=/home/norse/log
WismScript=/opt/netbackup/scripts/wism.sh

function makeFiles(){
  touch $logFile/`date +%m-%d-%y`wism.log
  touch $logFile/`date +%m-%d-%y`special.log
  touch $logFile/`date +%m-%d-%y`ssh.log
  touch $logFile/`date +%m-%d-%y`router.log
  touch $logFile/`date +%m-%d-%y`switch.log
  touch $logFile/`date +%m-%d-%y`bk_wap.log
  touch $logFile/`date +%m-%d-%y`wismError.log
  touch $logFile/`date +%m-%d-%y`specialError.log
  touch $logFile/`date +%m-%d-%y`sshError.log
  touch $logFile/`date +%m-%d-%y`routerError.log
  touch $logFile/`date +%m-%d-%y`switchError.log
  touch $logFile/`date +%m-%d-%y`bk_wapError.log
  touch $logFile/`date +%m-%d-%y`rename.log
}

##################################### tftp enabled devices ###########################################
function tftpEnabledSwitches(){
  for switches in `cat ${objectFile}/switches.txt`
    do
      #checks to see if the switches can be connected
	  if exec 3>/dev/tcp/${switches}/23
	  then
	      #connects to switch and copies running configs using telnet
	      (
		echo open $switches
		sleep 8
		echo "$LOGINNAME"
		sleep 5
		echo "$PASSWORD"
		sleep 5
		echo "en"
		sleep 5
		echo "$ROUTERPASSWORD1"
		sleep 5
		echo "copy run tftp"
		sleep 5
		echo "$IP"
		sleep 5
		echo " "
		sleep 60
		echo "exit"
	      )|telnet
	      echo $switches backed up on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`switch.log
	      echo >>$logFile/`date +%m-%d-%y`switch.log
	  else
	      #saves the errors in a file for later review and update
	      echo $switches could not be connected to on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`switchError.log
	      echo >>$logFile/`date +%m-%d-%y`switchError.log
	  fi    
    done
}


################################### routers and non tftp devices ############################################
function routerBackups(){
  for router in `cat ${objectFile}/router.txt`
    do 
      sleep 1
      #checks to see if the switches can be connected
	  if exec 3>/dev/tcp/${router}/23
	  then
	     #connects to the routers and copies running configs using telnet
	      echo working on $router
	      (
		echo open $router
		sleep 8
		echo "$LOGINNAME"
		sleep 5
		echo "$PASSWORD"
		sleep 5
		echo "terminal length 0"
		sleep 2
		echo "sh run"
		sleep 10
		echo "exit"
	      )|telnet > /tftpboot/$router.txt
	      echo done with $router
	      echo $router backed up on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`router.log
	      echo >>$logFile/`date +%m-%d-%y`router.log
	  else
	      #saves the errors in a file for later review and update
	      echo $router could not be connected to on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`routerError.log
	      echo >>$logFile/`date +%m-%d-%y`routerError.log
	  fi    
    done
}



######################################## ssh enabled devices (that dont need enable password)#######################################
function sshDevices() {
  for sshclient in `cat ${objectFile}/ssh.txt`
    do
      sleep 2
      #checks to see if the SSH can be connected
      if exec 3>/dev/tcp/${sshclient}/22
      then
	#connects using ssh to get configs
	sshpass -p ${PASSWORD} ssh -o StrictHostKeyChecking=no -t $LOGINNAME@$sshclient 'sh run' > /tftpboot/$sshclient.txt
	echo $sshclient backed up on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`ssh.log
	echo >>$logFile/`date +%m-%d-%y`ssh.log
      else
	#saves the errors in a file for later review and update
	echo $sshclient could not be connected to on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`sshError.log
	echo >>$logFile/`date +%m-%d-%y`sshError.log
      fi
    done
}


###############used for the three special devices#################################
function specialLoginDevices(){

    # code for connection to 192.168.0.1
    if exec 3>/dev/tcp/192.168.0.1/23
    then
	(
	  echo open 192.168.0.1
	  sleep 8
	  echo "$LOGINNAME"
	  sleep 5
	  echo "$PASSWORD"
	  sleep 5
	  echo "en"
	  echo "$ROUTERPASSWORD1"
	  sleep 1
	  echo "terminal length 0"
	  sleep 2
	  echo "sh run"
	  sleep 10
	  echo "exit"
	)|telnet > /tftpboot/192.168.0.1.txt
	echo 192.168.0.1  backed up on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`special.log
	echo >>$logFile/`date +%m-%d-%y`special.log
    else
	#saves the errors in a file for later review and update
	echo 192.168.0.1 could not be connected to on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`specialError.log
	echo >>$logFile/`date +%m-%d-%y`specialError.log
    fi

   
    # code for connection to 10.38.200.1    
    if exec 3>/dev/tcp/10.38.200.1/23
    then
	(
	  echo open 10.38.200.1
	  sleep 8
	  echo "$LOGINNAME"
	  sleep 5
	  echo "$PASSWORD"
	  sleep 5
	  echo "en"
	  echo "$ROUTERPASSWORD2"
	  sleep 1
	  echo "terminal length 0"
	  sleep 2
	  echo "sh run"
	  sleep 10
	  echo "exit"
	)|telnet > /tftpboot/10.38.200.1.txt
	echo 10.38.200.1  backed up on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`special.log
	echo >>$logFile/`date +%m-%d-%y`special.log
    else
	#saves the errors in a file for later review and update
	echo 10.38.200.1 could not be connected to on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`specialError.log
	echo >>$logFile/`date +%m-%d-%y`specialError.log
    fi


    # code for connection to 10.5.200.1
    if exec 3>/dev/tcp/10.5.200.1/23
    then
	(
	  echo open 10.5.200.1
	  sleep 8
	  echo "$LOGINNAME"
	  sleep 5
	  echo "$PASSWORD"
	  sleep 5
	  echo "en"
	  echo "$ROUTERPASSWORD1"
	  sleep 1
	  echo "terminal length 0"
	  sleep 2
	  echo "sh run"
	  sleep 10
	  echo "exit"
	)|telnet > /tftpboot/X.X.X.X.txt
	echo 10.5.200.1  backed up on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`special.log
	echo >>$logFile/`date +%m-%d-%y`special.log
    else
	#saves the errors in a file for later review and update
	echo 10.5.200.1 could not be connected to on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`specialError.log
	echo >>$logFile/`date +%m-%d-%y`specialError.log
    fi
}


################################# rename files #############################################
function rename(){
    cd /tftpboot/
    for i in *.[Tt][Xx][Tt]
    do
        filename=$i
	sed -n '/Current/,$p' -i $filename
        change=$(sed -nr "s/.*hostname (\w+.*).*/\1/p" $filename)
        cp $filename $change-confg
        echo $filename changed to $change-confg on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`rename.log
        rm -f $filename
    done
}


################################# email alert ###########################################
function alert(){
  for contact in `cat ${objectFile}/contact.con` 
  do
    #add person contact info to contact.con 
    echo "the backup for `date +%D` is done, please see backup.log for more information"| mutt -s "test email for new alert system `date +%D`" -a $logFile/`date +%m-%d-%y`backup.log ${contact}
  done
}


####################################### report generator #############################################
function report(){
  echo backup report for `date +%D`>>$logFile/`date +%m-%d-%y`backup.log
  echo >>$logFile/`date +%m-%d-%y`backup.log
  echo >>$logFile/`date +%m-%d-%y`backup.log
  echo __________failed backups______________>>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`switchError.log>>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`routerError.log >>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`sshError.log >>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`specialError.log >>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`wismError.log >>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`bk_wapError.log >>$logFile/`date +%m-%d-%y`backup.log
  echo >>$logFile/`date +%m-%d-%y`backup.log
  echo >>$logFile/`date +%m-%d-%y`backup.log
  echo _________devices backup_______________>>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`switch.log>>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`router.log >>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`ssh.log >>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`special.log >>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`wism.log >>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`bk_wap.log >>$logFile/`date +%m-%d-%y`backup.log
  echo >>$logFile/`date +%m-%d-%y`backup.log
  echo >>$logFile/`date +%m-%d-%y`backup.log
  echo ___________devices renamed____________>>$logFile/`date +%m-%d-%y`backup.log
  cat $logFile/`date +%m-%d-%y`rename.log >>$logFile/`date +%m-%d-%y`backup.log
  echo >>$logFile/`date +%m-%d-%y`backup.log
  echo >>$logFile/`date +%m-%d-%y`backup.log 
  echo _____contacts informed of backup______>>$logFile/`date +%m-%d-%y`backup.log
  cat ${objectFile}/contact.con>>$logFile/`date +%m-%d-%y`backup.login
  echo >>$logFile/`date +%m-%d-%y`backup.log
}

######################### backup bk awaps ###########################################
function BK_Wap(){
	while read line
	do
	  bk_wap_ip=$line
	if exec 3>/dev/tcp/${bk_wap_ip}/22
	then
	   /usr/bin/expect <<EOD
spawn ssh $wap_login@$bk_wap_ip
sleep 2
expect "password:"
sleep 2 
send "$wap_pass1\r"
expect ">"
send "en\r"
expect "Password:"
send "$wap_pass2\r"
expect "#"
send "cop run tftp\r"
expect "?"
send "$IP\r"
expect "?"
send "\r"
expect "#"
send "exit\r"
EOD	
	  echo $bk_wap_ip  backed up on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`bk_wap.log
            echo >>$logFile/`date +%m-%d-%y`bk_wap.log
 
	else
	   echo $bk_wap_ip could not be connected to on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`bk_wapError.log
	   echo >>logFile/`date +%m-%d-%y`bk_wapError.log
	fi
	done <${objectFile}/BK_awap.txt

}
	


######################################### backup wism ###################################
function wism(){
      while read line
      do
	WISMIP="$(echo $line | cut -d' ' -f1)"
	WISMNAME="$(echo $line | cut -d' ' -f2)"
	#checks to see if the SSH can be connected
	if exec 3>/dev/tcp/${WISMIP}/22  
	then  
	     /usr/bin/expect <<EOD
spawn ssh $WISMIP
sleep 5
expect "User:"
sleep 3
send "$LOGINNAME\r"
expect "Password:"
sleep 3
send "$PASSWORD\r"
expect ">"
send "transfer upload mode tftp\r"
expect ">"
send "transfer upload datatype config\r"
expect ">"
send "transfer upload serverip $IP\r"
expect ">"
send "transfer upload filename $WISMNAME\r"
expect ">"
send "transfer upload start\r"
expect ")"
send "y\r"
expect ">"
send "exit\r"
expect ")"
send "n\r"
EOD

	    echo $WISMNAME  backed up on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`wism.log
	    echo >>$logFile/`date +%m-%d-%y`wism.log
	else
	    echo X.X.X.X could not be connected to on `date +%D` at `date +%R` >>$logFile/`date +%m-%d-%y`wismError.log
	    echo >>$logFile/`date +%m-%d-%y`wismError.log
	fi
      done <${objectFile}/wism.txt
}

function cleanup(){
  rm -f $logFile/`date +%m-%d-%y`wism.log
  rm -f $logFile/`date +%m-%d-%y`special.log
  rm -f $logFile/`date +%m-%d-%y`ssh.log
  rm -f $logFile/`date +%m-%d-%y`router.log
  rm -f $logFile/`date +%m-%d-%y`switch.log
  rm -f $logFile/`date +%m-%d-%y`bk_wap.log
  rm -f $logFile/`date +%m-%d-%y`wismError.log
  rm -f $logFile/`date +%m-%d-%y`specialError.log
  rm -f $logFile/`date +%m-%d-%y`sshError.log
  rm -f $logFile/`date +%m-%d-%y`routerError.log
  rm -f $logFile/`date +%m-%d-%y`switchError.log
  rm -f $logFile/`date +%m-%d-%y`rename.log
  rm -f $logFile/`date +%m-%d-%y`bk_wapError.log
}

function notice(){
echo the back up is completed 
echo you view the results of the backup in the file `date +%m-%d-%y`backup.log under the log folder in your home dir
}




##########################  running part of the script ########################

############ get login infromation and tftp server location ###################
echo enter your user name
read LOGINNAME
echo enter your password 
stty -echo
read PASSWORD
stty echo
echo enter the ip address of the tftp server
read IP
echo enter the first special  password
stty -echo
read ROUTERPASSWORD1
stty echo
echo enter the second special password
stty -echo
read ROUTERPASSWORD2
stty echo
################# not finished bok module ########## ( needs to be tested)
#echo event wap username
#read wap_login
#echo enter wap password 1
#stty -echo
#read wap_pass1
#stty echo 
#echo enter wap password 2
#stty -echo 
#read wap_pass2
#stty echo 

makeFiles
tftpEnabledSwitches 
routerBackups
sshDevices
specialLoginDevices
#BK_Wap
#wism
rename
report
alert
cleanup
notice
