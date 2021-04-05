classdef Scene < handle
% Collection of dynamic properties
% Cartesian coordinates follow the right-hand rule:
% X = forward
% Y = left
% Z = up

   properties
       sourcePosition
       listenerPosition
       num_blocks
   end
    
    methods
        function obj = Scene()
            % default scene
            obj.sourcePosition = [1 2 1]; 
            obj.listenerPosition = [0 0 1];
            obj.num_blocks = 1;
        end
        
    end

end