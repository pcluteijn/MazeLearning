function pltConvergence(T,nr,nc,S,nW,gamma,alpha,epsilon,lambda,tlp,sFile)
% Convergence plot
% -------------------------------------------------------------------------
%   
%   Function :
%   pltConvergence(T)
%   
%   Inputs :
%   T - Array containing the number of itteration per episode 
%   
% -------------------------------------------------------------------------
%   Author  : P.C. Luteijn
%   email   : p.c.luteijn@gmail.com
%   Date    : July 2017
%   Comment : Plots the convergence of the solution. 
% -------------------------------------------------------------------------

    % Maximum iterations
    maxT = max(T);

    % Process information
    strMaze = sprintf('%ix%i',nr,nc);
    strProcess = sprintf([ ...
        'Maze    : %10s\n', ...
        'Seed    : %10i\n', ...
        'Wall    : %10i\n', ... 
        'gamma   : %10.2f\n', ...
        'alpha   : %10.2f\n', ...
        'epsilon : %10.2f\n', ...
        'lambda  : %10.2f\n', ...
        'tlp     : %10i\n', ...
        'MaxItt  : %10i'], ...
        strMaze,S,nW,gamma,alpha,epsilon,lambda,tlp,maxT);
    
    % Plot figure
    figure('Name','Convergence'), plot(1:length(T),T), grid on
    xlabel('episodes [-]'), ylabel('iterations [-]')
    ylim([0,1.05*max(T)])
    
    % Add textbox
    axPos = get(gca,'Position');
    xx = 1.5*axPos(1) + axPos(3);
    yy = 1.5*axPos(2) + axPos(4);
    text(xx,yy,strProcess, ... 
        'Units', 'Normalized', ...
        'HorizontalAlignment', 'Right', ...
        'VerticalAlignment', 'Top', ...
        'FontName','FixedWidth')
    
    % Save file
    if exist('sFile','var')
        strSave = [ '../Report/figures/' sFile '.png' ];
        saveas(gcf,strSave)
    end
    
end