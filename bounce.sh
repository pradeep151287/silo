##########################################################################
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
CSV_FILE="silo_env_info.csv"

server_list_fun()
{
  OLDIFS=$IFS
  IFS=","
  COUNT=1
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

  s_list=`echo "${csv[*]}" | tr -d " "`
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

#healthcheck()
#{
#  ssh to the respective instance and run  dupcheck command and store some where to verify later
#   check health status of Hawk agent
#   check permission of ASI files
#}

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
# calling health check function 
#healthcheck $HNAME

ssh $1 

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
echo -e " silo name : $SILO
BW name: $BW
role base count: $COUNT"



if [[ ! -z "$SILO" ]] && [[ ! -z "$BW" ]] && [[ ! -z "$ALL" ]] && [[  -z "$COUNT_VAR" ]]
      then
       # calling server_list_fun 
	server_list_fun $SILO	

	if [ -z "$s_list" ]
	then 	
		echo "SILO not Found"
		exit
	fi

        echo "Bouncing below instance"
	echo "${s_list[*]}"	
	s_list_new=${s_list[*]}

        for i in $(echo $s_list_new| sed "s/|/ /g")
                do
                        #bounce_allinstance($i)
                        echo -e "server name : $i"
                done




elif [[ ! -z "$SILO" ]] && [[ ! -z "$BW" ]] && [[ -z "$ALL" ]] && [[ ! -z "$COUNT_VAR" ]]
      then

                for i in $(echo $server_list| sed "s/,/ /g")
                do
                        #echo -e "server name : $i"
                        SCOUNT=`expr $SCOUNT + 1`

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
