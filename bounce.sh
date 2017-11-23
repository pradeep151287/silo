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


if [ $# -eq 0 ]
then
        usage
        exit
fi

#getopts to get all the parameters passed to script


while getopts "s:b:r:l:ah" o; do
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
    l)
      server_list=${OPTARG}
      LIST="true"
  ;;
    h)
        usage
        HELP="true"
  ;;
  esac
done
echo -e " silo name : $SILO
BW name: $BW
list of server: $server_list
role base count: $COUNT"



if [[ ! -z "$SILO" ]] && [[ ! -z "$BW" ]] && [[ ! -z "$ALL" ]] && [[ ! -z "$LIST" ]] && [[  -z "$COUNT_VAR" ]]
      then
        for i in $(echo $server_list| sed "s/,/ /g")
                do
#                       echo -e "server name : $i"
                        SCOUNT=`expr $SCOUNT + 1`

                done

        echo "Total number of server: $SCOUNT "
        echo "Bouncing below instance"

        for i in $(echo $server_list| sed "s/,/ /g")
                do
                        #bounce_allinstance($i)
                        echo -e "server name : $i"
                done




elif [[ ! -z "$SILO" ]] && [[ ! -z "$BW" ]] && [[ -z "$ALL" ]] && [[ ! -z "$LIST" ]] && [[ ! -z "$COUNT_VAR" ]]
      then

                for i in $(echo $server_list| sed "s/,/ /g")
                do
                        #echo -e "server name : $i"
                        SCOUNT=`expr $SCOUNT + 1`

                done
              elif [[ ! -z "$SILO" ]] && [[ ! -z "$BW" ]] && [[ ! -z "ALL" ]] && [[ ! -z "COUNT_VAR" ]] && [[ ! -z "$server_list" ]]
                    then
                      echo "Both -a and -r cannot be used at a time "
                      usage

              elif [[ ! -z "$HELP" ]]
                      then
                      exit
              else
                      echo "Wrong parameters passed : please refer the Usage"
                      usage
              fi
