fun_read_original_data_files <- function(file.name, ...){
  lines <- scan(file.name, what="character", sep="\n")
  first.line <- min(grep("Trialnumber", lines))
  sub_num<-substr(lines[1],13,14)
  blktype<-substr(lines[1],25,26)
  ifreverse<-substr(lines[1],37,38)
  nsubnum=as.numeric(sub_num)
  nblktype=as.numeric(blktype)
  nver=as.numeric(ifreverse)
  ret_list <- list("data"=read.delim(textConnection(lines), skip=first.line-1),"subnum"=nsubnum,'blktype'=nblktype,'ver'=nver)
  return(ret_list)
  }
