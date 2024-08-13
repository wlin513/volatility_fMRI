%% load the subject data
clear;
clc;
getfolders;
filename=dir([datadir,'*.txt']);
data=read_txt([datadir,filename.name]);
nblk=4;
tn=80;
start=[0.5,0.5];
abandontn=10;
outcomedur=3;
constant=ones(tn,1);
%calculate the choice present duration(the rule is if the participant responds within 1s the choice will be presentted for 1s, if they don't
%response within 5s, a ramdom choice will be made for them, RT for this trial will nan)
choicedur=ones(length(data.trialnum),1);

for i=1:length(data.trialnum)
    if isnan(data.RT(i))
        choicedur(i)=5;
    else
        if data.RT(i)>1
        choicedur(i)=data.RT(i);
        end
    end
end
% %% calculate timing for all visual stimuli except for fixation
% for i=1:nblk
% visual(i).onset=data.choiceonset_tr((i-1)*tn+1:i*tn);
% %     for j=1:ntrl
% %         visual(i).dur(j,1)=choicedur((i-1)*ntrl+j)+data.ISIjitter((i-1)*ntrl+j)+outcomedur;%the duration of chosen option presented is the ISIjitter
% %     end
% visual(i).dur=data.fixationonset_tr((i-1)*tn+2:i*tn)-data.choiceonset_tr((i-1)*tn+1:i*tn-1);
% visual(i).dur(tn,1)=choicedur(i*tn)+data.ISIjitter(i*tn)+outcomedur;
% visual(i).value=constant;
% end

% % check if visual is correctly calculated(the time interval between the offset of the visual and its next visual onset should be the ITIjitter)
% visual_offset=zeros(length(data.trialnum),1);
% visual_nextonset=zeros(length(data.trialnum),1);
% for i=1:nblk
%     for j=1:ntrl-1
%         visual_offset((i-1)*ntrl+j)=visual(i).onset(j)+visual(i).dur(j);
%         visual_nextonset((i-1)*ntrl+j)=visual(i).onset(j+1);
%     end
% end
% visualtimeinterval=visual_nextonset-visual_offset;
% Tdiff_visual=visualtimeinterval(1:end-1)-data.ITIjitter(2:end);

%% calculate timing for Eexpected Value for chosen option at choice and absolute Prediction Error(surprise) for chosen option at outcome
% get the model result
% 2alpha2beta

for i=1:nblk
information=[data.winpos(((i-1)*tn+1):i*tn),data.losspos(((i-1)*tn+1):i*tn)];
choice=data.choice(((i-1)*tn+1):i*tn);
result_2lr_2b=fit_linked_2lr_2beta_il_rev(information,choice, start, abandontn);
bel=rescorla_wagner_2lr(information,[result_2lr_2b.mean_alpha_rew result_2lr_2b.mean_alpha_loss],start);
evch=bel(:,1)-bel(:,2);
evch(choice==0)=-evch(choice==0);
EVchosen(i).value=evch-mean(evch);
EVchosen(i).onset=data.choiceonset_tr((i-1)*tn+1:i*tn);
EVchosen(i).dur=choicedur((i-1)*tn+1:i*tn);
pech=data.winchosen((i-1)*tn+1:i*tn)-data.losschosen((i-1)*tn+1:i*tn)-evch;
PEchosen(i).value=abs(pech)-mean(abs(pech));
PEchosen(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn);
PEchosen(i).dur=ones(80,1)*outcomedur;
end

%% 2alpha1beta + bias term
for i=1:blkn
information=[data.winpos(((i-1)*tn+1):i*tn),data.losspos(((i-1)*tn+1):i*tn)];
choice=data.choice(((i-1)*tn+1):i*tn);
result_2lr_1b_bias(i,:)=fit_linked_2lr_beta_add(information,choice, start, abandontn);
end


for i=1:blkn
    alpha_rew_2lr_1b_bias(i,1)=getfield(result_2lr_1b_bias,{i,1},'mean_alpha_rew');
    alpha_rew_var_2lr_1b_bias(i,1)=getfield(result_2lr_1b_bias,{i,1},'var_alpha_rew');
    alpha_loss_2lr_1b_bias(i,1)=getfield(result_2lr_1b_bias,{i,1},'mean_alpha_loss');
    alpha_loss_var_2lr_1b_bias(i,1)=getfield(result_2lr_1b_bias,{i,1},'var_alpha_loss');
    BIC_2lr_1b_bias(i,1)=getfield(result_2lr_1b_bias,{i,1},'BIC');
    AIC_2lr_1b_bias(i,1)=getfield(result_2lr_1b_bias,{i,1},'AIC');
end


%% save the timing as three column txt file
% for i=1:nblk
%     visualtmp=[visual(i).onset visual(i).dur visual(i).value];
%     save([datadir,'EVfiles/','visual_b',num2str(i),'.txt'],'visualtmp','-ascii');
% end
%% sorting timing for receipt of win and loss respectively

for i=1:nblk
outcomesonset=data.outcomesonset_tr((i-1)*tn+1:i*tn);

winchosen=data.winchosen((i-1)*tn+1:i*tn);
reptWin(i).onset=outcomesonset(winchosen==1);
reptWin(i).value=ones(size(reptWin(i).onset));
reptWin(i).dur=reptWin(i).value.*3;

losschosen=data.losschosen((i-1)*tn+1:i*tn);
reptLoss(i).onset=outcomesonset(losschosen==1);
reptLoss(i).value=ones(size(reptLoss(i).onset));
reptLoss(i).dur=reptLoss(i).value.*3;

reptNeither(i).onset=outcomesonset(winchosen==0 & losschosen==0);
reptNeither(i).value=ones(size(reptNeither(i).onset));
reptNeither(i).dur=reptNeither(i).value.*3;
clear outcomesonset neitherchosen winchosen losschosen

EVchoice(i).onset=data.choiceonset_tr((i-1)*tn+1:i*tn);
EVchoice(i).dur=choicedur((i-1)*tn+1:i*tn);
EVchoice(i).value=constant;
end

%
mkdir([datadir,'EVfiles/OutcomeRept2']);
for i=1:nblk
    reptWintmp=[reptWin(i).onset reptWin(i).dur reptWin(i).value];
    save([datadir,'EVfiles/OutcomeRept2/','reptWin_b',num2str(i),'.txt'],'reptWintmp','-ascii');
    
    reptLosstmp=[reptLoss(i).onset reptLoss(i).dur reptLoss(i).value];
    save([datadir,'EVfiles/OutcomeRept2/','reptLoss_b',num2str(i),'.txt'],'reptLosstmp','-ascii');
 
    reptNeithertmp=[reptNeither(i).onset reptNeither(i).dur reptNeither(i).value];
    save([datadir,'EVfiles/OutcomeRept2/','reptNeither_b',num2str(i),'.txt'],'reptNeithertmp','-ascii');
    
    EVchoicetmp=[EVchoice(i).onset EVchoice(i).dur EVchoice(i).value];
    save([datadir,'EVfiles/OutcomeRept2/','choice_b',num2str(i),'.txt'],'EVchoicetmp','-ascii');
    
end
%%
for i=1:nblk
    EVchosentmp=[EVchosen(i).onset EVchosen(i).dur EVchosen(i).value];
    save([datadir,'EVfiles/','EVchosen_value_b',num2str(i),'.txt'],'EVchosentmp','-ascii');
    EVchosentmp=[EVchosen(i).onset EVchosen(i).dur constant];
    save([datadir,'EVfiles/','EVchosen_constant_b',num2str(i),'.txt'],'EVchosentmp','-ascii');
    PEchosentmp=[PEchosen(i).onset PEchosen(i).dur PEchosen(i).value];
    save([datadir,'EVfiles/','PEchosen_value_b',num2str(i),'.txt'],'PEchosentmp','-ascii');
    PEchosentmp=[PEchosen(i).onset PEchosen(i).dur constant];
    save([datadir,'EVfiles/','PEchosen_constant_b',num2str(i),'.txt'],'PEchosentmp','-ascii');
end



%%
%% sorting timing for receipt-noreceipt of win and loss respectively(suggested by L)
% you need to exclude the response missed trials later on
for i=1:nblk

winchosen=data.winchosen((i-1)*tn+1:i*tn);
winchosen(winchosen==0)=-1;
reptWin(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn);
reptWin(i).value=winchosen-mean(winchosen);
reptWin(i).dur=ones(size(reptWin(i).onset)).*3;

losschosen=data.losschosen((i-1)*tn+1:i*tn);
losschosen(losschosen==0)=-1;
reptLoss(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn);
reptLoss(i).value=losschosen-mean(losschosen);
reptLoss(i).dur=ones(size(reptLoss(i).onset)).*3;

Outcome(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn);
Outcome(i).value=ones(size(Outcome(i).onset));
Outcome(i).dur=Outcome(i).value.*3;

clear winchosen losschosen

EVchoice(i).onset=data.choiceonset_tr((i-1)*tn+1:i*tn);
EVchoice(i).dur=choicedur((i-1)*tn+1:i*tn);
EVchoice(i).value=constant;
end

%
mkdir([datadir,'EVfiles/OutcomeRept3L']);
for i=1:nblk
    reptWintmp=[reptWin(i).onset reptWin(i).dur reptWin(i).value];
    save([datadir,'EVfiles/OutcomeRept3L/','ifreptWin_b',num2str(i),'.txt'],'reptWintmp','-ascii');
    
    reptLosstmp=[reptLoss(i).onset reptLoss(i).dur reptLoss(i).value];
    save([datadir,'EVfiles/OutcomeRept3L/','ifreptLoss_b',num2str(i),'.txt'],'reptLosstmp','-ascii');
 
    outcomesonset=[Outcome(i).onset Outcome(i).dur Outcome(i).value];
    save([datadir,'EVfiles/OutcomeRept3L/','Outcome_b',num2str(i),'.txt'],'outcomesonset','-ascii');
    
    EVchoicetmp=[EVchoice(i).onset EVchoice(i).dur EVchoice(i).value];
    save([datadir,'EVfiles/OutcomeRept3L/','choice_b',num2str(i),'.txt'],'EVchoicetmp','-ascii');
    
end

%% MW_MB_model for test if contrast [1 -1/1] would work compared to concatenate data

for i=1:nblk

Outcome_mean(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn-40);
Outcome_mean(i).value=ones(size(Outcome_mean(i).onset));
Outcome_mean(i).dur=Outcome_mean(i).value.*3;

end
lin(:,1)=1:1:40;
lin=lin./20;
lininc=lin-mean(lin);
lindec=flipud(lininc);
linear(:,1)=lininc;linear(:,3)=lininc;
linear(:,2)=lindec;linear(:,4)=lindec;
%
mkdir([datadir,'EVfiles/MW_MB_model']);
for i=1:nblk
    outcomesonset=[Outcome_mean(i).onset Outcome_mean(i).dur Outcome_mean(i).value];
    save([datadir,'EVfiles/MW_MB_model/','mean_Outcome_b',num2str(i),'.txt'],'outcomesonset','-ascii');
    clear outcomesonset
    outcomesonset=[Outcome_mean(i).onset Outcome_mean(i).dur linear(:,i)];
    save([datadir,'EVfiles/MW_MB_model/','Outcome_b',num2str(i),'.txt'],'outcomesonset','-ascii');
end

b1dur=543*0.8;
b2dur=539*0.8;
b3dur=547*0.8;
%b4dur=560*0.8;
outcomesforlongdata.onset((1-1)*tn/2+1:1*tn/2,1)=Outcome_mean(1).onset;
outcomesforlongdata.onset((2-1)*tn/2+1:2*tn/2,1)=Outcome_mean(2).onset+b1dur;
outcomesforlongdata.onset((3-1)*tn/2+1:3*tn/2,1)=Outcome_mean(3).onset+b1dur+b2dur;
outcomesforlongdata.onset((4-1)*tn/2+1:4*tn/2,1)=Outcome_mean(4).onset+b1dur+b2dur+b3dur;

outcomesforlongdata.value_mean=ones(size(outcomesforlongdata.onset));

outcomesforlongdata.value_linear=[lininc; lindec; lininc; lindec];

outcomesforlongdata.dur=outcomesforlongdata.value_mean*3;


mkdir([datadir,'EVfiles/MW_MB_model/allblocks']);
clear outcomesonset
outcomesonset=[outcomesforlongdata.onset outcomesforlongdata.dur outcomesforlongdata.value_mean];
save([datadir,'EVfiles/MW_MB_model/allblocks/','mean_outcome_allblocks.txt'],'outcomesonset','-ascii');
clear outcomesonset
outcomesonset=[outcomesforlongdata.onset outcomesforlongdata.dur outcomesforlongdata.value_linear];
save([datadir,'EVfiles/MW_MB_model/allblocks/','para_outcome_allblocks.txt'],'outcomesonset','-ascii');  

getfolders;
data=read_txt([datadir,'Dynamic_learning_fMRI_20_blktype_4_rev_1_ntry_1.txt']);
nblk=4;
tn=80;
for i=1:nblk

Outcome_mean(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn-40);
Outcome_mean(i).value=ones(size(Outcome_mean(i).onset));
Outcome_mean(i).dur=Outcome_mean(i).value.*3;

end
lin(:,1)=1:1:40;
lin=lin./20;
lininc=lin-mean(lin);
lindec=flipud(lininc);
linear(:,1)=lininc;linear(:,3)=lininc;
linear(:,2)=lindec;linear(:,4)=lindec;
%
mkdir([datadir,'EVfiles/MW_MB_model/pilot2']);
for i=1:nblk
    outcomesonset=[Outcome_mean(i).onset Outcome_mean(i).dur Outcome_mean(i).value];
    save([datadir,'EVfiles/MW_MB_model/pilot2/','mean_Outcome_b',num2str(i),'.txt'],'outcomesonset','-ascii');
    clear outcomesonset
    outcomesonset=[Outcome_mean(i).onset Outcome_mean(i).dur linear(:,i)];
    save([datadir,'EVfiles/MW_MB_model/pilot2/','Outcome_b',num2str(i),'.txt'],'outcomesonset','-ascii');
end

b1dur=553*0.8;
b2dur=512*0.8;
b3dur=558*0.8;
outcomesforlongdata.onset((1-1)*tn/2+1:1*tn/2,1)=Outcome_mean(1).onset;
outcomesforlongdata.onset((2-1)*tn/2+1:2*tn/2,1)=Outcome_mean(2).onset+b1dur;
outcomesforlongdata.onset((3-1)*tn/2+1:3*tn/2,1)=Outcome_mean(3).onset+b1dur+b2dur;
outcomesforlongdata.onset((4-1)*tn/2+1:4*tn/2,1)=Outcome_mean(4).onset+b1dur+b2dur+b3dur;

outcomesforlongdata.value_mean=ones(size(outcomesforlongdata.onset));

outcomesforlongdata.value_linear=[lininc; lindec; lininc; lindec];

outcomesforlongdata.dur=outcomesforlongdata.value_mean*3;


mkdir([datadir,'EVfiles/MW_MB_model/pilot2/allblocks']);
clear outcomesonset
outcomesonset=[outcomesforlongdata.onset outcomesforlongdata.dur outcomesforlongdata.value_mean];
save([datadir,'EVfiles/MW_MB_model/pilot2/allblocks/','mean_outcome_allblocks.txt'],'outcomesonset','-ascii');
clear outcomesonset
outcomesonset=[outcomesforlongdata.onset outcomesforlongdata.dur outcomesforlongdata.value_linear];
save([datadir,'EVfiles/MW_MB_model/pilot2/allblocks/','para_outcome_allblocks.txt'],'outcomesonset','-ascii');  
%%
getfolders
data=read_txt([datadir,'Dynamic_learning_fMRI_11_blktype_3_rev_2_ntry_1.txt']);
nblk=4;
tn=80;
for i=1:nblk

Outcome_mean(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn);
Outcome_mean(i).value=ones(size(Outcome_mean(i).onset));
Outcome_mean(i).dur=Outcome_mean(i).value.*3;

end
lin(:,1)=1:1:80;
lin=lin./40;
lininc=lin-mean(lin);
lindec=flipud(lininc);
linear(:,1)=lininc;linear(:,3)=lininc;
linear(:,2)=lindec;linear(:,4)=lindec;

b1dur=1108*0.8;
b2dur=1114*0.8;
b3dur=1121*0.8;

outcomesforfullconc.onset((1-1)*tn+1:1*tn,1)=Outcome_mean(1).onset+5*0.8;
outcomesforfullconc.onset((2-1)*tn+1:2*tn,1)=Outcome_mean(2).onset+b1dur+5*0.8;
outcomesforfullconc.onset((3-1)*tn+1:3*tn,1)=Outcome_mean(3).onset+b1dur+b2dur+5*0.8;
outcomesforfullconc.onset((4-1)*tn+1:4*tn,1)=Outcome_mean(4).onset+b1dur+b2dur+b3dur+5*0.8;

outcomesforfullconc.value_mean=ones(size(outcomesforfullconc.onset));

outcomesforfullconc.value_linear=[lininc; lindec; lininc; lindec];

outcomesforfullconc.dur=outcomesforfullconc.value_mean*3;

mkdir([datadir,'EVfiles/MW_MB_model/pilot1']);
mkdir([datadir,'EVfiles/MW_MB_model/pilot1/fullconc']);
clear outcomesonset
outcomesonset=[outcomesforfullconc.onset outcomesforfullconc.dur outcomesforfullconc.value_mean];
save([datadir,'EVfiles/MW_MB_model/pilot1/fullconc/','mean_outcome_allblocks.txt'],'outcomesonset','-ascii');
clear outcomesonset
outcomesonset=[outcomesforfullconc.onset outcomesforfullconc.dur outcomesforfullconc.value_linear];
save([datadir,'EVfiles/MW_MB_model/pilot1/fullconc/','para_outcome_allblocks.txt'],'outcomesonset','-ascii');  