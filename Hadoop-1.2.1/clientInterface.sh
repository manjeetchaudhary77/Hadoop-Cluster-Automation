checkpoint()
{
	hadoop dfsadmin -safemode enter > tmp1.txt
	a=`cat tmp1.txt`
	dialog --infobox "$a" 0 0
	hadoop dfsadmin -safemode get > tmp1.txt
	a=`cat tmp1.txt`
	dialog --infobox "$a" 0 0
	hadoop dfsadmin -saveNamespace > tmp1.txt
	hadoop dfsadmin -safemode leave > tmp1.txt
	dialog --msgbox "Successfull" 0 0
}

setBlockSize()
{
	dialog --inputbox "Enter block Size:" 8 40 2> tmp1.txt
 	block=`cat tmp1.txt`
	
	line=` cat -n hdfs-site.xml | grep "</configuration>" | cut -d" " -f1 ` 
	sed -i " i $line <property><name>dfs.block.size</name><value>$block</value></property>" hdfs-site.xml 
	bash clientInterface.sh
	
}

setReplication()
{
	dialog --inputbox "Enter the number of replicas" 8 40 2> tmp1.txt
 	rapl=`cat tmp1.txt`
	
	line=` cat -n hdfs-site.xml | grep "</configuration>" | cut -d" " -f1 `
        sed -i " i $line <property><name>dfs.raplication</name><value>$rapl</value><property>" hdfs-site.xml
	bash clientInterface.sh

}




dialog --menu "Select Your Choice" 0 40 12 1 "View Storage Status"  2 "Put File" 3 "Browse File" 4 "set Block Size" 5 "Set Number of Replications" 6 "Display Active TaskTrackers" 7 "Process a Job" 8 "Checkpoint" 9 "Exit" 2>tmp.txt


ch=`cat tmp.txt` 

case "$ch" in
1)	dialog --inputbox "Enter file name" 8 40 2> tmp1.txt	
	f=`cat tmp1.txt`
	hadoop fs -du $f > execute.txt
	dialog --textbox execute.txt 0 0
	bash clientInterface.sh
;;
2)	
	dialog --inputbox "Enter file name" 8 40 2> tmp1.txt	
	f=`cat tmp1.txt`
	hadoop fs -put $f / > execute.txt 
	dialog --textbox execute.txt 0 0
	bash clientInterface.sh
;;
3)	dialog --inputbox "Enter file name" 8 40 2> tmp1.txt	
	f=`cat tmp1.txt`
	hadoop fs -cat $f > execute.txt
	dialog --textbox execute.txt 0 0
	bash clientInterface.sh
;;
4)
	setBlockSize
;;
5)
	setReplication
;;
6)
	hadoop job -list-active-trackers > execute.txt
	dialog --textbox execute.txt 0 0
	bash clientInterface.sh
;;
7)
	bash processJob.sh
	bash clientInterface.sh
;;
8)
	checkpoint
	bash clientInterface.sh
	
;;	
9)
esac
