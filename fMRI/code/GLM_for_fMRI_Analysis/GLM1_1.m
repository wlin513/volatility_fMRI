%%not complete yet (please add EV for mean outcome and mean choice)

%% load the subject data
clear;
clc;

cd('/Users/wanjunlin/Documents/2018_Dynamic_learning_fMRI_MB/Analysis/fMRI/fMRI/code/GLM_for_fMRI_Analysis');
getfolders;
behdatadir='/Users/wanjunlin/Documents/2018_Dynamic_learning_fMRI_MB/Analysis/fMRI/2018_fMRI_data/';

sublist={'s01','s02','s03','s04','s05','s06','s07','s08','s09','s10','s11','s12','s13','s14','s15','s16','s17','s18','s19','s20','s21','s22','s23','s24'};

nblk=4;
tn=80;

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
    for i=1:nblk
    realblkname(i)=blkname(blockorders(blktype,i));
    end
    %calculate the choice present duration(the rule is if the participant responds within 1s the choice will be presentted for 1s, if they don't
    %response within 5s, a ramdom choice will be made for them, RT for this trial will nan)
%     choicedur=ones(length(data.trialnum),1);end
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

%regressor 4: the choice constant
for i=1:nblk
    choice_constant(i).onset=resp(i).onset;
    choice_constant(i).value=constant;
    choice_constant(i).dur=resp(i).dur;
end

%% @outcome onset
    for i=1:nblk
        %regressor 4. win outcomes (1 for win received, -1 for win not-received, then demean)
        winchosen=data.winchosen((i-1)*tn+1:i*tn);
        winchosen(winchosen==0)=-1;
        reptWin(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn);
        reptWin(i).value=winchosen-mean(winchosen);
        reptWin(i).dur=zerocon;
        %regressor 5. loss outcomes (1 for loss received, -1 for loss not-received, then demean)
        losschosen=data.losschosen((i-1)*tn+1:i*tn);
        losschosen(losschosen==0)=-1;
        reptLoss(i).onset=data.outcomesonset_tr((i-1)*tn+1:i*tn);
        reptLoss(i).value=losschosen-mean(losschosen);
        reptLoss(i).dur=zerocon;

        clear winchosen losschosen
    end

%% write txt files for each regressor
    mkdir([datadir,'EVfiles/GLM1/',sublist{ss}]);
    for i=1:nblk
        resptmp=[resp(i).onset resp(i).dur resp(i).value];
        save([datadir,'EVfiles/GLM1_1/',sublist{ss},'/1_response_',realblkname{i},'.txt'],'resptmp','-ascii');

        RTtmp=[RT(i).onset RT(i).dur RT(i).value];
        save([datadir,'EVfiles/GLM1_1/',sublist{ss},'/2_reactiontime_',realblkname{i},'.txt'],'RTtmp','-ascii');
        
        ifswitchtmp=[ifswitch(i).onset ifswitch(i).dur ifswitch(i).value];
        save([datadir,'EVfiles/GLM1_1/',sublist{ss},'/3_ifswitch_',realblkname{i},'.txt'],'ifswitchtmp','-ascii');
        
        reptWintmp=[reptWin(i).onset reptWin(i).dur reptWin(i).value];
        save([datadir,'EVfiles/GLM1_1/',sublist{ss},'/4_winoutcomes_',realblkname{i},'.txt'],'reptWintmp','-ascii');

        reptLosstmp=[reptLoss(i).onset reptLoss(i).dur reptLoss(i).value];
        save([datadir,'EVfiles/GLM1_1/',sublist{ss},'/5_lossoutcomes_',realblkname{i},'.txt'],'reptLosstmp','-ascii');
    end
end