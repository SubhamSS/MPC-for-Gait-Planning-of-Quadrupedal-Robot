function[X_pos,X_vel,U_plot ,posfig,copfig] = plotResults(X,U,time,params)
%PLOTRESULTS Summary of this function goes here
%   Detailed explanation goes here
close all
FS = 15;

posfig = figure;
subplot(411)
plot(time,X(1:params.n:end),'LineWidth',1,'Color','k')
ylabel('$\textrm{COM}_{x}$ (m)','Interpreter','LaTex','FontSize',FS)
subplot(412)
plot(time,X(2:params.n:end),'LineWidth',1,'Color','k')
ylabel('$\frac{d}{dt}\textrm{COM}_{x}$ (m/s)','Interpreter','LaTex','FontSize',FS)
subplot(413)
plot(time,X(3:params.n:end),'LineWidth',1,'Color','k')
ylabel('$\textrm{COM}_{y}$ (m)','Interpreter','LaTex','FontSize',FS)
subplot(414)
plot(time,X(4:params.n:end),'LineWidth',1,'Color','k')
ylabel('$\frac{d}{dt}\textrm{COM}_{y}$ (m/s)','Interpreter','LaTex','FontSize',FS)
xlabel('Time (s)','Interpreter','LaTex','FontSize',FS)

copfig = figure;
subplot(211)
plot(time,U(1:params.m:end),'LineWidth',1,'Color','r')
ylabel('$\textrm{COP}_{x}$ (m)','Interpreter','LaTex','FontSize',FS)
subplot(212)
plot(time,U(2:params.m:end),'LineWidth',1,'Color','r')
ylabel('$\textrm{COP}_{y}$ (m)','Interpreter','LaTex','FontSize',FS)
xlabel('Time (s)','Interpreter','LaTex','FontSize',FS)


X_pos = [X(1:params.n:end)';X(3:params.n:end)';params.height*ones(size(X(1:params.n:end)'))];
X_vel = [X(2:params.n:end)';X(4:params.n:end)';zeros(size(X(1:params.n:end)'))];
U_plot = [U(1:params.m:end)';U(2:params.m:end)'];


end

