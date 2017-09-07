function [M,H,S] = fncPrimsMaze(nrows,ncols,seed,doPlot,doAnimate,doVertex)
% Maze generation algorithm (Prim's)
% -------------------------------------------------------------------------
%   
%   Function :
%   [M,H] = fncPrimsMaze(nrows,ncols,seed,doPlot,doAnimate,doVertex)
%   
%   Inputs :
%   nrows     - Number of horizontal lines
%   ncols     - Number of vertical lines
%   seed      - Random number generation seed (optional)
%   doPlot    - Returns a maze plot (optional)
%   doAnimate - Animate the maze creation (optional)
%   doVertex  - Highlight the vertex points and deadends (optional)
%   
%   Outputs :
%   M         - Multi layer cell array containing the maze structure,  
%               where layers 1-4 (left,up,right,down) contain the wall 
%               locations. Layer 5 contains the dead-end locations. 
%   H(n,rcd)  - History of maze generation with locations (r&c) and 
%               directions (d).
%   
% -------------------------------------------------------------------------
%   Author  : P.C. Luteijn
%   email   : p.c.luteijn@gmail.com
%   Date    : July 2017
%   Comment : Function generates a maze according to Prim's algorithm,
%             with an option to plot the maze.
%             
%             Final remark, positive y-axis points down, positive x-axis
%             points right. So down is up and up is down.
%
% -------------------------------------------------------------------------
    
    % random number generation
    if not(exist('seed')) || seed <= 0
        S = randi(2^32);
        seed = S;
    else
        S = seed;
    end
    rng(S);
    
    % visited cells
    V = zeros(nrows,ncols,2);
    
    % maze structure
    M = zeros(nrows,ncols,7);
    
    % history record
    H = zeros(nrows*nrows,3);
    
    % randomized initial location
    nr = ceil(rand(1)*nrows);
    nc = ceil(rand(1)*ncols);
    
    % declare iterator
    n = 0;
    
    % start timer
    tic;
    
    % START PRIM'S MAZE ITERATION ROUTINE
    % ---------------------------------------------------------------------
    % run loop until all cells have been visited
    while length(V(V(:,:,1)==0)) > 0 
        % iteration for history tracking
        n = n + 1;
        
        % weight
        w = rand(1,4);
        
        % options, i.e. possible neighbouring cell locations
        optR = [ nr  , nr+1, nr  , nr-1 ];
        optC = [ nc-1, nc  , nc+1, nc   ];
        
        % DETERMINE COURSE
        % -----------------------------------------------------------------
        % check if the current cell location has been visited, if it has
        % then the walkback routine is started
        if V(nr,nc) == 0
            
            % scan for connections between neigbouring cells
            for i = 1:4
                
                % edge constraint 
                if ( optR(i) < 1 && optC(i) >= 1 ), c(i) = 0;
                elseif ( optR(i) >= 1 && optC(i) < 1 ), c(i) = 0;
                elseif ( optR(i) < 1 && optC(i) < 1 ), c(i) = 0;
                elseif ( optR(i) > nrows && optC(i) <= ncols ), c(i) = 0;
                elseif ( optR(i) <= nrows && optC(i) > ncols ), c(i) = 0;
                elseif ( optR(i) > nrows && optC(i) > ncols ), c(i) = 0;

                % focus on legal cells
                else
                    % check if cell is empty
                    if V(optR(i),optC(i),1) == 0
                        % Set connection
                        c(i) = 1;
                    else
                        % Set zero connection
                        c(i) = 0;        
                    end
                end

            end

            % decision
            [~,choice] = max(w.*c);

            % Update new location, pays respect to deadends by reversing 
            % direction defining the deadend
            if sum(c) == 0
                % previous direction
                pdir = revDir(H(n-1,3));
                
                % update : visited cell
                V(nr,nc,1) = pdir;              % point back                
                V(nr,nc,2) = 5;                 % dead-end
                
                % update : maze structure
                M(nr,nc,pdir) = 1;              % current direction
                M(nr,nc,5) = 1;                 % dead-end layer
                
                % update : history        
                H(n,:) = [nr,nc,pdir];
                
                % set same location
                nr = H(n,1);
                nc = H(n,2);
                
            else
                
                % update : history
                H(n,:) = [nr,nc,choice];
                
                % update : visited cell
                V(nr,nc,1) = choice;
                
                % update : maze structure (current & previous direction)
                if n == 1
                    M(nr,nc,choice) = 1;
                else
                    pdir = revDir(H(n-1,3));
                    M(nr,nc,choice) = 1;        % current direction
                    M(nr,nc,pdir)   = 1;        % previous direction
                end
                
                % set new location
                nr = optR(choice);
                nc = optC(choice);
                
            end
        
        % WALKBACK ROUTINE
        % -----------------------------------------------------------------
        % walkback to new vertex location with neighbouring potential
        % unvisited cells, when a vertex is found a choice is made if there
        % exist multiple branches.
        else
            
            % start walkback routine
            for j = 1:n
                
                % walkback location
                nr = H(n-j,1);
                nc = H(n-j,2);

                % options
                optR = [ nr  , nr+1, nr  , nr-1 ];
                optC = [ nc-1, nc  , nc+1, nc   ];

                % weight
                w = rand(1,4);

                % find neighbouring free cell
                % and create a connection array
                for k = 1:4
                    
                    % edge constraint
                    if ( optR(k) < 1 && optC(k) >= 1 ), c(k) = 0;
                    elseif ( optR(k) >= 1 && optC(k) < 1 ), c(k) = 0;
                    elseif ( optR(k) < 1 && optC(k) < 1 ), c(k) = 0;
                    elseif ( optR(k) > nrows && optC(k) <= ncols ), c(k) = 0;
                    elseif ( optR(k) <= nrows && optC(k) > ncols ), c(k) = 0;
                    elseif ( optR(k) > nrows && optC(k) > ncols ), c(k) = 0;

                    % focus on legal cells
                    else
                        % check if cell is empty
                        if V(optR(k),optC(k),1) == 0
                            c(k) = 1;
                        else
                            c(k) = 0;
                        end
                    end

                end

                % decision upon empty cell found
                if max(c) == 1
                    
                    % desicion
                    [~,choice] = max(w.*c);
                    
                    % ceeate history record
                    H(n,1) = nr;
                    H(n,2) = nc;
                    H(n,3) = choice;
                    
                    % add to maze structure
                    M(nr,nc,choice) = 1;            % current direction
                    V(nr,nc,2) = 1;                 % mark vertex point
                    
                    % update new location
                    nr = optR(choice);
                    nc = optC(choice);
                    
                    % terminate loop
                    break;
                    
                % if no free cells are connected, remaining get filled up
                % this will most likely never occur, but put there just to
                % be sure! ;)
                elseif j == n
                    [r0,c0] = find(M(:,:,1)==0); M(r0,c0,1) = -1;
                    warning('Unreachable cells have been found!')

                end

            end

        end   

    end
    
    % Record generation time
    t1 = toc;
    
    % OUTPUT STATS TO CONSOLE
    % ---------------------------------------------------------------------
    % Separator line
    strLine = []; for i=1:66; strLine = [ strLine '-']; end
    fprintf([strLine '\n']);
    
    % Some maze statistics
    strSPos = [ '(' num2str(nr) ',' num2str(nc) ')' ];
    strSize = [ num2str(nrows) ' by ' num2str(ncols) ];
    
    % Output to console
    fprintf('Seed               : %16i [-]\n',seed);
    fprintf('Size               : %16s \n',strSize);
    fprintf('Start Position     : %16s \n',strSPos);
    fprintf('Generation Time    : %16.2f [s]\n',t1);
    fprintf('Vertex Count       : %16i [-]\n',length(find(V(:,:,2)==1)));
    fprintf('Dead-end Count     : %16i [-]\n',length(find(V(:,:,2)==5)));
    fprintf([strLine '\n']);
    
    % PLOT PRIM'S MAZE
    % ---------------------------------------------------------------------
    % plots the complete maze
     try
        if doPlot

            % color array
            arrColor = [ ...
                1.0 1.0 1.0 ; ...   % white
                0.6 1.0 0.6 ; ...   % green
                1.0 0.6 0.6 ];      % red

            % border size
            bs = 0.2;

            % create figure
            figure(...
                'Name', 'Prims Maze', ...
                'Units', 'pixels', ...
                'Position', [600,200,800,800], ...
                'Color', 'black' )

            % create basis canvas
            rectangle( ...
                'Position', [0,0,1,1], ...
                'FaceColor', [0, 0, 0], ...
                'EdgeColor', 'k',...
                'LineWidth', 3 )
            axis([1, ncols+1, 0, nrows ])
            ax = gca;
            ax.Color = 'black';
            ax.XColor = 'black';
            ax.YColor = 'black';
            ax.Units  = 'Normalized';
            ax.Position = [0.02,0.02,0.96,0.96];

            % draw maze history by stacking rectangles
            hold on

            for i = 1:length(H)

                % Animate
                try
                    if doAnimate
                        pause(4/(nrows*ncols));
                    end
                catch
                end

                % get location
                x   = H(i,2);
                y   = nrows - H(i,1);
                pos = [ x, y, 1, 1 ];

                % get current direction
                cd = H(i,3);

                % highlight vertex locations
                vtx = V(H(i,1),H(i,2),2);
                try
                    if vtx >= 1 && vtx <= 4 && doVertex
                        iclr = 2;
                    elseif vtx == 5 && doVertex
                        iclr = 3;
                    else
                        iclr = 1;
                    end
                catch
                    iclr = 1;
                end

                % draw cell
                pcell = pos + [ bs, bs, -2*bs, -2*bs ];
                rectangle( ...
                    'Position', pcell, ...
                    'FaceColor', arrColor(iclr,:), ...
                    'EdgeColor', arrColor(iclr,:),...
                    'LineWidth', 3 )

                % path direction
                if cd == 1       % ==[ LEFT  ]==
                    pcarve = [ x-bs, y+bs, 2*bs, 1-2*bs ];
                elseif cd == 2   % ==[  UP   ]==
                    pcarve = [ x+bs, y-bs, 1-2*bs, 2*bs ];
                elseif cd == 3   % ==[ RIGHT ]==
                    pcarve = [ x+1-bs, y+bs, 2*bs, 1-2*bs ];
                elseif cd == 4   % ==[ DOWN  ]==
                    pcarve = [ x+bs, y+1-bs, 1-2*bs, 2*bs ];
                end
                
                % carve path
                rectangle( ...
                    'Position', pcarve, ...
                    'FaceColor', [1, 1, 1], ...
                    'EdgeColor', [1, 1, 1],...
                    'LineWidth', 3 )
                
                % Animate
                try
                    if doCreateGif                    
                        [A,map] = rgb2ind(frame2im(getframe(gcf)),256);
                        delay_time = 10/(nrows*ncols);
                        if i == 1
                            imwrite(A,map,'prims_maze.gif','gif', ...
                                'LoopCount', Inf, ...
                                'DelayTime', delay_time );
                        else
                            imwrite(...
                                A,map,'prims_maze.gif','gif', ...
                                'WriteMode', 'append', ... 
                                'DelayTime', delay_time );
                        end
                    end
                catch
                end

            end

            % end hold draw mode
            hold off

        end
     catch
     end

end

function out = revDir(in)
    % Reverse direction
    if in == 1
        out = 3;
    elseif in == 2
        out = 4;
    elseif in == 3
        out = 1;
    elseif in == 4
        out = 2;
    end
end

% ------------------------------------------------------------------------
% EoF
% ------------------------------------------------------------------------
