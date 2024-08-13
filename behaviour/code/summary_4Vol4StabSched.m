%% summary and plot alpha for each volatile and stable schedule regardless win/loss or blkorder
clear clc
getfolders;
blkn=4;
load([datadir,'/Result_2lr2b_inv']);
for i=1:size(Result_2lr2b_inv,1)
    if Result_2lr2b_inv(i,32)==1
        V(i,1)=Result_2lr2b_inv(i,2);
        V(i,2)=Result_2lr2b_inv(i,6);
        V(i,3)=Result_2lr2b_inv(i,3);
        V(i,4)=Result_2lr2b_inv(i,8);
        
        S(i,1)=Result_2lr2b_inv(i,7);
        S(i,2)=Result_2lr2b_inv(i,4);
        S(i,3)=Result_2lr2b_inv(i,5);
        S(i,4)=Result_2lr2b_inv(i,9);
    else 
        V(i,1)=Result_2lr2b_inv(i,6);
        V(i,2)=Result_2lr2b_inv(i,2);
        V(i,3)=Result_2lr2b_inv(i,8);
        V(i,4)=Result_2lr2b_inv(i,3);
        
        S(i,1)=Result_2lr2b_inv(i,4);
        S(i,2)=Result_2lr2b_inv(i,7);
        S(i,3)=Result_2lr2b_inv(i,9);
        S(i,4)=Result_2lr2b_inv(i,5);
    end      
end
%%

sem_inv=std(V)./sqrt(size(Result_2lr2b_inv,1));
sem_low_inv=mean(V)-sem_inv;
sem_up_inv=mean(V)+sem_inv;
up=inv_logit(sem_up_inv,1);
low=inv_logit(sem_low_inv,1);
subplot(1,2,1)
bar(inv_logit(mean(V),1));
hold on
for iii=1:blkn
  plot([iii,iii],[low(iii),up(iii)],'-k','LineWidth',1)
end
xticks([1 2 3 4]);
xticklabels({'V1','V2','V3','V4'});
ylim([0,0.45]);
%text(3,0.4,'p=0.028');
sigstar([3,4])
subplot(1,2,2)
sem_inv=std(S)./sqrt(size(Result_2lr2b_inv,1));
sem_low_inv=mean(S)-sem_inv;
sem_up_inv=mean(S)+sem_inv;
up=inv_logit(sem_up_inv,1);
low=inv_logit(sem_low_inv,1);
bar(inv_logit(mean(S),1));
ylim([0,0.45]);
hold on
for iii=1:blkn
  plot([iii,iii],[low(iii),up(iii)],'-k','LineWidth',1)
end
sigstar([3,4],[0.01]);
xticks([1 2 3 4]);
xticklabels({'S1','S2','S3','S4'});

print('summary_4Vol4Stable_Schedules.png','-dpng');