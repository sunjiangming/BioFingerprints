#!/usr/bin/env Rscript
library(e1071)
args = commandArgs(trailingOnly=TRUE)

file=args[1]

dat=read.table(file,header=F,sep="\t",na.strings = "NA")

scale_dat = dat[,4]

dat_mean = mean(scale_dat,na.rm=T)
dat_sd = sd(scale_dat,na.rm=T)

if(dat_sd<=0){
 print(paste("errors found in sd! ",file))
} else {
output_z = (scale_dat-dat_mean)/dat_sd

#active 1, inacitve -1, inconclusive 0
flag=rep.int(NA,length(scale_dat))
flag[dat[,5]!="A" & dat[,3]!="N"] = 0
flag[dat[,5]=="A"]=1
flag[dat[,5]=="N"]=-1

zflag=abs(output_z)>=3
zf=rep.int(NA,length(zflag))
zf[zflag]=1
zf[!zflag]=-1

output=data.frame(cbind(as.character(dat[,2]),flag,dat[,4],output_z,zf))
ofile=args[2]
write.table(output,ofile,sep="\t",quote=F,col.names=F,row.names=F)
}
