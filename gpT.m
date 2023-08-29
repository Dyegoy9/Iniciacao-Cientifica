function gpT(Server,res60,resLim60,ExpNumber)
% PARAMETERS
% populationSize    - Number of individuals on each generation
% maxGeneration     - Maximun of generations stop criterium
% numberOfElits     - Number of individuals passed through the next generation without crossover neither mutations
% crossoverMaximum  - Maximum times to occur crossover between two individuals, the crossover chance is Uniformly distributed between 1 and crossoverMaximun
% mutationRate      - Rate of mutation
% replaceRate       - Rate of replacements on mutations, decrease will rate will be the complement of this rate
% initMaximumDepth  - Maximum depth of the individuals in the first generation
% initMinimumDepth  - Minimum depth of the individuals in the first generation
% maximumDepth      - Maximum depth possible
% parallel          - Flag to parallel computing of the fitness
    global nBOperators stop;
    stop             = false; % Utilizado para parar manualmente a evolucao na proxima geracao
    if Server 
        parallel = true;
        populationSize   = 1000;
        maxGeneration    = 100;
        numberOfElits    = 100;
    else
        parallel = false;
        populationSize   = 100;
        maxGeneration    = 20;
        numberOfElits    = 10;
    end
    mutationRate     = 0.05;
    replaceRate      = 0.1;
    initMaximumDepth = 3;
    initMinimumDepth = 2;
    maximumDepth     = 5;
    nFunction        = 14;      % Numero de operacoes derivadas de outros detectores
    nBOperators      = 5;       % Numero de operadores binarios
    nUOperators      = 0;       % Numero de operadores unarios

    % GLOBAL VARIABLES
    % pop        - Population of the current generation
    % futPop     - Population of the next generation
    % generation - Current generation counter
    pop(populationSize) = treeGP();
    futPop(populationSize) = treeGP();
    bestOfGeneration(maxGeneration)=treeGP();
    fit = zeros(1,populationSize);     % Vetor dos fitness relativos aos individuos
    bestFit = nan(1,maxGeneration);    % Historico do melhor fitness em cada geracao
    meanFit = nan(1,maxGeneration);    % Historico do fitness medio em cada geracao
    minCount = nan(1,maxGeneration);
    maxCount = nan(1,maxGeneration);
    meanCount = nan(1,maxGeneration);
    minDepth = nan(1,maxGeneration);
    maxDepth = nan(1,maxGeneration);
    meanDepth = nan(1,maxGeneration);
    bestFitDepth = nan(1,maxGeneration);
    bestFitCount = nan(1,maxGeneration);

    EXP = ['ResultadosEVO/EXPERIMENTO*_pop.mat'];
    nexp = length(dir(EXP));
    FILE = ['ResultadosEVO/EXPERIMENTO' ExpNumber '_' num2str(nexp+1)];
    if ~Server
    fprintf('O algoritmo foi inicializado em %s\n',datestr(datetime()))
    t = tic();
    end
    % MAIN ALGORITHM
    generateInitialPop();
    for generation = 1:maxGeneration
        measureFitness();
        elitism();
        crossover();
        mutation();
        pop = futPop;
        bestOfGeneration(generation)=futPop(1);
        if ~Server
        fprintf('Fim da geracao %3d em %s\t\t %8d segundos foram gastos\n',generation, datestr(datetime()), toc(t))
        end
        plotFcn();
        if stopCriterium || stop
            break;
        end
        %t = tic();
    end
    savefig([FILE '.fig']);                       % Salva a figura resultante do GA como fig
    print([FILE '.png'],'-dpng','-noui');         % Salva a figura resultante do GA como PNG

    temp = struct('DNA',pop); 
    save([FILE '_pop.mat'],'-struct','temp');
    temp = struct('DNA',bestOfGeneration); 
    save([FILE '_hist.mat'],'-struct','temp');

        % Create randomly the first generation population
        function generateInitialPop()
            for cont = 1:populationSize
                tree = zeros(1,2^initMaximumDepth-1);
                createTree(initMinimumDepth,initMaximumDepth,1);
                pop(cont) = treeGP(tree);
            end
        
            % Modify recursively the array elements at node position to be an node of the mathematical tree
            function createTree(minLevel,maxLevel, node)
                % Strategy to create a population of trees with uniformly distributed depth
                if minLevel>=1                  % Verify if the minimun number of levels hasn't been achieved, if so the node must be intermediate
                    minLevel = minLevel - 1;    % Decrease the limits to the next recursion
                    maxLevel = maxLevel - 1;
                    flagIntermediate = true;
                else
                    maxLevel = maxLevel - 1;
                    if maxLevel==0              % If the max number of levels has been achieve the node must be terminal
                        flagIntermediate = false;
                    else                        % If not, the node type will be random
                        if rand(1) <= 1/maxLevel
                            flagIntermediate = false;
                        else
                            flagIntermediate = true;
                        end
                    end
                end
                w = rand();            % Create the weight at the pos
                w = min(max(w,0),1);   % Constrain the weight value between -1 and 1
            
                if flagIntermediate
                    operacao = randi([-nUOperators-nBOperators, -1]);    % Chose randomly the intermediate operation
                else
                    operacao = randi([1, nFunction+1]);      % Chose randomly the terminal operation
                end
            
                if flagIntermediate     % If is an indermediate node it will have at least one child
                    createTree(minLevel,maxLevel, node*2)
                    if operacao>=-nBOperators     % If the operation is binary it will have two child
                        createTree(minLevel,maxLevel, node*2+1)
                    end
                end
                tree(node) = operacao*1000+w;       % Change the value in the array that will create the tree
            end
        end

        % Calculate the fitness of the current population
        function measureFitness()
            
            if parallel                             % Uses parfor iff parallel is true
                parfor cont = 1:populationSize
                    fit(cont) = fitness(pop(cont),Server,res60,resLim60);
                end
            else
                for cont = 1:populationSize
                    fit(cont) = fitness(pop(cont),Server,res60,resLim60);
                end
            end
            meanFit(generation)=mean(fit);          % Calculates the mean fitness
            bestFit(generation)=max(fit);           % Calculates the best fitness
        end

        % Breed the individuals using the roulette method
        function crossover()
            for cont=numberOfElits+1:2:populationSize       % Complete the future population with crossbreed individuals
                [pai1, pai2]=roleta();                      % Choose the parents
            
                data1 = pai1.getData();                     % Get the data from parent1
                data1 = data1(1:find(data1(:),1,'last'));   % Cleanup the data and put in column format
                nosPai1 = 1:length(data1);                  % Create an index for each element in data1
                nosPai1 = nosPai1(data1~=0);                % Remove any index whose data is zero
            
                data2 = pai2.getData();
                data2 = data2(1:find(data2(:),1,'last'));
                nosPai2 = 1:length(data2);
                nosPai2 = nosPai2(data2~=0);
            
                no1 = nosPai1(randi(length(nosPai1)));      % Choose randomly the crossover node
                no2 = nosPai2(randi(length(nosPai2)));
                while ~validate()                           % Repeat the choose of the crossover node until it is valid
                    no1 = nosPai1(randi(length(nosPai1)));
                    no2 = nosPai2(randi(length(nosPai2)));
                end
                [filho1, filho2] = treeGP.crossNodes(pai1,pai2,no1,no2);    % Cross the trees in the chosen nodes
                futPop(cont)=filho1;                        % Add each child tree to future population
                futPop(cont+1)=filho2;
            end
        
            % Validate the crossover nodes
            function val = validate()
                filho2Lvl = max(floor(log2(no2))-floor(log2(no1))+floor(log2(max(nosPai1)))+1,floor(log2(max(nosPai1))));  % Calculate the expected child tree depth
                filho1Lvl = max(floor(log2(no1))-floor(log2(no2))+floor(log2(max(nosPai2)))+1,floor(log2(max(nosPai2))));
                if filho1Lvl>maximumDepth || filho2Lvl>maximumDepth     % Compare the depth with the max depth alowed
                    val = false;
                else
                    val = true;
                end
            end
        
            function [pai1, pai2]=roleta()
                maxSorteio = sum(fit);          % Obtém maior valor possível na roleta
                roleta = cumsum(fit);           % Determina os limites superiores de cada indivíduo na roleta
                alvo = rand*maxSorteio;         % Gera aleatoriamente um alvo na roleta
                pai1 = find(roleta>alvo,1);     % Determina qual o índice do indivíduo selecionado
                alvo = rand*maxSorteio;         % Gera aleatoriamente um alvo na roleta
                pai2 = find(roleta>alvo,1);     % Determina qual o índice do indivíduo selecionado
                while(pai2==pai1)               % Repete a escolha do pai2 até que este seja diferente do pai1
                    alvo = rand*maxSorteio;
                    pai2 = find(roleta>alvo,1);
                end
                pai1 = pop(pai1);               % Obtém o índivíduo relativo ao indice sorteado
                pai2 = pop(pai2);               % Obtém o índivíduo relativo ao indice sorteado
            end
        end
        
        % Pass the numberOfElits best individuals in terms of fitness to the next generation without crossover or mutation
        function elitism()
            [~,I]=sort(fit,'descend');                  % Get the index of the sorted fitness
            for i = 1:numberOfElits
                futPop(i)=treeGP(pop(I(i)).getData());  % Copy to the next generation population
            end
            bestFitCount(generation) = pop(I(1)).getCount();
            bestFitDepth(generation) = pop(I(1)).getDepth();
        end

    
        function mutation()
            for i = numberOfElits+1:populationSize
                if rand()<mutationRate
                    dataBeforMutation = futPop(i).customData();  
                    data = futPop(i).getData();                      % Get the data from individual
                    data = data(1:find(data(:),1,'last'));          % Cleanup the data and put in column format
                    nodes = 1:length(data);                         % Create an index for each element in data1
                    nodes = nodes(data~=0); 
                    depth = randi(3);
                        try     % Caso ocorra algum erro na mutacao a mesma sera ignorada
                            no = nodes(randi([1 length(nodes)]));           % Randomly choose a node
                            if rand() < replaceRate                         % Replaces the tree at the chosen node
                                tree = 1:depth;
                                if depth==1
                                    func = round(data(no)/1000);
                                    w = data(no)-func*1000;                    % Get the weigth information
                                    func= randi([1 nFunction+1]);              % Choose a new terminal function to replace
                                    clearTree(futPop(i),no)                    % Cleanup the tree
                                    futPop(i).setNodesDataAt(no,func*1000+w);  % Put the new terminal node in the node place
                                else
                                    try
                                        createTree(1,depth,1);
                                    catch
                                        beep();
                                        pause(1)
                                        beep();
                                        pause(1)
                                        beep();
                                        disp oi
                                    end
                                    index = treeGP.generateSubIndex(no, depth);
                                    clearTree(futPop(i),no);                    % Cleanup the tree
                                    futPop(i).setNodesDataAt(index,tree);
                                end
                            else                                            % Removes the child nodes and replace the node by a terminal node
                                func = round(data(no)/1000);
                                w = data(no)-func*1000;                    % Get the weigth information
                                func= randi([1 nFunction+1]);              % Choose a new terminal function to replace
                                clearTree(futPop(i),no)% Cleanup the tree
                                futPop(i).setNodesDataAt(no,func*1000+w);  % Put the new terminal node in the node place
                            end
                            
                        catch
                            continue;
                        end
                end
            end
        
            % Erase the subtree data from the array representing the original tree
            function clearTree(tree,nodePos)
                depth=floor(log2(find(data, 1, 'last')))-floor(log2(nodePos))+1;  % Get the depth of the subtree 
                cleanIndex = treeGP.generateSubIndex(nodePos, depth);             % Create the index for the erased data
                tree.setNodesDataAt(cleanIndex,0);                                % Cleanup the subtree data on tree array
            end
        
            % Modify recursively the array elements at node position to be an node of the mathematical tree
            function createTree(minLevel,maxLevel, node)
                % Strategy to create a population of trees with uniformly distributed depth
                if minLevel>=1                  % Verify if the minimun number of levels hasn't been achieved, if so the node must be intermediate
                    minLevel = minLevel - 1;    % Decrease the limits to the next recursion
                    maxLevel = maxLevel - 1;
                    flagIntermediate = true;
                else
                    maxLevel = maxLevel - 1;
                    if maxLevel==0              % If the max number of levels has been achieve the node must be terminal
                        flagIntermediate = false;
                    else                        % If not, the node type will be random
                        if rand(1) <= 1/maxLevel
                            flagIntermediate = false;
                        else
                            flagIntermediate = true;
                        end
                    end
                end
                w = rand();            % Create the weight at the pos
                w = min(max(w,0),1);          % Constrain the weight value between -1 and 1
            
                if flagIntermediate
                    operacao = randi([-12, -1]);    % Chose randomly the intermediate operation
                else
                    operacao = randi([1, 25]);      % Chose randomly the terminal operation
                end
            
                if flagIntermediate     % If is an indermediate node it will have at least one child
                    createTree(minLevel,maxLevel, node*2)
                    if operacao>=-7     % If the operation is binary it will have two child
                        createTree(minLevel,maxLevel, node*2+1)
                    end
                end
                tree(node) = operacao*1000+w;       % Change the value in the array that will create the tree
            end
        end

        % Plot the best and mean fitness across the generations
        function plotFcn()
            depth = zeros(1,populationSize);
            count = zeros(1,populationSize);
            for i = 1:populationSize
                depth(i) = nan;
                try
                    depth(i) = pop(i).getDepth();
                catch
                    warning('Error while trying to get tree depth');
                end
                count(i) = pop(i).getCount();
            end
            minCount(generation) = min(count);
            maxCount(generation) = max(count);
            meanCount(generation) = mean(count);
            minDepth(generation) = min(depth);
            maxDepth(generation) = max(depth);
            meanDepth(generation) = mean(depth(~isnan(depth)));
        
            clf
            subplot(2,2,[2 4])
            plot(bestFit,'r')
            hold on
            plot(meanFit,'k')
            ylabel('Fitness (PD)')
            xlim([0 maxGeneration])
            xlabel('Generation')
        
            subplot(2,2,1)
            plot(minCount,'.-b')
            hold on
            plot(meanCount,'.-k')
            plot(maxCount,'.-r')
            plot(bestFitCount, 'om')
            ylabel('Count')
            xlim([0 maxGeneration])
        
            subplot(2,2,3)
            plot(minDepth,'.-b')
            hold on
            plot(meanDepth,'.-k')
            plot(maxDepth,'.-r')
            plot(bestFitDepth, 'om')
            ylabel('Depth')
            xlim([0 maxGeneration])
            xlabel('Generation')
        
            drawnow
        end

        function stop = stopCriterium()
            stop = generation>=maxGeneration;
        end
end