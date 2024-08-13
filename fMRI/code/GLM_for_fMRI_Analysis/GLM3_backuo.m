        
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

%regressor 5: the response(1 for left; -1 for right; leave out the trial in which the participants didn't respond; then demean)
right={'right'};
right=repmat(right,length(data.choiceside),1);
none={'none'};
none=repmat(none,length(data.choiceside),1);
choiceside=ones(length(data.choiceside),1);
choiceside(strcmp(right,data.choiceside))=-1;
choiceside(strcmp(none,data.choiceside))=nan;
choiceonset_tr=data.choiceonset_tr;
choiceonset_tr(isnan(choiceside))=nan;

for i=1:nblk
    resp(i).onset=choiceonset_tr((i-1)*tn+1:i*tn);
    resp(i).onset=resp(i).onset(~isnan(choiceside((i-1)*tn+1:i*tn)));
    resp(i).value=choiceside((i-1)*tn+1:i*tn);
    resp(i).value=resp(i).value(~isnan(choiceside((i-1)*tn+1:i*tn)));
    resp(i).value=resp(i).value-mean(resp(i).value);
    resp(i).dur=zerocon(~isnan(choiceside((i-1)*tn+1:i*tn)));
end

%regressior 1-4: trial-by-trial decision(1 for switch, -1 for stay conditioned on what was received on the previous trial(leave out the first choice in each block, and those choice not made))
storeswi(2:length(data.choice),1)=data.choice(2:end)-data.choice(1:end-1);
storeswi(storeswi~=0)=1;
storeswi(storeswi==0)=-1;
storeswi(1)=nan; storeswi(tn+1)=nan;storeswi(2*tn+1)=nan;storeswi(3*tn+1)=nan;
storeswi(strcmp(none,data.choiceside))=nan;
winoutlasttrial(2:length(data.choice),1)=data.winchosen(1:end-1);
winoutlasttrial(isnan(storeswi))=nan;
lossoutlasttrial(2:length(data.choice),1)=data.losschosen(1:end-1);
lossoutlasttrial(isnan(storeswi))=nan;

%%  
for i=1:nblk
    ifswitch(i).onset=choiceonset_tr((i-1)*tn+1:i*tn);
    ifswitch(i).value=storeswi((i-1)*tn+1:i*tn);
    ifswitch(i).dur=zerocon;
    %regressor 1: ifswitch on trials when win was received last trial
    ifswitch_win(i).onset=ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==1);
    ifswitch_win(i).value=ifswitch(i).value(winoutlasttrial((i-1)*tn+1:i*tn)==1);
    ifswitch_win(i).dur=ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==1);
        
    %regressor 2: ifswitch on trials when win was not received last trial
    ifswitch_nowin(i).onset=ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==0);
    ifswitch_nowin(i).value=ifswitch(i).value(winoutlasttrial((i-1)*tn+1:i*tn)==0);
    ifswitch_nowin(i).dur=ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==0);
    
    %regressor 3: ifswitch on trials when loss was received last trial
    ifswitch_loss(i).onset=ifswitch(i).onset(lossoutlasttrial((i-1)*tn+1:i*tn)==1);
    ifswitch_loss(i).value=ifswitch(i).value(lossoutlasttrial((i-1)*tn+1:i*tn)==1);
    ifswitch_loss(i).dur=ifswitch(i).dur(lossoutlasttrial((i-1)*tn+1:i*tn)==1);
        
    %regressor 4: ifswitch on trials when loss was not received last trial
    ifswitch_noloss(i).onset=ifswitch(i).onset(lossoutlasttrial((i-1)*tn+1:i*tn)==0);
    ifswitch_noloss(i).value=ifswitch(i).value(lossoutlasttrial((i-1)*tn+1:i*tn)==0);
    ifswitch_noloss(i).dur=ifswitch(i).dur(lossoutlasttrial((i-1)*tn+1:i*tn)==0);
    
    %demean
    ifswitch_win(i).value=ifswitch_win(i).value-mean(ifswitch_win(i).value);
    ifswitch_nowin(i).value=ifswitch_nowin(i).value-mean(ifswitch_nowin(i).value);
    ifswitch_loss(i).value=ifswitch_loss(i).value-mean(ifswitch_loss(i).value);
    ifswitch_noloss(i).value=ifswitch_noloss(i).value-mean(ifswitch_noloss(i).value);
end
%% 


%regressor 6: the reaction time (demean)
for i=1:nblk
    RT(i).onset=resp(i).onset;
    RT(i).value=data.RT((i-1)*tn+1:i*tn);
    RT(i).value=RT(i).value(~isnan(choiceside((i-1)*tn+1:i*tn)));
    RT(i).value=RT(i).value-mean(RT(i).value);
    RT(i).dur=resp(i).dur;
end

%regressor 7: the choice constant
for i=1:nblk
    choice_constant(i).onset=data.choiceonset_tr((i-1)*tn+1:i*tn);
    choice_constant(i).value=constant;
    choice_constant(i).dur=zerocon;
end

%% @outcome onset
    for i=1:nblk
        outonsets=data.outcomesonset_tr((i-1)*tn+1:i*tn);
        winchosen=data.winchosen((i-1)*tn+1:i*tn);
        losschosen=data.losschosen((i-1)*tn+1:i*tn);
        %regressor 8. win received;
        reptWin(i).onset=outonsets(winchosen==1);
        reptWin(i).value=constant(winchosen==1);
        reptWin(i).dur=3/TR*constant(winchosen==1);
        %regressor 9. win not-received;
        reptNowin(i).onset=outonsets(winchosen==0);
        reptNowin(i).value=constant(winchosen==0);
        reptNowin(i).dur=3/TR*constant(winchosen==0);
        %regressor 10. loss received;
        reptLoss(i).onset=outonsets(losschosen==1);
        reptLoss(i).value=constant(losschosen==1);
        reptLoss(i).dur=3/TR*constant(losschosen==1);       
        %regressor 11. loss not-received;
        reptNoloss(i).onset=outonsets(losschosen==0);
        reptNoloss(i).value=constant(losschosen==0);
        reptNoloss(i).dur=3/TR*constant(losschosen==0);       

        clear outonsets winchosen losschosen
    end

%% write txt files for each regressor
    mkdir([datadir,'EVfiles/GLM3/',sublist{ss}]);
    for i=1:nblk
        ifswitch_wintmp=[ifswitch_win(i).onset ifswitch_win(i).dur ifswitch_win(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/1_ifswitch_win_',realblkname{i},'.txt'],'ifswitch_wintmp','-ascii');
        
        ifswitch_nowintmp=[ifswitch_nowin(i).onset ifswitch_nowin(i).dur ifswitch_nowin(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/2_ifswitch_nowin_',realblkname{i},'.txt'],'ifswitch_nowintmp','-ascii');      
 
        ifswitch_losstmp=[ifswitch_loss(i).onset ifswitch_loss(i).dur ifswitch_loss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/3_ifswitch_loss_',realblkname{i},'.txt'],'ifswitch_losstmp','-ascii');
        
        ifswitch_nolosstmp=[ifswitch_noloss(i).onset ifswitch_noloss(i).dur ifswitch_noloss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/4_ifswitch_noloss_',realblkname{i},'.txt'],'ifswitch_nolosstmp','-ascii'); 
        
        resptmp=[resp(i).onset resp(i).dur resp(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/5_response_',realblkname{i},'.txt'],'resptmp','-ascii');

        RTtmp=[RT(i).onset RT(i).dur RT(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/6_reactiontime_',realblkname{i},'.txt'],'RTtmp','-ascii');
        
        ch_consttmp=[choice_constant(i).onset choice_constant(i).dur choice_constant(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/7_choice_mean_',realblkname{i},'.txt'],'ch_consttmp','-ascii');
        
        reptWintmp=[reptWin(i).onset reptWin(i).dur reptWin(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/8_winout_',realblkname{i},'.txt'],'reptWintmp','-ascii');
        
        reptNowintmp=[reptNowin(i).onset reptNowin(i).dur reptNowin(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/9_nowinout_',realblkname{i},'.txt'],'reptNowintmp','-ascii');
        
        reptLosstmp=[reptLoss(i).onset reptLoss(i).dur reptLoss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/10_lossout_',realblkname{i},'.txt'],'reptLosstmp','-ascii');
        
        reptNolosstmp=[reptNoloss(i).onset reptNoloss(i).dur reptNoloss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/11_nolossout_',realblkname{i},'.txt'],'reptNolosstmp','-ascii');
    end
 
 names_regressor={'switch_win','switch_nowin','switch_loss','switch_noloss','response','RT','choice mean',...
     'win_received','nowin_received','loss_received','noloss_received'};
 for i=1:nblk
     endtime=data.outcomesonset_tr(i*tn,1);
     tmpR=cal_design_matrix(endtime,ifswitch_win(i),ifswitch_nowin(i),ifswitch_loss(i),ifswitch_noloss(i),resp(i),RT(i),choice_constant(i),reptWin(i),reptNowin(i),reptLoss(i),reptNoloss(i));
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

    saveas(f1,[datadir,'EVfiles/GLM3/',sublist{ss},'/designmatrix_',realblkname{i},'.png'])
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

saveas(f2,[datadir,'EVfiles/GLM3/max_designmatrix_',realblkname{i},'.png'])
end