 function info = read_markers(fid, hdr, data_size)
     
     % AM foolproof way of getting to the markers: see where data starts and
     % add the size of the data..
     
     start_real_chan = hdr.graph.ext_item_header_len;

     for i = 1:hdr.graph.num_channels
         start_real_chan = start_real_chan + hdr.per_chan_data(i).chan_header_len;

         if hdr.per_chan_type(i).type ~= 1			% if integer
             hdr.per_chan_type(i).size = 2;			% only use int16
         end
     end

     start_real_chan = start_real_chan + hdr.foreign.length2 + 4*hdr.graph.num_channels;

     size_channel_data = sum([hdr.per_chan_type.size])*data_size(1);
     start_markers = start_real_chan + size_channel_data;

     % AM place the file position in the position where data ends
     fseek(fid,start_markers,'bof');

     % AM then follow specifications; borrowed from code of the
     % non-functioning (at least for me) ACQREAD,
     %    ACQREAD, version 2.0 (2007-08-21)
     %    Copyright (C) 2006-2007  Sebastien Authier and Vincent Finnerty

     info.lLength = fread(fid,1,'*int32');
     info.lMarkers = fread(fid,1,'*int32');		% Number of markers
     if (info.lLength > 0) & (info.lMarkers > 0)
         for n = 1:double(info.lMarkers)
             info.lSample(n) = fread(fid,1,'*int32');	% Location of marker
             info.fSelected(n) = fread(fid,1,'*int16');
             info.fTextLocked(n) = fread(fid,1,'*int16');
             info.fPositionLocked(n) = fread(fid,1,'*int16');
             info.nTextLength(n) = fread(fid,1,'*int16');  % Length of marker text string
             info.szText{n} = deblank(fread(fid,double(info.nTextLength(n))+1,'*char')');  % Marker text string
         end
     else
         info.lSample = [];
         info.fSelected = [];
         info.fTextLocked = [];
         info.fPositionLocked = [];
         info.nTextLength = [];
         info.szText = [];
     end

     return;