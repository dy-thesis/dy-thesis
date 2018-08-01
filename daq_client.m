clear all; 

% If the MATLAB is 32bit
if strcmp(computer('arch'),'win32'),
  addpath '.\mex_files\32bit'; 
end      

% If the MATLAB is 64bit    
if strcmp(computer('arch'),'win64'),
  addpath '.\mex_files\64bit'; 
end

ports = OptoPorts(3);                   % For 3 axis sensors - Get an instance of the OptoPorts class (3 - only 3D sensors; 6 - only 6D sensors ) 

% version = ports.getAPIversion;        % Get the API version (Major,Minor,Revision,Build)
pause(1)                                % To be sure about OptoPorts enumerated the sensor(s)
available_ports = ports.listPorts;      % Get the list of the available ports 

if (isempty(available_ports)),
  disp('No DAQ is connected...');
else
  disp(available_ports);
end;

if (ports.getLastSize()>0),             % Is there at least 1 available port?
    port = available_ports(1,:);        % If at least 1 port is available then select the first one
    daq = OptoDAQ();                    % Get an instance of the OptoDAQ class (this class handles the actual sensor reading)
    isOpen = daq.open(port,0);          % Open the previously selected port (the second argument:  0 - high-speed mode; 1 - slower debug mode)

  if (isOpen==1),    
   
    speed = 100;                    % Set the required DAQ's internal sampling speed (valid options: 1000Hz,333Hz, 100Hz, 30Hz)
    filter = 0;                     % Set the required DAQ's internal filtering-cutoff frequency (valid options: 0(No filtering),150Hz,50Hz, 15Hz)
    daq.sendConfig(speed,filter);   % Sends the required configuration
    
    channel = 1;                    % Some DAQ support multi-channel, othwerwise it must be 1
        
%   elapsed_time = 0; 
    received_samples = 0; 
    n = 0; 
    Fx = [];
    Fy = []; 
    Fz = []; 
    T = table();
    
    output = daq.read3D(channel);   % For 3 axis sensors - Reads all the available samples (output.size) to empty the buffer

    start = now;
   
    while ((exist('lock.txt', 'file') == 2) && output.size>=0 ),      
      output = daq.read3D(channel);   % For 3 axis sensors - Reads all the available samples (output.size)
	  
	  switch output.size
        case -2
          disp('The DAQ has been disconnected...');
        case -3
          disp('The selected DAQ channel does not exist...');
      end
                   
     % For 3 axis sensors - Display the most current Fx,Fy,Fz sensor values (all are in Counts, refer to the sensitivity report to convert it to N.)  
            
      Fx = [Fx, output.Fx()];            % Fx stores all the received samples of output.Fx
      Fy = [Fy, output.Fy()];            % Fy stores all the received samples of output.Fy
      Fz = [Fz, output.Fz()];            % Fz stores all the received samples of output.Fz
  
    end % close the while loop

    elapsed_time = (now - start);
	
	timestring = datestr(start,'HH:MM:SS.FFF');
    [~,~,~,hours,minutes,seconds] = datevec(timestring);
    start_ms = 1000*(3600*hours + 60*minutes + seconds);	
	
	timestring = datestr(elapsed_time,'HH:MM:SS.FFF');
    [~,~,~,hours,minutes,seconds] = datevec(timestring);
    elapsed_time_ms = 1000*(3600*hours + 60*minutes + seconds);
	
  	samples_count = numel(Fx);
    sampling_time = round(elapsed_time_ms / samples_count);

    timestamps = zeros(1, samples_count);
    for sample = 1:samples_count
      timestamp = start_ms + sample * sampling_time;
      timestamps(1, sample) = timestamp; 
    end
   
%   received_samples = received_samples + Fx.size;      % All samples received since the beginning of the code
    T = table(timestamps',Fx',Fy',Fz');  

    writetable(T,'forcedata.csv','Delimiter',',');

    daq.close();                    % Close the already opened DAQ 
  else
    disp('The DAQ could not be opened');   
  end
end

clear daq;                              % Destroy the OptoDAQ class
clear ports;                            % Destroy the OptoPorts class

