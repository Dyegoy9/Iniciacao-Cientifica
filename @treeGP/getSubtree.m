function subtree = getSubtree(this,root)
 % Returns a new tree representing the subtree that has the desired root index
	newDepth = this.getDepth()-floor(log2(root));       % Get the subtree predicted depth
	newVector=treeGP.generateSubIndex(root,newDepth);   % Create the index of the subtree on the original tree
	newVector(newVector>numel(this.data))=[];
	try
        subtree = treeGP(this.data(newVector));             % Create the new treeGP object representing the subtree
    catch
        disp oi
	end
end