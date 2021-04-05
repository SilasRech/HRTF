classdef Binaural_DSP < DSP
% Multiple input binaural rendering

    properties
        % handle to loaded SOFA
        sofaData
        
        % config
        blockSize
        fs
        
        % HRIR data
        hrirPositions
        hrirs
        numHrir
        
        % Renderer
        doa
        numSrc
        
        % DSP
        convolverLeft  % for left ear
        convolverRight  % for right ear
        
    end
    
    
    methods
        function obj = Binaural_DSP(config, doa)
            % Constructor, pass DOAs [numSrc, 3](rad) to be rendered or [].
            
            obj.blockSize = config.blockSize;
            
            obj.doa = doa;
            obj.numSrc = size(doa, 1);
            
            obj.numberOfInputs = obj.numSrc;
            obj.numberOfOutputs = 2;
            
            % load Sofa Data
            obj.sofaData = getSOFA("HRIR_L2354.sofa", ...
                "http://sofacoustics.org/data/database/thk/HRIR_L2354.sofa");
            obj.numHrir = size(obj.sofaData.SourcePosition, 2);
            obj.hrirs = obj.sofaData.DataIR;
            obj.fs = round(obj.sofaData.DataSamplingRate);
            
            assert(obj.fs == config.fs)
            
            % hrir Positions in cartesian coordinates
            [obj.hrirPositions(:, 1), ...
                obj.hrirPositions(:, 2), ...
                obj.hrirPositions(:, 3)] = sph2cart(...
                         deg2rad(obj.sofaData.SourcePosition(1, :)).', ...
                         deg2rad(obj.sofaData.SourcePosition(2, :).'), 1);
            

            % do some pre-processing, e.g., diffuse field

            % init convolver
            if obj.numSrc
                obj.convolverLeft = BlockConvolver_DSP(obj.blockSize, ...
                                                       obj.numberOfInputs, ...
                                                       size(obj.hrirs, 1));
                obj.convolverRight = BlockConvolver_DSP(obj.blockSize, ...
                                                        obj.numberOfInputs, ...
                                                        size(obj.hrirs, 1));           

                % set initial doa
                obj.setDOA(obj.doa);
                obj.CheckConfig();
            end
        end


        function [] = setDOA(obj, doa)
            % Updates convolver with new HRIRs from DOAs [numSrc, 3].
            assert(size(doa, 1) == obj.numberOfInputs)

            obj.doa = doa;            
            idxHrir = obj.nearestPoint(doa);
            
            irsLeft = squeeze(obj.hrirs(:,  1, idxHrir ));
            irsRight = squeeze(obj.hrirs(:,  2, idxHrir ));
            
            obj.convolverLeft.setIRs(irsLeft);
            obj.convolverRight.setIRs(irsRight);

        end


        function idxHrir = nearestPoint(obj, doa)
            % Return index of nearest measurement grid point for each DOA.
            % INPUT
            %   doa : [numSrc, 3] (rad)
            % OUTPUT
            %   idxHrir : [numSrc, 1]
            assert(size(doa, 2) == 3)
            numDoa = size(doa, 1);  % number of queries
            pos = sph2cartVec(doa);
            idxHrir = ones(numDoa, 1);
            
            % Hint: The dot product is a fast distance evaluation strategy here,
            % make sure to check the conventions of this coordinate system: 
            % X-forward, Z-up
            
            %%% SOLUTION START %%%
            for idxSrc = 1:numDoa
                angleDist = acos(obj.hrirPositions * pos(idxSrc, :).');
                [~, idxHrir(idxSrc)] = min(angleDist);
            end
            %%% SOLUTION END %%%
        end


        function [output] = process(obj, input)
            % Input:    [t, numSrc]
            % Output:   [t, 2]
            assert( size(input,2) == obj.numberOfInputs, ...
                'Number of Inputs incorrect.')
            
            output = zeros(obj.blockSize, 2);
            % hints: obj.convolverLeft.process()
            %%% SOLUTION START %%%
            output(:, 1) = sum(obj.convolverLeft.process(input), 2);
            output(:, 2) = sum(obj.convolverRight.process(input), 2);
            %%% SOLUTION END %%%
        end
        
        
    end
    
end
