% Prim's Maze Demonstration
% -------------------------------------------------------------------------
% Author  : P.C. Luteijn
% Email   : p.c.luteijn@gmail.com
% Date    : July 2017
% Comment : Demonstrates the maze generation using Prim's algorithm
% -------------------------------------------------------------------------

% Reset
clear; close all; clc;

% Maze parameters
nrows     = 20;         % Number of rows
ncols     = 20;         % Number of columns
seed      = -1;         % Seed: -1 is random
doPlot    =  1;         % Show a plot of the maze
doAnimate =  1;         % Show plot animantion
doVertex  =  0;         % Highlight all vertex locations
nElim     = 80;         % Number of walls to be eliminated from the maze

% Plot parameters
cellWidth = 40;

% Create a randomly 20x20 maze
[~,~,S] = fncPrimsMaze(nrows,ncols,seed,doPlot,doAnimate,doVertex);

% Create a 20x20 maze with a known seed 'S'
[M,~,S] = fncPrimsMaze(nrows,ncols,S,doPlot,doAnimate,doVertex);

% Eliminate Walls
M  = fncEliminateWalls(M,nElim);

% Check maze structure for corruptions
fncCheckStructure(M);

% Draw maze object (allows grid manipulation)
[~,~,~,tbTitle] = pltDrawMaze(M,cellWidth);
tbTitle.String = sprintf('[ maze : %i x %i  | seed : %i ]',nrows,ncols,S);