function physio_chop(work_dir,subname,matdir,blktype,ds,hr_lp, resp_lp)
% function to chop up the physiological data from the fmri learning task.

% arguement work_dir specifies where acq file is stored. ds is the
% frequenct in hertz to which the data is downsampled

if ~isdir(work_dir); error('Directory not found'); end

if nargin<5; ds=50; end
if nargin<6; hr_lp=2;end  % 120 bpm
if nargin<7; resp_lp=1;end % 60 rpm

fns= dir([work_dir,subname,'/','*.acq']);
[p f] = fileparts(fns(1).name);
mat_fn = fullfile(matdir, [f '.mat']);
%process  files
mkdir([matdir,'physio/',subname]);
    
    work=load(mat_fn);
    
    col_types={'resp','pulse ox','scanner triggers'};
    %col_found=ones(size(col_types)).*-99;
    physio=[];

    physiods=[];
    
    dropoutmakerinxs=[];
    
    %iterate through the chanels to find relevantdata  
    %the acq2mat code doesn't read the channel name correctly (don't know why) so I manually checked the
    %what the data is for in each channel but this only apply to the
    %2018_fMRI_Dynamic_learning project data ---WanjunLin
    %In 2018_fMRI_Dynamic_learning project, the channel 1 is for resp and
    %channel 2 if for scanner triggers and channel 3 for pulse
%     for j=1:size(work.acq.hdr.per_chan_data,2)
%     
%           if strcmp(work.acq.hdr.per_chan_data(1,j).comment_text,'resp')
%               col_found(1)=j;
%           elseif strcmp(work.acq.hdr.per_chan_data(1,j).comment_text,'scanner triggers')
%               col_found(3)=j;
%           elseif strcmp(work.acq.hdr.per_chan_data(1,j).comment_text,'pulse ox')
%               col_found(2)=j;
%           end
%     end
    
%     if sum(col_found==-99)
%            
%         error('Unable to find data column')
%    
%         
%     end
    
    % put physiological  data together and then downsample if necessary
    % physio data is repsiritory, cardiac and trigger
    physio(:,1)=work.acq.data(:,1);
    physio(:,2)=work.acq.data(:,3);
    physio(:,3)=work.acq.data(:,2);
             
    % this is number of miliseconds per sample (this is 2 in 2018_fMRI_Dynamic_learning project because the sample rate is 500HZ--WanjunLin)
    ms_per_sample=work.acq.hdr.graph.sample_time;
    
    % remove data which occurs before first trigger
    trigger_index=find(physio(:,3)==5);% find each marker position
    trigger_numdiff=trigger_index(2:end,1)-trigger_index(1:end-1,1);
    startinxs=find(trigger_numdiff>791);% s04 (and others) seems to drop a marker in the middle of 1st, 2nd and 3rd block making the gap=791 instead of 391.
    dropoutmakerinxs=find(trigger_numdiff==791);
    
    if dropoutmakerinxs
        save([matdir,'markerdropout/',f,'_','makerdropout'],'dropoutmakerinxs');
    end
        
    if length(startinxs)==4
        blockinx(1,1)=trigger_index(startinxs(1,1)+1,1);
        blockinx(2,1)=trigger_index(startinxs(2,1),1);
        blockinx(1,2)=trigger_index(startinxs(2,1)+1,1);
        blockinx(2,2)=trigger_index(startinxs(3,1),1);
        blockinx(1,3)=trigger_index(startinxs(3,1)+1,1);
        blockinx(2,3)=trigger_index(startinxs(4,1),1);
        blockinx(1,4)=trigger_index(startinxs(4,1)+1,1);
        blockinx(2,4)=trigger_index(end,1);
    elseif length(startinxs)==3
        blockinx(1,1)=trigger_index(1,1);
        blockinx(2,1)=trigger_index(startinxs(1,1),1);
        blockinx(1,2)=trigger_index(startinxs(1,1)+1,1);
        blockinx(2,2)=trigger_index(startinxs(2,1),1);
        blockinx(1,3)=trigger_index(startinxs(2,1)+1,1);
        blockinx(2,4)=trigger_index(startinxs(3,1),1);
        blockinx(1,4)=trigger_index(startinxs(3,1)+1,1);
        blockinx(2,5)=trigger_index(end,1);
    elseif length(startinxs)>4
           error('too much start triggers found');
    else
         error('too less start triggers found');
    end
        
    for b=1:4 %4blocks
        if blockinx(1,b)>500
           blockinx(1,b)=blockinx(1,b)-(500./ms_per_sample);  % NB collect 500ms before the first trigger   ??
        end
        
        blockinx(2,b)=blockinx(2,b)+391; %collect the whole TR(0.8s) after the last trigger maker
        
        if blockinx(2,b)<length(physio)
        physio_block{b}=physio(blockinx(1,b):blockinx(2,b),:);
        else
            physio_block{b}=physio(blockinx(1,b):end,:);
        end
    
    
    
    %downsample to ds Hz
    
    %first trim sample down to the nearest integer multiple of downsampled
    %rate
    nsamps=size(physio_block{b},1);
    new_ms_per_sample=1000./ds;
    conversion_ratio=new_ms_per_sample./ms_per_sample;
    
    if conversion_ratio ~= 1
        nsamps=floor(nsamps./conversion_ratio).*conversion_ratio;

        physio_block{b}=physio_block{b}(1:nsamps,:);


        % then downsample data
            for k=1:size(physio_block{b},2)
                physiods{b}(:,k)=decimate(physio_block{b}(:,k),conversion_ratio);
            end

        else
            physiods{b}=physio_block{b};
    end
    % save the physio file as txt for PNM 
    
    % NB converting the trigger into a logical vector
    % using the following cut offs and low pass filtering the respiratory
    % data seems to help PNM work better

     physiods{b}(:,3)=physiods{b}(:,3)>2;
     tmpinx=[0;physiods{b}(2:end,3)-physiods{b}(1:end-1,3)];
     physiods{b}(tmpinx==0,3)=0;

     
         % filter respiratory data
     [z pfilt k]=butter(1,resp_lp/25,'low');
     [sos g]=zp2sos(z,pfilt,k);
     Hd=dfilt.df2tsos(sos,g);
     physiods{b}(:,1)=filter(Hd,physiods{b}(:,1));
     
      % filter cardiac data
     [z pfilt k]=butter(1,hr_lp/25,'low');
     [sos g]=zp2sos(z,pfilt,k);
     Hd=dfilt.df2tsos(sos,g);
     physiods{b}(:,2)=filter(Hd,physiods{b}(:,2));

    if blktype(b)==1
       tmp=physiods{b}(25:end,:);
       save([matdir,'physio/',subname,'/',f,'_','both_vol_block_physio.txt'],'tmp','-ascii');
    end
    if blktype(b)==2
       tmp=physiods{b}(25:end,:);
       save([matdir,'physio/',subname,'/',f,'_','win_vol_block_physio.txt'],'tmp','-ascii');
    end
    if blktype(b)==3
       tmp=physiods{b}(25:end,:);
       save([matdir,'physio/',subname,'/',f,'_','loss_vol_block_physio.txt'],'tmp','-ascii');
    end
    if blktype(b)==4
       tmp=physiods{b}(25:end,:);
       save([matdir,'physio/',subname,'/',f,'_','both_stable_block_physio.txt'],'tmp','-ascii');
    end

   end
end
    