#!/bin/bash
source /etc/bashrc
module load R

# sh step3.sh $1 $2
# $1 kepted_assay_cnt-aid-row-op
# $2 Path to HTS data

mkdir -p $2/htsfp

while read -r cnt aid cols op others;
do
	if [ -s "files/concise/$aid.concise.tsv" ]
    then
      Rscript --vanilla compute_biofingerprints_within_assay.R "$2/files/concise/$aid.concise.tsv" "$2/htsfp/$aid.htsfp.txt"
      if [ -s "htsfp/$aid.htsfp.txt" ]
      then
        Rscript --vanilla hit_rate.R "$2/htsfp/$aid.htsfp.txt" "$2/htsfp/$aid.htsfp.hitrate.tsv"
        sed -i "s|^|$aid\t|" htsfp/$aid.htsfp.hitrate.tsv
      fi
    fi

done < $1
echo Done Z-score computation
