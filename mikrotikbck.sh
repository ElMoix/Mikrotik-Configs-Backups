#!/bin/bash
# Script to automate backups for Mikrotiks

BCKSd="/home/mikrotiks/"
trap "rm $BCKSd*.rsc.tmp" EXIT	# If we combine Ctrl+C we delete all the .rsc.tmp files

if (( $# < 1 ));then
	echo "Need at least one param"
	exit 1
fi


input=$1
DATA=`date +%Y-%m-%d`
CORREU="/var/log/mikrotik/mikrotiksbck_$DATA.log"
sshlog="/var/log/mikrotik/mikrotikErrSHH_$DATA.log"
sendmail="test@example.com"				# Change this
regexdyn='^[a-zA-Z0-9]{12}\.sn\.mynetname\.net$'	# mikrotik dyn dns
regexip='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$' # check if ip is valid
wcc=$(cat $input | grep -v "#" | wc -l)
OK=0
ERR=0

# Re-order the $input file
sed -i '/^$/d' $input
grep "#" $input > /tmp/ordered-servers.tmp
grep -v "#" $input | sort >> /tmp/ordered-servers.tmp
cat /tmp/ordered-servers.tmp > $input
rm /tmp/ordered-servers.tmp

if [ -f $CORREU ];then
	rm $CORREU
fi

echo "<html>" >> $CORREU
echo "<head>" >> $CORREU
echo "</head>" >> $CORREU
echo "<body>" >> $CORREU
echo "<h2>BACKUPS MIKROTIK USERS - $(date)</h2>" >> $CORREU
echo "<p>Users: $wcc</p>" >> $CORREU
echo "<br/>" >> $CORREU
echo "<hr/>" >> $CORREU

# Check for $input file is well done
while read line
do
	if [[ $(echo $line | cut -c 1) != "#" ]];then

		client=$(echo $line | awk -F "," '{print $1}')
		ip=$(echo $line | awk -F "," '{print $2}')
		passwd=$(echo $line | awk -F "," '{print $3}')
		port=$(echo $line | awk -F "," '{print $4}')

		if [ -z $client ];then
			echo "<div style=\"color:red;\"> <a>File $input is NOT well done (Client: $client/IP: $ip/Pass: $pass/Port: $port)<br/></a></div>" >> $CORREU
			cat $CORREU | mail -a "Content-type: text/html ; charset=UTF-8" -s "MikrotiksBCK: File $input is NOT well done (client-$client)" $sendmail
			exit 1
		fi
		if [ -z $ip ];then
			echo "<div style=\"color:red;\"> <a>File $input is NOT well done (Client: $client/IP: $ip/Pass: $pass/Port: $port)<br/></a></div>" >> $CORREU
                        cat $CORREU | mail -a "Content-type: text/html ; charset=UTF-8" -s "MikrotiksBCK: File $input is NOT well done (ip1-$ip)" $sendmail
			exit 1
		fi
		
		if ! [[ $ip =~ $regexip || $ip =~ $regexdyn ]]; then
			echo "<div style=\"color:red;\"> <a>File $input is NOT well done (Client: $client/IP: $ip/Pass: $pass/Port: $port)<br/></a></div>" >> $CORREU
                        cat $CORREU | mail -a "Content-type: text/html ; charset=UTF-8" -s "MikrotiksBCK: File $input is NOT well done (ip2-$ip)" $sendmail
			exit 1
		fi
		if [ -z $passwd ];then
			echo "<div style=\"color:red;\"> <a>File $input is NOT well done (Client: $client/IP: $ip/Pass: $pass/Port: $port)<br/></a></div>" >> $CORREU
                        cat $CORREU | mail -a "Content-type: text/html ; charset=UTF-8" -s "MikrotiksBCK: File $input is NOT well done (pass-$pass)" $sendmail
			exit 1
		fi
		if ! [[ $port =~ ^[0-9]{1,5}$ || -z $port ]]; then	
                        echo "<div style=\"color:red;\"> <a>File $input is NOT well done (Client: $client/IP: $ip/Pass: $pass/Port: $port)<br/></a></div>" >> $CORREU
                        cat $CORREU | mail -a "Content-type: text/html ; charset=UTF-8" -s "MikrotiksBCK: File $input is NOT well done (port-$port)" $sendmail
                        exit 1
		fi
	fi
done < "$input"
while read line
do
        if [[ $(echo $line | cut -c 1) != "#" ]];then

      		client=$(echo $line | awk -F "," '{print $1}')
        	ip=$(echo $line | awk -F "," '{print $2}')
	        passwd=$(echo $line | awk -F "," '{print $3}')
		port=$(echo $line | awk -F "," '{print $4}')

		if ! [ -d $BCKd$client/ ];then
			echo "Directory $BCKd$client doesn't exists" > /dev/null 	# DEBUG
			mkdir $BCKd$client/
		fi

		# Check if host replies to icmp
		cmd="ping -c 3 $ip"
		loss=$($cmd | grep "loss" | cut -d "," -f3 | cut -d " " -f2)
		if [ $loss == "0%" ];then
			echo "User $client with IP $ip replies to ping" > /dev/null # DEBUG
				
			if [ -z $port ];then
				port2=""
			else 
				port2=$(echo -p $port)
			fi

			sshpass -p $passwd ssh -no StrictHostKeyChecking=no -o ConnectTimeout=10 $port2 admin@$ip export show-sensitive > $BCKd$client/$client.rsc.tmp 2> $sshlog
			if [ $? == '0' ];then
				echo "<a>$client OK<br/></a>" >> $CORREU
				mv $BCKd$client/$client.rsc.tmp $BCKd$client/$client"0".rsc
				OK=$(($OK+1))
			else
				echo -e "<div style=\"color:red;\"> <a>$client ERROR => $(cat $sshlog)<br/></a></div>" >> $CORREU
				ERR=$(($ERR+1))
			fi
			
			# Log rotate
			if [ -f $BCKd$client/$client"0".rsc ];then			# Check if first backup went well
				echo "File $client"0".rsc exists" > /dev/null	# DEBUG
				if [ -f $BCKd$client/$client"7".rsc ];then		# Check if we have 7 days backup
					echo "File $client"7".rsc exists" > /dev/null	# DEBUG
					rm $BCKd$client/$client"7".rsc
				else
					echo "File $client"7".rsc doesn't exists" > /dev/null	# DEBUG
				fi
	
				for i in {6..0}
				do
					if [ -f $BCKd$client/$client$i.rsc ];then
						mv $BCKd$client/$client$i.rsc $BCKd$client/$client$(($i+1)).rsc
						echo "We moved $client$i to $client$(($i+1))" > /dev/null	# DEBUG
					else
						echo "File $BCKd$client/$client$i.rsc doesn't exists" > /dev/null	# DEBUG
					fi
				done
			else
				echo "ERROR - File $BCKd$client/$client"0".rsc doesn't exists" > /dev/null	# DEBUG
			fi
		else
			echo "ERROR: $client with IP $ip doesn't reply to ping!!" > /dev/null	# DEBUG
                       	echo -e "<div style=\"color:red;\"> <a>$client ERROR => IP $ip doesn't reply to ping!!<br/></a></div>" >> $CORREU
			ERR=$(($ERR+1))
		fi
	fi
done < "$input"

if [ -f *.rsc.tmp ];then
	rm *.rsc.tmp
fi

if [ -f /var/log/mikrotik/mikrotikErrSHH_*.log ];then
	rm /var/log/mikrotik/mikrotikErrSHH_*.log
fi

echo "<br/>" >> $CORREU
echo "<hr/>" >> $CORREU
echo "<h3>BACKUPS FINISHED - $(date)</h3>" >> $CORREU
echo "</body>" >> $CORREU
echo "</html>" >> $CORREU

SUBJECT="Backups Mikrotiks $DATA || Errors: $ERR Successfully: $OK"
cat $CORREU | mail -a "Content-type: text/html ; charset=UTF-8" -s "$SUBJECT" $sendmail
