function [ resR ] = funcoes( dna, res)
%FUNCOES Executa uma funcao representada por uma arvore
%   Cada operador e funcao matematica utilizada é representado por um
%   indice que esta contido na primeira posicao do vetor data de cada no da
%   arvore. Um fator de ponderamento ocupa a segunda posicao deste vetor.
%   Esta funcao executa recursivamente cada no a partir da raiz.
%   
%   Entradas:
%       dna - arvore que representa a funcao a ser calculada
%       res - Matriz com os resultados das operacoes primitivas para a base de dados testada.

[m,~,~] = size(res);
R=res(1,1,:)*nan;     % Pre-allocates with NaN
resR = abs(exec(1));   % Executa o primeiro no da arvore

    % Funcao que executa a funcao descrita pela arvore combinatoria contida no DNA
    function r = exec(no)
        
         r=R;
         try                     % Tenta acesar o primeiro no
            d = full(dna.getNodesDataAt(no));
         catch                   % Em caso de erro retorna NaN
             return;
         end
        func = round(d/1000);   % Obtem o indice da funcao
        w = d-func*1000;        % Obtem o peso
        
        if func>0               % Verify if the function index is more than zero to decrement by one
            func = func-1;
        elseif func==0          % If the function index already is zero, returns NaN
            return;
        end
        
        if func>m               % Verify if the function is not in the 'res' variable
            return;
        end
        
        % NOS INTERMEDIARIOS
        if func == -4   % Divisao
            r = exec(no*2)./exec(no*2+1);
        elseif func == -3   % Multiplicacao
            r = exec(no*2).*exec(no*2+1);
        elseif func == -2   % Subtracao
            r = exec(no*2)-exec(no*2+1);
        elseif func == -1   % Soma
            r = exec(no*2)+exec(no*2+1);
        
        % NOS FINAIS
        elseif func == 0    % Constante
            r=res(1,1,:)*0+1;
        elseif func>0
            r = res(func,1,:);
        end
        r = r.*w;
    end
end
