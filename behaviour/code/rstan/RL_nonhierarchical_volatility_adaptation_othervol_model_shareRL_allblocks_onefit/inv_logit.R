# extract and save data from stan model. 

inv_logit<- function(x){
  y=1/(1+exp(-x))
  return(y)
  
}