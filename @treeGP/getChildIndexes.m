function [childIndexes] = getChildIndexes(this,parentIndex)
 % Get the index of child nodes
	n = length(this.data(:));                   % Get the length of the data
	childIndexes = [];
	if parentIndex<2*n                          % Verify if the possible child indexes are in the matrix
        if ~this.data(parentIndex*2)==0        % Verify if the left child data exists
            if ~this.data(parentIndex*2+1)==0  % Verify if the right child data exists
                childIndexes = [parentIndex*2 parentIndex*2+1];
            else                               
                childIndexes = parentIndex*2;
            end
        end
    end
end