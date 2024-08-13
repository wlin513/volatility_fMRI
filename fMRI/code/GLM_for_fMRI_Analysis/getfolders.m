% execute when pwd is the code folder, output the data directory(datadir)
% and the figure directory(figdir), for a folder structure of {pwd/data},{pwd/code},{pwd/tmp_fig}; 
codedir=pwd;
datadir = [extractBefore(codedir,'code'),'data/'];
figdir =  [extractBefore(codedir,'code'),'tmp_fig/'];

