# extract and save data from stan model. 

read_ests<- function(fit,IDs,blockname){
  library(rstan)
  rstan_options(auto_write = TRUE)
  options(mc.cores = parallel::detectCores())
  
  alldata=summary(fit)
  sumdata=alldata$summary
  winposalpha=sumdata[paste0("alpha[1,",c(1:nsubs),"]"),1]  # NB winalpha_mu is name of variable, there are nsubs of them
  winnegalpha=sumdata[paste0("alpha[2,",c(1:nsubs),"]"),1]
  lossposalpha=sumdata[paste0("alpha[3,",c(1:nsubs),"]"),1]
  lossnegalpha=sumdata[paste0("alpha[4,",c(1:nsubs),"]"),1]
  beta=sumdata[paste0("beta[",c(1:nsubs),"]"),1]
  
  allout=rbind(winposalpha,winnegalpha,lossposalpha,lossnegalpha,beta)
  colnames(allout)<-IDs
  allout=melt(allout)
  colnames(allout)<-c("variables","IDs","values")
  allout=cbind(block=rep(blockname, nrow(allout)),allout)
  return(allout)
  #ncolao=ncol(allout)
  
#write.table(allout, file = writename,
     # sep = "\t", row.names = FALSE, col.names = FALSE)
  
}