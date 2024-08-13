function hdr = foreign(fid, file_version)

   %  Struct						% off + size
   hdr.length = fread(fid, 1, 'short')';		% 0 + 2
   hdr.id = fread(fid, 1, 'short')';			% 2 + 2

   if file_version < 68
      hdr.by_foreign_data = fread(fid, hdr.length-4, 'int8')'; % 4 + x
      hdr.length2 = hdr.length;
   elseif file_version < 80
      unused = fread(fid, 1, 'int32')';			% 4 + 4
      hdr.length2 = fread(fid, 1, 'int32')' + 8;	% 8 + 4
   else
      unused = fread(fid, 1, 'int32')';			% 4 + 4
      hdr.length2 = hdr.length + 8;
   end

   return;						% foreign


%---------------------------------------------------------------------
