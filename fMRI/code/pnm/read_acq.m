function data = read_acq(fid, hdr, chan_by_chan)

   start_real_chan = hdr.graph.ext_item_header_len;

   for i = 1:hdr.graph.num_channels
      start_real_chan = start_real_chan + hdr.per_chan_data(i).chan_header_len;

      if hdr.per_chan_type(i).type ~= 1			% if integer
         hdr.per_chan_type(i).size = 2;			% only use int16
      end
   end

   start_real_chan = start_real_chan + hdr.foreign.length2 + 4*hdr.graph.num_channels;
   
   sample_divider = [hdr.per_chan_data.var_sample_divider];

   if length(unique(sample_divider))==1 & unique(sample_divider)==1
      min_len = min([hdr.per_chan_data.buf_length]);
   else
      min_len = min([hdr.per_chan_data.buf_length].*sample_divider);
   end

   if length(unique([hdr.per_chan_type.type])) & ~chan_by_chan & ...
	length(unique(sample_divider))==1 & unique(sample_divider)==1

      half_chan = round(hdr.graph.num_channels/2);

      for i = 1:half_chan
         fprintf('.');
      end

      if hdr.per_chan_type(i).type == 1			% double

         data=fread(fid,[hdr.graph.num_channels min_len],'double');
         data=data';
      else						% int

         data=fread(fid,[hdr.graph.num_channels min_len],'int16');
         data=data'.*(ones(min_len,1)*[hdr.per_chan_data.ampl_scale]) ...
		    + ones(min_len,1)*[hdr.per_chan_data.ampl_offset];
      end

      for i = 1:(hdr.graph.num_channels-half_chan)
         fprintf('.');
      end

   else				% if we have to do it chan_by_chan

      if length(unique(sample_divider))==1 & unique(sample_divider)==1

         %  Since data are arranged like: "channel in sample"
         %  { s1 of {ch1 ch2 ...}, s2 of {ch1 ch2 ...} ... }
         %  We can either read data sample by sample (all chan at once),
         %  or, channel by channel, but need to skip the rest of chan
         %
         size_all_chan_per_sample = 0;

         for i = 1:hdr.graph.num_channels
            size_all_chan_per_sample = size_all_chan_per_sample + ...
					hdr.per_chan_type(i).size;
         end

         for i = 1:hdr.graph.num_channels

            fprintf('.');
            fseek(fid, start_real_chan, 'bof');

            %  First jump to the start point of the right channel
            %
            start_chan = 0;

            for j = 1 : (i-1)
               start_chan = start_chan + hdr.per_chan_type(j).size;
            end

            fseek(fid, start_chan, 'cof');

            %  Need to skip the rest of chan, in order to read each sample point
            %
            skip_chan = size_all_chan_per_sample - hdr.per_chan_type(i).size;

            if hdr.per_chan_type(i).type == 1		% double

               tmp=fread(fid,hdr.per_chan_data(i).buf_length,'double',skip_chan);

            else					% int

               %  Need to be scaled & shifted by ampl_scale & ampl_offset
               %  for integer data
               %
               tmp=fread(fid,hdr.per_chan_data(i).buf_length,'int16',skip_chan) ...
			* hdr.per_chan_data(i).ampl_scale ...
			+ hdr.per_chan_data(i).ampl_offset;
            end

            data(:,i) = tmp(1:min_len);
         end

      else				% sample_divider>1 or different

         %  If there is a sample_divider>1 in any channel, we have to
         %  read data sample by sample (very slow!)
         %
         data = zeros(min_len, hdr.graph.num_channels);
         mask=zeros(min_len, hdr.graph.num_channels);

         for j = 1:hdr.graph.num_channels
            mask(1:sample_divider(j):min_len, j)=1;
         end

         for i = 1:min_len

            if mod(i-1, ceil(min_len/hdr.graph.num_channels))==0
               fprintf('.');
            end

            for j = 1:hdr.graph.num_channels
               if mask(i,j) | sample_divider(j)==1
                  if hdr.per_chan_type(j).type == 1		% double
                     data(i,j) = fread(fid,1,'double');
                  else
                     data(i,j) = fread(fid,1,'int16');		% int

                     %  Need to be scaled & shifted by ampl_scale & ampl_offset
                     %  for integer data
                     %
                     data(i,j) = data(i,j) * hdr.per_chan_data(j).ampl_scale ...
					+ hdr.per_chan_data(j).ampl_offset;
                  end
               else
                  data(i,j) = data(i-1,j);
               end		% if mask ... read sample_divider

            end		% for j
         end		% for i

      end	% if length(unique(sample_divider
   end	% length(unique([hdr.per_chan_type.type

   return;					% read_acq


 %---------------------------------------------------------------------
