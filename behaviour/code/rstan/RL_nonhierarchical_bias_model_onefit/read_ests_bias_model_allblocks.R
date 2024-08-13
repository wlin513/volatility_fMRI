# extract and save data from stan model. 

read_ests<- function(fit,IDs,blocknames){
  library(rstan)
  library(reshape2)
  rstan_options(auto_write = TRUE)
  options(mc.cores = parallel::detectCores())
  
  alldatafit=summary(fit)
  sumdata=alldatafit$summary
  allout=vector()

  for (iblk in nblk:1){
  winposalpha=sumdata[paste0("alpha[1,",iblk,",",c(1:nsubs),"]"),1]  
  winnegalpha=sumdata[paste0("alpha[2,",iblk,",",c(1:nsubs),"]"),1]
  lossposalpha=sumdata[paste0("alpha[3,",iblk,",",c(1:nsubs),"]"),1]  
  lossnegalpha=sumdata[paste0("alpha[4,",iblk,",",c(1:nsubs),"]"),1]
  beta=sumdata[paste0("beta[",iblk,",",c(1:nsubs),"]"),1]

  allout1=rbind(winposalpha,winnegalpha,lossposalpha,lossnegalpha,beta)
  colnames(allout1)<-IDs
  allout1=melt(allout1)
  colnames(allout1)<-c("variables","IDs","values")
  allout1=cbind(block=rep(blocknames[iblk], nrow(allout1)),allout1)
  allout=rbind(allout1,allout)
  }
  
  PN_bias_tr=sumdata[paste0("PN_bias_tr[",c(1:nsubs),"]"),1]
  VS_bias_tr=sumdata[paste0("VS_bias_tr[",c(1:nsubs),"]"),1]
  WL_bias_tr=sumdata[paste0("WL_bias_tr[",c(1:nsubs),"]"),1]
  invx_tr=sumdata[paste0("invx_tr[",c(1:nsubs),"]"),1]
  allbias=rbind(PN_bias_tr,VS_bias_tr,WL_bias_tr,invx_tr)
  colnames(allbias)<-IDs
  allbias=melt(allbias)
  colnames(allbias)<-c("variables","IDs","values")
  allbias=cbind(block=rep("na",nrow(allbias)),allbias)
  
  allout=rbind(allbias,allout)
  return(allout)
  #ncolao=ncol(allout)
  
#write.table(allout, file = writename,
     # sep = "\t", row.names = FALSE, col.names = FALSE)
  
}