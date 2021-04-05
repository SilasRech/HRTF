function [scene, numBlocks] = RotatingBandScene(inSignals,blockSize)
% Slowly rotating with 16 sources in horizontal plane.
% PROVIDED %

numSources = size(inSignals,2);
azStart = linspace(0, (numSources-1)/numSources * 2*pi,numSources).';
azDelta = 0.03/(2*pi);

numBlocks = floor(size(inSignals,1) / blockSize);
for it_block = 1:numBlocks
    scene(1,it_block) = Scene();
    az = azStart + it_block*azDelta;
    scene(it_block).sourcePosition = sph2cartVec([az,az*0,az*0+1]);
end