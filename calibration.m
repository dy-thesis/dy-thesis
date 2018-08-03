function q = calibration()

clear all;
% If the MATLAB is 32bit
if strcmp(computer('arch'),'win32'),     
    addpath '.\mex_files\32bit'; 
end

% If the MATLAB is 64bit
if strcmp(computer('arch'),'win64'),    
    addpath '.\mex_files\64bit'; 
end 

offsets = tare(100);

function y = tare(samples)
    ports = OptoPorts(3);                   % For 3 axis sensors - Get an instance of the OptoPorts class (3 - only 3D sensors; 6 - only 6D sensors ) 
    pause(1)                                % To be sure about OptoPorts enumerated the sensor(s)
    available_ports = ports.listPorts;      % Get the list of the available ports 
    
    if (isempty(available_ports)), 
        disp('No DAQ is connected...'); 
    else disp(' ');
    end;

    if (ports.getLastSize()>0),             % Is there at least 1 available port?

        port = available_ports(1,:);        % If at least 1 port is available then select the first one

        daq = OptoDAQ();                    % Get an instance of the OptoDAQ class (this class handles the actual sensor reading)
        isOpen = daq.open(port,0);          % Open the previously selected port (the second argument:  0 - high-speed mode; 1 - slower debug mode)

       if (isOpen==1),    

            speed = 100;                   % Set the required DAQ's internal sampling speed (valid options: 1000Hz,333Hz, 100Hz, 30Hz)
            filter = 0;                   % Set the required DAQ's internal filtering-cutoff frequency (valid options: 0(No filtering),150Hz,50Hz, 15Hz)
            daq.sendConfig(speed,filter);   % Sends the required configuration

            channel = 1;                    % Some DAQ support multi-channel, othwerwise it must be 1
            output = daq.read3D(channel);   % For 3 axis sensors - Reads all the available samples (output.size) to empty the buffer
                       
            received_samples = 0;  
            Fx = []; 
            Fy = []; 
            Fz = []; 
            n = 0;
            
            while (received_samples <samples && output.size>=0 ),        % Loop for 10sec (quit if any error)
                n = n+1;
                output = daq.read3D(channel);   % For 3 axis sensors - Reads all the available samples (output.size)
                
              switch output.size
                 case -2
                    disp('The DAQ has been disconnected...');
                 case -3
                    disp('The selected DAQ channel does not exist...');
              end
%                 if (output.size==-2), disp('The DAQ has been disconnected... '); end;
%                 if (output.size==-3), disp('The selected DAQ channel does not exist... ');  end;

                Fx = [Fx output.Fx];            % Fx stores all the received samples of output.Fx
                Fy = [Fy output.Fy];            % Fy stores all the received samples of output.Fy
                Fz = [Fz output.Fz];            % Fz stores all the received samples of output.Fz

                received_samples = received_samples + output.size;      % All samples received since the beginning of the code

            end
            
            daq.close();                    % Close the already opened DAQ

        else
            disp('The DAQ could not be opened');   
        end

    end
    y = [mean(Fx(1:100)) mean(Fy(1:100)) mean(Fz(1:100))];
    clear daq;                              % Destroy the OptoDAQ class
    clear ports;                            % Destroy the OptoPorts class
end
q = offsets;
end
