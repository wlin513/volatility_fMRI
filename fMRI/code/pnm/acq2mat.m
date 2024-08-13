%  ACQ2MAT:  This script will automatically convert all ACQ files to MAT
%  files in all specified folders. You can simply let it run overnight.
%  The reason to do so is because it could be very time consuming to load
%  ACQ files, and to load corresponding MAT files will be much quicker.
%
%  i.e. In your MATLAB code,
%	instead of using:  acq = load_acq('MyGSR.acq');
%	you can now use:   load('MyGSR.mat');
%
%  Usage:  Please update the acq_folder list below

function acq2mat(acqdir,matdir)
%acq_folder = [acq_folder {'C:\GSR\1001'}];	% uncomment it if necessary
%acq_folder = [acq_folder {'C:\GSR\1002'}];	% uncomment it if necessary


%%%%%%%  Please specify all ACQ folders above   %%%%%%%


%%%%%%%  Please do not modify any code below   %%%%%%%


   fn_lst = dir([acqdir,'*.acq']);

   for j=1:length(fn_lst)
      acq_fn = fullfile(acqdir, fn_lst(j).name);
      [p f] = fileparts(acq_fn);
      mat_fn = fullfile(matdir, [f '.mat']);

      if ~exist(mat_fn,'file')
         acq = load_acq(acq_fn);

         v7 = version;
         if str2num(v7(1))<7
            save(mat_fn, 'acq');
         else
            save(mat_fn, '-V6', 'acq');
         end
         clear acq
      end
   end

