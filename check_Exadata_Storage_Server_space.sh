#!/bin/bash

# ASSUMPTIONS :
# MUST be run on physical server


if [ $(ps -ef|grep xend|grep -v grep|wc -l) -gt 0 ]; then
	_xen=1
else
	_xen=0
fi

IFS=$'\n'
for i in $(ibhosts|grep -v S |awk '{print $6}'|sed -e 's/"//'|sort -n)
do
	host=${i}
	ping -c 2 ${host} > /dev/null 
	if [ $? -ne 0 ]; then
		out="_SERVER_UNREACHABLE_"
		echo "${host}|||${out}"
	else
		ssh -o ConnectTimeout=2 -o BatchMode=yes -q ${host} exit
		if [ $? -ne 0 ]; then
			out="_CHECK_SSH_KEY_"
			echo "${host}|||${out}"
		else
			for j in $(dcli -l root -c ${host} "cellcli -e list celldisk attributes name,size,freespace,status,errorcount where name like \'CD_.*\'")
			do
				cdname=$(echo $j |awk '{print $2}')
				stat=$(echo $j |awk '{print $5}')
				cdsizeT=$(echo $j |awk '{print $3}'|sed -e 's/T//g')
				cdfreeT=$(echo $j |awk '{print $4}'|sed -e 's/T//g')
				if [ ${_xen} = 1 ];then
					perc_used=$(echo "100-(100*${cdfreeT}/${cdsizeT})"|bc)
				else
					perc_used=0
				fi
				err_count=$(echo $j |awk '{print $6}')
				echo "${host}|||${cdname}|||${stat}|||${err_count}|||${perc_used}"
			done
		fi
	fi
done


#EXAMPLE OUTPUT
#STORAGESERVER_NAME|||CELLDISK_NAME|||STATUS|||ERR_COUNT|||USED%
#fcax1sf1|||CD_00_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_01_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_02_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_03_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_04_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_05_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_06_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_07_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_08_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_09_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_10_fcax1sf1|||normal|||0|||54
#fcax1sf1|||CD_11_fcax1sf1|||normal|||0|||54
#fcax1sf2|||CD_00_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_01_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_02_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_03_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_04_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_05_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_06_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_07_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_08_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_09_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_10_fcax1sf2|||normal|||0|||54
#fcax1sf2|||CD_11_fcax1sf2|||normal|||0|||54
#fcax1sf3|||CD_00_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_01_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_02_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_03_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_04_fcax1sf3|||normal|||103|||54
#fcax1sf3|||CD_05_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_06_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_07_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_08_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_09_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_10_fcax1sf3|||normal|||0|||54
#fcax1sf3|||CD_11_fcax1sf3|||normal|||0|||54


















