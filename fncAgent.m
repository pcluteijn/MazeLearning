function [Q,M,HA,HQ] = ...
    fncAgent(M,seed,nTLP,gamma,alpha,epsilon,lambda,maxIt,maxEp,doReport)
% RL Algorithm - Q-Learning
% -------------------------------------------------------------------------
%   
%   Function :
%   [Q,T,M,HA,HQ] = fncRLMA_TP(M,nTLP,gamma,alpha,epsilon,decay,doReport)
%   
%   Inputs :
%   M        - Multi layer maze structure cell array
%   nTLP     - Number of teleportation pairs
%   gamma    - Discount parameter
%   alpha    - Step-Size parameter, i.e. learning-rate. Enter a negative
%              value in case of reducing rewards per step with respect to 
%              its the sum of previous rewards. Or enter some positive 
%              fraction to have a constant step-size. 
%   epsilon  - Probability of random action in e-greedy policy
%   lambda   - Decay-rate parameter for eligibility traces
%   doReport - Prints a report to the console per episode
%   
%   Outputs :
%   Q        - Q-Matrix with the current and previous state values
%   T        - Per episode iteration log
%   HA       - Agent behavior log
%   HQ       - Per episode progression log of the Q-Matrix
%   
% -------------------------------------------------------------------------
%   Author  : P.C. Luteijn
%   email   : p.c.luteijn@gmail.com
%   Date    : August 2017
%   Comment : Function excutes a reinforcement learning algortihm using  
%             teporal diference learning with a focus on Q-Learning.
%
% -------------------------------------------------------------------------

    % Get size
    [nr,nc,~] = size(M);
    
    % Initiallize random number generator with known seed
    if exist('seed') && and( seed > 0 , seed <= 2^32 )
        rng(seed);
    else
        rng;
    end

    % Agent internal parameters
    % ---------------------------------------------------------------------
    % Breaks episode loop after a given number of repeating iteration steps
    repeats = 2*max([nr,nc]);  

    % Reward "Penalty" for moving/staying
    rewardMove  = -1;
    
    % Small added reward for reaching the finish
    rewardFinish = 0.1;
    
    % Initial e-greedy parameter
    initEpsilon = epsilon;
    
    % Learning boolean, needs to be 1 else no learning
    doLearn = 1;         
    
    % Force Agent to converge to the least amount of found steps
    doMinimum = 0;
    
    % Define Start/Finish Locations
    % ---------------------------------------------------------------------
    % Create extra start/finish position layer in the maze structure
    M(:,:,6) = zeros(nr,nc);
    
    % Find dead-ends and put them as far apart as posible
    p0 = [ find(M(:, 1,5)==1,1),  1 ];
    p1 = [ find(M(:,nc,5)==1,1,'last'), nc ];

    if length(p0) < 2 || length(p1) < 2
        % Reset if no dead-ends are available
        p0 = [  1,  1 ];
        p1 = [ nr, nc ];
        
        % Issue a waring
        % warning(['No sufficient number of dead-end locations for' ...
        %    ' the start/finish position available!']);
        
    end
    
    % Add position to maze structure
    M(p0(1),p0(2),6) = 1;
    M(p1(1),p1(2),6) = 2;
    
    % Define Teleportation Locations
    % ---------------------------------------------------------------------
    [TL,M] = fncTeleportationLocations(M,p0,p1,nTLP);
    
    % ACTIONS
    % ---------------------------------------------------------------------
    % See action function -> fncActions

    % REWARDS
    % ---------------------------------------------------------------------
    % Reward structure for moving/staying per iteration
    R = rewardMove * ones(nr,nc);
    R(p1(1),p1(2)) = 0;             % Finish is zero else no conversion

    % Q-MATRIX
    %----------------------------------------------------------------------
    % Initialize with the reward matrix.
    Q = R;
    
    % =====================================================================
    % START LEARNING : Q-LEARNING
    % =====================================================================
    % Initialize timer, episode variable & iteration difference
    tic; episode = 0; dT(1) = 0; 
    cntMaxItt = 0; justTeleported = 0; dEpsilon = 0;
    
    % Start learning
    while doLearn
        % Count episodes
        episode = episode + 1;
        
        % Initital state
        s0 = p0;
        
        % *****************************************************************
        % START ITERATION
        % *****************************************************************
        % Reset counter & agent action log
        cnt = 0; logAgent = p0;
        for itt = 1:maxIt
            % Break iteration loop on finish
            if s0(1) == p1(1) && s0(2) == p1(2)
                if cnt == 10
                    break;
                else
                    cnt = cnt + 1;
                end
            end
            
            % Obtain environment options wrt the currect state
            options = ones(1,5);
            options(1:4) = reshape(M(s0(1),s0(2),1:4),[1,4]);
            
            % Obtain all possible next state action-values
            sOpt = zeros(5,2);
            qOpt = zeros(1,5);
            for i = 1:5
                if  options(i) == 1
                    sOpt(i,:) = s0 + fncActions(i);
                    qOpt(i)   = Q(sOpt(i,1),sOpt(i,2));
                else
                    qOpt(i) = NaN;
                end
            end
            
            % Desicion Process (Exploring vs Exploiting)
            if rand() < epsilon
                % Exploration
                [~,idxA] =  max(rand(1,5).*options);
            else
                % Exploitation
                [~,idxA] =  max(qOpt);
            end
            
            % Next state
            sP = sOpt(idxA,:);
            
            % Update next state in case of teleportation
            if nTLP > 0
                for i = 1:nTLP
                    % Check if TL is empty
                    if isempty(TL(i).A) && isempty(TL(i).B)
                        break;
                    end
                    
                    % Check if at TP location
                    if and(sP(1) == TL(i).A(1),sP(2) == TL(i).A(2)) ...
                            && justTeleported == 0
                        sP = TL(i).B;
                        justTeleported = 1;
                        break;
                    elseif and(sP(1) == TL(i).B(1),sP(2) == TL(i).B(2)) ...
                            && justTeleported == 0
                        sP = TL(i).A;
                        justTeleported = 1;
                        break;
                    else
                        justTeleported = 0;
                    end
                    
                end
            end            
            
            % Reward +1 for finish
            RF = 0; if s0 == p1; RF = rewardFinish; end
            
            % Reductuion vs constant step-size
            if alpha < 0; stepsize = 1/itt; else; stepsize = alpha; end

            % Update : Q-Matrix
            % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            Q(s0(1),s0(2)) = Q(s0(1),s0(2)) + ...
                stepsize * ( R(sP(1),sP(2)) + RF + ... 
                gamma * qOpt(idxA) - Q(s0(1),s0(2)) );
            % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            
            % Log agent actions
            logAgent(itt,:) = s0;
            
            % Update state
            s0 = sP;
            
        end
        
        % *****************************************************************
        % STOP ITERATION
        % *****************************************************************
        
        % End timer
        t_itt = toc;
                
        % Greedyness
        % -----------------------------------------------------------------
        % Sometimes explioting might lead to singularities where two or
        % more teleportation locations infinitely loop in each other, if
        % this happens the agent starts exploring again with decaying odds
        if itt == maxIt && epsilon < 0.1*initEpsilon
            % Count maximum itterations
            cntMaxItt = cntMaxItt + 1;
            
            % Upon exceeding the maximum reset epsilon
            if cntMaxItt == 2
                epsilon = initEpsilon;
                strMsg = '< EXPLORING >';
            end
            
        else
            epsilon = epsilon * lambda;      % Decaying odds
            strMsg = '';
            cntMaxItt = 0;
        end
        
        % Keep a record
        % -----------------------------------------------------------------
        % Iterations per episode
        T(episode) = itt;
        
        % Minimum amount of itterations
        minT = min(T);

        % Q-Matrix progression
        HQ(:,:,episode) = Q;
        
        % Agent behavior log
        HA(episode).logAgent = logAgent;
        HA(episode).steps    = itt - cnt;
        HA(episode).minT     = minT;
        HA(episode).T        = itt;

        % End episodes
        % -----------------------------------------------------------------
        % Upon sufficient convergence loop will discontinue.
        if episode > 1 && itt < maxIt
            % Stop learning upon convergence
            dT(episode) = abs( T(episode-1) - itt );
            if episode > repeats &&  ...
                    sum(dT(episode-repeats:end)) < repeats
                % Ensure minimum amount of steps
                if doMinimum == 1 && itt == minT
                    dEpsilon = 0;
                    doLearn  = 0;
                elseif doMinimum == 1
                    dEpsilon = dEpsilon + 1;
                    epsilon = initEpsilon*dEpsilon;
                    if epsilon >= 5; epsilon = 5; end
                    strMsg = '< EXPLORING >';
                else
                    doLearn = 0;
                end
            end
            
        end
        
        % Stop learning reaching a maximum number of episodes
        if episode == maxEp
            doLearn = 0;
            strMsg = '< TERMINATED >';
        end
        
        % Ouput to console
        % -----------------------------------------------------------------
        % Output episode update to console
        if doReport
            fprintf(['[ #%04i ] eps = %3.2f | ' ...
                'steps = %5i | minSteps = %5i | t = %5.1f [s]  %s\n'], ...
                episode, epsilon, itt-cnt, minT-cnt, t_itt, strMsg)
        end
        
    end
    
    % =====================================================================
    % STOP LEARNING
    % =====================================================================
    
    % Report optimality of the solution
    % ---------------------------------------------------------------------    
    % Output to console
    if itt == minT
        fprintf('\nMaze has an optimal solution!\n');
    else
        fprintf([...
            '\nMaze has converged to a sub-optimal solution with ' ...
            '%i steps\nwhile %i is the minimum amount, ' ...
            'i.e. a %3.1f%% difference.\n'], ...
            itt-cnt,minT-cnt,100*(itt-minT)/(minT-cnt));
    end
    
end