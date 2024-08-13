function hdr = getgraph(fid, file_version)

   %  Struct						% off + size
   unused = fread(fid, 1, 'int16')';			% 0 + 2
   hdr.file_version = fread(fid, 1, 'int32');		% 2 + 4
   hdr.ext_item_header_len = fread(fid, 1, 'int32');	% 6 + 4
   hdr.num_channels = fread(fid, 1, 'int16');		% 10 + 2
   hdr.horiz_axis_type = fread(fid, 1, 'int16');	% 12 + 2
   hdr.curr_channel = fread(fid, 1, 'int16');		% 14 + 2
   hdr.sample_time = fread(fid, 1, 'double');		% 16 + 8
   hdr.time_offset = fread(fid, 1, 'double');		% 24 + 8
   hdr.time_scale = fread(fid, 1, 'double');		% 32 + 8
   hdr.time_cursor1 = fread(fid, 1, 'double');		% 40 + 8
   hdr.time_cursor2 = fread(fid, 1, 'double');		% 48 + 8
   hdr.chart_window = fread(fid, 4, 'int16');		% 56 + 8
   hdr.measurement = fread(fid, 6, 'int16');		% 64 + 12
   hdr.hilite = fread(fid, 1, 'int16');			% 76 + 2
   hdr.first_time_offset = fread(fid, 1, 'double');	% 78 + 8
   hdr.rescale = fread(fid, 1, 'int16');		% 86 + 2
   hdr.horiz_units1 = deblank(fread(fid, 40, '*char')'); % 88 + 40
   hdr.horiz_units2 = deblank(fread(fid, 10, '*char')'); % 128 + 10
   hdr.in_memory = fread(fid, 1, 'int16');		% 138 + 2
   hdr.grid = fread(fid, 1, 'int16');			% 140 + 2
   hdr.markers = fread(fid, 1, 'int16');		% 142 + 2
   hdr.plot_draft = fread(fid, 1, 'int16');		% 144 + 2
   hdr.display_mode = fread(fid, 1, 'int16');		% 146 + 2
   hdr.reserved = fread(fid, 1, 'int16');		% 148 + 2

   if hdr.file_version > 33 & hdr.file_version < 68
      hdr.show_toolbar = fread(fid, 1, 'int16');	% 150 + 2
      hdr.show_chan_butt = fread(fid, 1, 'int16');	% 152 + 2
      hdr.show_measurement = fread(fid, 1, 'int16');	% 154 + 2
      hdr.show_marker = fread(fid, 1, 'int16');		% 156 + 2
      hdr.show_journal = fread(fid, 1, 'int16');	% 158 + 2
      hdr.cur_x_channel = fread(fid, 1, 'int16');	% 160 + 2
      hdr.mmt_precision = fread(fid, 1, 'int16');	% 162 + 2
   end

   if hdr.file_version > 34 & hdr.file_version < 68
      hdr.measurement_row = fread(fid, 1, 'int16');	% 164 + 2
      hdr.mmt = fread(fid, 40, 'int16');		% 166 + 80
      hdr.mmt_chan = fread(fid, 40, 'int16');		% 246 + 80
   end

   if hdr.file_version > 35 & hdr.file_version < 68
      hdr.mmt_calc_opnd1 = fread(fid, 40, 'int16');	% 326 + 80
      hdr.mmt_calc_opnd2 = fread(fid, 40, 'int16');	% 406 + 80
      hdr.mmt_calc_op = fread(fid, 40, 'int16');	% 486 + 80
      hdr.mmt_calc_constant = fread(fid, 40, 'double');	% 566 + 320
   end

   if hdr.file_version > 37 & hdr.file_version < 68
      hdr.new_grid_minor = fread(fid, 1, 'int32');	% 886 + 4
      hdr.color_major_grid = fread(fid, 1, 'int32');	% 890 + 4
      hdr.color_minor_grid = fread(fid, 1, 'int32');	% 894 + 4
      hdr.major_grid_style = fread(fid, 1, 'int16');	% 898 + 2
      hdr.minor_grid_style = fread(fid, 1, 'int16');	% 900 + 2
      hdr.major_grid_width = fread(fid, 1, 'int16');	% 902 + 2
      hdr.minor_grid_width = fread(fid, 1, 'int16');	% 904 + 2
      hdr.fixed_units_div = fread(fid, 1, 'int32');	% 906 + 4
      hdr.mid_range_show = fread(fid, 1, 'int32');	% 910 + 4
      hdr.start_middle_point = fread(fid, 1, 'double');	% 914 + 8
      hdr.offset_point = fread(fid, 60, 'double');	% 922 + 480
      hdr.h_grid = fread(fid, 1, 'double');		% 1402 + 8
      hdr.v_grid = fread(fid, 60, 'double');		% 1410 + 480
      hdr.enable_wave_tool = fread(fid, 1, 'int32');	% 1890 + 4

      %  interpret color_major_grid
      %
      color_str = sprintf('%06s', dec2hex(hdr.color_major_grid));
      hdr.color_major_grid = ...
         [hex2dec(color_str(5:6)) hex2dec(color_str(3:4)) hex2dec(color_str(1:2))]/255;

      %  interpret color_minor_grid
      %
      color_str = sprintf('%06s', dec2hex(hdr.color_minor_grid));
      hdr.color_minor_grid = ...
         [hex2dec(color_str(5:6)) hex2dec(color_str(3:4)) hex2dec(color_str(1:2))]/255;

   end

   if hdr.file_version > 38 & hdr.file_version < 68
      hdr.horiz_precision = fread(fid, 1, 'int16');	% 1894 + 2
   end

   if hdr.file_version > 40 & hdr.file_version < 68
      hdr.reserved2 = fread(fid, 20, 'int8');		% 1896 + 20
      hdr.overlap_mode = fread(fid, 1, 'int32');	% 1916 + 4
      hdr.show_hardware = fread(fid, 1, 'int32');	% 1920 + 4
      hdr.x_auto_plot = fread(fid, 1, 'int32');	% 1924 + 4
      hdr.x_auto_scroll = fread(fid, 1, 'int32');	% 1928 + 4
      hdr.start_butt_visible = fread(fid, 1, 'int32');	% 1932 + 4
      hdr.compressed = fread(fid, 1, 'int32');		% 1936 + 4
      hdr.always_start_butt_visible = fread(fid, 1, 'int32');	% 1940 + 4
   end

   if hdr.file_version > 42 & hdr.file_version < 68
      hdr.path_video = deblank(fread(fid, 260, '*char')'); % 1944 + 260
      hdr.opt_sync_delay = fread(fid, 1, 'int32');	% 2204 + 4
      hdr.sync_delay = fread(fid, 1, 'double');		% 2208 + 8
      hdr.hrp_paste_measurement = fread(fid, 1, 'int32'); % 2216 + 4
   end

   if hdr.file_version > 44 & hdr.file_version < 68
      hdr.graph_type = fread(fid, 1, 'int32');		% 2220 + 4
      hdr.mmt_calc_expr = fread(fid, [40 256], '*char'); % 2224 + 10240
      hdr.mmt_moment_order = fread(fid, 40, 'int32');	% 12464 + 160
      hdr.mmt_time_delay = fread(fid, 40, 'int32');	% 12624 + 160
      hdr.mmt_embed_dim = fread(fid, 40, 'int32');	% 12784 + 160
      hdr.mmt_mi_delay = fread(fid, 40, 'int32');	% 12944 + 160
   end

   if hdr.file_version >= 68
      unused = fread(fid, 411, 'int16')';		% 150 + 822
      hdr.compressed = fread(fid, 1, 'int32');		% 972 + 4
   end

   return;						% graph

