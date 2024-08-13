#function to parse vol_train data for R

fun_parse_data_into_blocks<- function(datalist){
  datain<-datalist$data
  subnum<-datalist$subnum
  blktype<-datalist$blktype
  ver<-datalist$ver
  

  block1_trials<-datain[which(datain$Trialnumber<81),]
  block2_trials<-datain[which(datain$Trialnumber>80 & datain$Trialnumber<161),]
  block3_trials<-datain[which(datain$Trialnumber>160 & datain$Trialnumber<241),]
  block4_trials<-datain[which(datain$Trialnumber>240),]
  
  
  #info is 1 if outcome associated with shape 1, 0 shape 2
  #choices are 1 for chosing shape 1, 0 shape 2
  block1_wins<-block1_trials$Winpos
  block1_loss<-block1_trials$Losspos
  block1_choice<-block1_trials$Choice
  block1_RT<-block1_trials$RT
  block2_wins<-block2_trials$Winpos
  block2_loss<-block2_trials$Losspos
  block2_choice<-block2_trials$Choice
  block2_RT<-block2_trials$RT
  block3_wins<-block3_trials$Winpos
  block3_loss<-block3_trials$Losspos
  block3_choice<-block3_trials$Choice
  block3_RT<-block3_trials$RT
  block4_wins<-block4_trials$Winpos
  block4_loss<-block4_trials$Losspos
  block4_choice<-block4_trials$Choice
  block4_RT<-block4_trials$RT
  
  return(ret_list<-list("data" = data.frame(block1_wins, block1_loss, block1_choice,block1_RT,block2_wins, block2_loss, block2_choice, block2_RT,
                                            block3_wins, block3_loss, block3_choice,block3_RT,block4_wins, block4_loss, block4_choice,block4_RT), 
                                            "subnum"=subnum,"blktype"=blktype,"ver"=ver))
}