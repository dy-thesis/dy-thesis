function TCP_coordinates = ur5_client(host, port)

  s = tcpclient(host, port);
  raw_data = [];
  while(exist('lock.txt', 'file') == 2)
      sample = double(read(s, 1108, 'uint8'));
      timestring = datestr(now,'HH:MM:SS.FFF');
      [~,~,~,hours,minutes,seconds] = datevec(timestring);
      timestamp= 1000*(3600*hours + 60*minutes + seconds);
      
      raw_data = [raw_data; timestamp, sample];
  end

  sz = size(raw_data);
  rows = sz(1);
  varTypes = {'double','double', 'double', 'double', 'double', 'double', 'double', 'double'}
  varNames = {'Time', 'digOutput0', 'x','y','z','rx','ry','rz'};
  TCP_coordinates = table('Size', [rows, 8],'VariableTypes',varTypes,'VariableNames',varNames);
  for row = 1:rows
    offset = 1;
    timestamp = raw_data(row, offset);
    
    offset = offset + 444;
    x_raw = uint8(raw_data(row, offset+1:offset+8));
    x = typecast(fliplr(x_raw), 'double');
    
    offset = offset + 8;
    y_raw = uint8(raw_data(row, offset+1:offset+8));
    y = typecast(fliplr(y_raw), 'double');
    
    offset = offset + 8;
    z_raw = uint8(raw_data(row, offset+1:offset+8));
    z = typecast(fliplr(z_raw), 'double');
    
    offset = offset + 8;
    rx_raw = uint8(raw_data(row, offset+1:offset+8));
    rx = typecast(fliplr(rx_raw), 'double');
    rx = (rx * 180)/ 3.1459;
    
    offset = offset + 8;
    ry_raw = uint8(raw_data(row, offset+1:offset+8));
    ry = typecast(fliplr(ry_raw), 'double');
    ry = (ry * 180)/ 3.1459;
    
    offset = offset + 8;
    rz_raw = uint8(raw_data(row, offset+1:offset+8));
    rz = typecast(fliplr(rz_raw), 'double');
    rz = (rx * 180)/ 3.1459;
    
    offset = offset + 552;
    digit_out_raw = uint8(raw_data(row, offset+1:offset+8));
    digit_out = typecast(fliplr(digit_out_raw), 'double');
    
    MASK0 = typecast(1, 'double'); 
    digOutput0 = bitand(digit_out, MASK0); 
    if (digOutput0 == MASK0)
      digital_out = 1;
    else
      digital_out = 0;
    end
    
    TCP_coordinates(row, :) = {timestamp, digital_out, x, y, z, rx, ry, rz};
  end

  filename = strcat('TCP_coordinates_', host, '.csv');
  writetable(TCP_coordinates, filename);
end
