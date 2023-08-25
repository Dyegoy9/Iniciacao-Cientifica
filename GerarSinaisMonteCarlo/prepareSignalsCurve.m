function prepareSignalsCurve(Server)
    if ~Server
        NsinaisTotal = 100; %Numero de sinais totais que serao gerados. Obrigatoriamente multiplo de 100
    else
        NsinaisTotal = 50000;
    end
    Njanelas = [60];%[30 60 90 120];
    NFFT = 1000;
    SFREQ = 80;
    FS = 1000;
    Nfun = 14;
    %SNR = -50:10;
    SNR = -40:0.25:0;
    nSNR = length(SNR);
    SNRfun = @()-15+5*randn;    % SNR aleatoria, centrada em -15, com desvio padrao igual a 5
    if ~Server
        tic
    end
    % Prepara os sinais para os numeros de janelas dejesados
    for iJAN = 1:length(Njanelas)
        M = Njanelas(iJAN);
        % Prealoca a matriz final para o numero de janelas atual
        res = nan(Nfun,nSNR,NsinaisTotal/100,100);
        resLim = nan(Nfun,nSNR,NsinaisTotal/100,100);
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
		    for iSinais = 1:NsinaisTotal/100
			    [S1, S2, S3, S4, S5, S6] = genSignals(SNRfun, FS, SFREQ, NFFT, 100, M);
			    for func = 1:Nfun
				    res(func, iSNR, iSinais,:) = funcoesPrimitivas(func, S5, S1, S6, S2, M, SFREQ);
				    resLim(func, iSNR, iSinais,:) = funcoesPrimitivas(func, S3, S1, S4, S2, M, SFREQ);
                end
                if mod(iSinais,10)==0
                    if ~Server
                        fprintf('%4d janelas: %6d de %6d conclu�dos.\n', M, iSinais, NsinaisTotal/100);
                    end
                end
		    end
	    end
        RES = nan(Nfun,nSNR,NsinaisTotal);
        RESLim = nan(Nfun,nSNR,NsinaisTotal);
        for i = 1:NsinaisTotal/100
            RES(:,:,(i-1)*100+1:i*100) = res(:,:,i,:);
            RESLim(:,:,(i-1)*100+1:i*100) = resLim(:,:,i,:);
        end
        res = RES;
        save(sprintf('../MC_curva/resY_%d.mat', M), 'res')
        resLim = RESLim;
        save(sprintf('../MC_curva/resX_%d.mat', M), 'resLim')
    end
end