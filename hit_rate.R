#!/usr/bin/env Rscript
library(e1071)
args = commandArgs(trailingOnly=TRUE)

file=args[1]

dat=read.table(file,header=F,sep="\t",na.strings = "NA")
inact_idx=dat[,2]==-1
act_idx=dat[,2]==1

scale_dat = as.numeric(dat[,4])
hit_raw=sum(abs(scale_dat)>=3.0,na.rm=T)
hit_rate=hit_raw/length(scale_dat)

hit_raw.act=sum(abs(scale_dat)>=3.0 & act_idx ,na.rm=T)
hit_rate.act=hit_raw.act/max(sum(act_idx,na.rm=T),1.0)

hit_raw.inact=sum(abs(scale_dat)>=3.0 & inact_idx ,na.rm=T)
hit_rate.inact=hit_raw.inact/max(sum(inact_idx,na.rm=T),1.0)

output=format(cbind(hit_rate,hit_rate.act,hit_rate.inact),digits=4, nsmall=4,scientific=F)
#names(output)=c("hit_rate","hit_raw.act","hit_raw.inact","hit_rate.rank","hit_rate.act.rank","hit_rate.inact.rank")

ofile=args[2]

write.table(output,ofile,sep="\t",quote=F,col.names=F,row.names=F)
