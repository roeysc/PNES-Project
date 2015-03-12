function indices = getTrialsIndicesSubset(a,b)
% Choose a subset of trials of condition B, most similar to that of 
% TODO: now you only get one, even if there is more than one possibility.
% a,b are vectors of serial times.
% a is the smaller one.

c = nchoosek(b, length(a));
c = sort(c,2);

cDiffMat = abs(diff(c,1,2));
cDiffMat = sort(cDiffMat,2);

aDiff = abs(diff(a));
aDiff = sort(aDiff,2);

aDiffMat = repmat(aDiff ,size(cDiffMat,1),1);

absDiffMatrix = abs(cDiffMat - aDiffMat);

diffSum = sum(absDiffMatrix');

[minDiff rowIndex] = min(diffSum);

% Now we have the row of c than we need
goodRow = c(rowIndex,:);
indices = zeros(1,length(goodRow));

for i = 1:length(goodRow)
    indices(i) = find(b == goodRow(i));
end

end

