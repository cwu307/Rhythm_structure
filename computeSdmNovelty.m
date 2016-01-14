%% compute novelty function from Self-distance matrix
% input:
%   SDM: float N by N matrix, self-distance matrix
%   L: int, size of the checkerboard kernel (L by L) preferably power of 2
% output:
%   nvt: float N by 1 vector, audio segmentation novelty function 

function [nvt] = computeSdmNovelty(SDM, L)

numBlocks = length(SDM);
C = [1 -1; -1 1];
kernel = kron(C, ones(L/2, L/2));
nvt = zeros(numBlocks, 1);
kernel_flip = flipud(kernel);

for i = 1:numBlocks
    xind_s = (i - 1)*1 - L/2 + 1;
    xind_e = xind_s + L - 1;
    yind_s = (i - 1)*1 - L/2 + 1;
    yind_e = yind_s + L - 1;
    
    xind_s = max(1, xind_s);
    yind_s = max(1, yind_s);
    xind_e = min(numBlocks, xind_e);
    yind_e = min(numBlocks, yind_e);
    
    S = SDM(xind_s:xind_e, yind_s:yind_e);
    S_pad = zeros(L, L);
    if xind_s == 1
        S_pad(L - length(S) + 1: L, L - length(S) + 1: L) = S;
    elseif xind_e == numBlocks
        S_pad(1:length(S), 1:length(S)) = S;
    else
        S_pad = S;
    end
    nvt(i) = sum(sum(kernel_flip.* S_pad));
    
end