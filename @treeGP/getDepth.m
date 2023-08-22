function depth = getDepth(this)
%% Returns the depth of tree
 	last = find(this.data(:), 1, 'last' );  % Get the position of the last non zero element
	depth = floor(log2(last))+1;            % Find the layer of the found position
    if isempty(depth)
        depth = 0;
    end
end