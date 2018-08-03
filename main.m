p = gcp(); % get the current parallel pool 

get_tcp_coordinates = parfeval(p, @ur5_client, 1, '10.53.53.195', 30003); 
% get_tcp_coordinates_clone = parfeval(p, @ur5_client, 1, '192.168.56.101', 30003); 
get_forces = parfeval(p, @daq_client, 1);

tcp_coordinates = fetchOutputs(get_tcp_coordinates); % Blocks until complete
forces = fetchOutputs(get_forces); % Blocks until complete
% tcp_coordinates_clone = fetchOutputs(get_tcp_coordinates_clone); % Blocks until complete

D1 = dataset('XLSFile','force.csv','Sheet',1,'ReadVarNames',false);
D2 = dataset('XLSFile','TCP_coordinates_10.53.53.195.csv','Sheet',1,'ReadVarNames',false);
Join the datasets
J = join(D1,D2,'type','outer','keys','Var1');
% Look for missing variables
% missing = strcmp(J.Var1_left,'');
% % Fill in missing values
% J.Var1_left(missing) = J.Var1_right(missing);
