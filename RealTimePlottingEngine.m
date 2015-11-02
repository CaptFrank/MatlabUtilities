classdef RealTimePlottingEngine
    %% Real Time Plotting Engine
    % 
    %   This is a base class that will do a pseudo real-time
    %   plot of an input. In other words this is a pseudo readltime
    %   plotting engine. We have based this engine on the event framework
    %   that matlab provides.
    % 
    %   author:     gammaRay
    %
    % ===========================================================
    
    properties(SetAccess = 'public', GetAccess = 'public')
        %% Global Class Attributes
        %
        %   This is the section of the class that groups the 
        %   publically accessible attributes for the class.
        %
        % =======================================================
        
        %% Plotter Update Attrbiutes
        % The interval at which the plots will be updated.
        updateInterval;
        
        % The sampling frequency of the plotter.
        samplingFrequency;
        
        %% Plotter Drawing Attributes
        % These are all container vectors.
        timeVector;
        dftPoints;
        halfNumber;
        frequencyVector;
        
        % The plotting agent handle
        plotHandle;
        
        % Lines needed to update the plots
        hLine1;
        hLine2;
        
        % Axes needed to update the plots
        hAx1;
        hAx2;
        hAx3;
        
        % The plotter timer
        plotterTimer;
    end
    
    %% Class Method Definitions
    methods
        
        function obj = RealTimePlottingEngine(updateInterval, samplingFrequency)
           %% RealTimePlottingEngine
           %
           %    This is the default constructor for the class object.
           %    We pass the plotting engine update interval and the
           %    sampling frequency. In this default constructor we setup
           %    the event schedulers and setup the internal class
           %    attributes.
           %
           % ===========================================================

           % Check the input args
           if(nargin > 0)
                
                 fprintf('***********************************************\n');
                 fprintf('*         REAL TIME AUDIO PLOTTER             *\n');
                 fprintf('*          by:  gammaRay                      *\n');
                 fprintf('***********************************************\n\n');

                 fprintf('Starting up the real time audio plotter application...\n');
            
                 % Setting up the context varaibles
                 fprintf('[INFO] - Initializing the real time plotter\n');
                 
                 obj.updateInterval         = updateInterval;
                 obj.samplingFrequency      = samplingFrequency;
                 
                 % Derive the rest;
                 obj.timeVector             = 0:1/samplingFrequency:updateInterval-1/samplingFrequency;
                 obj.dftPoints              = 2^nextpow2(samplingFrequency);
                 obj.halfNumber             = ceil((obj.dftPoints + 1)/2);
                 obj.frequencyVector        = (0:obj.halfNumber - 1)'*obj.samplingFrequency/obj.dftPoints; 
                 
                 % Generating plots to a containers
                 fprintf('[INFO] - Generating the plots\n');
                 obj.plotHandle             = figure;
            
                 obj.hAx1                   = subplot(211);
                 obj.hLine1                 = line('XData',obj.timeVector, ...
                                                'YData',nan(size(obj.timeVector)), ...
                                                'Color','b', 'Parent',obj.hAx1);
                                            
                 xlabel('Time (s)'), ylabel('Amplitude')
            
                 obj.hAx2                   = subplot(212);
                 obj.hLine2                 = line('XData',obj.frequencyVector, ...
                                                'YData', nan(size(obj.frequencyVector)), ...
                                                'Color','b', 'Parent',obj.hAx2);
                                            
                 xlabel('Frequency (Hz)'), ylabel('Magnitude (dB)');  
                 
                 obj.hAx3 = subplot(313);
                 set(obj.hAx1, 'Box','on', 'XGrid','on', 'YGrid','on')
                 set(obj.hAx2, 'Box','on', 'XGrid','on', 'YGrid','on')
                 
                 % Start the plotter timer
                 fprintf('[INFO] - Setting plotter timer\n');
                 
                 obj.plotterTimer           = timer;
                 obj.plotterTimer.Period    = 0.3; % Acts ever 0.3 seconds;
                 obj.plotterTimer.ExecutionMode = 'fixedRate';
                 
                 obj.plotterTimer.StartFcn  = @(~,thisEvent)disp([thisEvent.Type ' started '...
                                        datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
                 obj.plotterTimer.TimerFcn  = @obj.plot;
                 obj.plotterTimer.StopFcn   = @(~,thisEvent)disp([thisEvent.Type ' stopped '...
                                        datestr(thisEvent.Data.time,'dd-mmm-yyyy HH:MM:SS.FFF')]);
           else
                % error occured return and exit
                fprintf('[ERROR] - Not enough arguments past to constructor\n');
            end
        end
        
        function plot(obj, ~, ~)
            %% Plot
            %
            %   This is the plotting method of the class.
            %   Here we pass an object and we plot the data given.
            %
            % ===========================================================

            % Update the interval
            obj.interval                    = obj.interval + 1;
            
            % Get the magnitudes
            fftMag                          = 20*log10( abs(fft(obj.buffer, ...
                                                    obj.dftPoints)));
            % Update plots
            set(obj.hLine1, 'YData',obj.buffer)
            set(obj.hLine2, 'YData',fftMag(1:obj.halfNumber))
            title(obj.hAx1, num2str(obj.interval,'Interval = %d'))
            
            subplot(313);
            spectrogram(obj.buffer);
            
            % Force MATLAB to flush any queued displays
            drawnow                   
            
        end
        
        function startPlotter(obj)
            %% startPlotter
            %
            %   This starts the events and schedules them to fire at the
            %   interval specified above.
            %
            % ===========================================================
            
            start(obj.plotterTimer);
        end
        
        function stopPlotter(obj)
            %% stopPlotter
            %
            %   This stops the events.
            %
            % ===========================================================
            
            stop(obj.plotterTimer);
        end
        
        function setSignal(obj, signal)
            %% setSignal
            %
            %   This sets the signal internally to plot them.
            %
            % ===========================================================
            obj.buffer = signal;
        end
    end
end

