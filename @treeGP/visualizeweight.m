function visualizeweight(this)
  %% Creates a visualization for tree weights %%
	depth = this.getDepth();
	n = 1:2^(depth-1)-1;
	p = repelem(n,2);
	p = [0 p];
	treeplot(p);
	[x,y] = treelayout(p);
	NameIndex = {};
	for i = 1:length(p)
                
        data = this.getNodesDataAt(i);
        func = round(data/1000);   % Obtem o indice da funcao
        w = data-func*1000;        % Obtem o peso
        w = full(w);
        w= round(w*10)/10;
        w = string(w);
        NameIndex{i} = w;
    end    
    
	text(x +0.02,y,NameIndex);
    
end