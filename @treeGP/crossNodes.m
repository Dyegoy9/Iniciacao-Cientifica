function [offspring1, offspring2] = crossNodes(tree1, tree2, node1, node2)
%% Execute the crossover between two trees at the specified nodes
    global nBOperators
    nBOperators = 5;
	if node1~=1 && mod(node1,2)                         % Verify if the desired node is the right child
        if round(tree1.data(floor(node1/2))/1000)<-nBOperators   % Verify if the parent of the desired node requires only one child
            node1 = node1-1;                            % Turns the right child node on a left child
        end
    end
	if node2~=1 && mod(node2,2)                         % Verify if the desired node is the right child
        if round(tree2.data(floor(node2/2))/1000)<-nBOperators   % Verify if the parent of the desired node requires only one child
            node2 = node2-1;                            % Turns the right child node on a left child
        end
    end
            
	% Get the depth of each tree
	tree1Depth = tree1.getDepth();
	tree2Depth = tree2.getDepth();
	% Predict the offsprings depth
  	predictDepthOffspring1 = max(tree1Depth-floor(log2(node1))+floor(log2(node2)), tree1Depth);
	predictDepthOffspring2 = max(tree2Depth-floor(log2(node2))+floor(log2(node1)), tree2Depth);
	% Verify the max depth limit
	if predictDepthOffspring1 >= tree1.maxDepth || predictDepthOffspring2 >= tree1.maxDepth
        offspring1 = [];
        offspring2 = [];
	return;
    end
    tempArray1 = tree1.getData();                   % Get all the data from tree1
	tempArray2 = tree2.getData();                   % Get all the data from tree2
	tempArray1 = tempArray1(:);                     % Transform the data into column form
	tempArray2 = tempArray2(:);                     % Transform the data into column form
	tempArray1(2^predictDepthOffspring1-1)=0;       % Expand the array to the predicted max size
	tempArray2(2^predictDepthOffspring2-1)=0;       % Expand the array to the predicted max size
	subtreeData1 = tree1.getSubtree(node1).getData();  % Get data from the desired subtree
	subtreeData2 = tree2.getSubtree(node2).getData();  % Get data from the desired subtree
	crossoverWeight();                              % Cross the weights of both trees
    %AlternativeCrossoverWeight();
	tempArray1 = clearTree(tempArray1, node1);  % Cleanup the tree1
	tempArray2 = clearTree(tempArray2, node2);  % Cleanup the tree2
	% Create a new indexing array for the subtrees
	in1 = 1:find(subtreeData2, 1, 'last' );      % Create an index for the subtree2 new place in tree1
	in2 = 1:find(subtreeData1, 1, 'last' );      % Create an index for the subtree1 new place in tree2
	index1 = treeGP.generateSubIndex(node1,floor(log2(in1(end)))+1);    % Create the index for subtree2 on tree1
	index2 = treeGP.generateSubIndex(node2,floor(log2(in2(end)))+1);    % Create the index for subtree1 on tree2
            
	try
        tempArray1(index1(1:length(in1)))=subtreeData2(in1);           % Copy the data from subtree2 to tree1 Array
        tempArray2(index2(1:length(in2)))=subtreeData1(in2);           % Copy the data from subtree2 to tree1 Array
    catch
        disp oi
    end
	offspring1 = treeGP(tempArray1);                % Create the offspring tree1
	offspring2 = treeGP(tempArray2);                % Create the offspring tree2
            
            % Recombine linearly the weight of both trees
	function crossoverWeight()
        alpha = 0;                    % Extra possible span
        L = min(length(subtreeData1),length(subtreeData2)); % Get the minimun length between the trees
        A = rand(1,L)*(1+2*alpha)-alpha;% Get the weigth applied to the span range
        B = (1+2*alpha)-A;              % Get the weigth complement span range
        F1 = round(subtreeData1/1000);  % Get the function encoding of the subtree1
        F2 = round(subtreeData2/1000);  % Get the function encoding of the subtree2
        w1 = subtreeData1-1000*F1;      % Get the weights of the subtree1
        w2 = subtreeData2-1000*F2;      % Get the weights of the subtree2
        span = w1(1:L)-w2(1:L);         % Get the weight span
        w2(1:L) = w1(1:L)+span*B';      % Cross the weight of the first subtree
        w1(1:L) = w1(1:L)+span*A';      % Cross the weight of the second subtree
        subtreeData1 = 1000*F1+w1;      % Return the weight information to the treee
        subtreeData2 = 1000*F2+w2;      % Return the weight information to the treee
    end
    function AlternativeCrossoverWeight()
        L = min(length(subtreeData1),length(subtreeData2)); % Get the minimun length between the trees
        F1 = round(subtreeData1/1000);  % Get the function encoding of the subtree1
        F2 = round(subtreeData2/1000);  % Get the function encoding of the subtree2
        w1 = subtreeData1-1000*F1;      % Get the weights of the subtree1
        w2 = subtreeData2-1000*F2;      % Get the weights of the subtree2
        w1(1:L) = (w1(1:L) + w2(1:L))/2;    
        w2(1:L) = (w1(1:L) + w2(1:L))/2;  
        subtreeData1 = 1000*F1+w1;      % Return the weight information to the treee
        subtreeData2 = 1000*F2+w2;      % Return the weight information to the treee
    end
            
	% Erase the subtree data from the array representing the original tree
 	function array = clearTree(array,node)
        
        depth=floor(log2(find(array, 1, 'last')))-floor(log2(node))+1;  % Get the depth of the 
        if isempty(depth)
            depth = 1;
        end
        cleanIndex = treeGP.generateSubIndex(node, depth);              % Create the index for the erased data
        array(cleanIndex)=0;                                            % Cleanup the subtree data on tree array
    end

end
        