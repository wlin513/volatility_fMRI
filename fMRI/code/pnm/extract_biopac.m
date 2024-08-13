clear

getfolders

% where the results are kept
dir_name='/Users/wanjunlin/Documents/2018_Dynamic_learning_fMRI_MB/Analysis/fMRI/2018_fMRI_data/';

subs=dir([dir_name,'s26*']);% !!! change this to run a single participant or all participants

% load the details of the subjects
sid=fopen([datadir,'blockorderlist.txt'],'r');

listinfo=textscan(sid,'%s %d %d %d %d');

fclose(sid);

for ss=1:size(subs,1)
    subject_name=subs(ss).name;
    for i=1:size(listinfo{1,1},1)
        if strmatch(listinfo{1,1}(i,1),subject_name,'exact')
            blktype(1)=listinfo{1,2}(i,1);
            blktype(2)=listinfo{1,3}(i,1);
            blktype(3)=listinfo{1,4}(i,1);
            blktype(4)=listinfo{1,5}(i,1);
        end
    end

acq2mat([dir_name,subject_name,'/'],datadir);

physio_chop(dir_name,subject_name,datadir,blktype,50);

blktype

clear blktype
end
