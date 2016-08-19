cd /etc/hadoop/
#echo $1
#echo $2
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


#putting configuration entyr in mapred-site.xml for client
hdfs=`  cat -n mapred-site.xml | grep '<configuration>' |  awk '{print $1 ;}' `
last=`  cat -n mapred-site.xml | grep '</configuration>' |  awk '{print $1 ;}' `
ran1=$((hdfs+1))
ran2=$((last-1))
if [ $ran1 -ne $last ];then
sed -i "$ran1,$ran2 d" mapred-site.xml
fi

sed -i "$hdfs a <property>" mapred-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <name>mapred.job.tracker</name>" mapred-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a <value>$2:9002</value>" mapred-site.xml
hdfs=$((hdfs+1))
sed -i "$hdfs a </property>" mapred-site.xml
#END
