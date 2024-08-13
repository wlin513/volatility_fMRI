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
  winalpha=sumdata[paste0("alpha[1,",iblk,",",c(1:nsubs),"]"),1]  
  lossalpha=sumdata[paste0("alpha[2,",iblk,",",c(1:nsubs),"]"),1]  

  allout1=rbind(winalpha,lossalpha)
  colnames(allout1)<-IDs
  allout1=melt(allout1)
  colnames(allout1)<-c("variables","IDs","values")
  allout1=cbind(block=rep(blocknames[iblk], nrow(allout1)),allout1)
  allout=rbind(allout1,allout)
  }
  beta=sumdata[paste0("beta[",c(1:nsubs),"]"),1]
  win_sta_adpt_tr=sumdata[paste0("win_vol_adpt_tr[1,",c(1:nsubs),"]"),1]
  loss_sta_adpt_tr=sumdata[paste0("loss_vol_adpt_tr[1,",c(1:nsubs),"]"),1]
  win_vol_adpt_tr=sumdata[paste0("win_vol_adpt_tr[2,",c(1:nsubs),"]"),1]
  loss_vol_adpt_tr=sumdata[paste0("loss_vol_adpt_tr[2,",c(1:nsubs),"]"),1]
  allbias=rbind(beta,win_vol_adpt_tr,loss_vol_adpt_tr,win_sta_adpt_tr,loss_sta_adpt_tr)
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