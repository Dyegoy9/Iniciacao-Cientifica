function prepareSignals(Server)
    if ~Server
        NsinaisTotal = 1000;%Numero de sinais totais que serao gerados. Obrigatoriamente multiplo de TamanhoGrupo (Pois gera de TamanhoGrupo em TamanhoGrupo)
        TamanhoGrupo = 100;
    else
        NsinaisTotal = 50000;
        TamanhoGrupo = 5000;
    end
    Njanelas = [60];% 90 120];
    NFFT = 1000;
    SFREQ = 80;
    FS = 1000;
    %SNRfun = @()-15+5*randn;    % SNR aleatoria, centrada em -15, com desvio padrao igual a 10
    snr = -15;
    SNRfun = @()snr;
    Nfun = 14;

    % Prepara os sinais para os numeros de janelas dejesados
    for iJAN = 1:length(Njanelas)
        M = Njanelas(iJAN);
        % Prealoca a matriz final para o numero de janelas atual
        res = nan(Nfun,1,NsinaisTotal/TamanhoGrupo,TamanhoGrupo);
        resLim = nan(Nfun,1,NsinaisTotal/TamanhoGrupo,TamanhoGrupo);
        % Gera os sinais em grupos de 100, para evitar problemas de memoria
        for iSinais = 1:NsinaisTotal/TamanhoGrupo
            [S1, S2, S3, S4, S5, S6] = genSignals(SNRfun, FS, SFREQ, NFFT, TamanhoGrupo, M);
            for func = 1:Nfun
                res(func, 1, iSinais,:) = funcoesPrimitivas(func, S5, S1, S6, S2, M, SFREQ);
                resLim(func, 1, iSinais,:) = funcoesPrimitivas(func, S3, S1, S4, S2, M, SFREQ);
            end
            if ~Server
                fprintf('%4d janelas: %6d de %6d conclu�dos.\n', M, iSinais, NsinaisTotal/TamanhoGrupo);
            end
        end
        RES = nan(Nfun,1,NsinaisTotal);
        RESLim = nan(Nfun,1,NsinaisTotal);
        for i = 1:NsinaisTotal/TamanhoGrupo
            RES(:,:,(i-1)*TamanhoGrupo+1:i*TamanhoGrupo) = res(:,:,i,:);
            RESLim(:,:,(i-1)*TamanhoGrupo+1:i*TamanhoGrupo) = resLim(:,:,i,:);
        end
        res = RES;
        save(sprintf('../MC/resY_%d.mat', M), 'res')
        resLim = RESLim;
        save(sprintf('../MC/resX_%d.mat', M), 'resLim')
    end
end
