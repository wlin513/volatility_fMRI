        
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

%regressor 3: the response(1 for left; -1 for right; leave out the trial in which the participants didn't respond; then demean)
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

%regressior 1-4: 
storeswi(2:length(data.choice),1)=data.choice(2:end)-data.choice(1:end-1);
storeswi(storeswi~=0)=1;
storeswi(storeswi==0)=-1;
storeswi(1)=nan; storeswi(tn+1)=nan;storeswi(2*tn+1)=nan;storeswi(3*tn+1)=nan;
storeswi(strcmp(none,data.choiceside))=nan;
winoutlasttrial(2:length(data.choice),1)=data.winchosen(1:end-1);
winoutlasttrial(winoutlasttrial==0)=-1;
winoutlasttrial(1)=nan; winoutlasttrial(tn+1)=nan;winoutlasttrial(2*tn+1)=nan;winoutlasttrial(3*tn+1)=nan;
lossoutlasttrial(2:length(data.choice),1)=data.losschosen(1:end-1);
lossoutlasttrial(lossoutlasttrial==0)=-1;
lossoutlasttrial(1)=nan; lossoutlasttrial(tn+1)=nan;lossoutlasttrial(2*tn+1)=nan;lossoutlasttrial(3*tn+1)=nan;
choicedur=data.chosenoptiononset_tr-data.choiceonset_tr;
%%  
for i=1:nblk%     %stay
%     leftout(i).onset=[leftout(i).onset; ifswitch(i).onset(winoutlasttrial((i-1)*tn+1:i*tn)==0&lossoutlasttrial((i-1)*tn+1:i*tn)==1&ifswitch(i).value==-1)];
%     leftout(i).dur=[leftout(i).dur;  ifswitch(i).dur(winoutlasttrial((i-1)*tn+1:i*tn)==0&lossoutlasttrial((i-1)*tn+1:i*tn)==1&ifswitch(i).value==-1)];
%     
% 
%     %regressor 3: trials first tials and trials when participant didn't make a choice 
%     leftout(i).onset=[leftout(i).onset;ifswitch(i).onset(isnan(ifswitch(i).value))];
%     leftout(i).dur=[leftout(i).dur;ifswitch(i).dur(isnan(ifswitch(i).value))];
%     
%     leftout(i).value=ones(length(leftout(i).onset),1);
%     
%     leftoutcount(ss,i)=length(leftout(i).onset);

    ifswitch(i).onset=choiceonset_tr((i-1)*tn+1:i*tn);
    ifswitch(i).value=storeswi((i-1)*tn+1:i*tn);
    ifswitch(i).dur=choicedur((i-1)*tn+1:i*tn);
    
    %regressor 1: if receiving a win in the previous trial(win=1,nowin=-1,first trial=0)
    choice_ifwin(i).value=winoutlasttrial((i-1)*tn+1:i*tn);
    choice_ifwin(i).onset=ifswitch(i).onset;
    choice_ifwin(i).dur=ifswitch(i).dur;
    choice_ifwin(i).value(isnan(choice_ifwin(i).value))=nanmean(choice_ifwin(i).value);
    choice_ifwin(i).value=choice_ifwin(i).value-mean(choice_ifwin(i).value);
    
    %regressor 2: if receiving a loss in the previous trail(noloss=1,loss=-1)
    choice_ifloss(i).value=-lossoutlasttrial((i-1)*tn+1:i*tn);
    choice_ifloss(i).onset=ifswitch(i).onset;
    choice_ifloss(i).dur=ifswitch(i).dur;
    choice_ifloss(i).value(isnan(choice_ifloss(i).value))=nanmean(choice_ifloss(i).value);
    choice_ifloss(i).value=choice_ifloss(i).value-mean(choice_ifloss(i).value);
    
    %regressor 5: choice mean
    ch_const(i).onset=ifswitch(i).onset;
    ch_const(i).value=constant;
    ch_const(i).dur=ifswitch(i).dur;

end

%% @outcome onset
    for i=1:nblk
        outonsets=data.outcomesonset_tr((i-1)*tn+1:i*tn);
        winchosen=data.winchosen((i-1)*tn+1:i*tn);
        losschosen=data.losschosen((i-1)*tn+1:i*tn);
        %regressor 6. overall value
        %received(win+noloss=1,win+loss=0,nowin+noloss=0,nowin+loss=-1);
        reptvalue(i).onset=outonsets;
        reptvalue(i).value=winchosen-losschosen;
        reptvalue(i).dur=3*constant;   
        reptvalue(i).value=reptvalue(i).value-mean(reptvalue(i).value);
        %regressor 7: outcome mean
        out_const(i).onset=outonsets;
        out_const(i).value=constant;
        out_const(i).dur=3*constant;
    end

%% write txt files for each regressor
    mkdir([datadir,'EVfiles/GLM7/',sublist{ss}]);
    for i=1:nblk
        choice_ifwintmp=[choice_ifwin(i).onset choice_ifwin(i).dur choice_ifwin(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/1_choice_ifwin_',realblkname{i},'.txt'],'choice_ifwintmp','-ascii');
        
        choice_iflosstmp=[choice_ifloss(i).onset choice_ifloss(i).dur choice_ifloss(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/2_choice_ifloss_',realblkname{i},'.txt'],'choice_iflosstmp','-ascii');   
        
        resptmp=[resp(i).onset resp(i).dur resp(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/3_response_',realblkname{i},'.txt'],'resptmp','-ascii');

        ch_consttmp=[ch_const(i).onset ch_const(i).dur ch_const(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/4_choice_mean_',realblkname{i},'.txt'],'ch_consttmp','-ascii');
         
        reptvaluetmp=[reptvalue(i).onset reptvalue(i).dur reptvalue(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/5_chosen_value_',realblkname{i},'.txt'],'reptvaluetmp','-ascii');
        
        out_consttmp=[out_const(i).onset out_const(i).dur out_const(i).value];
        save([datadir,'EVfiles/GLM7/',sublist{ss},'/6_outcome_mean_',realblkname{i},'.txt'],'out_consttmp','-ascii');
    end
 
 names_regressor={'choice-ifwin','choice-ifloss','response','choice-mean','out-value','out-mean'};

 for i=1:nblk
    endtime=data.outcomesonset_tr(i*tn,1);
    tmpR=cal_design_matrix(endtime,choice_ifwin(i),choice_ifloss(i),resp(i),ch_const(i),reptvalue(i),out_const(i));
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

title(strrep(blkname{i},'_',' '));

set(gca,'Xtick',1:length(names_regressor),'XTickLabel',[ ])
set(gca,'Ytick',1:length(names_regressor),'YTickLabel',[ ])
for t=1:length(names_regressor)
text(0,t+1,names_regressor{t});
text(t-0.4,length(names_regressor)+1,names_regressor{t});
end
H=findobj(gca,'Type','text');
set(H,'Rotation',60); % tilt

saveas(f2,[datadir,'EVfiles/GLM7/max_designmatrix_',blkname{i},'.png'])

end
% %%
% clc
% aaa=squeeze(maxR(1,4,:,:));
% aaa