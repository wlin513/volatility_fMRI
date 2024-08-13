cd('/Users/wanjunlin/Documents/2018_Dynamic_learning_fMRI_MB/Analysis/fMRI/fMRI/code');
getfolders;

blockorders1=[1,2,3,4; 1,3,2,4;4,2,3,1;4,3,2,1;2,1,4,3;2,4,1,3;3,1,4,2;3,4,1,2];%blockorder for the not reversed version
blockorders2=[1,3,2,4; 1,2,3,4;4,3,2,1;4,2,3,1;3,1,4,2;3,4,1,2;2,1,4,3;2,4,1,3];%blockorder for the reversed version

fileID = fopen([datadir,'blockorderlist.txt'],'w');

for s=1:64 % for every participants

    if mod(ceil(s/8),2)==1
        blockorders=blockorders1;
        else
            if mod(ceil(s/8),2)==0
                blockorders=blockorders2;
            end
    end

    i=mod(s,8);
    if i==0
        i=8;
    end
    blockorder=blockorders(i,:); 

    fprintf(fileID,'s');fprintf(fileID,'%02d',s);fprintf(fileID,'% d',blockorder);fprintf(fileID,'\n');
    
    clear blockorder
end
fclose(fileID);