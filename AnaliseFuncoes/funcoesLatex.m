function [ res ] = funcoesLatex(dna)
%Arrumar

%FUNCOES Executa uma funcao representada por uma �rvore
%   Cada operador e funcao matematica utilizada � representado por um
%   �ndice que est� contido na primeira posi��o do vetor data de cada n� da
%   �rvore. Um fator de ponderamento ocupa a segunda posi��o deste vetor.
%   Esta fun��o executa recursivamente cada n� a partir da raiz.
%   
%   Entradas:
%       raiz   - N� raiz da �rvore que representa a fun��o a ser calculada
%       sinal  - Matriz MxNxO das transformadas de fourier, apenas das
%                frequ�ncias positivas e j� excluindo-se o n�vel DC. A
%                frequ�ncia de amostragem deve ser identica ao tamanho de
%                uma janela (para facilitar a simula��o, j� que o indice do
%                bin corresponder� � frequ�ncia do mesmo).
%                M - Bins
%                N - Janelas
%                O - Sujeitos
%       sinalB - Matriz identica ao sinal, porem sempre contera apenas
%                ruido, equivale a uma coleta sem estimula��o
%       M      - N�mero de janelas
%       fr     - Frequ�ncia a ser testada

L = 10;             % N�mero de bins laterais utilizados no teste F local
res = abs(exec(1));   % Executa o primeiro no da arvore
res = sprintf('%s',res);
    % Fun��o que executa a fun��o descrita pela arvore combinatoria contida no DNA
    function r = exec(no)
                          % Tenta acesar o primeiro n�
        d = full(dna.getNodesDataAt(no));
  
        func = round(d/1000);   % Obt�m o �ndice da fun��o
        w = d-func*1000;        % Obt�m o peso
        r = '';
        % N�S INTERMEDI�RIOS
        if func == -12      % Ceil
            r = ['\left \lceil ' exec(no*2) ' \right \rceil'];
        elseif func == -11  % Floor
            r = ['\left \lfloor ' exec(no*2) ' \right \rfloor'];
        elseif func == -10  % Round
            r = ['round \left ( ' exec(no*2) ' \right )'];
        elseif func == -9   % Abs
            r = ['\left | ' exec(no*2) ' \right |'];
        elseif func == -8   % Log
            r = ['\ln \left ( \left | ' exec(no*2) ' \right | \right )'];
        elseif func == -7   % M�nimo
            r = ['\min \left\{ ' exec(no*2) ',' exec(no*2+1) ' \rigth\}'];
        elseif func == -6   % M�ximo
            r = ['\max \left\{ ' exec(no*2) ',' exec(no*2+1) ' \rigth\}'];
        elseif func == -5   % Exponencial
            r = [exec(no*2) ' ^{ ' exec(no*2+1) ' }'];
        elseif func == -4   % Divis�o
            r = ['\frac{ ' exec(no*2) ' }{ ' exec(no*2+1) ' }'];
        elseif func == -3   % Multiplica��o
            r = [exec(no*2) ' \times ' exec(no*2+1)];
        elseif func == -2   % Subtra��o
            r = [exec(no*2) ' - ' exec(no*2+1)];
        elseif func == -1   % Soma
            r = [exec(no*2) ' + ' exec(no*2+1)];
        
        % N�S FINAIS
        elseif func == 1    % Constante
            r=' ';
        elseif func == 2    % M�dia de Yi(f)
            r='\frac{1}{M}\sum_{j=1}^{M}Y_i(f_0)';
        elseif func == 3    % M�dia de Xi(f)
            r='\frac{1}{M}\sum_{j=1}^{M}X_i(f_0)';
        elseif func == 4    % M�dia de |Yi(f)|^2
            r='\frac{1}{M}\sum_{j=1}^{M}\left | Y_i(f_0) \right |^2';
        elseif func == 5    % M�dia de |Xi(f)|^2
            r='\frac{1}{M}\sum_{j=1}^{M}\left | X_i(f_0) \right |^2';
        elseif func == 6    % M�dia da m�dia da FFT dos L bins laterais de Yi(f) em cada janela
            r='\frac{1}{LM}\sum_{k=-L/2 ; k\neq 0}^{L/2}\sum_{j=1}^{M} Y_i(f_{0+k})';
        elseif func == 7    % M�dia da m�dia da FFT dos L bins laterais de Xi(f) em cada janela
            r='\frac{1}{LM}\sum_{k=-L/2 ; k\neq 0}^{L/2}\sum_{j=1}^{M} X_i(f_{0+k})';
        elseif func == 8    % M�dia da m�dia da energia dos L bins laterais de Yi(f) em cada janela
            r='\frac{1}{LM}\sum_{k=-L/2 ; k\neq 0}^{L/2}\sum_{j=1}^{M}\left | Y_i(f_{0+k}) \right |^2';
        elseif func == 9    % M�dia da m�dia da energia dos L bins laterais de Xi(f) em cada janela
            r='\frac{1}{LM}\sum_{k=-L/2 ; k\neq 0}^{L/2}\sum_{j=1}^{M}\left | X_i(f_{0+k}) \right |^2';
        
        elseif func == 10    % M�dia dos cossenos da fase de Yi(f)
            r='\frac{1}{M}\sum_{j=1}^{M} \cos \phi_{Y_i}(f_{0})';
        elseif func == 11   % M�dia dos senos da fase de Yi(f)
            r='\frac{1}{M}\sum_{j=1}^{M} \sin \phi_{Y_i}(f_{0})';
        elseif func == 12   % M�dia dos cossenos da fase de Yi(f) ao quadrado
            r='\frac{1}{M}\sum_{j=1}^{M} \cos^2 \phi_{Y_i}(f_{0})';
        elseif func == 13   % M�dia dos senos da fase de Yi(f) ao quadrado
            r='\frac{1}{M}\sum_{j=1}^{M} \sin^2 \phi_{Y_i}(f_{0})';
        elseif func == 14   % M�dia dos cossenos hiperb�lico da fase de Yi(f)
            r='\frac{1}{M}\sum_{j=1}^{M} \cosh \phi_{Y_i}(f_{0})';
        elseif func == 15   % M�dia dos senos hiperb�lico da fase de Yi(f)
            r='\frac{1}{M}\sum_{j=1}^{M} \sinh \phi_{Y_i}(f_{0})';
        elseif func == 16   % M�dia dos cossenos hiperb�lico da fase de Yi(f) ao quadrado
            r='\frac{1}{M}\sum_{j=1}^{M} \cosh^2 \phi_{Y_i}(f_{0})';
        elseif func == 17   % M�dia dos senos hiperb�lico da fase de Yi(f) ao quadrado
            r='\frac{1}{M}\sum_{j=1}^{M} \sinh^2 \phi_{Y_i}(f_{0})';
            
        elseif func == 18   % Vari�ncia da fase de Yi(f)
            r = 'Var \left [ \phi_{Y}(f_{0}) \right ]';
        elseif func == 19   % Vari�ncia da fase de Xi(f)
            r = 'Var \left [ \phi_{X}(f_{0}) \right ]';
        elseif func == 20   % M�dia da [vari�ncia da fase dos bins laterais de Yi(f) ao longo das lanelas]
            r = '\frac{1}{L} \sum_{k=-L/2;k \neq 0}^{L/2} Var \left [ \phi_{Y}(f_{0+k}) \right ]';
        elseif func == 21   % M�dia da [vari�ncia da fase dos bins laterais de Xi(f) ao longo das lanelas]
            r = '\frac{1}{L} \sum_{k=-L/2;k \neq 0}^{L/2} Var \left [ \phi_{X}(f_{0+k}) \right ]';
            
        elseif func == 22   % Vari�ncia da parte real de Yi(f)
            r = 'Var \left [ \Re(Y(f_{0})) \right ]';
        elseif func == 23   % Vari�ncia da parte real de Xi(f)
            r = 'Var \left [ \Re(X(f_{0})) \right ]';
        elseif func == 24   % M�dia da [vari�ncia da parte real dos bins laterais de Yi(f) ao longo das lanelas]
            r = '\frac{1}{L} \sum_{k=-L/2;k \neq 0}^{L/2} Var \left [ \Re(Y(f_{0+k})) \right ]';
        elseif func == 25   % M�dia da [vari�ncia da parte real dos bins laterais de Xi(f) ao longo das lanelas]
            r = '\frac{1}{L} \sum_{k=-L/2;k \neq 0}^{L/2} Var \left [ \Re(X(f_{0+k})) \right ]';
        end
        %r = [num2str(w) r];
    end
end