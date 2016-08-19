#!/bin/bash/

#scanning devices  
scan()
{
        nmap -sP 192.168.43.0/24 -n | grep "Nmap scan" | awk '{print $5}'
}


#sorting According to RAM 
sort_ip_ram()
{
	local line=` wc -l totalIp1.txt | cut -d" " -f1 `
	#echo $line
	rm -f ipRam.txt
	for((i=1;i<=line;i++))
	do
		local ll=$i\p
		local ip=` sed -n "$ll" totalIp1.txt `
		#echo $ip
		local ram=` sshpass -p redhat ssh -o StrictHostKeyChecking=no $ip free -m | grep Mem: | awk '{print $2}' `
		#echo $ram
		if [ $ram -ge 0 ];then
			echo "$ip  $ram" >> ipRam.txt
			#cat ipRam.txt
		fi
	done

	sort -k 2 ipRam.txt > ip_ram_sort.txt
	#cat ip_ram_sort.txt
}


#list all ip for dialog 
list_ip()
{
local line=` cat totalip.txt | wc -l `
for((i=1;i<=line;i++))
	do
	j=$i\p
	a=`sed -n "$j" totalip.txt `
	echo -n "$i $a "
	echo off
done 
}



#total ip connected with network 

scan > totalIp.txt

#cat totalIp.txt
#own=` ifconfig enp0s8 | grep 192.168. | cut -d":" -f2 | cut -d" " -f1 `

own=` ifconfig enp0s8 | grep 192.168. | awk '{print $2}' `

#echo $own

l=`cat -n totalIp.txt | grep $own | awk '{ print $1 }' `

#echo $l
sed -i " $l d " totalIp.txt

l=`cat -n totalIp.txt | grep 192.168.43.1 | awk '{ print $1 }' `
sed -i " $l d " totalIp.txt

l=`cat -n totalIp.txt | grep 192.168.43.5 | awk '{ print $1 }' `

sed -i " $l d " totalIp.txt
cat totalIp.txt | grep 192.168. > totalIp1.txt

#cat totalIp1.txt
#soretd ip according to ram 

sort_ip_ram
cat ip_ram_sort.txt | cut -d" " -f1 > totalip.txt
#cat totalip.txt

#total number ips 

line=` cat totalip.txt | wc -l `

#echo "lene: "$line


#NAMENODE
dialog --backtitle "Hadoop Installation" \
	--title "NAMENODE" \
       --radiolist "SELECT ONE FOR NAMENODE "  0 0 $line \
	`list_ip ` 2>/tmp/namenode.txt
if [ $? -eq 0 ];then
	choice=`cat /tmp/namenode.txt`
	j=$choice\p
	namenodeIp=`sed -n "$j" totalip.txt `
	j=$choice
	sed -i " $j d " totalip.txt
	#configuration of namenode
	sshpass -p redhat ssh -o StrictHostKeyChecking=no $namenodeIp 'bash -s' < namenode.sh
fi

#JOB TRACKER 
line=$((line-1))

#echo "jt line: "$line

dialog --backtitle "Hadoop Installation" \
	--title "JOBTRACKER" \
       --radiolist "SELECT ONE FOR JOBTRACKER "  0 0 $line \
	`list_ip ` 2>/tmp/jobtracker.txt
#echo "/tmp/jobtracker.txt"
#cat /tmp/jobtracker.txt
if [ $? -eq 0 ];then
	choice=`cat /tmp/jobtracker.txt`	
	j=$choice\p
	jobtrackerIp=`sed -n "$j" totalip.txt `	
	j=$choice
	sed -i " $j d " totalip.txt
	#configuratiion job tracker
	sshpass -p redhat ssh -o StrictHostKeyChecking=no $jobtrackerIp 'bash -s' < jobtracker.sh $namenodeIp
fi
#DATANODE &Task Tracker
line=$((line-1))
for((i=1;i<=line;i++))
do
	dialog --backtitle "Hadoop Installation" \
	--title "TASKTRACKER" \
       --checklist "SELECT ONE FOR TASKTRACKER/DATANODE"  0 0 $line \
	`list_ip ` 2>/tmp/jobtracker.txt
	if [ $? -eq 0 ];then
		choice=` cat /tmp/jobtracker.txt `
		j=$choice\p
		dataTaskIp=`sed -n "$j" totalip.txt `
		j=$choice
		sed -i " $j d " totalip.txt
		# configuration of datanode & tasktracker setup
		sshpass -p redhat ssh -o StrictHostKeyChecking=no $dataTaskIp 'bash -s' < dataTask.sh $namenodeIp $jobtrackerIp
	fi
done


#Setup CLIENT OF CLUSTER 

echo "nameNode: "$namenodeIp
echo "jobTracker:" $jobtrackerIp
bash client.sh $namenodeIp $jobtrackerIp
bash clientInterface.sh $namenodeIp $jobtrackerIp
#END 
