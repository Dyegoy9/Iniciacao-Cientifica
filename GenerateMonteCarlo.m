function GenerateMonteCarlo(Server,SNR)
    DIR = pwd();

    cd('GerarSinaisMonteCarlo')

    if ~Server
        fprintf('Generating simulated signals for GP\n')
    end
    prepareSignals(Server,SNR)

    if ~Server
        fprintf('Generating simulated signals with multiples SNR\n')
    end
    if SNR == -20
        prepareSignalsCurve(Server)
    end
    if ~Server
        fprintf('Preparing real EEG data\n')
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%% Prepara os dados reais de teste %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RAIZ = '../Dados/';
    [RES, RESESP] = PrepareRealDataTest(RAIZ, 60,Server);
    save('../EEG_sinais/res60Test.mat', 'RES', 'RESESP');
    cd ..
end