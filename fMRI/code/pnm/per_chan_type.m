function hdr = per_chan_type(fid)

   %  Struct						% off + size
   hdr.size = fread(fid, 1, 'short')';			% 0 + 2
   hdr.type = fread(fid, 1, 'short')';			% 2 + 2

   return;						% per_chan_type


%---------------------------------------------------------------------
