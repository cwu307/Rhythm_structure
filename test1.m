clear all; clc; close all;

addpath('/Users/mac/Desktop/GTCMT/NmfDrumToolbox/src');

% filepath = '/Users/mac/Desktop/Database/BallroomData/ChaChaCha/Albums-Cafe_Paradiso-05.wav';
% filepath = '/Users/mac/Desktop/Database/BallroomData/ChaChaCha/Albums-Cafe_Paradiso-08.wav';
 filepath = '/Users/mac/Desktop/Database/BallroomData/Jive/Albums-Cafe_Paradiso-14.wav';
% filepath = '/Users/mac/Desktop/Database2/CW_ENST_minus_one_wet_new_ratio/drummer2/audio/142_MID.wav';
% filepath = '/Users/mac/Desktop/[2]My files and backups/2013 Georgia Tech/2015 Fall/TA_MUSI6201/Assignments/HW4/HW4_ProblemSet/03-Sargon-Waiting For Silence.mp3';

%=== read audio files
[x, fs] = audioread(filepath); 
x = mean(x,2); %down-mixing   
x = resample(x, 44100, fs); %sample rate consistency
fs = 44100;

%=== compute magnitude spectrogram
load DefaultSetting.mat
param.rh = 20;
overlap = param.windowSize - param.hopSize;
X = spectrogram(x, param.windowSize, overlap, param.windowSize, fs);    
X = abs(X);

%=== get novelty functions
[~, HD, ~, ~, ~] = PfNmf(X, param.WD, [], [], [], param.rh, param.sparsity);
% [~, HD, ~, ~, ~] = Am1(X, param.WD, param.rh, param.rhoThreshold...
%         , param.maxIter, param.sparsity);


%=== find the rhythmic representation
%nvt = HD(2, :); %use bass drum information 
nvt = sum(HD, 1);
tWindowSize = 512; %about 6 seconds
tHopSize = 64; %about 0.742 seconds
tMat = buffer(nvt, tWindowSize, tHopSize, 'nodelay');

numTatum = 64; 
rhythm = zeros(numTatum, size(tMat, 2));
accumulated = ones(numTatum, 1);
for i = 1:size(tMat, 2)
    % compute autocorrelation
    afCorr  = xcorr(tMat(:, i),'coeff');
    afCorr  = afCorr((ceil((length(afCorr)/2))+1):end);
    
    % find periodicity
    [pks, loc] = findpeaks(afCorr(2:end));
    [val, ind] = max(pks);
    lag = loc(ind);
    
    % compute representative rhythm
    circularRhythm = buffer(tMat(:, i), lag);
    rhythm(:, i) = resample(sum(circularRhythm, 2), numTatum, lag);
    accumulated = rhythm(:, i).*accumulated;
end

[~, loc] = findpeaks(accumulated);
binaryRhythm = zeros(numTatum, 1);
binaryRhythm(loc) = 1;



%=== compute self-similarity matrix
SDM = pdist2(HD', HD');


%=== visualize SDM
[~, numBlocks] = size(HD);
ht = param.hopSize/fs;
t = 0:ht:(numBlocks - 1)*ht;
figure;
imagesc(t, t, SDM);
%colormap(jet);
colorbar;
xlabel('time (sec)');
ylabel('time (sec)');


rmpath('/Users/mac/Desktop/GTCMT/NmfDrumToolbox/src');