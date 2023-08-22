function fit = fitness(DNA,Server,res60,resLim60)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%% Fitness: Calcula o fitness do individuo DNA %%%%%%%%%%%
        %%%%%% Entradas: Dna do individuo, Dados ja transformados %%%%%%%%
        %%%%%% pelos detectores , mas nao pela combinacao deles  %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%% Para 60 Janelas %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        %resR60 = funcoes( DNA, resLim60 );
        %lim60 = prctile(resR60(:),95);
        %TD60 = mean(funcoes( DNA, RES60 )>lim60);
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%  For 60 Windows  %%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        resR60 = funcoes( DNA, resLim60 );
        lim60 = prctile(resR60(:),95);
        PD60 = mean(funcoes( DNA, res60 )>lim60);
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%% Uses Detection ratio as fitness (30 Windows) %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        fit = PD60; % Fitness é a probabilidade de deteccao do detector
    
        if isnan(fit) % Garante que o fitness é um numero
            fit = eps;
        end
        DNA.customData =  fit;
    end