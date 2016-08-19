#!/bin/bash/
#restat service of docker

systemctl restart docker

#remove the container if exist
#NAMENODE
docker rm -f nn

#run new docker container
#put rhle7rpm and rhel7 folder in redhat to share with namenode of container
#redhat folder contains rhel7rpm and rhel7 folder of rpm
#namenode and redhat contains same folder
docker run -it --name=nn --privileged=true -v  /root/Desktop/redhat/:/namenode -d  3cd5fcd7fd44

#fetch container ip

docker exec nn ifconfig eth0 | grep "inet addr" | awk '{print $2}'| cut -f2 -d ":">/tmp/tmp1.txt
cat /tmp/tmp1.txt | cut -d" " -f1 >/tmp/tmp2.txt

#making container namenode

namenodeIp=` sed -n '1p' /tmp/tmp2.txt `
echo "namenodeIP: "$namenodeIp

#install jdk and hadoop
docker exec nn rpm -ivh /namenode/rhel7rpm/jdk*
docker exec nn rpm -ivh /namenode/rhel7rpm/hadoop-1.2.1-1.x86_64.rpm --replacefiles
#start ssh service
docker exec nn service sshd restart
#change container root password
cp /root/Desktop/DOCKER_HADOOP_1.2.1/ssh.sh /root/Desktop/redhat/
docker exec nn sh /namenode/ssh.sh

#start namenode daemon
sshpass -p redhat ssh -o StrictHostKeyChecking=no $namenodeIp 'bash -s' < namenode.sh $namenodeIp

#JOBTRACKER

docker rm -f jt
docker run -it --name=jt --privileged=true -v  /root/Desktop/redhat/:/jobtracker -d  3cd5fcd7fd44
docker exec jt ifconfig eth0 | grep "inet addr" | awk '{print $2}'| cut -f2 -d ":">/tmp/tmp1.txt
cat /tmp/tmp1.txt | cut -d" " -f1 >/tmp/tmp2.txt
jobtrackerIp=` sed -n '1p' /tmp/tmp2.txt `
echo $jobtrackerIp
docker exec jt rpm -ivh /jobtracker/rhel7rpm/jdk*
docker exec jt rpm -ivh /jobtracker/rhel7rpm/hadoop-1.2.1-1.x86_64.rpm --replacefiles
#docker exec passwd
docker exec jt service sshd restart
cp /root/Desktop/DOCKER_HADOOP_1.2.1/ssh.sh /root/Desktop/redhat/
docker exec jt sh /jobtracker/ssh.sh
sshpass -p redhat ssh -o StrictHostKeyChecking=no $jobtrackerIp 'bash -s' < jobtracker.sh $namenodeIp $jobtrackerIp

#DATANODE TASKTRACKER
dtnum=0
echo "Enter no of Datanodes and Tasktrackers"
read dtnum
for((i=1;i<=dtnum;i++))
do
	docker rm -f dt$i
	docker run -it --name=dt$i --privileged=true -v  /root/Desktop/redhat/:/datatask -d  3cd5fcd7fd44
	docker exec dt$i ifconfig eth0 | grep "inet addr" | awk '{print $2}'| cut -f2 -d ":">/tmp/tmp1.txt
	cat /tmp/tmp1.txt | cut -d" " -f1 >/tmp/tmp2.txt
	datanodeIp=` sed -n '1p' /tmp/tmp2.txt `
	echo $datanodeIp
	docker exec dt$i rpm -ivh /datatask/rhel7rpm/jdk*
	docker exec dt$i rpm -ivh /datatask/rhel7rpm/hadoop-1.2.1-1.x86_64.rpm --replacefiles
	#docker exec passwd
	docker exec dt$i service sshd restart
	cp /root/Desktop/DOCKER_HADOOP_1.2.1/ssh.sh /root/Desktop/redhat/
	docker exec dt$i sh /datatask/ssh.sh
	sshpass -p redhat ssh -o StrictHostKeyChecking=no $datanodeIp 'bash -s' < dataTask.sh $namenodeIp $jobtrackerIp
done
cd /root/Desktop/redhat/rhel7rpm/
rpm -ivh jdk*
rpm -ivh hadoop-1.2.1-1.x86_64.rpm --replacefiles

cd /root/Desktop/DOCKER_HADOOP_1.2.1
bash client.sh $namenodeIp $jobtrackerIp
hadoop dfsadmin -report
bash clientInterface.sh $namenodeIp $jobtrackerIp

