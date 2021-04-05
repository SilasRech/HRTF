beep off;

%% assignment VBAP_and_HRTF_DSP
%% TASK: Add your name and date here
% Name: Silas Rech
% Date: -----------
clear; clc; close all;
addpath('./provided');


%% Define Config = Fixed during runtime
% The Config struct contains many global parameters of the virtual
% acoustics pipeline like the speed of sound or sampling frequency. Those
% parameters are typically constant over time.
config = Config();
vbap = VBAP_DSP(config);

%% BINAURALIZE with HRTFs

binauralizer = Binaural_DSP(config, []);  % initialize with empty source

theta = -90;
leftHrirIdx = binauralizer.calculateHRIR(theta);
leftHrirIdx = reshape(leftHrirIdx, [256, 2]);
% Plot the HRIRs as well as HRTFs together in one figure.
figure;
subplot(211)
plot(leftHrirIdx)
title('HRIRs for \Omega = [90, 0]')
legend('left', 'right')
xlabel('Time in samples')
ylabel('Amplitude')
grid on
subplot(212)
semilogx(linspace(eps, config.fs, size(leftHrirIdx, 1)), ...
         20*log10(abs(fft(leftHrirIdx))));
title('HRTFs for \Omega = [90, 0]')
xlim([20, config.fs/2])
grid on
xlabel('Frequency in Hz')
ylabel('Magnitude in dB')

%% TASK: Render VBAP loudspeaker signals binaurally
% TASK: Implement process in Binaural_DSP
[inSignals, fs] = audioread('band_combined_snip.wav');
[scene, numBlocks] = RotatingBandScene(inSignals, config.blockSize);

% Initialize binaural engine with loudspeaker DOAs
binauralizer = Binaural_DSP(config, config.lsPositions);
assert(fs == binauralizer.fs)

% Block Processing
blockSize = config.blockSize;
binauralOut = zeros(numBlocks*blockSize,2);
for it_block = 1:numBlocks
   block_index = (it_block-1)*blockSize + (1:blockSize);
   frame = inSignals(block_index,:);
   
   sph = cart2sphVec(scene(it_block).sourcePosition);
   % Set new DOAs and update internal VBAP gains
   vbap.setSources( sph(:,1), sph(:,2) );
   lsSignals = vbap.process(frame);
   % Binauralize loudspeakers
   binauralOut(block_index, :) = binauralizer.process(lsSignals);  
end

gridWeights = ones(binauralizer.numHrir, 1) * (4*pi / binauralizer.numHrir);

diffEqTaps = hrirsDiffuseFieldEQ(binauralizer.hrirs, true, gridWeights);

binauralOutCompensated = fftfilt(diffEqTaps, binauralOut);
binauralOutCompensated = binauralOut;
%soundsc(binauralOutCompensated, config.fs)

% Write to file
audiowrite("out_binaural_AssignmentVBAP.wav", ...
            binauralOutCompensated / max(max(binauralOutCompensated)), ...
            config.fs)
