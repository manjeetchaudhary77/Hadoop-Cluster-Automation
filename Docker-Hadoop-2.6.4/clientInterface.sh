#!/bin/bash/
dialog --menu "Select Your Choice" 0 40 12 1 "View Storage Status"  2 "Put File" 3 "Browse File" 4 "Process a Job" 5 "Exit" 2>tmp.txt

ch=`cat tmp.txt` 

case "$ch" in
1)	dialog --inputbox "Enter file name" 8 40 2> tmp1.txt	
	f=`cat tmp1.txt`
	hdfs dfs -du $f > execute.txt
	dialog --textbox execute.txt 0 0
	bash clientInterface.sh
;;
2)	
	dialog --inputbox "Enter file name" 8 40 2> tmp1.txt	
	f=`cat tmp1.txt`
	hdfs dfs -put $f / > execute.txt 
	dialog --textbox execute.txt 0 0
	bash clientInterface.sh
;;
3)	dialog --inputbox "Enter file name" 8 40 2> tmp1.txt	
	f=`cat tmp1.txt`
	hdfs dfs -cat $f > execute.txt
	dialog --textbox execute.txt 0 0
	bash clientInterface.sh
;;
4)
	bash processJob.sh
	bash clientInterface.sh
;;	
5)
	exit
esac
