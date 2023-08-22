function index = generateSubIndex(root, depth)
%% Creates recursively the subtree indexing starting in the desired root
	index = 1:2^depth-1;            % Generate the original indexing system
	recursiveReIndex(1,root,depth); % Call the reindexing function starting in the root node
            
	 % Reindex the child nodes
    function recursiveReIndex(ind,newInd,depth)
        index(ind) = newInd;                                % Reindex the current node
        if depth>1                                          % Check if the depth criterium hasn't been achieved
            recursiveReIndex(ind*2, newInd*2,depth-1);      % Call the reindexing function to child nodes
            recursiveReIndex(ind*2+1, newInd*2+1,depth-1);  % Call the reindexing function to child nodes
        end
	end
end