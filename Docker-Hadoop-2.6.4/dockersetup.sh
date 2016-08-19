#!/bin/bash/
#restat service of docker
#rpm -ivh docker-engine-selinux-1.9.1-1.el7.centos.noarch.rpm 
#rpm -ivh docker-engine-1.9.1-1.el7.centos.x86_64.rpm
systemctl restart docker

#remove the container if exist
#NAMENODE
docker rm -f nn

#run new docker container
#redhat folder contains rhel7rpm and rhel7 folder of rpm
#namenode and redhat contains same folder
docker run -it --name=nn --privileged=true -v  /root/Desktop/redhat/:/node -d  3cd5fcd7fd44

#fetch container ip

docker exec nn ifconfig eth0 | grep "inet addr" | awk '{print $2}'| cut -f2 -d ":">/tmp/tmp1.txt
cat /tmp/tmp1.txt | cut -d" " -f1 >/tmp/tmp2.txt

#making container namenode

namenodeIp=` sed -n '1p' /tmp/tmp2.txt `
echo "namenodeIP: "$namenodeIp

#install jdk and hadoop
cp -vf /root/Desktop/DOCKER_HADOOP_2.6.4/install.sh /root/Desktop/redhat/
docker exec nn sh /node/install.sh
#start ssh service
docker exec nn service sshd restart
#change container root password
cp -vf /root/Desktop/DOCKER_HADOOP_2.6.4/ssh.sh /root/Desktop/redhat/
docker exec nn sh /node/ssh.sh

#start namenode daemon
sshpass -p redhat ssh -o StrictHostKeyChecking=no $namenodeIp 'bash -s' < namenode.sh $namenodeIp

#RESOURCEMANAGER

docker rm -f rman
docker run -it --name=rman --privileged=true -v  /root/Desktop/redhat/:/node -d  3cd5fcd7fd44
docker exec rman ifconfig eth0 | grep "inet addr" | awk '{print $2}'| cut -f2 -d ":">/tmp/tmp1.txt
cat /tmp/tmp1.txt | cut -d" " -f1 >/tmp/tmp2.txt
resourceManagerIp=` sed -n '1p' /tmp/tmp2.txt `
echo $resourceManagerIp

cp -vf /root/Desktop/DOCKER_HADOOP_2.6.4/install.sh /root/Desktop/redhat/
docker exec rman sh /node/install.sh
docker start nn
#cp -vf /root/Desktop/DOCKER_HADOOP_2.6.4/bashrc.sh /root/Desktop/redhat/
#docker exec rman sh /node/bashrc.sh
#docker exec passwd
docker exec rman service sshd restart
cp -vf /root/Desktop/DOCKER_HADOOP_2.6.4/ssh.sh /root/Desktop/redhat/
docker exec rman sh /node/ssh.sh
sshpass -p redhat ssh -o StrictHostKeyChecking=no $resourceManagerIp 'bash -s' < resourceManager.sh $namenodeIp $resourceManagerIp

#DATANODE NODEMANAGER
dnnum=0
echo "Enter no of Datanodes and Tasktrackers"
read dnnum
for((i=1;i<=dnnum;i++))
do
	docker rm -f dn$i
	docker run -it --name=dn$i --privileged=true -v  /root/Desktop/redhat/:/node -d  3cd5fcd7fd44
	docker exec dn$i ifconfig eth0 | grep "inet addr" | awk '{print $2}'| cut -f2 -d ":">/tmp/tmp1.txt
	cat /tmp/tmp1.txt | cut -d" " -f1 >/tmp/tmp2.txt
	datanodeIp=` sed -n '1p' /tmp/tmp2.txt `
	echo $datanodeIp
	
	cp -vf /root/Desktop/DOCKER_HADOOP_2.6.4/install.sh /root/Desktop/redhat/
	docker exec dn$i sh /node/install.sh

	#docker exec passwd
	docker exec dn$i service sshd restart
	cp -vf /root/Desktop/DOCKER_HADOOP_2.6.4/ssh.sh /root/Desktop/redhat/
	docker exec dn$i sh /node/ssh.sh
	sshpass -p redhat ssh -o StrictHostKeyChecking=no $datanodeIp 'bash -s' < dataNode.sh $namenodeIp $resourceManagerIp
done

rpm -ivh /root/Desktop/redhat/rhel7rpm/jdk*
tar -xvzf /root/Desktop/redhat/hadoop-2.6.4.tar.gz
mv hadoop-2.6.4 /hadoop2
export JAVA_HOME=/usr/java/jdk1.7.0_79
export PATH=/usr/java/jdk1.7.0_79/bin:$PATH
export HADOOP_HOME=/hadoop2
export PATH=/hadoop2/bin/:/hadoop2/sbin/:$PATH

sed -i " 1 i export JAVA_HOME=/usr/java/jdk1.7.0_79" /root/.bashrc
l=$((l+1))
sed -i " 1 i export PATH=/usr/java/jdk1.7.0_79/bin:\$PATH" /root/.bashrc
l=$((l+1))
sed -i " 1 i export HADOOP_HOME=/hadoop2" /root/.bashrc
l=$((l+1))
sed -i " 1 i export PATH=/hadoop2/bin/:/hadoop2/sbin/:\$PATH" /root/.bashrc
source /root/.bashrc

bash client.sh $namenodeIp $resourceManagerIp

bash clientInterface.sh $namenodeIp $resourceManagerIp
