function findBest(Server)
PrintNome = false;
[ExArq, vp60, fp60,vpMSC,fpMSC,increm,curvasTudo,DNATudo ] = GetResultInfo(PrintNome);
addpath('AnaliseCurvas');
DnaMSC = treeGP(2001);
curvaMSC = calcCurve(DnaMSC,Server);

if ExArq
    mkdir('ResultadosDetectores')
    [fitnessIndividuos, individuos_bons] = getBest(vp60,fp60,increm,DNATudo);
    %VpMelhores = vp60(individuos_bons);
    %id = find(VpMelhores == max(VpMelhores));
    id = find(increm == max(increm));
    id = individuos_bons(id);
    id = id(1);
    plotAllBestSNR(curvaMSC,curvasTudo,individuos_bons);
    saveas(gcf,['ResultadosDetectores/CurvaSNRMelhores.png'])
    %plotBest(individuos_bons,fitnessIndividuos);
    %id = find(fitnessIndividuos == max(fitnessIndividuos));
    %id = individuos_bons(id);
    %plotBestSNR(curvaMSC,curvasTudo,id(1));
    plotBestRealData(id,curvaMSC,vp60,fp60,individuos_bons,curvasTudo);
    saveas(gcf,['ResultadosDetectores/CurvaSNRMelhorDetector.png'])
    %equacao = GetEquation(DNATudo,id(1));
    Melhoresincrem = increm(individuos_bons);
    BestDetectorsTest = TestBestDetectors(individuos_bons,DnaMSC,DNATudo(individuos_bons),Melhoresincrem,fpMSC,fp60)
    MelhoresDnas = DNATudo(individuos_bons);
        DNATudo(id).visualizemain;
        set(gcf,'unit','norm','position',[0 0 0.8 0.8]);
        saveas(gcf,['ResultadosDetectores/' 'Dna' num2str(id) 'Detectores.png'])
        DNATudo(id).visualizeweight;
        set(gcf,'unit','norm','position',[0 0 0.8 0.8]);
        saveas(gcf,['ResultadosDetectores/' 'Dna' num2str(id) 'Pesos.png'])
    save('ResultadosDetectores/MelhoresDetectores.mat','BestDetectorsTest','MelhoresDnas')
end

%DnaRef = DNATudo(id);
%[H,p,e1,e2] = McnemarTest60(DnaRef,DnaMSC);

function [ExArq,vp60,fp60,vpMSC,fpMSC,increm,curvasTudo,DNATudo ] = GetResultInfo(PrintNome)
% Obtêm metricas de resultados para um dado experimento realizado
        eegResultsDir = 'ResultadosEEG/';
        evoResultsDir = 'ResultadosEVO/';
        curveResultsDir = 'ResultadosCurva/';
        arquivos = dir([eegResultsDir 'EXP*pop*']);
    %Verifica se existem arquivos no diretório
    if length(arquivos) ~= 0
        %fp30=nan(length(arquivos)*100,1);
        %vp30=nan(length(arquivos)*100,1);
        fp60=nan(length(arquivos)*100,1);
        vp60=nan(length(arquivos)*100,1);
        increm=nan(length(arquivos)*100,1);
        curvasTudo{length(arquivos)*100}=0;
        DNATudo(length(arquivos)) = treeGP();
        cont = 0;
        for i = 1:length(arquivos)
            if PrintNome
                fprintf('Arquivo: %30s\n',arquivos(i).name);
            end
            eeg = load([eegResultsDir arquivos(i).name]);
            Evo = load([evoResultsDir arquivos(i).name]);
            cur = load([curveResultsDir arquivos(i).name]);
            for k = 1:length(eeg.vp60)
                cont = cont+1;
                %vp30(cont)=eeg.vp30(k);
                %fp30(cont)=eeg.fp30(k);
                vp60(cont)=eeg.vp60(k);
                fp60(cont)=eeg.fp60(k);
                increm(cont) = cur.increm(k);
                curvasTudo{cont}=cur.curvas{k};
                DNATudo(cont) = Evo.DNA(k);
            end
        end
        vpMSC = eeg.vpM60(1);
        fpMSC = eeg.fpM60(1);
        ExArq = true;
        disp('Dados Exportados com sucesso')
    else 
        disp('Sem arquivos para análise')
        ExArq = false;
        vp30 = 0; vp60 = 0; fp30 = 0; fp60 = 0; increm = 0; curvasTudo = 0;DNATudo = 0; vpMSC =0; fpMSC =0;
    end
end

function [fitnessIndividuos, individuos_bons] = getBest(vp60,fp60,increm,DNATudo)
%Busca os melhores indivíduos com base no critério de falso e verdadeiro
%positivo simultaneamente
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Carrega dados para analise do fp no fitness
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Dado = load('EEG_sinais/res60Test.mat');     % Carrega os dados dos EEGs reais
    RES60 = Dado.RES;
    RESESP60 = Dado.RESESP;
    
    Dado = load('MC/resX_60.mat'); 
    resLim60 = Dado.resLim;
    Dado = load('MC/resY_60.mat');% Carrega os dados simulados para encontrar o limiar
    res60 = Dado.res;
    clear RES RESESP resLim
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Server = false;
    % Busca os indices do vetor falso positivo e verdadeiro positivo
    critFp60 = find(1 > fp60 > 0);
    critVp60 = find(vp60 > 0);
    critIncrem = find(increm>0);
    cont = 0;
    individuos_bons = [];
    for i = 1:length(critFp60)
        x = critFp60(i);
        for j = 1:length(critVp60)
            y = critVp60(j);
            if x == y
                cont = cont + 1;
                individuos_bons(cont) = x;
            end
        end
    end
    IndividuosBonsIncrem = increm(individuos_bons);
    for i = length(IndividuosBonsIncrem):-1:1
        if IndividuosBonsIncrem(i) < 0
            individuos_bons(i) = [];
        end
    end
    fitnessIndividuos = [];
    cont = 0;
    dominio = -40:0.25:0;
    for i = individuos_bons
        cont = cont +1;
        fitnessIndividuos(cont) = fitness(DNATudo(1,i),Server,res60,resLim60);
        %fitnessIndividuos(cont) = fitness(DNATudo(1,i),Server);
    end
    
end

function plotAllBestSNR(curvaMSC,curvasTudo,individuos_bons)
% busca o fítness dos melhores indivíduos e plota a curva em função da SNR
    dominio = -40:0.25:0;
    for i = individuos_bons
        plot(dominio,curvasTudo{1,i},'g');
        hold on;
    end
    p1 = plot(dominio,curvaMSC,'b');
    p1.DisplayName = 'MSC';
    legend(p1)
    ylabel('PD - Probability of Detection');
    xlabel('SNR (dB)');
    hold on;
    plot(dominio,curvasTudo{1,individuos_bons(1)},'g','DisplayName','Best Ones')
    hold off
    
end

function plotBest(individuos_bons,fitnessIndividuos)
%Plota os melhores indivíduos
    stem(individuos_bons,fitnessIndividuos);
    title('Melhores Indivíduos');
    xlabel('Indivíduo');
    ylabel('Fitness');
end


function plotBestSNR(curvaMSC,curvasTudo,id)
    dominio = -40:0.25:0;
    plot(dominio,curvasTudo{1,id});
    hold on ;
    %load('AnaliseCurvas/curvaMSC.mat');
    plot(dominio,curvaMSC);
    title('Melhor Indivíduo e MSC para valores de SNR');
    ylabel('PD - Probability of Detection');
    xlabel('SNR (dB)');
    hold off;
    legend("Best ORD","MSC");
end

function equacao = GetEquation(DNATudo,id)
%Encontra a equação da melhor ord em latex
    cd AnaliseFuncoes
    equacao = funcoesLatex(DNATudo(id));
    disp(equacao);
    cd ..
end

function plotBestRealData(id,curvaMSC,vp60,fp60,individuos_bons,curvasTudo,DNATudo)
% Encontra A melhor Ord para Dados Reais e plota a curva em dados simulados

dominio = -40:0.25:0;
plot(dominio,curvasTudo{1,id});
hold on ;
%load('AnaliseCurvas/curvaMSC.mat');
plot(dominio,curvaMSC);
title('SNR curve comparing best detector found and MSC');
ylabel('PD - Probability of Detection');
xlabel('SNR (dB)');
hold off;
legend("Best ORD","MSC");
%disp(["FP " string(fp60(id)+fp30(id)/2)])
disp(["VP60 " string(vp60(id))])
%disp(["VP30" string(vp30(id))])
disp(["ID " id])

end

% Realiza o teste de MCnemar para os melhores detectores encontrados
function TestParameters = TestBestDetectors(individuos_bons,DnaMSC,DNAs,increm,fpMSC,fp60)
file = load('MC/resY_60.mat');
res60 = file.res;
file = load('MC/resX_60.mat');
resLim60 = file.resLim;
clear RES RESESP resLim
TestParameters = zeros(length(DNAs),10);
for i = 1:length(DNAs)
    Fitness = fitness(DNAs(i),true,res60,resLim60);
    FitnessMSC = fitness(DnaMSC,true,res60,resLim60);
    [H,p,e1,e2] = McnemarTest60(DnaMSC,DNAs(i));
    TestParameters(i,:) = [i,H,p,e1,FitnessMSC,fpMSC,e2,Fitness,fp60(individuos_bons(i)),increm(i)];
end
TestParameters = array2table(TestParameters);
% Default heading for the columns will be A1, A2 and so on. 
% You can assign the specific headings to your table in the following manner
TestParameters.Properties.VariableNames(1:10) = {'Detector','H','P-Valor','TD-MSC','PD-MSC','FP-MSC','TD-ND','PD-ND','FP-ND','Increm'};
end

function [H,p,e1,e2] = McnemarTest60(DNA1,DNA2)
    Dado = load('EEG_sinais/res60Test.mat');     % Carrega os dados dos EEGs reais 60 Janelas
    RES60 = Dado.RES;
    RESESP60 = Dado.RESESP;
    Dado = load('MC/resX_60.mat');   % Carrega os dados simulados para encontrar o limiar
    resLim60 = Dado.resLim;
    Dado = load('MC/resY_60.mat');   % Carrega os dados simulados para encontrar o limiar
    res60 = Dado.res;
    clear RES RESESP resLim res
    res60DNA1 = funcoes( DNA1, RES60 ); % Aplica as funcoes nos dados reais (pesos e operações do dna do detector)
    res60DNA2 = funcoes( DNA2, RES60 );
    resESP60DNA1 = funcoes( DNA1, resLim60 );
    resESP60DNA2 = funcoes( DNA2, resLim60 );
    limDNA1 = prctile(resESP60DNA1(:),95);
    limDNA2 = prctile(resESP60DNA2(:),95);
    DNA1_Detection = res60DNA1 > limDNA1;
    DNA1_Detection = reshape(DNA1_Detection,1,length(DNA1_Detection));
    DNA2_Detection = res60DNA2 > limDNA2;
    DNA2_Detection = reshape(DNA2_Detection,1,length(DNA2_Detection));
    Reference = zeros(1,length(DNA2_Detection));
    % testa se o a taxa de deteccao do detector de DNA1 é maior que a do detector de
    % DNA2 [H = 0 Não é maior; H= 1 é maior]
    [H,p,e1,e2] = testcholdout(DNA1_Detection,DNA2_Detection,Reference,Test = 'asymptotic');
end

end
