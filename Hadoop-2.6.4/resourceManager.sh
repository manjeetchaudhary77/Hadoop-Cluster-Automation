#!/bin/bash/
cd /hadoop2/etc/hadoop/
ip=` ifconfig enp0s8 | grep 192.168. | awk '{print $2}' `

hdfs=`  cat -n yarn-site.xml | grep '<configuration>' |  awk '{print $1 ;}' `
last=`  cat -n yarn-site.xml | grep '</configuration>' |  awk '{print $1 ;}' `
ran1=$((hdfs+1))
ran2=$((last-1))
if [ $ran1 -ne $last ];then
sed -i "$ran1,$ran2 d" yarn-site.xml
fi

sed -i "$hdfs a <property>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <name>yarn.resourcemanager.resource-tracker.address</name>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <value>$ip:8025</value>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a </property>" yarn-site.xml
hdfs=$((hdfs+1))

sed -i "$hdfs a <property>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <name>yarn.resourcemanager.scheduler.address</name>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <value>$ip:8030</value>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a </property>" yarn-site.xml


hdfs=`  cat -n core-site.xml | grep '<configuration>' |  awk '{print $1 ;}' `
last=`  cat -n core-site.xml | grep '</configuration>' |  awk '{print $1 ;}' `
ran1=$((hdfs+1))
ran2=$((last-1))
if [ $ran1 -ne $last ];then
sed -i "$ran1,$ran2 d" core-site.xml
fi

sed -i "$hdfs a <property>" core-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <name>fs.default.name</name>" core-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <value>hdfs://$1:9001</value>" core-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a </property>" core-site.xml

iptables -F
setenforce 0
systemctl disable firewalld


yarn-daemon.sh stop nodemanager
hadoop-daemon.sh stop namenode
hadoop-daemon.sh stop datanode
yarn-daemon.sh stop resourcemanager
yarn-daemon.sh start resourcemanager
/usr/java/jdk1.7.0_79/bin/jps
