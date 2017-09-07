function h = anmAgentActions(M,HA,pxlCellWidth,doEndResult,sFile)

    % Plot setup
    % ---------------------------------------------------------------------
    % Get maze size
    [nr,nc,~] = size(M);
    
    % Get action log size
    [~,nE] = size(HA);
    
    % Numer of maze cells
    N = nr*nc;
    
    % Number of teleport locations
    nTP = max(max(M(:,:,7)));
    
    % Start/End position
    [p0(1),p0(2)] = find(M(:,:,6)==1);
    [p1(1),p1(2)] = find(M(:,:,6)==2);
    
    % Create figure
    [h,objShape,idxR,tbTitle] = pltDrawMaze(M,pxlCellWidth);
    
    % Shape color
    valShapeColor = [ 1.0, 1.0, 1.0; ...    % [1] White
                      0.8, 0.8, 0.8; ...    % [2] Drak-Grey
                      1.0, 0.5, 0.5; ...    % [3] Red
                      0.8, 1.0, 0.8; ...    % [4] Green
                      1.0, 1.0, 0.8; ...    % [5] Yellow
                      1.0, 0.0, 1.0];       % [6] Magenta
                  
    % Modify figure
    tbTitle.String = '';
    
    % Only display end result
    if doEndResult == 1
        nStart = nE;
    else
        nStart = 1;
    end
    
    % TextBox & Cell color finishing
    % ---------------------------------------------------------------------
    % Start/End location
    hold on, text( p0(2) - 0.5, nr + 0.5 - p0(1) , 'S', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 8, ...
        'FontWeight', 'Bold' ); hold off
    hold on, text( p1(2) - 0.5, nr + 0.5 - p1(1), 'F', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 8, ...
        'FontWeight', 'Bold' ); hold off
    
    % Cell color : Start/Finish
    objShape(idxR(p0(1),p0(2))).FaceColor = valShapeColor(2,:);
    objShape(idxR(p1(1),p1(2))).FaceColor = valShapeColor(2,:);

    % Teleport Locations
    idx = 0; exLocs = [];
    for i = 1:nTP        
        % Teleport location
        [tR(i,:),tC(i,:)] = find(M(:,:,7)==i);
        
        % Excluded color change locations
        idx = idx + 1; exLocs(idx,:) = [tR(i,1),tC(i,1)];
        idx = idx + 1; exLocs(idx,:) = [tR(i,2),tC(i,2)];

        % String
        strTP = sprintf('%i',i);

        % Add to figure
        hold on, text( tC(i,1) - 0.5, nr + 0.5 - tR(i,1) , strTP, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 8, ...
            'FontWeight', 'Bold' ); hold off
        hold on, text( tC(i,2) - 0.5, nr + 0.5 - tR(i,2), strTP, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 8, ...
            'FontWeight', 'Bold' ); hold off
        
        % Cell color : Teleport Location
        objShape(idxR(tR(i,1),tC(i,1))).FaceColor = valShapeColor(6,:);
        objShape(idxR(tR(i,2),tC(i,2))).FaceColor = valShapeColor(6,:);
        
    end
    
    % Add start/fishish to excluded locations
    if isempty(exLocs)
        exLocs(1,:) = p0;
        exLocs(2,:) = p1;
    else
        exLocs(end+1,:) = p0;
        exLocs(end+1,:) = p1;
    end
    
    % Replay action log
    % ---------------------------------------------------------------------
    % Update all cell wrt to the corresponding Q-Matrix
    for episode = nStart:nE
        % Number of iterations
        [ittMax,~] = size(HA(episode).logAgent);
        
        idxS0 = [];
        idxS1 = [];
        
        for itt = 2:ittMax
            tbTitle.String = ...
                sprintf('[ episode : %05i / %05i | steps : %04i ]', ...
                episode,nE,HA(episode).steps);
            
            s0 = HA(episode).logAgent(itt-1,:);
            s1 = HA(episode).logAgent(itt,:);
            
            % Grid locations
            idxS0(itt) = idxR(s0(1),s0(2));
            idxS1(itt) = idxR(s1(1),s1(2));
            
            % Find excluded index
            idxL0 = find(and(s0(1)==exLocs(:,1),s0(2)==exLocs(:,2)));
            idxL1 = find(and(s1(1)==exLocs(:,1),s1(2)==exLocs(:,2)));
            
            % Update current state in figure
            if isempty(idxL0)
                objShape(idxS0(itt)).FaceColor = valShapeColor(4,:);
                objShape(idxS0(itt)).EdgeColor = valShapeColor(4,:);
            else
                 idxS0(itt) = 0;
            end
            
            % Update next state in figure
            if isempty(idxL1)
                objShape(idxS1(itt)).FaceColor = valShapeColor(5,:);
                objShape(idxS1(itt)).EdgeColor = valShapeColor(5,:);
            else
                idxS1(itt) = 0;
            end
            
        end
        
        pause(6/ittMax);
        
        % Reset figure
        for itt = 1:ittMax
            % Reset current state in figure
            if idxS0(itt) > 0  && episode < nE    
                objShape(idxS0(itt)).FaceColor = valShapeColor(1,:);
                objShape(idxS0(itt)).EdgeColor = valShapeColor(1,:);
            end
            
            % Reset next state in figure
            if idxS1(itt) > 0  && episode < nE
                objShape(idxS1(itt)).FaceColor = valShapeColor(1,:);
                objShape(idxS1(itt)).EdgeColor = valShapeColor(1,:);
            end
            
        end
        
    end
    
    % Save file
    if exist('sFile','var')
        strSave = [ '../Report/figures/' sFile '.png' ];
        saveas(gcf,strSave)
    end

end