%% compute self-distance matrix
% input:
%   featureMatrix: numFeatures by numSamples float matrix, feature matrix
% output:
%   SDM: numSamples by numSamples float matrix, self-distance matrix

function SDM = computeSelfDistMat(featureMatrix)

[~, numSamples] = size(featureMatrix);
SDM = zeros(numSamples, numSamples);

for i = 1:numSamples
    for j = 1:numSamples
        a = featureMatrix(:, i);
        b = featureMatrix(:, j);
        SDM(i, j) = norm(a - b, 2);
        %SDM(i, j) = cosineDistance(a, b);
    end 
end
