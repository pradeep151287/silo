#########################################################################
##                Script to Bounce BW                                   ##
##                Author: Pavan                                         ##
##                Date: 15/11/2017                                      ##
##########################################################################
#!/bin/bash

# Color code variable set
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
SCOUNT=0
CSV_FILE="../silo_env_info.csv"

server_list_fun()
{
  OLDIFS=$IFS
  IFS=","
  local  COUNT=1
  I=1
  SNAME=$1

  hostlist=`grep "$SNAME" $CSV_FILE`

  for http in $hostlist
  do
          list[$COUNT]=`echo $http | grep http | cut -d"/" -f3 | cut -d"." -f1`
          let "COUNT += 1"
  done

  IFS=$OLDIFS

  for s in `echo "${list[*]}"`
  do
          csv[$I]=`echo "$s|"`
          let "I += 1"
  done


  #echo "${csv[1]}"
  slist=`echo "${csv[*]}" | tr -d " "`
}

# Usage function
usage()
{
echo -e "$RED Usage: $NC"
echo -e "$GREEN $0  -s <silo name> -b <BW name > -a -r <count of instance> -l <list of the server> $NC"
echo -e "$RED -s : Silo name which want to Bounce $NC"
echo -e "$RED -b : name of the BW to bounce $NC"
echo -e "$RED -a : use this option to bounce all BW at once $NC"
echo -e "$RED -r : Role based bounce of BW/half and half $NC"

echo -e "$RED HELP: $NC "
echo -e "$GREEN $0 -h $NC"
}

## Initiall healthcheck before bounceing BW

healthcheck()
{

# Variable declaration
local HNAME=$1
#  ssh to the respective instance and run  dupcheck command and store some where to verify later
echo "ssh $HNAME "run dupcheck command to verify health status of BW" "

#   check health status of Hawk agent and store the value in variable
echo "ssh $HNAME "command to check health status of Hawk process "  "
#   check permission of ASI files for respective BW and store it in variable
echo "ssh $HNAME "command to check permiss of ASI file""

}

## Bounce all instance in Silo function

#bounce_allinstance()
#{
#   call health check function to verify status of BW or initials state of BW
#   if Hawk agent is not running on that Box quit that instance with : Msg saying Hawk is not running
#   command to kill all BW instance Eg: Use sshsilo script on 174 box to kill all BW or ps -aux | grep "bwengine" kill -9 <PID>
#   sleep for some time and verify health status of all BW and compare with initial health heck
#}

bounce_instance()
{

HNAME=$1
BBW=$2
# calling health check function
echo "======================================================"
echo "health check of the Host"
echo "======================================================"

healthcheck $HNAME

echo "if Hawk agent running then continue else exit the function "
echo -e  "\n"
echo "======================================================"

echo "Grepping $BBW process in $HNAME"
echo ""ssh $HNAME "ps -eo pid,user,args --sort user | grep $BBW | grep bwengine | awk '{ print \\$1" "\\$7 }' | cut -d'/' -s '-f1,8,9' | tr '/' ' ' | sed -e "s/-/ /" -e "s/-/ /" | tr -s " ""
echo "killing BW process : kill -9 \$PID"
echo "ssh $HNAME "kill -9 \$PID""
echo "\$? based on the exit value of previous command display success message"
sleep 5
echo "do post health verification with dupcheck "

}

if [ $# -eq 0 ]
then
        usage
        exit
fi

#getopts to get all the parameters passed to script


while getopts "s:b:r:ah" o; do
   case "$o" in
     s)
        SILO=${OPTARG}
  ;;
    b)
        BW=${OPTARG}
  ;;
    r)
        COUNT=${OPTARG}
        COUNT_VAR="true"
  ;;
    a)
        ALL="true"
  ;;
    h)
        usage
        exit
  ;;
  esac
done
#echo -e " silo name : $SILO
#BW name: $BW
#role base count: $COUNT
#ALL: $ALL"

#role based function
if [[ ! -z "$SILO" ]] && [[ ! -z "$BW" ]] && [[ ! -z "$COUNT_VAR" ]] && [[ -z "$ALL" ]]
      then

	if [[  $COUNT -gt 0 ]];  then

      # calling server_list_fun
      server_list_fun $SILO
      if [ -z "$slist" ]
          then
          echo "SILO not Found"
          exit
      fi

      echo "${slist[*]}"
      slist_new=${slist[*]}

      for i in $(echo $slist_new| sed "s/|/ /g")
          do
         # echo -e "server name : $i"
          SCOUNT=`expr $SCOUNT + 1`
      done

		echo "count: $COUNT SCOUNT: $SCOUNT "
		if [ ! "$COUNT" -ge "$SCOUNT" ]; then
			echo "calling expr function"
			NSER=`expr $SCOUNT / $COUNT`
			#echo $NSER
			FNSER=$(printf '%.0f\n' "$NSER")
			echo "Total number of Batche's : $FNSER"

			if [ $FNSER == 1 ]
			   then
			      read -p "with given Role based option its like, Running kill BW on instances at one batch : Do you want to process [Y/N] " prompt
			         if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
			            then

			               ITE=1
			               l=1
			                  while [ $ITE -lt $SCOUNT ]
	 	                         do
								                       for ((i=1;i<=$FNSER;i++))
				                                   do
					                                      N=${csv[$l]}
										                                      if [ ! -z $N ]
					                                                     then
						                                                           echo "server: ${csv[$l]}"
					                                                                  #	bounce_instance $N $BW
						                                                           let "l += 1"
						                                                           let "ITE += 1"
					                                                fi
				                                   done
				                                   if [ $ITE -gt $SCOUNT ]
				                                       then
                                                 exit
                                          fi
				                             echo "starting next batch"
				                             sleep 10
			                      done

			       else
				           echo -e "Quit "
				               exit
      			fi

			else
			       ITE=1
             l=1
                while [ $ITE -lt $SCOUNT ]
                   do
                      for ((i=1;i<=$FNSER;i++))
                                do
                                        N=${csv[$l]}
                                        #echo $N
                                        if [ ! -z $N ]
                                        then
                                                echo "server: ${csv[$l]}"
                                        #       bounce_instance $N $BW
                                                let "l += 1"
                                                let "ITE += 1"
                                        fi
                               done
                                if [ $ITE -gt $SCOUNT ]
                                then
                                     exit
                                fi

                                echo "starting next batch"
                                sleep 10
                        done
			fi

		else
			echo -e "$RED Role based argument passed is greter then total number of servers $NC"
		fi

	else
		echo -e "$RED Argument passed with "-r" option is non integer or negetive value
 pass the valid intiger value 	$NC"
	fi



elif [[ ! -z "$SILO" ]] && [[ ! -z "$BW" ]] && [[ ! -z "$ALL" ]] && [[  -z "$COUNT_VAR" ]]
            then
                 # calling server_list_fun
                	server_list_fun $SILO

                	if [ -z "$slist" ]
                	then
                		echo "SILO not Found"
                		exit
                	fi

                  echo "Bouncing below instance"
                	echo "${slist[*]}"
                	echo -e "\n"
                	slist_new=${slist[*]}

                        for i in $(echo $slist_new| sed "s/|/ /g")
                                do
                                        echo "======================================================"
                                        bounce_instance $i $BW
                #                        echo -e "server name : $i"
                                        echo "======================================================"
                                done

elif [[ ! -z "$SILO" ]] && [[ ! -z "$BW" ]] && [[ ! -z "ALL" ]] && [[ ! -z "COUNT_VAR" ]]
      then
                      echo "Both -a and -r cannot be used at a time "
                      usage

else
                      echo "Wrong parameters passed : please refer the Usage"
                      usage
		      exit
fi
