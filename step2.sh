#!/bin/bash
source /etc/bashrc

outdir=$2
cd $outdir

mkdir -p $outdir/concise

while read -r cnt aid cols op others;
do
  cut -f 1,3-5 $outdir/$aid.tsv | awk -F"\t" '$1!~"[a-z,A-Z]"' | cut -f 2- | awk 'BEGIN{FS="\t";OFS="\t"} {print "'$aid'",$0}' > $outdir/concise/$aid.concise.tsv1
  cut -f 1,$cols $outdir/$aid.tsv | awk -F"\t" '$1!~"[a-z,A-Z]"' | cut -f 2- | sed 's|\t\+|\t|g' | awk 'BEGIN{FS="\t";OFS="\t"} {split($0, a, " " ); asort(a); if(a[length(a)]=="") print ""; else { if("'$op'"!="max" && length(a)%2) print a[(length(a)+1)/2]; else if("'$op'"!="max" && (length(a)+1)%2) print (a[(length(a)/2)] + a[(length(a)/2)+ 1])/2.0; else print a[length(a)]};}' > $outdir/concise/$aid.concise.tsv2
  paste -d"\t" $outdir/concise/$aid.concise.tsv1 $outdir/concise/$aid.concise.tsv2 > $outdir/concise/$aid.concise.tsv
  rm $outdir/concise/$aid.concise.tsv1 $outdir/concise/$aid.concise.tsv2
done < $1
echo Done
