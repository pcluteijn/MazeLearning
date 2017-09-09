% Reinforcement Learning : Maze navigation (Animated)
% -------------------------------------------------------------------------
% Author   : P.C. Luteijn
% Email    : p.c.luteijn@gmail.com
% Date     : September 2017
% Version  : 1.1
% Comment  : Q-Learing algorithm solves simple mazes.
% -------------------------------------------------------------------------
% Reset
clear; close all; clc;

%% Maze Parameters
% =========================================================================
nr = 14;
nc = 14;
seed  = 819058848;
nWall = 2*max([nr,nc]);

%% Agent Parameters
% =========================================================================
% RL parameters
gamma   = 0.999;        % Discount parameter
alpha   = 1/8;         % Learningrate parameter
epsilon = 1.0;          % e-greedy search behaviour
lambda  = 0.98;         % Rate of decaying greedyness
tlp     = 4;            % Teleport location pairs
maxIt   = nr*nc;        % Maximum amount of allowed iteration steps
maxEp   = 20000;        % Maximum amount of allowed eposodes

%% RUN ALGORITM
% =========================================================================
% Generate maze structure (Environment)
M = fncPrimsMaze(nr,nc,seed);       % Create maze structure
M = fncEliminateWalls(M,nWall);     % Remove some walls
fncCheckStructure(M);               % Check for corruptions

% Start agent
[Q,M,HA,HQ] = fncAgent(M,0,tlp,gamma,alpha,epsilon,lambda,maxIt,maxEp,1);

%% SAVE DATA
% =========================================================================
% Save obtained optimal action-value so you dont have to run it again
strFile = sprintf('save\\maze_%010i_%03i_%03i_%03i_%03i_%03i.mat', ...
    seed,nr,nc,round(gamma*100),round(alpha*100),round(epsilon*100));
save(strFile)

%% POST DATA PROCESSING
% =========================================================================
% Set maze-cell width
mcw = 30; close all;

% Plot : Convergence
pltConvergence(HA,nr,nc,seed,nWall,gamma,alpha,epsilon,lambda,tlp);

% Plot : Action-Values
pltActionValue(M,HQ,mcw,1);

% Animate : Agent actions
anmAgentActions(M,HA,mcw,0);
