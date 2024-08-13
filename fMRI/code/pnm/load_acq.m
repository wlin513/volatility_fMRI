%LOAD_ACQ  load BIOPAC's AcqKnowledge file format for Windows PC
%
%  Usage: acq = load_acq(filename, [force_chan_by_chan_load])
%
%  acq - AcqKnowledge file structure containing ACQ header field, 
%	and data matrix.
%
%  filename - BIOPAC's AcqKnowledge file
%
%  force_chan_by_chan_load - Optional. By default, this optional flag will
%	be set to 1, which means that when you use acq = load_acq(fname),
%	the data will be loaded one channel after the other. This can
%	avoid memory crash when you load very large ACQ data. If your
%	ACQ data is not huge, I suggest that you set this optional flag to
%	0, i.e. acq = load_acq(fname, 0). In this case, the program will
%	read data depending on the data type. If the program detects that
%	the data type in ACQ file are different from channel to channel,
%	it will still read data channel by channel. Otherwise, it will
%	read whole data in one block (a lot faster than using traditional
%	way from channel to channel with the same result).
%
%  Notes:
%
%  This program is based on Application Note #156 from BIOPAC web site:
%  http://www.biopac.com/ResearchNotes.asp?Aid=&ANid=82&Level=4
%  ( 156 - ACQKNOWLEDGE FILE FORMATS FOR PC WITH WINDOWS )
%
%  The note mentioned that: "This document describes file formatting for
%  all Windows versions of AcqKnowledge 3.9.x or below". Thanks to the 
%  open Python source code provided by Nathan Vack, this program can also
%  read AcqKnowledge 4.0 & 4.1 data (with no documentation from BIOPAC).
%  Compressed data is not supported by this program.
%
%  Created on 5-APR-2007 by Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
%  Modify on 31-JUL-2007 by Julio Cruz (julio.cruz@juliocruz.info) to
%	make the program also work on MAC OS.
%
%  Modify on 01-MAY-2008 by Antonio Molins (amolins@mit.edu) to
%	make the program work with files recorded in Biopac student data 
%	acquisition system. Changes include:
%	- added reading of markers, with "markers" field included in 
%	returned structure..
%	- proper handling of foreign data (was not getting quite there with
%	the code (as it was downloaded from MathWorks).
%	- proper handling of var_sampling_rate = 0, as produced by the
%	Biopac software in occasions.
%
function acq = load_acq(filename, chan_by_chan)

   if ~exist('chan_by_chan','var')
      chan_by_chan = 1;
   end

   if ~exist('filename','var')
      error('Usage: acq = load_acq(filename)');
   end

   if ~exist(filename,'file')
      error([filename, ': Can''t open file']);
   end

   fid = fopen(filename,'r', 'l');

   if fid < 0
      msg = sprintf('Cannot open file %s.',filename);
      error(msg);
   end

   fread(fid, 1, 'int16')';
   file_version = fread(fid, 1, 'int32')';

   %  try different endian
   %
   if file_version < 0 | file_version > 200
      fclose(fid);
      fid = fopen(filename,'r', 'b');

      fread(fid, 1, 'int16')';
      file_version = fread(fid, 1, 'int32')';
      fseek(fid, 0, 'bof');

      if file_version < 0 | file_version > 200
         error('This ACQ file is not supported');
      end
   end

   fprintf('Loading %s ', filename);

   %  read header
   %
   acq.hdr = read_acq_hdr(fid);

   %  read data
   %
   acq.data = read_acq(fid, acq.hdr, chan_by_chan);

   %  read markers written by AM (Antonio Molins) for ACQ 3
   %
   if file_version < 68
      acq.markers = read_markers(fid, acq.hdr, size(acq.data));
   end

   fclose(fid);

   fprintf(' Done!\n');

   return;					% load_acq


%---------------------------------------------------------------------

