 function parentIndex = getParentIndex(this, childIndex)
  % Get the index of the parent node
	parentIndex = floor(childIndex/2);
	if parentIndex <=0 || this.data(parentIndex)==0
        parentIndex = nan;
    end
end