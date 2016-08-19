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

#l=`cat -n totalIp.txt | grep 192.168.43.1 | awk '{ print $1 }' `
#sed -i " $l d " totalIp.txt

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

#Resource Manager 
line=$((line-1))

#echo "jt line: "$line

dialog --backtitle "Hadoop Installation" \
	--title "RESOURCE MANAGER" \
       --radiolist "SELECT ONE RESOURCE MANAGER "  0 0 $line \
	`list_ip ` 2>/tmp/resourceManager.txt
#echo "/tmp/resourceManager.txt"
#cat /tmp/resourceManager.txt
if [ $? -eq 0 ];then
	choice=`cat /tmp/resourceManager.txt`	
	j=$choice\p
	resourceManagerIp=`sed -n "$j" totalip.txt `	
	j=$choice
	sed -i " $j d " totalip.txt
	#configuratiion job tracker
	sshpass -p redhat ssh -o StrictHostKeyChecking=no $resourceManagerIp 'bash -s' < resourceManager.sh $namenodeIp
fi
#DATANODE &NODE MANAGER
line=$((line-1))
for((i=1;i<=line;i++))
do
	dialog --backtitle "Hadoop Installation" \
	--title "DATANODE/NODE MANAGER" \
       --checklist "SELECT ONE FOR DATANODE/NODE MANAGER"  0 0 $line \
	`list_ip ` 2>/tmp/resourceManager.txt
	if [ $? -eq 0 ];then
		choice=` cat /tmp/resourceManager.txt `
		j=$choice\p
		dataNodeIp=`sed -n "$j" totalip.txt `
		j=$choice
		sed -i " $j d " totalip.txt
		# configuration of datanode & node manager setup
		sshpass -p redhat ssh -o StrictHostKeyChecking=no $dataNodeIp 'bash -s' < dataNode.sh $namenodeIp $resourceManagerIp
	fi
done


#Setup CLIENT OF CLUSTER 

#echo "nameNode: "$namenodeIp
#echo "resourceManager:" $resourceManagerIp
bash client.sh $namenodeIp $resourceManagerIp
bash clientInterface.sh $namenodeIp $resourceManagerIp
#END 
