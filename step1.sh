#!/bin/bash
# Retrive_PubChem_HTS_Assay_by_AID
## Download PubChem data by given assay IDs, one ID per line
# $1: HTS_assay_ID_list.txt
# ID can be retrieved via https://www.ncbi.nlm.nih.gov/pcassay/limits
# $2: output dir
# e.g. sh step1.sh HTS_assay_ID_list.txt outdir
# you can split single ID_list into multi files as well
# contact Jiangming.Sun at astrazeneca.com for more details

mkdir -p $2

echo -e "Downloading data from PubChem by a NCBI REST service...\n"
if [ -e "$1".logs_check.txt ]
then
	rm $1.logs_check.txt
fi
echo -ne "ID\tStatus\n" > $1.logs_check.txt

awk 'NR==FNR{a[$1];next} !($1 in a)' $1.logs_check.txt $1 > $1.t1

try_times=1
while [ -s $1.t1 ]
do
	if [ "$try_times" -eq 1 ]; then
		echo -e "First try to download data from PubChem:\n"
	else
		echo -e "$trytimes tries to download data from PubChem.\n"
	fi
	
	while read -r aid
		do wget -t 1 --timeout=0 -O $2/$aid.txt -o $2/$aid.log "http://pubchem.ncbi.nlm.nih.gov/assay/getassay.cgi?query=datatable&task=download&aid=$aid"
		sleep 2s
		echo -ne "\n" >> $2/$aid.txt
		
		if grep "saved" $2/$aid.log
		then
			echo -ne "$aid\tok\n" >> $1.logs_check.txt
		fi
		
		if [ -e $2/$aid.log ]; then
			rm $2/$aid.log
		fi
	done < $1.t1
	try_times=$((try_times+1))
	if [ "$try_times" -gt 10 ]; then
		break
	fi
	awk 'NR==FNR{a[$1];next} !($1 in a)' $1.logs_check.txt $1 > $1.t1
done

echo -e "\nDownloading is done!\n"
rm $1.t1

