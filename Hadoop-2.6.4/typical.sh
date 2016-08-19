#function for scanning devices  
scan()
{
        nmap -sP 192.168.43.0/24 -n | grep "Nmap scan" | awk '{print $5}'
}


#sorting According to RAM 
sort_ip_ram()
{
	local line=` wc -l totalIp1.txt | cut -d" " -f1 `
	#echo "line: "$line
	rm -f ipRam.txt
	for((i=2;i<=line;i++))
	do
		local ll=$i\p
		#echo "ll: "$ll
		local ip=` sed -n "$ll" totalIp1.txt `
		#echo "ip :"$ip
		local ram=` sshpass -p redhat ssh -o StrictHostKeyChecking=no $ip free -m | grep Mem: | awk '{print $2}' `
		#echo "ram:" $ram
		if [ $ram -ge 0 ];then
			echo "$ip  $ram" >> ipRam.txt
		fi
	done

	sort -k 2 ipRam.txt > ip_ram_sort.txt
}

#total ip connected with network  
scan > totalIp.txt
#echo "totalIp.txt:"
#cat totalIp.txt
#own=` ifconfig eth0 | grep 192.168. | cut -d":" -f2 | cut -d" " -f1 `

own=` ifconfig enp0s8 | grep 192.168. | awk '{print $2}' `

#echo "ownip:"$own
l=`cat -n totalIp.txt | grep $own | awk '{ print $1 }' `
sed -i " $l d " totalIp.txt

#l=`cat -n totalIp.txt | grep 192.168.43.1 | awk '{ print $1 }' `
#sed -i " $l d " totalIp.txt

l=`cat -n totalIp.txt | grep 192.168.43.5 | awk '{ print $1 }' `
sed -i " $l d " totalIp.txt

#l=`cat -n totalIp.txt | grep 192.168.43.6 | awk '{ print $1 }' `
#sed -i " $l d " totalIp.txt

#echo "total ip:"
#cat totalIp.txt

cat totalIp.txt | grep 192.168. > totalIp1.txt
#echo "totalIp1.txt"
#cat totalIp1.txt
# soretd ip according to ram 
sort_ip_ram
cat ip_ram_sort.txt | cut -d" " -f1 > totalip.txt
#cat totalip.txt
#total number ipes 
line=` cat totalip.txt | wc -l `

# ip of namenode

namenodeIp=` sed -n '1p' totalip.txt `

#echo "namenode ip:"$namenodeIp

#Setup NAMENODE 
#configuration of namenode
sshpass -p redhat ssh -o StrictHostKeyChecking=no $namenodeIp 'bash -s' < namenode.sh

#setup resourceManager
# ip of resourceManager

resourceManagerIp=` sed -n '2p' totalip.txt `

#echo "resource manager ip:"$resourceManagerIp
#configuratiion resourceManager

sshpass -p redhat ssh -o StrictHostKeyChecking=no $resourceManagerIp 'bash -s' < resourceManager.sh $namenodeIp

#setup DATANODE and nodeManager
for((i=3;i<=line;i++))
do
	a=$i\p
        ip=` sed -n "$a" totalip.txt `
        sshpass -p redhat ssh -o StrictHostKeyChecking=no $ip 'bash -s' < dataNode.sh $namenodeIp $resourceManagerIp

done


#Setup CLIENT OF CLUSTER 

bash client.sh $namenodeIp $resourceManagerIp

#echo "nameNode $namenodeIp"
#echo "jobTracker $resourceManagerIp"

bash clientInterface.sh $namenodeIp $resourceManagerIp
#END
