function [h,objShape,idxR,tbTitle] = pltDrawMaze(M,figCPxl,doClrBar)
% Draw maze plotting function
% -------------------------------------------------------------------------
%   
%   Function :
%   [h,objShape,idxR,tbTitle] = pltDrawMaze(M,figCPxl)
%   
%   Inputs :
%   M        - Multi layer maze structure cell array
%   figCPxl  - Pixel cellsize of the maze
%   
%   Outputs :
%   h        - Figure handle of the drawn maze
%   objShape - Contains all shape objects
%   idxR     - Refference index of the cell objects
%   tbTitle  - Title textbox object
%   
% -------------------------------------------------------------------------
%   Author  : P.C. Luteijn
%   email   : p.c.luteijn@gmail.com
%   Date    : July 2017
%   Comment : Plotting function draws the maze using rectangles and lines.
% -------------------------------------------------------------------------
    
    % Dimension maze structure
    [nr,nc,~] = size(M);
    
    % Number of maze ellements
    N = nr * nc;
    
    % Parameters
    valLineWidth = 1;
    
    % Screen parameters
    scrWidth  = 1920;
    scrHeight = 1080;
    scrRatio  = scrWidth / scrHeight;
    scrWinBar = 85;
    scrOffset = 20;
    if exist('doClrBar') && doClrBar == 1
        scrClrBar = 67;
    else
        scrClrBar = 0;
    end
    
    % Figure parameters
    figWidth  = figCPxl * nc;
    figHeight = figCPxl * nr;
    figRatio  = figWidth / figHeight;
    
    % Normalized figure dimensions
    xoffset = scrOffset / scrWidth;
    yoffset = ( scrOffset + scrWinBar ) / scrHeight;
    width   = ( figWidth + scrClrBar ) / scrWidth;
    height  = figHeight / scrHeight;
    xpos    = 1 - width - xoffset;
    ypos    = 1 - height - yoffset;
    
    % Out of bounds recalculation : Width
    beta = 0.98;
    if xpos < 0 && ypos > 0
        width  = beta;
        height = beta * scrRatio / figRatio;
        xpos   = 1 - width - (1-beta)/2;
        ypos   = 1 - height - (1-beta)/2;
    end
    
    % Out of bounds recalculation : Height
    beta = 0.94;
    if xpos > 0 && ypos < 0
        width  = beta * figRatio / scrRatio;
        height = beta;
        xpos   = 1 - width - (1-beta)/2;
        ypos   = 1 - height - (1-beta)/2;
    end
    
    % Create figure
    h = figure( ...
        'Name', 'Maze', ...
        'Units','Normalized', ...
        'InnerPosition', [xpos,ypos,width,height] );
    
    % Axis setup
    ax_bdr    = 20;
    ax_xpos   = ax_bdr / figWidth;
    ax_ypos   = ax_bdr / figHeight;
    ax_width  = 1 - 2*ax_xpos;
    ax_height = 1 - 2*ax_ypos;
    axis([0 nc 0 nr]);
    set( gca, 'Units', 'Normalized', ...
        'Position',[ ax_xpos, ax_ypos, ax_width, ax_height ] );
    
    % Position on axis
    X = [1:nc] - 1;
    Y = nr - [1:nr];
    
    % Initialize textbox object
    tbTitle = text(0.5,(1+(5*scrOffset/8)/figHeight),'TEXT', ... 
        'Units', 'Normalized', ...
        'HorizontalAlignment', 'Center', ...
        'VerticalAlignment', 'Middle', ...
        'FontSize', 10);
    
    % Offset axis labels
    doNumbers = 0;
    if doNumbers
        set(gca,'xTick',0.5:1:nc);
        set(gca,'yTick',0.5:1:nr);
        set(gca,'xTickLabel',1:nc);
        set(gca,'yTickLabel',1:nr);
        set(gca,'XTickLabelRotation',90);
    else
        set(gca,'xTick',[]);
        set(gca,'yTick',[]);
        set(gca,'xTickLabel',[]);
        set(gca,'yTickLabel',[]);
    end
    
    % Hold plot properties
    hold on
    
    % Draw squares
    for i = 1:nr
        for j = 1:nc
            % Index
            idx = j + nr*(i-1);
                        
            % Add squares
            square(idx) = rectangle( ...
                'Position', [X(j),Y(i),1,1], ...
                'EdgeColor', [1,1,1], ...
                'FaceColor', [1,1,1] ); 
        end
    end
    
    % Draw walls
    for i = 1:nr
        for j = 1:nc
            x = X(j); y = Y(i);
            if i == 1 && j == 1
                % WALL : LEFT
                if M(i,j,1) == 0
                    line( [x,x], [y,y+1], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
                % WALL : BOTTOM
                if M(i,j,2) == 0
                    line( [x,x+1], [y,y], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
                % WALL : RIGHT
                if M(i,j,3) == 0
                    line( [x+1,x+1], [y,y+1], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
                % WALL : TOP
                if M(i,j,4) == 0
                    line( [x,x+1], [y+1,y+1], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
            elseif i == 1 && j > 1               
                % WALL : BOTTOM
                if M(i,j,2) == 0
                    line( [x,x+1], [y,y], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
                % WALL : RIGHT
                if M(i,j,3) == 0
                    line( [x+1,x+1], [y,y+1], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
                % WALL : TOP
                if M(i,j,4) == 0
                    line( [x,x+1], [y+1,y+1], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
            elseif i > 0 && j == 1
                % WALL : LEFT
                if M(i,j,1) == 0
                    line( [x,x], [y,y+1], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
                % WALL : BOTTOM
                if M(i,j,2) == 0
                    line( [x,x+1], [y,y], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
                % WALL : RIGHT
                if M(i,j,3) == 0
                    line( [x+1,x+1], [y,y+1], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
              
            else              
                % WALL : BOTTOM
                if M(i,j,2) == 0
                    line( [x,x+1], [y,y], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
                % WALL : RIGHT
                if M(i,j,3) == 0
                    line( [x+1,x+1], [y,y+1], ...
                        'Color', 'k', 'LineWidth', valLineWidth );
                end
                
            end
            
        end
    end
    
    % End holding plot properties
    hold off
    
    % Return maze rectangle index
    % ---------------------------------------------------------------------
    % Get figure object handles
    objShape = get(get(h,'Children'),'Children');
    
    % Number of object shapes
    nobj = length(objShape);

    % Rectangle index (added -1 to compensate tb)
    idxR = nobj - reshape([1:N]-1,[nc,nr])' - 1;

end