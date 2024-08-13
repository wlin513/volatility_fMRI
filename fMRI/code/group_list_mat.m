 
clear all

clc

getfolders

sublistlow=[10,06,13,01,05,03,12,14,02];

sublisthigh=[11,15,07,09,04,08,16,17,18,19];

allsub=[sublistlow,sublisthigh];

allsub=sort(allsub);

indexlow=ismember(allsub,sublistlow);

G=ones(length(allsub),1);

G(indexlow==1)=-1;

G=G-mean(G);

save([datadir,'GroupDiffInfo.mat'],'G');
