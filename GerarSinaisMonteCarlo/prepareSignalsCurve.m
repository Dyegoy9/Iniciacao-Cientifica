function prepareSignalsCurve(Server)
    if ~Server
        NsinaisTotal = 1000;%Numero de sinais totais que serao gerados. Obrigatoriamente multiplo de TamanhoGrupo (Pois gera de TamanhoGrupo em TamanhoGrupo)
        TamanhoGrupo = 100;
    else
        NsinaisTotal = 50000;
        TamanhoGrupo = 1000;
    end
    Njanelas = [60];%[30 60 90 120];
    NFFT = 1000;
    SFREQ = 80;
    FS = 1000;
    Nfun = 14;
    %SNR = -50:10;
    SNR = -40:0.25:0;
    nSNR = length(SNR);
    if ~Server
        tic
    end
    % Prepara os sinais para os numeros de janelas dejesados
    for iJAN = 1:length(Njanelas)
        M = Njanelas(iJAN);
        % Prealoca a matriz final para o numero de janelas atual
        res = nan(Nfun,nSNR,NsinaisTotal/TamanhoGrupo,TamanhoGrupo);
        resLim = nan(Nfun,nSNR,NsinaisTotal/TamanhoGrupo,TamanhoGrupo);
	    for iSNR = 1:nSNR
            if ~Server
                toc;
                tic;
            end
		    snr = SNR(iSNR);
		    SNRfun = @()snr;
            if ~Server
                fprintf('SNR %08.3f: ', snr)
            end
		    % Gera os sinais em grupos de 100, para evitar problemas de memoria
		    for iSinais = 1:NsinaisTotal/TamanhoGrupo
			    [S1, S2, S3, S4, S5, S6] = genSignals(SNRfun, FS, SFREQ, NFFT, TamanhoGrupo, M);
			    for func = 1:Nfun
				    res(func, iSNR, iSinais,:) = funcoesPrimitivas(func, S5, S1, S6, S2, M, SFREQ);
				    resLim(func, iSNR, iSinais,:) = funcoesPrimitivas(func, S3, S1, S4, S2, M, SFREQ);
                end
                if mod(iSinais,10)==0
                    if ~Server
                        fprintf('%4d janelas: %6d de %6d conclu�dos.\n', M, iSinais, NsinaisTotal/TamanhoGrupo);
                    end
                end
		    end
	    end
        RES = nan(Nfun,nSNR,NsinaisTotal);
        RESLim = nan(Nfun,nSNR,NsinaisTotal);
        for i = 1:NsinaisTotal/TamanhoGrupo
            RES(:,:,(i-1)*TamanhoGrupo+1:i*TamanhoGrupo) = res(:,:,i,:);
            RESLim(:,:,(i-1)*TamanhoGrupo+1:i*TamanhoGrupo) = resLim(:,:,i,:);
        end
        res = RES;
        save(sprintf('../MC_curva/resY_%d.mat', M), 'res')
        resLim = RESLim;
        save(sprintf('../MC_curva/resX_%d.mat', M), 'resLim')
    end
end