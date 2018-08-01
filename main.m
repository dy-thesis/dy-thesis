p = gcp(); % get the current parallel pool 

get_tcp_coordinates = parfeval(p, @ur5_client, 1, '192.168.56.102', 30003); 
% get_tcp_coordinates_clone = parfeval(p, @ur5_client, 1, '192.168.56.101', 30003); 
get_forces = parfeval(p, @daq_client, 1);

tcp_coordinates = fetchOutputs(get_tcp_coordinates); % Blocks until complete
forces = fetchOutputs(get_forces); % Blocks until complete
% tcp_coordinates_clone = fetchOutputs(get_tcp_coordinates_clone); % Blocks until complete
