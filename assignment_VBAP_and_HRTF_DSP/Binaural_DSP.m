classdef Binaural_DSP < DSP
% Multiple input binaural rendering

    properties
        % handle to loaded
        mu_0
        referenceX
        referenceY
        
        % config
        blockSize
        fs
        
        % HRIR data
        hrirPositions
        hrirs
        numHrir
        radius
        
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
            
            [obj.referenceX, Fs] = audioread('xk_20s.wav');
            [obj.referenceY, Fs] = audioread('yk_20s.wav');
            obj.mu_0 = 0.25;
            obj.fs = 48000;
            obj.numHrir = obj.numSrc;
            
            % do some pre-processing, e.g., diffuse field

            % init convolver
            if obj.numSrc
                obj.convolverLeft = BlockConvolver_DSP(obj.blockSize, ...
                                                       obj.numberOfInputs, ...
                                                       256);
                obj.convolverRight = BlockConvolver_DSP(obj.blockSize, ...
                                                        obj.numberOfInputs, ...
                                                        256);           

                % set initial doa
                obj.setDOA(obj.doa);
                
                obj.CheckConfig();
            end
        end


        function [] = setDOA(obj, doa)
            % Updates convolver with new HRIRs from DOAs [numSrc, 3].
            assert(size(doa, 1) == obj.numberOfInputs)

            obj.doa = doa;            
            
            
            cart2sphVec(obj.doa);
            theta = cart2sphVec(obj.doa);
            obj.radius = theta(:, 3);
          
            hrir = calculateHRIR(obj, theta(:, 1)*180/pi);
            
            obj.hrirs = permute(hrir,[2 3 1]);
            
            left_hrir = hrir(:,:, 1)';
            right_hrir =hrir(:,:, 2)';
            
            obj.convolverLeft.setIRs(left_hrir);
            obj.convolverRight.setIRs(right_hrir);

        end
        
        function hrir = calculateHRIR(obj, theta)
            [hrir, ~] = calculate_HRIR(obj.referenceX, obj.referenceY, obj.blockSize, obj.mu_0, theta);
        end
        
        function [output] = process(obj, input)
            % Input:    [t, numSrc]
            % Output:   [t, 2]
            assert( size(input,2) == obj.numberOfInputs, ...
                'Number of Inputs incorrect.')
              
            left = sum(obj.convolverLeft.process(input), 2);
            right = sum(obj.convolverRight.process(input),2);
            
            output = [left, right];
        end
        
        
    end
    
end
