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
start=[0.5,0.5];
abandontn=10;
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
 %  read data 
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
    
    resp_made=(strcmp(data.choiceside,'left')|strcmp(data.choiceside,'right'));
    
    for i=1:nblk
        realblkname(i)=blkname(blockorders(blktype,i));
        % calculate timing for Eexpected Value for chosen option at choice and absolute Prediction Error(surprise) for chosen option at outcome
        % get the model result
        % 2alpha2beta
        
        resp_made_blk(:,i)=resp_made(((i-1)*tn+1):i*tn);
        information=[data.winpos(((i-1)*tn+1):i*tn),data.losspos(((i-1)*tn+1):i*tn)];
        choice=data.choice(((i-1)*tn+1):i*tn);
        result_2lr_2b=fit_linked_2lr_2beta_il_rev(information,choice, start, abandontn,resp_made_blk(:,i));
        bel=rescorla_wagner_2lr(information,[result_2lr_2b.mean_alpha_rew result_2lr_2b.mean_alpha_loss],start);
        
        
        evch=bel(:,1)-bel(:,2);
        evch(choice==0)=-evch(choice==0);
        EVchosen(i).value=evch-mean(evch);
        EVchosen(i).onset=data.choiceonset_tr((i-1)*tn+1:i*tn);
        EVchosen(i).dur=zerocon;
        
            
        ch_const(i).onset=EVchosen(i).onset;
        ch_const(i).value=constant;
        ch_const(i).dur=zerocon;
        
        pech=data.winchosen((i-1)*tn+1:i*tn)-data.losschosen((i-1)*tn+1:i*tn)-evch;
        Surp(i).value=abs(pech)-mean(abs(pech));
        Surp(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn);
        Surp(i).dur=zerocon;
        
        out_const(i).onset=Surp(i).onset;
        out_const(i).value=constant;
        out_const(i).dur=zerocon;
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
%regressor 1: the response(1 for left; -1 for right; leave out the trial in which the participants didn't respond; then demean)
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
%regressor 2: the reaction time (demean)
for i=1:nblk
    RT(i).onset=resp(i).onset;
    RT(i).value=data.RT((i-1)*tn+1:i*tn);
    RT(i).value=RT(i).value(~isnan(choiceside((i-1)*tn+1:i*tn)));
    RT(i).value=RT(i).value-mean(RT(i).value);
    RT(i).dur=resp(i).dur;
    
end

%regressior 3: trial-by-trial decision(1 for switch, -1 for stay (leave out the first choice in each block, and those choice not made))
storeswi=ones(length(data.choice),1);
storeswi(2:end,1)=data.choice(2:end)-data.choice(1:end-1);
storeswi(storeswi~=0)=1;
storeswi(storeswi==0)=-1;
storeswi(1)=nan; storeswi(tn+1)=nan;storeswi(2*tn+1)=nan;storeswi(3*tn+1)=nan;
storeswi(strcmp(none,data.choiceside))=nan;

for i=1:nblk
    ifswitch(i).onset=choiceonset_tr((i-1)*tn+1:i*tn);
    ifswitch(i).value=storeswi((i-1)*tn+1:i*tn);
    ifswitch(i).dur=zerocon;
    
    %delete NaNs
    ifswitch(i).onset=ifswitch(i).onset(~isnan(ifswitch(i).value));
    ifswitch(i).dur=ifswitch(i).dur(~isnan(ifswitch(i).value));
    ifswitch(i).value=ifswitch(i).value(~isnan(ifswitch(i).value));
    
    %demean
    ifswitch(i).value=ifswitch(i).value-mean(ifswitch(i).value);
   
end
%% write txt files for each regressor
mkdir([datadir,'EVfiles/GLM2/',sublist{ss}]);
    for i=1:nblk
        resptmp=[resp(i).onset resp(i).dur resp(i).value];
        save([datadir,'EVfiles/GLM2/',sublist{ss},'/1_response_',realblkname{i},'.txt'],'resptmp','-ascii');

        RTtmp=[RT(i).onset RT(i).dur RT(i).value];
        save([datadir,'EVfiles/GLM2/',sublist{ss},'/2_reactiontime_',realblkname{i},'.txt'],'RTtmp','-ascii');
        
        ifswitchtmp=[ifswitch(i).onset ifswitch(i).dur ifswitch(i).value];
        save([datadir,'EVfiles/GLM2/',sublist{ss},'/3_ifswitch_',realblkname{i},'.txt'],'ifswitchtmp','-ascii');

        evchosentmp=[EVchosen(i).onset EVchosen(i).dur EVchosen(i).value];
        save([datadir,'EVfiles/GLM2/',sublist{ss},'/4_evchosen_',realblkname{i},'.txt'],'evchosentmp','-ascii');
        
        ch_consttmp=[ch_const(i).onset ch_const(i).dur ch_const(i).value];
        save([datadir,'EVfiles/GLM2/',sublist{ss},'/5_ch_const_',realblkname{i},'.txt'],'ch_consttmp','-ascii');
        
        Surptmp=[Surp(i).onset Surp(i).dur Surp(i).value];
        save([datadir,'EVfiles/GLM2/',sublist{ss},'/6_surprise_',realblkname{i},'.txt'],'Surptmp','-ascii');

        out_consttmp=[out_const(i).onset out_const(i).dur out_const(i).value];
        save([datadir,'EVfiles/GLM2/',sublist{ss},'/7_out_const_',realblkname{i},'.txt'],'out_consttmp','-ascii');        
    end
%% Make the hrf and plot the corr matrix
names_regressor={'Response','Reaction time','Switch','EV chosen','Choice constant','Surprise','Outcome constant'};
 for i=1:nblk
     endtime=data.outcomesonset_tr(i*tn,1);
     tmpR=cal_design_matrix(endtime,resp(i),RT(i),ifswitch(i),EVchosen(i),ch_const(i),Surp(i),out_const(i));
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

    saveas(f1,[datadir,'EVfiles/GLM2/',sublist{ss},'/designmatrix_',realblkname{i},'.png'])
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

set(gca,'Xtick',1:7,'XTickLabel',[ ])
set(gca,'Ytick',1:7,'YTickLabel',[ ])

for t=1:length(names_regressor)
text(0,t+1,names_regressor{t});
text(t-0.4,length(names_regressor)+1,names_regressor{t});
end
H=findobj(gca,'Type','text');
set(H,'Rotation',60); % tilt

saveas(f2,[datadir,'EVfiles/GLM2/max_designmatrix_',blkname{i},'.png'])
end
