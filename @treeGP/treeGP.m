classdef treeGP < handle
    %TREEGP Tree representation for a specific genetic programming problem
    %   This class manipulate tree data structures as sparse matrix and
    %   implements all necessary methods and properties to do an genetic
    %   programming that searches for an encoded function.
    
    properties (Access=public)
        % ENCODING SYSTEM
        % data = weight+1000*FUNC    for MSC (2001 = 1 + 1000*2).
        %   weight must be between -1 and 1
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
          
	error = setNodesDataAt(this, pos, dataNode)
	nodesData = getNodesDataAt(this, pos)
    [childIndexes] = getChildIndexes(this,parentIndex)
    parentIndex = getParentIndex(this, childIndex)
    data = getData(this)
    subtree = getSubtree(this,root)
    depth = getDepth(this)
    visualizemain(this)
    visualizeweight(this)
    count = getCount(this)
    compression = getCompression(this)
    
    end
    
    methods(Static)
        
    [offspring1, offspring2] = crossNodes(tree1, tree2, node1, node2)
    index = generateSubIndex(root, depth)

    end
end
