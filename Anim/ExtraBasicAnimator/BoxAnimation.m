function  BoxAnimation(t,Q,feet,GRF,rate,moviename)
    % This is an extra simple animation that uses a rectangle to represent
    % the body of the robot. 
    %
    % Inputs:
    %   t - (nx1) Time vector
    %   Q - (6xn) State vector representing the position and orientation
    %   rate - The number of data points to step the animation by
    %   moviename - If empty, no recording is made. Otherwise, an avi file
    %               of the corresponding name will be made.
    %
    
    makemovie = true;
    if isempty(moviename)
        makemovie = false;
    end
    if makemovie
        mov = VideoWriter(moviename);
        open(mov);
    end
    
    % Data for making the box
    X = [-0.15 -0.15 0.15 -0.15 -0.15 -0.15;
        -0.15  0.15 0.15  0.15 -0.15 -0.15;
        -0.15  0.15 0.15  0.15  0.15  0.15;
        -0.15 -0.15 0.15 -0.15  0.15  0.15;
        -0.15 -0.15 0.15 -0.15 -0.15 -0.15];
    
    Y = [-0.08 -0.08 -0.08 0.08  0.08 -0.08;
        0.08 -0.08  0.08 0.08 -0.08  0.08;
        0.08 -0.08  0.08 0.08 -0.08  0.08;
        -0.08 -0.08 -0.08 0.08  0.08 -0.08;
        -0.08 -0.08 -0.08 0.08  0.08 -0.08];
    
    Z = [-0.04 -0.04 -0.04 -0.04 0.04 -0.04;
        -0.04 -0.04 -0.04 -0.04 0.04 -0.04;
        0.04  0.04  0.04  0.04 0.04 -0.04;
        0.04  0.04  0.04  0.04 0.04 -0.04;
        -0.04 -0.04 -0.04 -0.04 0.04 -0.04];
    
    % Make figure
    fig = figure(4096);
    fig.Name = 'Quad_Anim';
    clf(fig);
    ax = axes();
    
    % Plot the ground
    [terrain.Tx, terrain.Ty] = meshgrid(-10:10:30, -20:10:20);
    terrain.Tz = 0.*terrain.Tx;
    ground = ColoredChecker(80,20,'g');
    surface(ax,terrain.Tx,terrain.Ty,terrain.Tz,...
           'FaceColor','texturemap',...
           'CData',ground,...
           'EdgeColor','none');
    hold(ax,'on');
       
    % Initial plot of the body
    b = fill3(ax,X,Y,Z,'g','FaceAlpha',0.65);
    H = hgtransform('Parent',ax);
    set(b,'Parent',H);
    
    
    % Plot the feet
    for n = 1:4
        FP(n) = scatter3(0,0,0,'SizeData',200,...
                               'MarkerFaceColor','r',...
                               'MarkerEdgeColor','none');
    end
    
    % Setup axis and view
    daspect([1,1,1]);
    grid(ax,'on');
    ax.XLimMode = 'manual';
    ax.YLimMode = 'manual';
    ax.ZLimMode = 'manual';
    ax.ZLim = [-0.05,0.6];
    xlabel('X'); ylabel('Y'); zlabel('Z');
    Title = title(ax,'Time: 0.00 (sec)');
    view([230 20]);
    hold(ax,'off');
    
    del = 0.6;	% axis width and length
    for n = 1:rate:length(t)
        T = H_trunk(Q(:,n));    % COM transformation matrix
        if ishandle(fig)
            set(H,'Matrix',T);              % Set the transform
            ax.XLim = Q(1,n)+[-del,del];    % Change X limits
            ax.YLim = Q(2,n)+[-del,del];    % Change Y limits
            for leg = 1:4
                if norm(GRF(n,(leg-1)*3+1:3*leg)) <1e-4
                    FP(leg).MarkerFaceAlpha = 0;
                else
                    FP(leg).MarkerFaceAlpha = 1;
                end
                set(FP(leg),'XData',feet(n,(leg-1)*3+1),'YData',feet(n,(leg-1)*3+2));
            end
            set( Title,'String',sprintf('Time: %0.2f (sec)',t(n)) );    % Update title
            drawnow;    % Draw the figure
        else
            break;
        end
        if makemovie && ishandle(fig)
            f = getframe(fig);
            writeVideo(mov,f);
        end
        pause(0.01);
    end
    if makemovie
        close(mov);
    end
    
end

