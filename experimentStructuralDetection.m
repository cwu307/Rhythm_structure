clear all; clc; close all;

% read input audio signal
%filepath = '/Users/mac/Desktop/Database/Sargon/audio/03-Sargon-Waiting For Silence.mp3';
filepath = '/Users/mac/Desktop/Database/BallroomData/ChaChaCha/Albums-Cafe_Paradiso-05.wav';
[x, fs] = audioread(filepath);
x = mean(x, 2);
windowSize = 1 * fs; 
hopSize = 1/4 * windowSize;
X = spectrogram(x, windowSize, (windowSize - hopSize), fs);
X_mag = abs(X);

% compute features
[vmfcc] = FeatureSpectralMfccs(X_mag, fs);
[vpc] = FeatureSpectralPitchChroma(X_mag, fs);

% compute SDM
for i = 1:1
    if i == 1
        featureMatrix = vmfcc;
        threshold = 0.07; %mfcc
    else
        featureMatrix = vpc;
        threshold = 0.2;
    end
    [numFeatures, numBlocks] = size(featureMatrix);
    SDM = computeSelfDistMat(featureMatrix);

    % visualize SDM
    ht = hopSize/fs;
    t = 0:ht:(numBlocks - 1)*ht;
    figure;
    imagesc(t, t, SDM);
    %colormap(jet);
    colorbar;
    xlabel('time (sec)');
    ylabel('time (sec)');

    %% compute novelty from SDM
    L = 2;
    [nvt] = computeSdmNovelty(SDM, L);
    % figure;
    % plot(t, nvt); hold on;
    % xlabel('time (Sec)');
    % ylabel('novelty level');

    %% read annotation 
    annpath = '/Users/mac/Desktop/Database/Sargon/original_references/03-Sargon-Waiting For Silence.csv';
    annData = importdata(annpath, ',');
    fileID = fopen(annpath);
    C = textscan(fileID, '%f , %s');
    gt_time = C{1};
    gt_label = C{2};
    gt_timeInBlocks = round(gt_time * fs / hopSize);

    figure;
    addVerticalLines(nvt, gt_timeInBlocks);
    xlabel('# block');
    ylabel('novelty level');

    %% binary SDM + lag distance 
    [SDM_binary] = computeBinSdm(SDM, threshold);
    R = computeLagDistMatrix(SDM_binary);
    figure;
    imagesc(t, t, R);
    colormap(gray);
    colorbar;
    xlabel('time (sec)');
    ylabel('lag (sec)');


    %% detect lines
    [IM2] = erodeDilate(R, 10);
    figure;
    imagesc(IM2);
    colormap(gray);
    colorbar;
    xlabel('time (sec)');
    ylabel('lag (sec)');

end