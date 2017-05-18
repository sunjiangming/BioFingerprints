#!/usr/bin/env Rscript

library(e1071)
args = commandArgs(trailingOnly=TRUE)

suppressMessages(library(pROC))

file1=args[1]
file2=args[2]

v1=read.table(file1,header=F,sep="\t",skip=1,na.strings = "NA")
v2=read.table(file2,header=F,sep="\t",skip=1,na.strings = "NA")
v1=as.numeric(v1[,1])
v2=as.numeric(v2[,1])

empty = is.na(v1) | is.na(v2)

#condition_exclude
v1_all = v1[v1==1 & !empty]
v1_pn=v1[v1!=0 & !empty]

v2_all=v2[v1==1 & !empty]
v2_pn=v2[v1!=0 & !empty]

if(length(v2_pn)>1 && max(v1_pn)>-1 && min(v1_pn)<1){
#corr=cor(v1,v2,use = "na.or.complete", method="spearman")
auc_v=auc(v1_pn,v2_pn)
} else if(length(v2_pn)>1 && (max(v1_pn)==-1 || min(v1_pn)==1)){
auc_v="single_flag"
} else{
auc_v=NA
}

output=auc_v
#names(output)=c("hit_rate","hit_raw.act","hit_raw.inact","hit_rate.rank","hit_rate.act.rank","hit_rate.inact.rank")
ofile=args[3]
write.table(output,ofile,sep="\t",quote=F,col.names=F,row.names=F)
