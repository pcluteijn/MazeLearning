% Reinforcement Learning : Maze navigation
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
nr = 30;
nc = 30;
seed  = randi(2^32);
nWall = 4*max([nr,nc]);

%% Agent Parameters
% =========================================================================
% RL parameters
gamma   = 0.99;         % Discount parameter
alpha   = 1/8;          % Learningrate parameter
epsilon = 0.10;         % e-greedy search behaviour
lambda  = 0.98;         % Rate of decaying greedyness
tlp     = 6;            % Teleport location pairs
maxIt   = nr*nr;        % Maximum amount of allowed iteration steps
maxEp   = 20000;        % Maximum amount of allowed eposodes

%% RUN ALGORITM
% =========================================================================
% Generate maze structure (Environment)
M = fncPrimsMaze(nr,nc,seed);       % Create maze structure
M = fncEliminateWalls(M,nWall);     % Remove some walls
fncCheckStructure(M);               % Check for corruptions

% Start agent
[Q,T,M,HA,HQ] = fncAgent(M,0,tlp,gamma,alpha,epsilon,lambda,maxIt,maxEp,1);

%% SAVE DATA
% =========================================================================
% Save obtained optimal action-value so you dont have to run it again
strFile = sprintf('save\\maze_%010i_%03i_%03i_%03i_%03i_%03i.mat', ...
    seed,nr,nc,round(gamma*100),round(alpha*100),round(epsilon*100));
save(strFile)

%% POST DATA PROCESSING
% =========================================================================
% Set maze-cell width
mcw = 18; close all;

% Plot : Convergence
pltConvergence(T,nr,nc,seed,nWall,gamma,alpha,epsilon,lambda,tlp);

% Plot : Action-Values
pltActionValue(M,HQ,mcw,1);

% Animate : Agent actions
anmAgentActions(M,HA,mcw,1);
