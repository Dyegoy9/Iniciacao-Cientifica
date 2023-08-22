function [ res ] = funcoesLatex2(dna)
%Arrumar

%FUNCOES Executa uma fun��o representada por uma �rvore
%   Cada operador e fun��o matem�tica utilizada � representado por um
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
        if func == -10  % Round
            r = ['round (' exec(no*2) ')'];
        elseif func == -7   % Abs
            r = ['\left|' exec(no*2) '\right|'];
        elseif func == -6   % Log
            r = ['\ln  (\left|' exec(no*2) '\right|)'];
        elseif func == -5   % Exponencial
            r = [exec(no*2) ' ^{' exec(no*2+1) '}'];
        elseif func == -4   % Divis�o
            r = ['\frac{ ' exec(no*2) ' }{ ' exec(no*2+1) ' }'];
        elseif func == -3   % Multiplica��o
            r = [ exec(no*2) ' \times ' exec(no*2+1)];
        elseif func == -2   % Subtra��o
            r = [exec(no*2) ' - ' exec(no*2+1)];
        elseif func == -1   % Soma
            r = [exec(no*2) ' + ' exec(no*2+1)];
            
        % N�S FINAIS
        elseif func == 1    % Constante
            r=' ';
        elseif func == 2    % M�dia de Yi(f)
            r='MSC';
        elseif func == 3    % M�dia de Xi(f)
            r='CSM';
        elseif func == 4    % M�dia de |Yi(f)|^2
            r='TFG';
        elseif func == 5    % M�dia de |Xi(f)|^2
            r='TFL';
        elseif func == 6    % M�dia da m�dia da FFT dos L bins laterais de Yi(f) em cada janela
            r='MSC_n';
        elseif func == 7    % M�dia da m�dia da FFT dos L bins laterais de Xi(f) em cada janela
            r='MSC_d';
        elseif func == 8    % M�dia da m�dia da energia dos L bins laterais de Yi(f) em cada janela
            r='CSM_s';
        elseif func == 9    % M�dia da m�dia da energia dos L bins laterais de Xi(f) em cada janela
            r='CSM_c';
        
        elseif func == 10    % M�dia dos cossenos da fase de Yi(f)
            r='TFG_n';
        elseif func == 11   % M�dia dos senos da fase de Yi(f)
            r='TFG_d';
        elseif func == 12   % M�dia dos cossenos da fase de Yi(f) ao quadrado
            r='TFL_n';
        elseif func == 13   % M�dia dos senos da fase de Yi(f) ao quadrado
            r='TFL_d';
        elseif func == 14   % M�dia dos cossenos hiperb�lico da fase de Yi(f)
            r='CSM_h';
        elseif func == 15   % M�dia dos senos hiperb�lico da fase de Yi(f)
            r='TFL_m';
        end
        r = [sprintf('%4.2f',w) '(' r ')'];
    end
end