classdef DSP < handle
   % API for DSP units
   % PROVIDED %
   
   properties
      numberOfInputs = 0;
      numberOfOutputs = 0;
   end
   
   methods
       function CheckConfig (obj)
          assert(obj.numberOfInputs > 0, 'Set Input number')
          assert(obj.numberOfOutputs > 0, 'Set Output number')
          output = obj.process(zeros(256,obj.numberOfInputs));
          assert(size(output, 2) == obj.numberOfOutputs, 'Output size mismatch');
       end
   end
   
   methods (Abstract)
      process
   end
   
end