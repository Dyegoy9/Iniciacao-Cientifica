function res = funcoesPrimitivas(dna, sinal, sinalB, sinalLFT,~, M, fr)
%FUNCOES Executa uma fun��o representada por uma �rvore
%   Cada operador e fun��o matem�tica utilizada � representado por um
%   �ndice que est� contido na primeira posi��o do vetor data de cada n� da
%   �rvore. Um fator de ponderamento ocupa a segunda posi��o deste vetor.
%   Esta fun��o executa recursivamente cada n� a partir da raiz.
%
%   Entradas
%       sinal  - Matriz MxNxO das transformadas de fourier, apenas das
%                frequ�ncias positivas e j� excluindo-se o n�vel DC. A
%                frequ�ncia de amostragem deve ser identica ao tamanho de
%                uma janela (para facilitar a simula��o, j� que o indice do
%                bin corresponder� � frequ�ncia do mesmo).
%                M - Bins
%                N - Janelas
%                O - Sujeitos
%       sinalLFT - Vers�o do sinal calculado sem janelamento.
%       sinalB - Matriz identica ao sinal, porem sempre contera apenas
%                ruido, equivale a uma coleta sem estimula��o
%       M      - N�mero de janelas
%       fr     - Frequ�ncia a ser testada

L = 10;         % N�mero de bins laterais utilizados no teste F local

    % Fun��o que executa a fun��o descrita pela arvore combinatoria contida no DNA
        if dna==0                  %  0 - Constante
            res = 1;
        elseif dna==1              %  1 - MSC
            res = msc();
        elseif dna==2              %  2 - CSM
            res = csm();
        elseif dna==3              %  3 - TFG
            res = tfg();
        elseif dna==4              %  4 - TFL
            res = tfl();
        elseif dna==5              %  5 - MSC numerador 
            res = msc_n();
        elseif dna==6              %  6 - MSC denominador
            res = msc_d();
        elseif dna==7              %  7 - CSM parcela seno
            res = csm_s();
        elseif dna==8              %  8 - CSM parcela cosseno
            res = csm_c();
        elseif dna==9              %  9 - TFG numerador
            res = tfg_n();
        elseif dna==10             % 10 - TFG denominador
            res = tfg_d();
        elseif dna==11             % 11 - TFL numerador
            res = tfl_n();
        elseif dna==12             % 12 - TFL denominador
            res = tfl_d();
        elseif dna==13             % 13 - CSM hiperb�lica
            res = csm_h();
        elseif dna==14             % 14 - TFL m�dia
            res = tfl_media();
        end
        
    %% MSC
    % Vers�o completa
    function r = msc()
        r = (abs(sum(sinal(fr,1:M,:))).^2)./(sum(abs(sinal(fr,1:M,:)).^2))./M;
    end
    % Numerador
    function r = msc_n()
        r = (abs(sum(sinal(fr,1:M,:))).^2)./M;
    end
    % Denominador
    function r = msc_d()
        r = (sum(abs(sinal(fr,1:M,:)).^2));
    end

    %% CSM
    % Vers�o completa
    function r = csm()
        r = (sum(cos(angle(sinal(fr,1:M,:))))./M).^2+(sum(sin(angle(sinal(fr,1:M,:))))./M).^2;
    end
    % Parcela do seno
    function r = csm_s()
        r = (sum(sin(angle(sinal(fr,1:M,:))))./M).^2;
    end
    % Parcela do cosseno
    function r = csm_c()
        r = (sum(cos(angle(sinal(fr,1:M,:))))./M).^2;
    end
    % Vers�o hiperb�lica
    function r = csm_h()
        r = abs(1-var(cos(angle(sinal(fr,1:M,:))),[],2)./mean(std(cos(angle(sinal(fr+[-5:-1 1:5],1:M,:))),[],2),1));
    end
    
    %% Teste F local normalizado
    % Vers�o completa
    function r = tfl()
        r = (abs(mean(sinalLFT(fr*M,1,:))).^(2))./sum(abs(mean(sinalLFT((fr*M)+[(-L:-L/2)+4 0 (L/2:L)-4],1,:),2)).^(2));
    end
    % Numerador
    function r = tfl_n()
        r = (abs(mean(sinalLFT(fr*M,1,:))).^2);
    end
    % Denominador
    function r = tfl_d()
        r = sum(abs(mean(sinalLFT((fr*M)+[-L:-L/2 L/2:L],1,:),2)).^2)./L;
    end
    % Vers�o adaptada onde o denominador inclui a m�dia dos bins vizinhos e n�o a soma pura
    function r = tfl_media()
        r = (abs(mean(sinalLFT(fr*M,1,:))).^2)./(sum(abs(mean(sinalLFT((fr*M)+[-L/2:-1 0 1:L/2],1,:),2)).^2)./L+(abs(mean(sinalLFT(fr*M,1,:))).^2));
    end
    
    %% Teste F Global normalizado
    % Vers�o completa
    function r = tfg()
        r = sum(abs(sinal(fr,1:M,:)).^2)./...
            (sum(abs(sinal(fr,1:M,:)).^2)+sum(abs(sinalB(fr,1:M,:)).^2));
    end
    % Numerador
    function r = tfg_n()
        r = sum(abs(sinal(fr,1:M,:)).^2);
    end
    % Denominador
    function r = tfg_d()
        r = (sum(abs(sinal(fr,1:M,:)).^2)+sum(abs(sinalB(fr,1:M,:)).^2));
    end
end