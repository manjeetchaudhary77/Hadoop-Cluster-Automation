#!/bin/bash/
cd /hadoop2/etc/hadoop/
#echo $1
#echo $2
#putting configuration entry in hdfs-site.xml 
hdfs=`  cat -n hdfs-site.xml | grep '<configuration>' |  awk '{print $1 ;}' `
last=`  cat -n hdfs-site.xml | grep '</configuration>' |  awk '{print $1 ;}' `
ran1=$((hdfs+1))
ran2=$((last-1))
if [ $ran1 -ne $last ];then
sed -i "$ran1,$ran2 d" hdfs-site.xml
fi
rm -rf /testing2
mkdir /testing2
sed -i "$hdfs a <property>" hdfs-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <name>dfs.data.dir</name>" hdfs-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <value>/testing2</value>" hdfs-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a </property>" hdfs-site.xml

#putting configuration entry in core-site.xml 
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


#putting configuration entry in yarn-site.xml for nodemanager
hdfs=`  cat -n yarn-site.xml | grep '<configuration>' |  awk '{print $1 ;}' `
last=`  cat -n yarn-site.xml | grep '</configuration>' |  awk '{print $1 ;}' `
ran1=$((hdfs+1))
ran2=$((last-1))
if [ $ran1 -ne $last ];then
sed -i "$ran1,$ran2 d" yarn-site.xml
fi

sed -i "$hdfs a <property>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <name>yarn.nodemanager.aux-services</name>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <value>mapreduce_shuffle</value>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a </property>" yarn-site.xml
hdfs=$((hdfs+1))

sed -i "$hdfs a <property>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <name>yarn.resourcemanager.resource-tracker.address</name>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <value>$2:8025</value>" yarn-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a </property>" yarn-site.xml
iptables -F
setenforce 0
systemctl disable firewalld


# stop if already start 
yarn-daemon.sh stop nodemanager
hadoop-daemon.sh stop namenode
hadoop-daemon.sh stop datanode
yarn-daemon.sh stop resourcemanager

# start nodemanager and datanode
hadoop-daemon.sh start datanode
yarn-daemon.sh start nodemanager


/usr/java/jdk1.7.0_79/bin/jps
exit
