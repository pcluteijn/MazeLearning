function M = fncEliminateWalls(M,E)
% Wall elimination algorithm
% -------------------------------------------------------------------------
%   
%   Function :
%   [M] = fncEliminateWalls(M,E)
%   
%   Inputs :
%   M - Multi layer cell array containing the maze structure
%   E - Number walls to be eliminated
%   
%   Outputs :
%   M - Multi layer cell array containing the maze structure, where 
%       layers 1-4 (left,up,right,down) contain the wall locations. 
%       Layer 5 contains the dead-end locations. 
%   
% -------------------------------------------------------------------------
%   Author  : P.C. Luteijn
%   email   : p.c.luteijn@gmail.com
%   Date    : July 2017
%   Comment : Function eliminates wall's from the multi layer maze
%             structure randomly per row/column. The routine terminates
%             automatically after the squared number of to be eliminated 
%             walls have been reached.
%
% -------------------------------------------------------------------------

    % Get size
    [nr,nc,~] = size(M);
    
    % Number of cycles till cutt-off
    cutoff = 500;
    
    % Setup colum range
    arrRow = 2:nr-1;
    arrCol = 2:nc-1;
    
    % Eliminate walls for number of E passes
    nElim = 0; nCutOff = 0;
    while nElim <= E            
        % Select random row/column
        i = arrRow(ceil(rand*(nr-2)));
        j = arrCol(ceil(rand*(nc-2)));
        
        % Get walls
        W = reshape(M(i,j,1:4),[1,4]);
        
        % Number of walls
        nW = 4 - sum(W);
        
        % Continue if walls are pressent
        if nW > 0
            % Increment
            nElim = nElim + 1;
            
            % Locate walls
            [~,wIdx] = find(W==0);
            
            % Wall to be eliminated
            elimWall = wIdx(randi(nW));
            
            % Eliminate wall
            M(i,j,elimWall) = 1; 
            
            % Update neigbouring maze-cell
            if elimWall == 1; M(i,j-1,3) = 1;
            elseif elimWall == 2; M(i+1,j,4) = 1;
            elseif elimWall == 3; M(i,j+1,1) = 1;
            elseif elimWall == 4; M(i-1,j,2) = 1; 
            end
            
        else
            % Cut-off loop when it gets harder to find cells
            nCutOff = nCutOff + 1;
            if nCutOff > cutoff
                fprintf('Wall elimination has been cut-off\n')
                break; 
            end
        end

    end

end