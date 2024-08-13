function hdr = read_acq_hdr(fid)

   fseek(fid, 0, 'bof');
   hdr.graph = getgraph(fid);
   acc_chan_header_len = 0;

   for i = 1:hdr.graph.num_channels
      fseek(fid, hdr.graph.ext_item_header_len+acc_chan_header_len, 'bof');
      hdr.per_chan_data(i) = per_chan_data(fid, hdr.graph.file_version);
      acc_chan_header_len = acc_chan_header_len + hdr.per_chan_data(i).chan_header_len;
   end

   % added by AM: foreign data section was being started to read one short,
   % this fseek takes care of that
   fseek(fid, hdr.graph.ext_item_header_len+acc_chan_header_len, 'bof');
      
   hdr.foreign = foreign(fid, hdr.graph.file_version);

   if hdr.graph.file_version >= 68 & hdr.graph.file_version < 80
      unused = fread(fid, hdr.foreign.length2-12, 'uint8')';
   end

   for i = 1:hdr.graph.num_channels
      hdr.per_chan_type(i) = per_chan_type(fid);
   end

   return;					% read_acq_hdr


%---------------------------------------------------------------------
