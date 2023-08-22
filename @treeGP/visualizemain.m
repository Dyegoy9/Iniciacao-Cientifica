function visualizemain(this)
% Graphic visualization of tree
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
        func = full(func);
        w = data-func*1000;        % Obtem o peso
        w = full(w);
        w = string(w);
        r = '';
        % NOS INTERMEDIARIOS
        if func == -10  % Round
        	r = ['round ()'];
        elseif func == -7   % Abs
            r = '||';
        elseif func == -6   % Log
            r = 'log';
        elseif func == -5   % Exponencial
            r = '^';
        elseif func == -4   % Divisao
            r = '\';
        elseif func == -3   % Multiplicacao
            r = '*';
        elseif func == -2   % Subtracao
            r = '-';
        elseif func == -1   % Soma
            r = '+';
            
        % NOS FINAIS
        elseif func == 1    % Constante
            r='';
        elseif func == 2    
            r='MSC';
        elseif func == 3    
            r='CSM';
        elseif func == 4   
            r='TFG';
        elseif func == 5    
            r='TFL';
        elseif func == 6    
            r='MSC_n';
        elseif func == 7    
            r='MSC_d';
        elseif func == 8    
            r='CSM_s';
        elseif func == 9    
            r='CSM_c';
        
        elseif func == 10    
            r='TFG_n';
        elseif func == 11   
            r='TFG_d';
        elseif func == 12  
            r='TFL_n';
        elseif func == 13  
            r='TFL_d';
        elseif func == 14   
            r='CSM_h';
        elseif func == 15   
            r='TFL_m';
        elseif func == 16
            r='RICE';
        end
        
        NameIndex{i} = r;
    end  
    
    text(x +0.01,y,NameIndex);
    disp(NameIndex);

end