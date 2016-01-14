
function [SDM_binary] = computeBinSdm(SDM, threshold)

maxValue = max(max(SDM));
SDM_binary = SDM;
SDM_binary(SDM > (threshold * maxValue)) = 1;
SDM_binary(SDM <= (threshold * maxValue)) = 0;