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
	 --menu "What Type of Configuration Do You Want?" 0 0 3 \
	1 "Automatic(Recommended)"  \
	2 "Manual(Advance)" \
	3 "On Demand" 2>/tmp/menu.txt 	
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
			#installation in automatic mode
			#executing script for automatic installation 
			bash automatic.sh
		;;
		2)
			#installation in manual mode
			#executing script for manual installation 
			bash manual.sh
		;;
		3)
			#installation in on demand mode
			#executing script for on demand installation 
			bash dockersetup.sh
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
