clear;clc;close;
Server = true;
GerarDados = true;
DeleteMonteCarloData = true;
RunEvo = true;
%
RunPG(Server,GerarDados,DeleteMonteCarloData,RunEvo);
function RunPG(Server,GerarDados,DeleteMonteCarloData,RunEvo)
    %%%Server%%% Variavel que controla fatores para rodar como teste ou no servidor% false : tira os prints e warnigs e não salva as imagens referentes a
    %   evolução dos detectores nem as mostra na tela.
    %   true : mostra todos os prints bem como salva e mostra as figuras
    
    %%%GerarDados%%% Controla se queremos ou não gerar dados por simulação
    %   de montecarlo com base nas funções primitivas pré estabelecidas
    
    %%%DeleteMonteCarloData%%% Se voce for realizar outro experimento e não
    %   quiser que os dados se misturem, isto apaga todos os dados dos
    %   experimentos anteriores.
    
    
    if Server
        NumRep = 20;
    else 
        NumRep = 20;
    end
    %Gera os diretórios necessários e faz backup do experimento anterior
    if DeleteMonteCarloData
        if isdir('MC')
            rmdir('MC','s');
        end
        if isdir('MC_curva')
            rmdir('MC_curva','s');
        end
        if isdir('EEG_sinais')
            rmdir('EEG_sinais','s');
        end
        if isdir('ResultadosEVO')
            rmdir('ResultadosEVO','s');
        end
        if isdir('ResultadosCurva')
            rmdir('ResultadosCurva','s');
        end
        if isdir('ResultadosEEG')
            rmdir('ResultadosEEG','s');
        end
    end
    
    try
        mkdir('MC')
        mkdir('MC_curva')
        mkdir('EEG_sinais')
        mkdir('ResultadosEVO')
        mkdir('ResultadosCurva')
        mkdir('ResultadosEEG')
    catch
    end
    if GerarDados
        GenerateMonteCarlo(Server)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%% Carrega dados para analise do fp no fitness %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load('EEG_sinais/res60Test.mat');     % Carrega os dados dos EEGs reais
    RES60 = RES;
    RESESP60 = RESESP;
    
    file = load('MC/resY_60.mat');
    res60 = file.res;
    file = load('MC/resX_60.mat');
    resLim60 = file.resLim;
    
    clear RES RESESP resLim
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%% Roda o argoritmo NumRep Vezes %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if RunEvo
        for i = 1:NumRep  
            gpT(Server,res60,resLim60);
            %gpT(Server);
        end
        cd AnaliseCurvas
        CalcularCurvasResultados(Server);
        analiseVP(Server,res60,resLim60);
        close all;
        findBest();
    end
    exit()
end