function [curve] = calcCurve(DNA)

persistent resLim res

if isempty(res) || isempty(resLim)
    %cd ..
    file = load('GerarSinaisMonteCarlo/../MC_curva/resY_60.mat');
    res = file.res;
    file = load('GerarSinaisMonteCarlo/../MC/resX_60.mat');
    resLim = file.resLim;
end

resR = funcoes( DNA, resLim );
lim_sup5 = prctile(resR(:),95);
[~, n, ~] = size(res);
curve = nan(1,n);
for i = 1:n
    resR = funcoes(DNA, res(:,i,:));
    curve(i)=mean(resR>lim_sup5);
end
end