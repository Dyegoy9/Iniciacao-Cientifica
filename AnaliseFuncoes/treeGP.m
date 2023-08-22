classdef treeGP < handle
    %TREEGP Tree representation for a specific genetic programming problem
    %   This class manipulate tree data structures as sparse matrix and
    %   implements all necessary methods and properties to do an genetic
    %   programming that searches for an encoded function.
    
    properties (Access=public)
        % ENCODING SYSTEM
        % data = weight+1000*FUNC
        %   weight must be between -100 and 100
        data    % Sparse square matrix that storages the encoded nodes
        customData
    end
    
    properties (Access = public, Constant)
        maxDepth = 20;  % Max allowed depth, due to memmory limitations
    end
    
    methods (Access = public)
        % Constructor
        function this=treeGP(data,customData)
            this.data = [];
            this.customData =[];
            if nargin == 0
                return;
            elseif nargin ==2
                this.customData = customData;
            end
            data = data(:);                         % Transform to column form
            data(find(data(:), 1, 'last')+1:end)=[];% Cleanup the data array
            count = length(data);                   % Get the data size
            n = ceil(log2(count)/2);                % Get the size of the sqare matrix that will storage the data
            this.data = sparse(2^n,2^n);            % Create the square matrix
            this.data(1:count)=data(:);             % Copy the received data to data matrix
        end
        
        % Return the data at the desired positions
        function nodesData = getNodesDataAt(this, pos)
            nodesData = this.data(pos);
        end
        
        function error = setNodesDataAt(this, pos, dataNode)
            try
                this.data(pos) = dataNode;
                error = false;
            catch
                error = true;
            end
        end
        
        % Get the index of child nodes 
        function [childIndexes] = getChildIndexes(this,parentIndex)
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
        
        % Get the index of the parent node
        function parentIndex = getParentIndex(this, childIndex)
            parentIndex = floor(childIndex/2);
            if parentIndex <=0 || this.data(parentIndex)==0
                parentIndex = nan;
            end
        end
        
        % Returns a new tree representing the subtree that has the desired root index
        function subtree = getSubtree(this,root)
            newDepth = this.getDepth()-floor(log2(root));       % Get the subtree predicted depth
            newVector=treeGP.generateSubIndex(root,newDepth);   % Create the index of the subtree on the original tree
            newVector(newVector>numel(this.data))=[];
            try
                subtree = treeGP(this.data(newVector));             % Create the new treeGP object representing the subtree
            catch
                disp oi
            end
        end
        
        % Obtém uma cópia da árvore
        function data = getData(this)
            data = this.data;
        end
        
        % Get the depth of the tree
        function depth = getDepth(this)
            last = find(this.data(:), 1, 'last' );  % Get the position of the last non zero element
            depth = floor(log2(last))+1;            % Find the layer of the found position
        end
        
        % Graphic visualization of the tree
        function visualize(this)
%             if isempty(which('TreeView'))                       % Verify if the .NET dll hasn't been already imported
                NET.addAssembly([pwd '\TreeView.dll']);          % Import the .NET dll
%             end
            array = this.data(1:find(this.data(:), 1, 'last' ));% Get the data as an columnarray
            array = full(array);                                % Transform the array to full format
            array(array==0)=nan;                                % Replace the zeros by NaN
            TreeView.Viewer(NET.convertArray(array));           % Show the graphic visualization
        end
        
        % Get the number of tree nodes
        function count = getCount(this)
            count = nnz(this.data);
        end
        
        % Get the compression ratio of the stored data
        function compression = getCompression(this)
            fullData = full(this.data);                     % Get the full matrix version of the data
            fullData(2^this.getDepth():end)=[]; %#ok<NASGU> % Eliminate the non-used data from the full matrix
            data = this.data; %#ok<PROP,NASGU>              % Get the sparse matrix data
            s = whos('fullData','data');                    % Get information about the variables
            compression = s(1).bytes/s(2).bytes;            % Calculate the compression rate
        end
    end
    
    methods(Static)
        % Execute the crossover between two trees at the specified nodes
        function [offspring1, offspring2] = crossNodes(tree1, tree2, node1, node2)
            global nBOperators
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
                alpha = 0.2;                    % Extra possible span
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
        
        % Creates recursively the subtree indexing starting in the desired root
        function index = generateSubIndex(root, depth)
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

    end
end
