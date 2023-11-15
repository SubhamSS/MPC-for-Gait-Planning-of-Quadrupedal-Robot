PathSetup;

%%

g = 9.81; % gravity
height = 0.26; % height of COM
% Robustness to height (modify to check robustness)
real_height = 1.0*height;
mass = 12.4530;    % mass
mu = 0.4; % friction coeff
Ts = 100e-3; % Sample time
Nd = 4; % No. of grids per domain
M = 20; % Total number of domains
horizon=8*4; % Horizon
action_horizon = 1*1; % Number of control inputs applied
p_foot = [[0.183;-0.1321],...
          [0.183;0.1321],...
          [-0.183;-0.1321],...
          [-0.183;0.1321]]; 

desired_step = [0.1;0.0];


%Setting up params

params.g = g;
params.height = height;
params.real_height = real_height;
params.mass = mass;
params.mu = mu;
params.Ts = Ts;
params.Nd = Nd;
params.M = M;
params.M_stabilize = 10;
params.Tdomain = params.Nd*params.Ts;
params.desired_step = desired_step;
params.p_foot = p_foot;
params.l = 4; %No. of feet

params.n_states = 4;
params.desired_step = desired_step;
params.COM_position_start = [0;0];

%%

%Getting Dynamics
[Ad,Bd,A,B] = getDynamics(params);


%MPC parameters
[n,~] = size(Ad);
[~,m] = size(Bd);
Q     = 1*eye(n,n);   %10 % MPC Q (point state cost matrix)
R     = 0.1*eye(m,m);     % MPC R (point control cost matrix)
P     = 1e3*eye(n,n); % MPC P (final cost matrix)

params.n = n;
params.m = m;
params.P = P;
params.Q = Q;
params.R = R;
params.horizon = horizon;
params.n_actions = action_horizon;

%Equality constraints
params.Ad = Ad;
params.Bd = Bd;
params.A = A;
params.B = B;

%Contact Index
params.contact_matrix = getContactMatrix(params,0); % 0 for not stationary
params.contact_matrix = [params.contact_matrix getContactMatrix(params,1)];

%Foothold planning
params.foot_holds = getFootHolds(params); %inspiration from Dr. Hamed's code

%COM trajectory
params.COM_target_trajectory = getCOMTargetTrajectory(params); %separately from step lengths
% params.COM_target_trajectory = getCOMTargetTrajectory_Footholds(params);
% target = load("DrHamedtraj.mat");
% params.COM_target_trajectory = target.COM_desired_traj_tot;

%Do we reshape COM?
%Yes all done inside get_QP functions


%Inequality
params.Phi = [1 0 0 0;-1 0 0 0;0 0 1 0;0 0 -1 0];
params.Psi = [-1 0;1 0; 0 -1; 0 1];
params.eta = (params.height*params.mu/sqrt(2))*ones(4,1);


%Initialize trajectories
X_achieved= [];
U_achieved = [];

%State trajectory
params.State_Trajectory_desired = getTargetTrajectory(params);

%Start
x0= params.State_Trajectory_desired(:,1);
t=0;
Feet = [];
lambda = [];
C_lambda = [];
Aeq_lambda = [];
lambdas_contact = [];
contact_indicator_feet = [];

for k=1:(params.M+params.M_stabilize)*params.Nd/(params.n_actions)

    %Set problem
    counter = (k-1)*params.n_actions+1;
    %Get QP
    [H,f,A,b,Aeq,beq,C_lambda,Aeq_lam,foots,con_indicator] = getQP(params,x0,counter);
    %Solve QP
    options = ecosoptimset('VERBOSE',0);
    tic
    [X_opt,FVAL,exitflag,info] = ecosqp(H,f,A,b,Aeq,beq,options);
    toc   

    %quadprog
%     options = optimoptions('quadprog','Display','iter');
%     [X_opt,f_star,exitflag,output,lambda] = quadprog(H,f,A,b,Aeq,beq);
%         if exitflag~=1
%             disp('I could not find an optimizer.')
%         end
%     fprintf("Exit flag %d at counter %d\n",exitflag,counter);
    % Run QP qpswift
%     [X_opt,~] = qpSWIFT(sparse(H),f,sparse(A),b,sparse(Aeq),beq);

    %Get actions
    [U_apply, C_lambda_apply,Aeq_lam_apply,feet_apply,lambda_apply,lambdas_cont,contact_indicator_apply] = getInputs(X_opt,C_lambda,Aeq_lam,foots,con_indicator,params);

    %Apply action
%     X_achieved_control = applyAction(x0,U_apply,params);
    X_achieved_control = applyActionODE(t,x0,U_apply,params);
    
    %Initial State for next control
    x0 = X_achieved_control(end-params.n+1:end,1);

    %Store X and U
    X_achieved = [X_achieved; X_achieved_control];
    U_achieved = [U_achieved; U_apply];
    Feet = [Feet feet_apply];
    lambda =[lambda;lambda_apply];
    C_lambda = [C_lambda;C_lambda_apply];
    lambdas_contact = [lambdas_contact lambdas_cont];
    contact_indicator_feet = [contact_indicator_feet contact_indicator_apply];
 
    t=t+params.n_actions*Ts;
end

tout = params.Ts:params.Ts:(params.M+params.M_stabilize)*params.Nd*Ts;
[X_pos,X_vel,U_plot,posfig,copfig] = plotResults(X_achieved,U_achieved,tout, params);

Net_force_xy = (params.mass*params.g/params.height)*(X_pos(1:2,:)-U_plot);
%no. of feet in contact
number_of_feet_cont = sum(contact_indicator_feet);

Net_force = [Net_force_xy; params.mass*params.g*ones(size(X_pos(1,:)))];

%Getting grfs FOR COP
GRF = [Net_force' zeros(size(Net_force')) zeros(size(Net_force')) zeros(size(Net_force'))];
U_an = [U_plot;zeros(1,length(U_plot))];
U_anim = [U_an' zeros(size(U_an')) zeros(size(U_an')) zeros(size(U_an'))];

%Feet
Feet(isnan(Feet))=0;
Feet_z = [Feet(1:2,:);0.01*ones(1,length(Feet(1:2,:)));Feet(3:4,:);0.01*ones(1,length(Feet(1:2,:)));Feet(5:6,:);0.01*ones(1,length(Feet(1:2,:)));Feet(7:8,:);0.01*ones(1,length(Feet(1:2,:)))]';
%Corresponding GRFS need lambda
GRF_feet = getForceFeet(Net_force_xy,lambdas_contact,contact_indicator_feet,params);




%% Animation
Q = [X_pos;zeros(size(X_pos))];

% ===== Super basic animation ===== %
animname = 'video'; % Empty name will not generate a video
BoxAnimation(tout,Q,feet,uout,1,'video');

% ===== Less basic animation ===== %
opts = AnimOptions('StepType','Frame',...
                   'FrameInc',1,...
                   'AutoPlay',false,...
                   'GRF',[GRF_feet,Feet_z],...
                   'LinkFig',[posfig,copfig]);
animview = 'iso';
animname = 'video'; % Empty name will not generate a video
anim = AnimateA1_SRB(tout, Q, animview, animname,'Options',opts);
%  anim = AnimateA1_SRB(tout, Q, animview, animname);












