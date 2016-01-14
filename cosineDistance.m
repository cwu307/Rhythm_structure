%% cosine distance 
% intput:
%   x: float n by 1 vector, instance x
%   y: float n by 1 vector, instance y
% output:
%   d: float, cosine distance between x & y

function d = cosineDistance(x, y)

assert(length(x) == length(y)); 

d = 0.5 * (1 - (x'*y)/(norm(x, 2)*norm(y, 2)));