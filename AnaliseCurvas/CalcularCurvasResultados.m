function CalcularCurvasResultados(Server)
    cd('..')
    MSCdna = treeGP(2001);
    addpath('AnaliseCurvas');
    TOKEN = {'ResultadosEVO/EXPERIMENTO1*_pop.mat'};%, 'ResultadosEVO/EXPERIMENTO1*_hist.mat'};
    %SNR = -50:10;
    SNR = -40:0.25:0;
    curvaMSC = calcCurve(MSCdna);
    ind10 = find(curvaMSC>0.1,1);
    ind95 = find(curvaMSC>0.95,1);

    for i = 1:1
        files = dir(TOKEN{i}); %dir(TOKEN{i});
        for j = 1:length(files)
            if Server
                tic;
            end
            arquivo = files(j).name;    % Obt�m o nome do arquivo do experimento analisado
            dados = load(['ResultadosEVO/' arquivo]);      % Carrega o arquivo
            nDNAs = length(dados.DNA);  % Obt�m o n�mero de DNAs no experimento em quest�o
            curvas = cell(nDNAs,1);     % Prealoca um cell array para as curvas
            increm = nan(nDNAs,1);      % Prealoca o vetor com os incrementos
            for k = 1:nDNAs
                X = calcCurve(dados.DNA(k));
                curvas{k} = X;
                increm(k) = trapz(X(ind10:ind95)-curvaMSC(ind10:ind95))/trapz(curvaMSC(ind10:ind95))*100;
            end
            save(['ResultadosCurva/' arquivo],'curvas','increm');
            if Server
                fprintf('Arquivo %30s       %f segundos\n',arquivo, toc);
            end
        end
    end
end