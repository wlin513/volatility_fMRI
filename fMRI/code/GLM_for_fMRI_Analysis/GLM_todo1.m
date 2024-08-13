        
clear;
clc;

cd('/home/wlin/Documents/2018_fMRI/behavior/fMRI/code/GLM_for_fMRI_Analysis');
getfolders;
behdatadir='/home/wlin/Documents/2018_fMRI/behavior/2018_fMRI_data/';
%%
sublist={'s01','s02','s03','s04','s05','s06','s07','s08','s09','s10',...
    's11','s12','s13','s14','s15','s16','s17','s18','s19','s20'...
    's21','s22','s23','s24','s25','s26','s27','s29','s30','s31' };

nblk=4;
tn=80;
TR=0.8;
outcomedur=3;
constant=ones(tn,1);
zerocon=zeros(tn,1);

%all matrices for orders of 4 blocks: for 1 for both volatile, 2 for win
%volatile/loss stable, 3 for loss volatile/win stable, 4 for both stable
blockorders1=[1,2,3,4; 1,3,2,4;4,2,3,1;4,3,2,1;2,1,4,3;2,4,1,3;3,1,4,2;3,4,1,2];%blockorder for the not reversed version
blockorders2=[1,3,2,4; 1,2,3,4;4,3,2,1;4,2,3,1;3,1,4,2;3,4,1,2;2,1,4,3;2,4,1,3];%blockorder for the reversed version


blkname={'both_vol_block','win_vol_block','loss_vol_block','both_stable_block'};


%%
for ss=1:size(sublist,2)
 %%  read data 
    sdatadir=[behdatadir,sublist{ss},'/'];
    
    % read blocks in the scanner
    if strcmp(sublist{ss},'s14') %list of participants whose fMRI behavior data was in second run of the task
    filename1=dir([sdatadir,'Dynamic_learning*2.txt']);
    else
        filename1=dir([sdatadir,'Dynamic_learning*1.txt']);
    end

    data=read_txt([sdatadir,filename1.name]);
    
    % blktype of this 8th order was marked as 0 in the scan psychopy data file
    blktype=data.blktype;
    if blktype==0
        blktype=8;
    end
    ver=data.ifreverse;
    %decide which version to print on the plot
    if ver==1
        blockorders=blockorders1;
    else
        blockorders=blockorders2;
    end
    for i=1:nblk
    realblkname(i)=blkname(blockorders(blktype,i));
    end
    %calculate the choice present duration(the rule is if the participant responds within 1s the choice will be presentted for 1s, if they don't
    %response within 5s, a ramdom choice will be made for them, RT for this trial will nan)
%     choicedur=ones(length(data.trialnum),1);
% 
%     for i=1:length(choicedur)
%         if isnan(data.RT(i))
%             choicedur(i)=5;
%         else
%             if data.RT(i)>1
%             choicedur(i)=data.RT(i);
%             end
%         end
%     end
 
%% @choice onset

%regressor 4: the response(1 for left; -1 for right; leave out the trial in which the participants didn't respond; then demean)
right={'right'};
right=repmat(right,length(data.choiceside),1);
none={'none'};
none=repmat(none,length(data.choiceside),1);
choiceside=ones(length(data.choiceside),1);
choiceside(strcmp(right,data.choiceside))=-1;
choiceside(strcmp(none,data.choiceside))=nan;
choiceonset_tr=data.choiceonset_tr;

for i=1:nblk
    resp(i).onset=choiceonset_tr((i-1)*tn+1:i*tn);
    resp(i).onset=resp(i).onset(~isnan(choiceside((i-1)*tn+1:i*tn)));
    resp(i).value=choiceside((i-1)*tn+1:i*tn);
    resp(i).value=resp(i).value(~isnan(choiceside((i-1)*tn+1:i*tn)));
    resp(i).value=resp(i).value-mean(resp(i).value);
    resp(i).dur=zerocon(~isnan(choiceside((i-1)*tn+1:i*tn)));
end
%regressor 5: the reaction time
for i=1:nblk
    RT(i).onset=resp(i).onset;
    RT(i).value=data.RT((i-1)*tn+1:i*tn);
    RT(i).value=RT(i).value(~isnan(choiceside((i-1)*tn+1:i*tn)));
    RT(i).value=RT(i).value-mean(RT(i).value);
    RT(i).dur=resp(i).dur;
end

%regressior 1-4: 
storeswi(2:length(data.choice),1)=data.choice(2:end)-data.choice(1:end-1);
storeswi(storeswi~=0)=1;
storeswi(storeswi==0)=-1;
storeswi(1)=nan; storeswi(tn+1)=nan;storeswi(2*tn+1)=nan;storeswi(3*tn+1)=nan;
storeswi(strcmp(none,data.choiceside))=nan;
winoutlasttrial(2:length(data.choice),1)=data.winchosen(1:end-1);
winoutlasttrial(winoutlasttrial==0)=-1;
%winoutlasttrial(isnan(storeswi))=nan;
lossoutlasttrial(2:length(data.choice),1)=data.losschosen(1:end-1);
%lossoutlasttrial(isnan(storeswi))=nan;
choicedur=data.chosenoptiononset_tr-data.choiceonset_tr;
%%  
for i=1:nblk
    ifswitch(i).onset=choiceonset_tr((i-1)*tn+1:i*tn);
    ifswitch(i).value=storeswi((i-1)*tn+1:i*tn);
    ifswitch(i).dur=choicedur((i-1)*tn+1:i*tn);
    
    %regressor 1: if win received(1 win received -1 not received) in the previous trials x if switch(1 stay -1 switch) in
    %this trial(therefore 1 for win-stay loss switch behavior)
    choice_win_switch(i).onset=ifswitch(i).onset;
    choice_win_switch(i).value=(-ifswitch(i).value).*winoutlasttrial((i-1)*tn+1:i*tn);
    choice_win_switch(i).dur=ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==1|lossoutlasttrial((i-1)*tn+1:i*tn)==0);
    %stay trials
    stay_pos(i).onset=choice_win_switch(i).onset(choice_win_switch(i).value==-1);
    stay_pos(i).dur=choice_win_switch(i).dur(choice_win_switch(i).value==-1);
    stay_pos(i).value=-choice_win_switch(i).value(choice_win_switch(i).value==-1);
    %switch trials
    leftout(i).onset=ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==1&lossoutlasttrial((i-1)*tn+1:i*tn)==0&ifswitch(i).value==1);
    leftout(i).dur=ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==1&lossoutlasttrial((i-1)*tn+1:i*tn)==0&ifswitch(i).value==1);

    
    %regressor 2: switch trials after a negative outcome received
    choice_neg(i).onset=ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==0|lossoutlasttrial((i-1)*tn+1:i*tn)==1);
    choice_neg(i).value=ifswitch(i).value(winoutlasttrial((i-1)*tn+1:i*tn)==0|lossoutlasttrial((i-1)*tn+1:i*tn)==1);
    choice_neg(i).dur=ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==0|lossoutlasttrial((i-1)*tn+1:i*tn)==1);
    
    %switch
    switch_neg(i).onset=choice_neg(i).onset(choice_neg(i).value==1);
    switch_neg(i).dur=choice_neg(i).dur(choice_neg(i).value==1);
    switch_neg(i).value=choice_neg(i).value(choice_neg(i).value==1);
    %stay
    leftout(i).onset=[leftout(i).onset; ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==0&lossoutlasttrial((i-1)*tn+1:i*tn)==1&ifswitch(i).value==-1)];
    leftout(i).dur=[leftout(i).dur;  ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==0&lossoutlasttrial((i-1)*tn+1:i*tn)==1&ifswitch(i).value==-1)];
    

    %regressor 3: trials first tials and trials when participant didn't make a choice 
    leftout(i).onset=[leftout(i).onset;ifswitch(i).onset(isnan(ifswitch(i).value))];
    leftout(i).dur=[leftout(i).dur;ifswitch(i).dur(isnan(ifswitch(i).value))];
    
    leftout(i).value=ones(length(leftout(i).onset),1);
    
    leftoutcount(ss,i)=length(leftout(i).onset);
end

%% @outcome onset
    for i=1:nblk
        outonsets=data.outcomesonset_tr((i-1)*tn+1:i*tn);
        winchosen=data.winchosen((i-1)*tn+1:i*tn);
        losschosen=data.losschosen((i-1)*tn+1:i*tn);
        %regressor 6. win or noloss was received;
        reptpos(i).onset=outonsets(winchosen==1|losschosen==0);
        reptpos(i).value=constant(winchosen==1|losschosen==0);
        reptpos(i).dur=3*constant(winchosen==1|losschosen==0);   
        %regressor 7. nowin or loss was received;
        reptneg(i).onset=outonsets(winchosen==0|losschosen==1);
        reptneg(i).value=constant(winchosen==0|losschosen==1);
        reptneg(i).dur=3*constant(winchosen==0|losschosen==1);         
    end

%% write txt files for each regressor
    mkdir([datadir,'EVfiles/GLM7/',sublist{ss}]);
    for i=1:nblk
        stay_postmp=[stay_pos(i).onset stay_pos(i).dur stay_pos(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/1_stay_trials_after_pos_out_',realblkname{i},'.txt'],'stay_postmp','-ascii');
        
        switch_negtmp=[switch_neg(i).onset switch_neg(i).dur switch_neg(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/2_switch_trials_after_neg_out_',realblkname{i},'.txt'],'switch_negtmp','-ascii');   
        
        leftouttmp=[leftout(i).onset leftout(i).dur leftout(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/3_leftout_trials_',realblkname{i},'.txt'],'leftouttmp','-ascii');     
        
        resptmp=[resp(i).onset resp(i).dur resp(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/4_response_',realblkname{i},'.txt'],'resptmp','-ascii');

        RTtmp=[RT(i).onset RT(i).dur RT(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/5_reactiontime_',realblkname{i},'.txt'],'RTtmp','-ascii');
         
        reptpostmp=[reptpos(i).onset reptpos(i).dur reptpos(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/6_positive_outcomes_',realblkname{i},'.txt'],'reptpostmp','-ascii');
        
        reptnegtmp=[reptneg(i).onset reptneg(i).dur reptneg(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/7_negative_outcomes_',realblkname{i},'.txt'],'reptnegtmp','-ascii');
    end
 
 names_regressor={'stay-pos','switch-neg','leftout-trials','response','RT','out-pos','out-neg'};

 for i=1:nblk
    endtime=data.outcomesonset_tr(i*tn,1);
    tmpR=cal_design_matrix(endtime,stay_pos(i),switch_neg(i),leftout(i),resp(i),RT(i),reptpos(i),reptneg(i));
    R(ss,i,:,:)=tmpR;
    
    f1=figure;
    imagesc(tmpR);
    colorbar;

    title(strrep(realblkname{i},'_',' '));

    set(gca,'Xtick',1:length(names_regressor),'XTickLabel',[ ])
    set(gca,'Ytick',1:length(names_regressor),'YTickLabel',[ ])
    
    for t=1:length(names_regressor)
        text(0,t+1,names_regressor{t});
        text(t-0.4,length(names_regressor),names_regressor{t});
    end
    H=findobj(gca,'Type','text');
    set(H,'Rotation',60); % tilt

    saveas(f1,[datadir,'EVfiles/GLM7/',sublist{ss},'/designmatrix_',realblkname{i},'.png'])
end
end
%% plot maximum corr coef design across participants
RR=R(:,:,:,:);
RR(RR==1)=0;
RRabs=abs(RR);
maxRabs=max(RRabs,[],1);
maxRori=max(RR,[],1);
NegCinx=(maxRabs-maxRori);
maxR=maxRabs;
maxR(NegCinx>0)=-maxR(NegCinx>0);

for i=1:nblk
f2=figure;
tmpR=maxR(:,i,:,:);
tmpR(tmpR==0)=1;
imagesc(squeeze(tmpR));
colorbar;

title(strrep(realblkname{i},'_',' '));

set(gca,'Xtick',1:length(names_regressor),'XTickLabel',[ ])
set(gca,'Ytick',1:length(names_regressor),'YTickLabel',[ ])
for t=1:length(names_regressor)
text(0,t+1,names_regressor{t});
text(t-0.4,length(names_regressor)+1,names_regressor{t});
end
H=findobj(gca,'Type','text');
set(H,'Rotation',60); % tilt

saveas(f2,[datadir,'EVfiles/GLM7/max_designmatrix_',realblkname{i},'.png'])
end