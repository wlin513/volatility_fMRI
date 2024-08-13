function hdr = per_chan_data(fid, file_version)

   %  Struct						% off + size
   hdr.chan_header_len = fread(fid, 1, 'int32')';	% 0 + 4
   hdr.num = fread(fid, 1, 'int16')';			% 4 + 2
   hdr.comment_text = deblank(fread(fid, 40, '*char')'); % 6 + 40
   hdr.rgb_color = fread(fid, 1, 'int32')';		% 46 + 4
   hdr.disp_chan = fread(fid, 1, 'int16')';		% 50 + 2
   hdr.volt_offset = fread(fid, 1, 'double')';		% 52 + 8
   hdr.volt_scale = fread(fid, 1, 'double')';		% 60 + 8
   hdr.units_text = deblank(fread(fid, 20, '*char')');	% 68 + 20
   hdr.buf_length = fread(fid, 1, 'int32')';		% 88 + 4
   hdr.ampl_scale = fread(fid, 1, 'double')';		% 92 + 8
   hdr.ampl_offset = fread(fid, 1, 'double')';		% 100 + 8
   hdr.chan_order = fread(fid, 1, 'int16')';		% 108 + 2
   hdr.disp_size = fread(fid, 1, 'int16')';		% 110 + 2

   if file_version >= 68

      unused = fread(fid, 5, 'double')';		% 112 + 40
      hdr.var_sample_divider = fread(fid, 1, 'int16')'; % 152 + 2
      % ?added by wanjunlin
      if hdr.var_sample_divider==-1
          hdr.var_sample_divider = 1; 
      end
      % ?added by wanjunlin
      
   else

   hdr.plot_mode = fread(fid, 1, 'int16')';		% 112 + 2
   hdr.mid = fread(fid, 1, 'double')';			% 114 + 8


   %  interpret rbg_color
   %
   color_str = sprintf('%06s', dec2hex(hdr.rgb_color));
   hdr.rgb_color = ...
      [hex2dec(color_str(5:6)) hex2dec(color_str(3:4)) hex2dec(color_str(1:2))]/255;

   if file_version > 37
      hdr.description = deblank(fread(fid, 128, '*char')'); % 122 + 128
      hdr.var_sample_divider = fread(fid, 1, 'int16')'; % 250 + 2
      
      % AM does not make sense to have a zero divider, set those to 1. No
      % warranties this is standard, but .ACQ files generated with biopac
      % programs produce files with var_sample_divider = 0 although this is
      % not documented. This fix works for the files seen so far.
      if hdr.var_sample_divider==0
          hdr.var_sample_divider = 1; 
      end
      
   else
      hdr.var_sample_divider = 1;
   end

   if file_version > 38
      hdr.vert_precision = fread(fid, 1, 'int16')';	% 252 + 2
   end

   if file_version > 42
      hdr.active_seg_color = fread(fid, 1, 'int32')';	% 254 + 4
      hdr.active_seg_style = fread(fid, 1, 'int32')';	% 258 + 4

      %  interpret active_seg_color
      %
      color_str = sprintf('%06s', dec2hex(hdr.active_seg_color));
      hdr.active_seg_color = ...
         [hex2dec(color_str(5:6)) hex2dec(color_str(3:4)) hex2dec(color_str(1:2))]/255;
   end

   end						% if file_version < 68

   return;						% per_chan_data


%---------------------------------------------------------------------

