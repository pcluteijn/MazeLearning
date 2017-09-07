function [h1,h2] = pltActionValue(M,HQ,pxlCellWidth,doSurf,sFile)
% Sensitivity Analysis
% -------------------------------------------------------------------------
%   
%   Function :
%   pltSensitivityAnalysis(M,H,pxlCellWidth)
%   
%   Inputs :
%   M        - Multi layer maze structure cell array
%   nTLP     - Number of teleportation pairs
%   gamma    - Discount parameter
%   alpha    - Learningrate parameter
%   epsilon  - Probability of random action in e-greedy policy
%   lambda   - Decay-rate parameter for eligibility traces
%   doReport - Prints a report to the console per episode
%   
% -------------------------------------------------------------------------
%   Author  : P.C. Luteijn
%   email   : p.c.luteijn@gmail.com
%   Date    : July 2017
%   Comment : Function excutes a reinforcement learning algortihm using  
%             teporal diference learning with a focus on Q-Learning. Also
%             an extra surface plot is generated portraing the normalized
%             Q-Matrix values.
% -------------------------------------------------------------------------

    % Get maze size
    [nr,nc,~] = size(M);
    
    % Numer of maze cells
    N = nr*nc;
    
    % Number of teleport locations
    nTP = max(max(M(:,:,7)));
    
    % Start/End position
    [p0(1),p0(2)] = find(M(:,:,6)==1);
    [p1(1),p1(2)] = find(M(:,:,6)==2);
    
    % Colormap
    res   = 1000;           % Resolution
    cmap  = hsv(res);       % Normalized values colormap
    cmap  = jet(res);
    
    % Create figure
    [h1,objShape,idxR,tbTitle] = pltDrawMaze(M,pxlCellWidth,1);
    
    % Shape color (unused)
    valShapeColor = [ 1.0, 1.0, 1.0; ...    % White
                      0.8, 0.8, 0.8; ...    % Drak-Grey
                      1.0, 0.5, 0.5; ...    % Red
                      0.1, 1.0, 0.1; ...    % Green
                      1.0, 1.0, 0.8; ...
                      1.0, 0.0, 1.0 ];      % Magenta
    
    % Modify parameters
    h.Name = 'Action-Values';
    tbTitle.FontWeight = 'Normal';
    tbTitle.FontSize = 10;
    tbTitle.String = '';
    
    % Normalize
    % ---------------------------------------------------------------------
    % Normalized Q-Matix record wrt a given resolution
    H = HQ(:,:,end);
    maxH = max(max(H));
    minH = min(min(H));
    normH = res - round(res*(H-maxH)./(minH-maxH),0);
    normH(normH==0) = 1;    % set end-point to zero
    
    % Visualize Q-Matrix
    % ---------------------------------------------------------------------
    % Update all cell wrt to the corresponding Q-Matrix
    for i = 1:nr
        for j = 1:nc
            % Grid locations
            idxC = idxR(i,j);
            
            % Color code
            clrCell = cmap(normH(i,j),:);
            
            % Update figure
            objShape(idxC).EdgeColor = clrCell;
            objShape(idxC).FaceColor = clrCell;
            
        end
    end
    
    % TextBox & Cell color finishing
    % ---------------------------------------------------------------------
    % Start/End location
    hold on, text( p0(2) - 0.5, nr + 0.5 - p0(1) , 'S', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 8, ...
        'FontWeight', 'Bold' ); hold off
    hold on, text( p1(2) - 0.5, nr + 0.5 - p1(1), 'F', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 8, ...
        'FontWeight', 'Bold' ); hold off
    
    % Cell color : Start/Finish
    objShape(idxR(p0(1),p0(2))).FaceColor = valShapeColor(2,:);
    objShape(idxR(p1(1),p1(2))).FaceColor = valShapeColor(2,:);

    % Teleport Locations    
    for i = 1:nTP
        % Teleport location
        [tR,tC] = find(M(:,:,7)==i);
        
        % String
        strTP = sprintf('%i',i);
        
        % Add to figure
        hold on, text( tC(1) - 0.5, nr + 0.5 - tR(1) , strTP, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 8, ...
            'FontWeight', 'Bold' ); hold off
        hold on, text( tC(2) - 0.5, nr + 0.5 - tR(2), strTP, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 8, ...
            'FontWeight', 'Bold' ); hold off
        
        % Cell color : Teleport Location
        objShape(idxR(tR(1),tC(1))).FaceColor = valShapeColor(6,:);
        objShape(idxR(tR(2),tC(2))).FaceColor = valShapeColor(6,:);
        
    end
    
    % Add the colorbar
    range = [0:1:5]./5;
    for i = 1:length(range)
        if range(7-i) == 0
            strRange{i} = sprintf(' % 2.1f',range(7-i));
        else
            strRange{i} = sprintf(' % 2.1f',-range(7-i));
        end
    end
    
    colormap(cmap)
    colorbar('Ticks',range,'TickLabels',strRange)
    
    % Save file
    if exist('sFile','var')
        strSave = [ '../Report/figures/' sFile '.png' ];
        saveas(gcf,strSave)
    end
    
    %% Extra: Surface plot
    % ---------------------------------------------------------------------
    % Check if surf-plot is requested
    if exist('doSurf') && doSurf == 1
        % Get normalized values
        surfF = zeros(nr,nc);
        
        % Flip the surface
        for i = 1:nr
            for j = 1:nc
                surfF(i,j) = normH(nr+1-i,j)./res;
            end
        end
        
        % Extension by 1 row/col
        surfFext = zeros(nr+2,nc+2);                % Extended empty
        surfFext(2:nr+1,2:nc+1) = surfF(:,:);       % Copy maze
        surfFext(1,2:nc+1) = surfF(1,:);            % Add top row
        surfFext(nr+2,2:nc+1) = surfF(nr,:);        % Add bottom row
        surfFext(2:nr+1,1) = surfF(:,1);            % Add left col
        surfFext(2:nr+1,nc+2) = surfF(:,nc);        % Add right col
        
        % Correct corner points
        surfFext(1,1)     = (surfFext(2,1)+surfFext(1,2))/2;
        surfFext(1,end)   = (surfFext(2,end)+surfFext(1,end-1))/2;
        surfFext(end,1)   = (surfFext(end,2)+surfFext(end-1,1))/2;
        surfFext(end,end) = (surfFext(end-1,end)+surfFext(end,end-1))/2;
        
        % Surface plot
        h2 = figure('Name','Action-Value surface plot', ...
            'Units','Normalized',...
            'Position',h1.Position);
        surf(1:nc+2,1:nr+2,surfFext-1), grid on
        
        % Modify plot
        colormap(cmap);
        
        % Modify axes
        ax = gca;
        ax.XLim = [2,nc+2];
        ax.YLim = [2,nr+2];
        ax.XTickLabel = '';
        ax.YTickLabel = '';
        
        % Save file
        if exist('sFile','var')
            strSave = [ '../Report/figures/' sFile '_surf.png' ];
            saveas(gcf,strSave)
        end
        
    end
    
end