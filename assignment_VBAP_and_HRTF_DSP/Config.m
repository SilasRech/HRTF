classdef Config < handle
    % Collection of fixed properties for the virtual acoustics pipeline
    % Cartesian coordinates follow the right-hand rule:
    % X = forward
    % Y = left
    % Z = up
    
    
    properties
        fs % sampling frequency in Hz
        speedOfSound % meter/seconds
        blockSize % number of samples per signal block
        temperature % Celsius degree
        relativeHumidity % between 0 - 100
        headRadius % in meters
        roomSize % width/length/heights in meters
        spatialEncoding % type of encoding, e.g., 'object'
        ambiOrder % Ambisonics order, e.g., 0, 1, 2, ...
        maxre % Flag to use max-rE weighting, Boolean = true/false
        spatialDecoding % type of decoding, e.g., 'binaural'
        maximumDelay % maximum time-delay in simulation in samples
        RT60 % Reverberation time in seconds
        lsPositions % Loudspeaker positions Cartesian coordinates (XYZ)
        
        % Substructs for stage specific parameters
        Direct
        Early
        Late
    end
    
    methods
        function obj = Config(varargin)
            % Construct config struct. Choose from different pre-defined
            % configurations.
            if(isempty(varargin))
                type = 'default';
            else
                type = varargin{1};
            end
            
            switch type
                case 'default'
                    obj = obj.DefaultConfig();
                case 'regularLsArray'
                    obj = obj.regularLsArrayConfig();
                otherwise
                    error('Not Defined');
            end
            
        end
        
        function obj = regularLsArrayConfig(obj)
            obj = DefaultConfig(obj);
            load('tdesign_7.mat')
            obj.lsPositions = tdesign_7;
            
        end
        
        function obj = DefaultConfig(obj)
            % default config
            obj.fs = 48000;
            obj.speedOfSound = 343;
            obj.blockSize = 256;
            obj.temperature = 20;
            obj.relativeHumidity = 50;
            obj.headRadius = 0.09;
            obj.roomSize = [10 7 4];
            obj.spatialEncoding = 'object';
            obj.ambiOrder = 3;
            obj.maxre = true;
            obj.spatialDecoding = 'binaural';
            obj.lsPositions = obj.defaultLoudspeakers();
            obj.maximumDelay = obj.fs;
            obj.RT60.Low = 2;
            obj.RT60.High = 0.5;
            
            obj.Early.maxImageSourceOrder = 3;
            obj.Early.MaximumDelay = obj.fs;
            
            obj.Late.numberOfDelays = 8;
            obj.Late.MaximumDelay = obj.fs;
            
        end
        
        function lsPositions = defaultLoudspeakers(obj)
            %% Define loudspeaker layout
            % The loudspeaker layout consists of 3 concentric rings, plus a top
            % louspeaker (also called "voice of god"). As a loudspeaker directly under
            % the listener is hard to implement, only the three main layers will be
            % symmetric. The coordinates are given in azimuth and elevation, and will
            % be then translated to Cartesian coordinates.
            
            % Define Loudspeaker first
            layerNum = [1, 12, 8, 8];
            layerEle = [90, 0, 45, -45];
            for it = 1:numel(layerNum)
                azi{it} = linspace(0,360 - 360/layerNum(it),layerNum(it));
                ele{it} = layerEle(it) * ones(size(azi{it}));
            end
            lsAzi = [azi{:}];
            lsEle = [ele{:}];
            
            [lsX, lsY, lsZ] = sph2cart(deg2rad(lsAzi), deg2rad(lsEle), 1);
            lsPositions = [lsX.', lsY.', lsZ.'];
        end
        
    end
    
end
