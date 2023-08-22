function analiseVP(Server,res60,resLim60)
    % Faz a análise dos falsos positivos com base em dados de EEG Reais 
    outdir = 'ResultadosEEG';
    
    load('EEG_sinais/res60Test.mat');     % Carrega os dados dos EEGs reais
    RES60 = RES;
    RESESP60 = RESESP;

    %load('MC/resX_60.mat')   % Carrega os dados simulados para encontrar o limiar
    %resLim60 = resLim;
    %load('MC/resX_30.mat')   % Carrega os dados simulados para encontrar o limiar
    %resLim30 = resLim;
    clear RES RESESP resLim

    %Calculo para a MSC
    MSCdna = treeGP(2001);
    %resR30 = funcoes( MSCdna, resLim30 );
    %lim30 = prctile(resR30(:),95);
    %vpM30 = mean(funcoes( MSCdna, RES30 )>lim30);
    %fpM30 = mean(funcoes( MSCdna, RESESP30 )>lim30);
    resR60 = funcoes( MSCdna, resLim60 );
    lim60 = prctile(resR60(:),95);
    vpM60 = mean(funcoes( MSCdna, RES60 )>lim60);
    fpM60 = mean(funcoes( MSCdna, RESESP60 )>lim60);


    TOKEN = {'ResultadosEVO/EXPERIMENTO1*_pop.mat', 'ResultadosEVO/EXPERIMENTO1*_hist.mat'};

    for i = 1:2
        files = dir(TOKEN{i});
        for j = 1:length(files)
            if Server
                tic
            end
            arquivo = files(j).name;    % Obtem o nome do arquivo do experimento analisado
            dados = load(['ResultadosEVO/' arquivo]);      % Carrega o arquivo
            nDNAs = length(dados.DNA);  % Obtem o numero de DNAs no experimento em questao
            %vp30 = nan(1,nDNAs);
            %fp30 = vp30;
            vp60 = nan(1,nDNAs);
            fp60 = vp60;
            for k = 1:nDNAs
                DNA = dados.DNA(k);
                %resR30 = funcoes( DNA, resLim30 );
                resR60 = funcoes( DNA, resLim60 ); 
                %lim30 = prctile(resR30(:),95);
                lim60 = prctile(resR60(:),95);
                %vp30(k) = mean(funcoes( DNA, RES30 )>lim30); 
                vp60(k) = mean(funcoes( DNA, RES60 )>lim60);
                %fp30(k) = mean(funcoes( DNA, RESESP30 )>lim30);
                fp60(k) = mean(funcoes( DNA, RESESP60 )>lim60);
            end
            save([outdir '/' arquivo],'vp60','fp60','vpM60','fpM60')
            if Server
                fprintf('Arquivo %30s       %f segundos\n',arquivo, toc);
            end
    end
end
