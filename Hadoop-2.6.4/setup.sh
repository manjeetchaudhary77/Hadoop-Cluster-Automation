#!/bin/bash/
#Function to display starting TUI 
start(){
dialog --title "Hadoop Installation Process" --backtitle "BIG DATA HADOOP 2.6.4" --msgbox\
 "Press Ok To Continue!!!" 10 50 ; 
}

#Function To Ask Type Of Installation 
select_type()
{
	dialog --title "Hadoop Installation Process" --backtitle "BIG DATA HADOOP 2.6.4" \
	 --menu "What Type of Configuration Do You Want?" 0 0 2 \
	1 "Automatic(Recommended)"  \
	 2 "Manual(Advance)"  2>/tmp/menu.txt 	
}


#Function To Process The Installation Process 
process()
{
start
flag=$?

case $flag in
0)
	#function call to select type(custom or typical)
	select_type
	flag=$?
	case $flag in
	0)
		val=` cat /tmp/menu.txt `
		case $val in
		1)
			#installation by typical mode
			#executing script for typical installation 
			bash typical.sh
		;;
		2)
			#installation by custom mode
			#executing script for custom installation 
			bash custom.sh
		;;
		esac
	;;
	*)
		# for wrong choice recalling process function 
		process
	;;
	esac
	
;;
255)
	# to quit installation process 
	dialog --title "Hadoop Installation Process" --backtitle "BIG DATA HADOOP" --yesno\
 "Do you want to Quit installation process!!!" 10 50 ;
	flag=$?
	case $flag in
	0)
		# exit from the installation process
		exit
	;;
	1)
		# go back to start if user doesn't want to quit the installation
		start
	;;
	*)
		exit
	;;
	esac
;;
esac
}

#START
#function call to start installation
#like main method
process
rm -f /tmp/radio.txt
#END  
