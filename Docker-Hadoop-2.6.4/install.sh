rpm -ivh /node/rhel7rpm/jdk*
tar -xvzf /node/hadoop-2.6.4.tar.gz
mv hadoop-2.6.4 /hadoop2
export JAVA_HOME=/usr/java/jdk1.7.0_79
export PATH=/usr/java/jdk1.7.0_79/bin:$PATH
export HADOOP_HOME=/hadoop2
export PATH=/hadoop2/bin/:/hadoop2/sbin/:$PATH
l=1
sed -i " $l i export JAVA_HOME=/usr/java/jdk1.7.0_79" /root/.bashrc
l=$((l+1))
sed -i " $l i export PATH=/usr/java/jdk1.7.0_79/bin:\$PATH" /root/.bashrc
l=$((l+1))
sed -i " $l i export HADOOP_HOME=/hadoop2" /root/.bashrc
l=$((l+1))
sed -i " $l i export PATH=/hadoop2/bin/:/hadoop2/sbin/:\$PATH" /root/.bashrc
source /root/.bashrc
export JAVA_HOME=/usr/java/jdk1.7.0_79
export PATH=/usr/java/jdk1.7.0_79/bin:$PATH
export HADOOP_HOME=/hadoop2
export PATH=/hadoop2/bin/:/hadoop2/sbin/:$PATH



