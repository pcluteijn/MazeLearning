function fncCheckStructure(M)
% Maze structure integrity check
% -------------------------------------------------------------------------
%   
%   Function :
%   fncCheckStructure(M)
%   
%   Inputs :
%   M        - Multi layer maze structure cell array
%   
% -------------------------------------------------------------------------
%   Author  : P.C. Luteijn
%   email   : p.c.luteijn@gmail.com
%   Date    : July 2017
%   Comment : Function checks the maze structure on inconsistencies and
%             issues a warning when a maze is corrupted. 
% -------------------------------------------------------------------------

    % Size
    [nr,nc,~] = size(M);
    
    n = 0;
    for i = 1:nr
        for j = 1:nc
            
            if i == 1 && j == 1                             % CTL
                W02 = M(1,1,2) == M(2,1,4);
                W03 = M(1,1,3) == M(1,2,1);
                
                if not(and(W02,W03))
                    n = n + 1;
                end
                
            elseif i == 1 && j == nc                        % CTR
                W01 = M(1,nc,1) == M(1,nc-1,3);
                W02 = M(1,nc,2) == M(2,nc,4);
                
                if not(and(W01,W02))
                    n = n + 1;
                end
                
            elseif i == nr && j == 1                        % CBL
                W03 = M(nr,1,3) == M(nr,2,1);
                W04 = M(nr,1,4) == M(nr-1,1,2);
                
                if not(and(W03,W04))
                    n = n + 1;
                end
            
            elseif i == nr && j == nc                       % CBR
                W01 = M(nr,nc,1) == M(nr,nc-1,3);
                W04 = M(nr,nc,4) == M(nr-1,nc,2);
                
                if not(and(W01,W04))
                    n = n + 1;
                end
            
            elseif i == 1 && ( j > 1 && j < nc )            % TOP 
                W01 = M(i,j,1) == M(i,j-1,3);
                W02 = M(i,j,2) == M(i+1,j,4);
                W03 = M(i,j,3) == M(i,j+1,1);
                
                if not(and(W01,and(W02,W03)))
                    n = n + 1;
                end
                
            elseif i == nr &&  ( j > 1 && j < nc )          % BOTTOM
                W01 = M(i,j,1) == M(i,j-1,3);
                W03 = M(i,j,3) == M(i,j+1,1);
                W04 = M(i,j,4) == M(i-1,j,2);
                
                if not(and(W01,and(W03,W04)))
                    n = n + 1;
                end
                
            elseif ( i > 1 && i < nr ) && j == 1            % LEFT
                W02 = M(i,j,2) == M(i+1,j,4);
                W03 = M(i,j,3) == M(i,j+1,1);
                W04 = M(i,j,4) == M(i-1,j,2);
                
                if not(and(W02,and(W03,W04)))
                    n = n + 1;
                end
                
            elseif ( i > 1 && i < nr ) && j == nc           % RIGHT
                W01 = M(i,j,1) == M(i,j-1,3);
                W02 = M(i,j,2) == M(i+1,j,4);
                W04 = M(i,j,4) == M(i-1,j,2);
                
                if not(and(W01,and(W02,W04)))
                    n = n + 1;
                end
                
            else                                            % CENTER
                W01 = M(i,j,1) == M(i,j-1,3);
                W02 = M(i,j,2) == M(i+1,j,4);
                W03 = M(i,j,3) == M(i,j+1,1);
                W04 = M(i,j,4) == M(i-1,j,2);
                
                if not(and(and(W01,W02),and(W03,W04)))
                    n = n + 1;
                end
                
            end
            
        end
    end
    
    % Isue a warning when the maze structure is corrupt
    if n > 0
        warning(['Corrupt maze structure! A number of %i instances' ...
            ' have been found where neigbouring cells do not match!'],n);
    end

end