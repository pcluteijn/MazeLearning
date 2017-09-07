function [TL,M] = fncTeleportationLocations(M,p0,p1,nTLP)
% Teleportation Locations
% -------------------------------------------------------------------------
%   
%   Function :
%   [TL,M] = fncTeleportationLocations(M,p0,p1,nTLP)
%   
%   Inputs :
%   M    - Multi layer maze structure cell array
%   p0   - Start position
%   p1   - Finish position
%   nTLP - Number of teleportation-pairs
%   
%   Outputs :
%   TL   - Structure with teleport-pair locations 
%   M    - Updated multi layer maze structure cell array
%   
% -------------------------------------------------------------------------
%   Author  : P.C. Luteijn
%   email   : p.c.luteijn@gmail.com
%   Date    : July 2017
%   Comment : Function randomly selects teleportation pair locations using
%             the dead-end locations, where the start/finish positions are
%             excluded.
% -------------------------------------------------------------------------
    
    % Get size
    [nr,nc,~] = size(M);
    
    % Number of maze elements
    N = nr*nc;
    
    % Create extra  teleportation layer in the Maze structure
    M(:,:,7) = zeros(nr,nc);
    
    % Inverse postion matrix
    invPos = ones(nr,nc);
    invPos(p0(1),p0(2)) = 0;
    invPos(p1(1),p1(2)) = 0; 

    % Obtain dead-end matrix
    DEM = invPos.*reshape(M(:,:,5),[nr,nc]);
    nDE = sum(sum(M(:,:,5)));
    
    % Initialize TP structure
    TL.A = []; TL.B = [];
        
    % Add some teleportation locations
    nTL = 0;
    if nTLP > 0
        % Number of pairs to total locations
        nTL = 2*nTLP;
        
        % Find teleportation locations
        for i = 1:nTLP
            % Check logic
            if nTL >= nDE
               warning('Error concerning the teleport points.');
               break;
            end
            
            % Find possible teleport locations
            [tpR,tpC] = find(DEM==1);
            
            % Index length
            lenIdx = length(tpR);
            
            % Assign randomly and uniquely
            tp0 = []; tp1 = []; doSelection = 1; cnt = 0;
            while doSelection           
                % Random index
                idx0 = randi(lenIdx);
                idx1 = randi(lenIdx);
                
                % Randomly selected teleportation locations
                tp0 = [ tpR(idx0) , tpC(idx0) ];
                tp1 = [ tpR(idx1) , tpC(idx1) ];
                
                % Look again if locations are the same
                if tp0(1)~=tp1(1) && tp0(2)~=tp1(2)
                   doSelection = 0;
                end
                
                % Stop when nothing can be found
                cnt = cnt + 1;
                if cnt > N && and(tp0(1)==tp1(1),tp0(2)==tp1(2))
                   tp0 = []; tp1 = [];
                   doSelection = 0;
                end
                
            end
            
            % Assign to structure
            TL(i).A = tp0;
            TL(i).B = tp1;
            
            % Only update if there are tp-locations
            if not(isempty(tp0)) && not(isempty(tp1))
                % Update dead-end matrix
                DEM(tp0(1),tp0(2)) = 0;
                DEM(tp1(1),tp1(2)) = 0;

                % Update maze matrix
                M(tp0(1),tp0(2),7) = i;
                M(tp1(1),tp1(2),7) = i;
            end
            
        end
        
    end
    
end