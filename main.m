clear;clc;close;
Server = true;
GerarDados = true;
DeleteMonteCarloData = false;
RunEvo = true;
%
RunPG(Server,GerarDados,DeleteMonteCarloData,RunEvo);
function RunPG(Server,GerarDados,DeleteMonteCarloData,RunEvo)
    %%%Server%%% 
    %  controla se queremos rodar o código com parâmetros de servidos
    %   true - Parametros de servidor, como processamento paralelo e
    %   geração de montecarlo com 50mil dados e muita memória ram
    %  false - Parâmetros de computador local poucos dados simulados e sem
    %  processamento paralelo
    
    %%%GerarDados%%% 
    %   Controla se queremos ou não gerar dados por simulação
    %   de montecarlo com base nas funções primitivas pré estabelecidas
    
    %%%DeleteMonteCarloData%%% 
    %   Se voce for realizar outro experimento e não
    %   quiser que os dados se misturem, isto apaga todos os dados dos
    %   experimentos anteriores.
    
    
    if ~Server
        NumRep = 1;
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
        if ~Server
            gpT(Server,res60,resLim60,'1');
        else
          parfor i = 1:NumRep  
            gpT(Server,res60,resLim60,num2str(i));
            %gpT(Server);
            end
        end
        cd AnaliseCurvas
        CalcularCurvasResultados(Server);
        analiseVP(Server,res60,resLim60);
        close all;clc;
        findBest(Server);
    end
    exit();
end