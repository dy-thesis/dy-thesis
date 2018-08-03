clear all

idleForces = calibration();

 while (exist('lock.txt', 'file') == 2)
  measuredForces = daq_client();
  Forces = (measuredForces- idleForces);
  Row = table(Forces);
  
end

writetable(Row,'force2data.csv','Delimiter',',')

% D1 = dataset('XLSFile','forcedata.csv','Sheet',1,'ReadVarNames',false);
% D2 = dataset('XLSFile','robotdataX.csv','Sheet',1,'ReadVarNames',false);
% Join the datasets
% J = join(D1,D2,'type','outer','keys','Var1');
% Look for missing variables
% missing = strcmp(J.Var1_left,'');
% Fill in missing values
% J.Var1_left(missing) = J.Var1_right(missing);

