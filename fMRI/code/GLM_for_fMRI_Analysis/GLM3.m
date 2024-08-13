        
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

for i=1:nblk
    resp(i).onset=choiceonset_tr((i-1)*tn+1:i*tn);
    resp(i).onset=resp(i).onset(~isnan(choiceside((i-1)*tn+1:i*tn)));
    resp(i).value=choiceside((i-1)*tn+1:i*tn);
    resp(i).value=resp(i).value(~isnan(choiceside((i-1)*tn+1:i*tn)));
    resp(i).value=resp(i).value-mean(resp(i).value);
    resp(i).dur=zerocon(~isnan(choiceside((i-1)*tn+1:i*tn)));
end
%regressor 6: the reaction time
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
winoutlasttrial(isnan(storeswi))=nan;
lossoutlasttrial(2:length(data.choice),1)=data.losschosen(1:end-1);
lossoutlasttrial(isnan(storeswi))=nan;
choicedur=data.chosenoptiononset_tr-data.choiceonset_tr;
%%  
for i=1:nblk
    ifswitch(i).onset=choiceonset_tr((i-1)*tn+1:i*tn);
    ifswitch(i).value=storeswi((i-1)*tn+1:i*tn);
    ifswitch(i).dur=choicedur((i-1)*tn+1:i*tn);
    %regressor 1: choice after win and noloss outcome
    choice_win_noloss(i).onset=ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==1&lossoutlasttrial((i-1)*tn+1:i*tn)==0);
    choice_win_noloss(i).value=ones(length(choice_win_noloss(i).onset),1);
    choice_win_noloss(i).dur=ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==1&lossoutlasttrial((i-1)*tn+1:i*tn)==0);
        
    %regressor 2: choice after win and loss outcome
    choice_win_loss(i).onset=ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==1&lossoutlasttrial((i-1)*tn+1:i*tn)==1);
    choice_win_loss(i).value=ones(length(choice_win_loss(i).onset),1);
    choice_win_loss(i).dur=ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==1&lossoutlasttrial((i-1)*tn+1:i*tn)==1);
    
    %regressor 3: choice after nowin and noloss outcome
    choice_nowin_noloss(i).onset=ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==0&lossoutlasttrial((i-1)*tn+1:i*tn)==0);
    choice_nowin_noloss(i).value=ones(length(choice_nowin_noloss(i).onset),1);
    choice_nowin_noloss(i).dur=ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==0&lossoutlasttrial((i-1)*tn+1:i*tn)==0);
        
    %regressor 4: choice after nowin and loss outcome
    choice_nowin_loss(i).onset=ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==0&lossoutlasttrial((i-1)*tn+1:i*tn)==1);
    choice_nowin_loss(i).value=ones(length(choice_nowin_loss(i).onset),1);
    choice_nowin_loss(i).dur=ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==0&lossoutlasttrial((i-1)*tn+1:i*tn)==1);

%regressor 7: choice for the first trial of each block

    nan_choices(i).onset=ifswitch(i).onset(isnan(winoutlasttrial((i-1)*tn+1:i*tn))&isnan(lossoutlasttrial((i-1)*tn+1:i*tn)));
    nan_choices(i).value=ones(length(nan_choices(i).onset),1);
    nan_choices(i).dur=ifswitch(i).dur(isnan(winoutlasttrial((i-1)*tn+1:i*tn))&isnan(lossoutlasttrial((i-1)*tn+1:i*tn)));
end

%% @outcome onset
    for i=1:nblk
        outonsets=data.outcomesonset_tr((i-1)*tn+1:i*tn);
        winchosen=data.winchosen((i-1)*tn+1:i*tn);
        losschosen=data.losschosen((i-1)*tn+1:i*tn);
        %regressor 8. win & noloss was received;
        reptWinNoloss(i).onset=outonsets(winchosen==1&losschosen==0);
        reptWinNoloss(i).value=constant(winchosen==1&losschosen==0);
        reptWinNoloss(i).dur=3*constant(winchosen==1&losschosen==0);
        %regressor 9. win & loss was received;
        reptWinLoss(i).onset=outonsets(winchosen==1&losschosen==1);
        reptWinLoss(i).value=constant(winchosen==1&losschosen==1);
        reptWinLoss(i).dur=3*constant(winchosen==1&losschosen==1);
        %regressor 10. no win & no loss received;
        reptNowinNoloss(i).onset=outonsets(winchosen==0&losschosen==0);
        reptNowinNoloss(i).value=constant(winchosen==0&losschosen==0);
        reptNowinNoloss(i).dur=3*constant(winchosen==0&losschosen==0);   
        %regressor 11. no win & loss was received;
        reptNowinLoss(i).onset=outonsets(winchosen==0&losschosen==1);  
        reptNowinLoss(i).value=constant(winchosen==0&losschosen==1);  
        reptNowinLoss(i).dur=3*constant(winchosen==0&losschosen==1);       

    end

%% write txt files for each regressor
    mkdir([datadir,'EVfiles/GLM3/',sublist{ss}]);
    for i=1:nblk
        choice_win_nolosstmp=[choice_win_noloss(i).onset choice_win_noloss(i).dur choice_win_noloss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/1_choice_win_noloss_',realblkname{i},'.txt'],'choice_win_nolosstmp','-ascii');
        
        choice_win_losstmp=[choice_win_loss(i).onset choice_win_loss(i).dur choice_win_loss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/2_choice_win_loss_',realblkname{i},'.txt'],'choice_win_losstmp','-ascii');      
 
        choice_nowin_nolosstmp=[choice_nowin_noloss(i).onset choice_nowin_noloss(i).dur choice_nowin_noloss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/3_choice_nowin_noloss_',realblkname{i},'.txt'],'choice_nowin_nolosstmp','-ascii');
        
        choice_nowin_losstmp=[choice_nowin_loss(i).onset choice_nowin_loss(i).dur choice_nowin_loss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/4_choice_nowin_loss_',realblkname{i},'.txt'],'choice_nowin_losstmp','-ascii'); 
        
        resptmp=[resp(i).onset resp(i).dur resp(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/5_response_',realblkname{i},'.txt'],'resptmp','-ascii');

        RTtmp=[RT(i).onset RT(i).dur RT(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/6_reactiontime_',realblkname{i},'.txt'],'RTtmp','-ascii');
        
        nan_choicestmp=[nan_choices(i).onset nan_choices(i).dur nan_choices(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/7_nan_choices_',realblkname{i},'.txt'],'nan_choicestmp','-ascii');
        
        reptWinNolosstmp=[reptWinNoloss(i).onset reptWinNoloss(i).dur reptWinNoloss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/8_out_win_noloss_',realblkname{i},'.txt'],'reptWinNolosstmp','-ascii');
        
        reptWinLosstmp=[reptWinLoss(i).onset reptWinLoss(i).dur reptWinLoss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/9_out_win_loss_',realblkname{i},'.txt'],'reptWinLosstmp','-ascii');
        
        reptNowinNolosstmp=[reptNowinNoloss(i).onset reptNowinNoloss(i).dur reptNowinNoloss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/10_out_nowin_noloss_',realblkname{i},'.txt'],'reptNowinNolosstmp','-ascii');
        
        reptNowinLosstmp=[reptNowinLoss(i).onset reptNowinLoss(i).dur reptNowinLoss(i).value];
        save([datadir,'EVfiles/GLM3/',sublist{ss},'/11_out_nowin_loss_',realblkname{i},'.txt'],'reptNowinLosstmp','-ascii');
    end
 
 names_regressor={'choice-win&noloss','choice-win&loss','choice-nowin&noloss','choice-nowin&loss','response','RT','nan_choices',...
     'out-win-noloss','out-win-loss','out-nowin-noloss','out-nowin-loss'};
 for i=1:nblk
    endtime=data.outcomesonset_tr(i*tn,1);
    tmpR=cal_design_matrix(endtime,choice_win_noloss(i),choice_win_loss(i),choice_nowin_noloss(i),choice_nowin_loss(i),resp(i),RT(i),nan_choices(i),reptWinNoloss(i),reptWinLoss(i),reptNowinNoloss(i),reptNowinLoss(i));
    R(ss,blockorders(blktype,i),:,:)=tmpR;
    
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

title(strrep(blkname{i},'_',' '));

set(gca,'Xtick',1:length(names_regressor),'XTickLabel',[ ])
set(gca,'Ytick',1:length(names_regressor),'YTickLabel',[ ])
for t=1:length(names_regressor)
text(0,t+1,names_regressor{t});
text(t-0.4,length(names_regressor)+1,names_regressor{t});
end
H=findobj(gca,'Type','text');
set(H,'Rotation',60); % tilt

saveas(f2,[datadir,'EVfiles/GLM3/max_designmatrix_',blkname{i},'.png'])
end