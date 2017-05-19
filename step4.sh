#!/bin/bash
source /etc/bashrc
## $1, HTS assay file
## $2, dir of htsfp

ifile=$1
filename=${ifile##*/}

tmpdir=$2/htsfp/$filename/

mkdir -p $tmpdir

mkdir -p $2/htsfp/median/

while read -r count aid others;
do
  if [ -s $2/htsfp/median/$aid.htsfp.250.median.txt ]; then
    rm $2/htsfp/median/$aid.htsfp.250.median.txt
  fi

  #Pubmed CID to Ambit_InChIKey, may not necessary
  awk 'BEGIN{FS="\t";OFS="\t"} NR==FNR{a[$1]=$0;next} {if($1 in a) print $2,a[$1]}' $2/htsfp/$aid.htsfp.250.txt path2Ambit_standardized_PubChemCompounds/PubChem_Std_Compound_2016-04-08.txt | sort -k 1,1f -k 5,5f > $2/htsfp/$aid.htsfp.inchikey.sorted.txt
  
  awk -F"\t" '{print $1}' $2/htsfp/$aid.htsfp.inchikey.sorted.txt | uniq -c | sed 's|^ \+||g' | sed 's| |\t|g' | awk -v OFS="\t" '{print $2,$1}' > $2/htsfp/$aid.inchikey.count.txt
  awk 'BEGIN{FS="\t";OFS="\t"} $2>1' $2/htsfp/$aid.inchikey.count.txt  > $2/htsfp/$aid.inchikey.count_lastrow_medianrow.dup.txt

  if [ -s $2/htsfp/$aid.inchikey.count_lastrow_medianrow.dup.txt ];then
    awk 'BEGIN{FS="\t";OFS="\t"} NR==FNR{a[$1];next} !($1 in a)' $2/htsfp/$aid.inchikey.count_lastrow_medianrow.dup.txt $2/htsfp/$aid.htsfp.inchikey.sorted.txt > $2/htsfp/$aid.htsfp.inchikey.sorted.single.txt
    awk 'BEGIN{FS="\t";OFS="\t"} NR==FNR{a[$1];next} $1 in a' $2/htsfp/$aid.inchikey.count_lastrow_medianrow.dup.txt $2/htsfp/$aid.htsfp.inchikey.sorted.txt > $2/htsfp/$aid.htsfp.inchikey.sorted.dup.txt

    cat $2/htsfp/$aid.htsfp.inchikey.sorted.single.txt > $2/htsfp/median/$aid.htsfp.250.median.txt
    cat $2/htsfp/$aid.inchikey.count_lastrow_medianrow.dup.txt | awk -v OFS="\t" '{s+=$2;print $0,s}' | awk -v OFS="\t" '{if($2==1) print $0,$3; else if($2>1) print $0,$3+1-int(($2+1)/2);}' > $2/htsfp/$aid.inchikey.count_lastrow_medianrow.txt

    if [ "$(ls -A $tmpdir)" ]; then
      rm $tmpdir/split*
    fi

    split -l 5000 $2/htsfp/$aid.inchikey.count_lastrow_medianrow.txt $tmpdir/split
    for f in $tmpdir/split*; do
       sed_args=""
       sed_args=$(cut -f 4 $f | paste -s -d 'p' | sed 's/p/p;/g')
       sed -n "$sed_args"p $2/htsfp/$aid.htsfp.inchikey.sorted.dup.txt >> $2/htsfp/median/$aid.htsfp.250.median.txt
    done

    rm $2/htsfp/$aid.htsfp.inchikey.sorted.dup.txt $2/htsfp/$aid.inchikey.count_lastrow_medianrow.txt $2/htsfp/$aid.htsfp.inchikey.sorted.single.txt
  else
    cat $2/htsfp/$aid.htsfp.inchikey.sorted.txt > $2/htsfp/median/$aid.htsfp.250.median.txt
  fi

  rm $2/htsfp/$aid.htsfp.inchikey.sorted.txt $2/htsfp/$aid.inchikey.count.txt $2/htsfp/$aid.inchikey.count_lastrow_medianrow.dup.txt
done < $ifile
rm -fr $tmpdir
echo Done
