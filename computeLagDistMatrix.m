
function R = computeLagDistMatrix(SDM)

L = length(SDM);
R = ones(L, L);

for i = 1:L
    for j = 1:L
        if (j - i) > 0
            R(j - i, i) = SDM(j, i);
        end
    end
end

