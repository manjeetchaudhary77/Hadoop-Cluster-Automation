#put configuration entry in mapred-site.xml 
cd /etc/hadoop/
echo $1

#get line number for entry 
hdfs=`  cat -n mapred-site.xml | grep '<configuration>' |  awk '{print $1 ;}' `
last=`  cat -n mapred-site.xml | grep '</configuration>' |  awk '{print $1 ;}' `
ran1=$((hdfs+1))
ran2=$((last-1))

#delete content if exist 
if [ $ran1 -ne $last ];then
sed -i "$ran1,$ran2 d" mapred-site.xml
fi

sed -i "$hdfs a <property>" mapred-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <name>mapred.job.tracker</name>" mapred-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <value>$1:9002</value>" mapred-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a </property>" mapred-site.xml

iptables -F
setenforce 0
systemctl disable firewalld
#start tasktracker 
hadoop-daemon.sh stop tasktracker
hadoop-daemon.sh start tasktracker

# display status 
/usr/java/jdk1.7.0_79/bin/jps
exit
