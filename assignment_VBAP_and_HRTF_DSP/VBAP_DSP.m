classdef VBAP_DSP < DSP
    %VBAP Vector Base Ambplitude Panning
    
    properties
        lsPositions
        hull
        % internal
        invBases
        numLS
        lsGains
    end
    
    methods
        function obj = VBAP_DSP(config)
            %VBAP Construct an instance of this class
            %   Pass config struct containing lsPositions [numLS, 3].
            lsPositions = config.lsPositions;
            assert(size(lsPositions, 2) == 3)
            obj.lsPositions = lsPositions;
            obj.numLS = size(lsPositions, 1);
            
            %% TASK: compute and store convex hull of this layout
            obj.hull = obj.getConvHull();
            %% TASK: precompute and store inverted loudspeaker bases
            obj.invBases = obj.invertBases();
        end
        
        function lsHull = getConvHull(obj)
            % GETCONVHULL Create convex hull from obj.lsPositions
            % hint: use convhull
            
            %%% DUMMY SOLUTION %%%
            lsHull = [];
            %%% SOLUTION START %%%
            lsHull = convhull(obj.lsPositions, 'Simplify', true);
            %%% SOLUTION END %%%
        end
        
        
        function showHull(obj)
            %SHOWHULL Plot loudspeaker hull.
            figure; hold on;
            trisurf(obj.hull, ...
                    obj.lsPositions(:, 1), ...
                    obj.lsPositions(:, 2), ...
                    obj.lsPositions(:, 3), ...
                    'FaceAlpha', 0.5)
            plot3(obj.lsPositions(:, 1), ...
                  obj.lsPositions(:, 2), ...
                  obj.lsPositions(:, 3), ...
                  'o','Color','k','MarkerSize',10,'MarkerFaceColor','y')
            for lsIdx = 1:obj.numLS
                text(obj.lsPositions(lsIdx, 1), ...
                     obj.lsPositions(lsIdx, 2), ...
                     obj.lsPositions(lsIdx, 3), ...
                     num2str(lsIdx), 'FontSize',14)
            end
            view(3)
            title("Loudspeaker Hull");
            grid on;
            xlabel("x");
            ylabel("y");
            zlabel("z");
            axis equal
        end
        
 
        function setSources(obj, phantomAzi, phantomEle)
            % SETSOURCES Pass phantom sources azimuth and elevation in rad
            % as vectors [numSrc, 1]. Calls calculateGains().
            assert(all(size(phantomAzi) == size(phantomEle)))
            numSrc = length(phantomAzi);
            % Calculate VBAP loudspeaker gains and store
            gains = obj.calculateGains(cat(2, phantomAzi, phantomEle, ...
                                       ones(numSrc, 1)));
            obj.lsGains = gains;
        end
        
        
        function invbases = invertBases(obj)
            % INVERTBASES Precompute inverted bases for VBAP
            % OUTPUT : invbases [3, 3, numFaces]
            % hint: invert the loudspeaker base matrix of each face 
            % in the hull (base : [numLS, pos])
            numFaces = size(obj.hull, 1);
            invbases = zeros(3, 3, numFaces);
            
            %%% SOLUTION START %%%
            for faceIdx = 1:numFaces
                base = obj.lsPositions(obj.hull(faceIdx, :), :);
                % invert base
                invbases(:, :, faceIdx) = inv(base);
            end
            %%% SOLUTION END %%%
        end
        
        
        function gains = calculateGains(obj,doa)
            %CALCULATEGAINS VBAP Phantom source loudspeaker gains.
            %   INPUT
            %       doa :   [numSrc, 3] (rad)
            %   OUTPUT
            %       gains : [numSrc, numLS]
            assert(size(doa, 2) == 3)            
            numSrc = size(doa, 1);
            gains = zeros(numSrc, obj.numLS);
            
            %%% SOLUTION START %%%
            for srcIdx = 1:numSrc
                pos = sph2cartVec(doa(srcIdx, :));
                for faceIdx = 1:size(obj.hull, 1)
                    % project source on base
                    g = pos * obj.invBases(:, :, faceIdx);
                    if all(ge(g, -10e-6))
                        % found suitable vector base
                        % normalize and write back to corresponding LS
                        gains(srcIdx, obj.hull(faceIdx, :)) = g / vecnorm(g, 1);
                        break
                    end
                end
            end
            %%% SOLUTION END %%%
        end


        function [outputsig] = process(obj, inputsig)
            % PROCESS Apply loudspeaker gains to phantom source signals
            %   INPUT
            %       inputsig : [t x numSrc]
            %   OUTPUT
            %       outputsig : [t x numLS]
            
            % TASK: Implement VBAP processing
            % hint: it's just a matrix multiplication with lsGains
            
            %%% DUMMY SOLUTION %%%
            outputsig = zeros(size(inputsig,1),obj.numLS);
            
            %%% SOLUTION START %%%
            % [t x numSrc] @ [numSrc x lsGains]
            outputsig = inputsig * obj.lsGains;
            %%% SOLUTION END %%%
        end
        
    end
end
