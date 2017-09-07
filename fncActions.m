function A = fncActions(idxA)
% Action selection function
% -------------------------------------------------------------------------
%   
%   Function :
%   [A] = fncActions(idxA)
%   
%   Inputs :
%   idxA  - Action index
%   
%   Outputs :
%   A     - Action to be taken given the input index
%   
% -------------------------------------------------------------------------
%   Author  : P.C. Luteijn
%   email   : p.c.luteijn@gmail.com
%   Date    : July 2017
%   Comment : Fuction returns an action given a specific action index.
%
% -------------------------------------------------------------------------
    
    % Action list
    ACTION = [   0,  -1; ...   % Left
                 1,   0; ...   % Up
                 0,   1; ...   % Right
                -1,   0; ...   % Down
                 0,   0];      % Stay
    
    % Return selected action given the action index 
    A = ACTION(idxA,:);
    
end