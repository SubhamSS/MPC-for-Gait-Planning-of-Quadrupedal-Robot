function [H,f,A,b,Aeq,beq, C_lambda, Aeq_lam,foot_holds_step, contact_matrix] = getQP(params,x0,counter)
%GETQP Summary of this function goes here
%   Detailed explanation goes here
%Decision variable X,U,lambda
Q = params.Q;
P = params.P;
R = params.R;
M = params.M;
Nd = params.Nd;
horizon = params.horizon;
[n,~] = size(params.Ad);
[~,m] = size(params.Bd);

l = params.l;%no. of legs

contact_matrix = [];

for i=counter:horizon+counter-1
    domain_number = getDomainIndicator(params,i-1);
    contact_matrix_raw(:,i) = params.contact_matrix(:,domain_number);
    foot_holds_step_raw(:,i) = params.foot_holds(:,domain_number);
end

foot_holds_step = foot_holds_step_raw(:,counter:horizon+counter-1);
contact_matrix = contact_matrix_raw(:,counter:horizon+counter-1);

lambda_matrix = 0.5*sum(~isinf(foot_holds_step));
n_lambda = sum(0.5*sum(~isinf(foot_holds_step)));
total_dec_var= horizon*(n+m)+n_lambda;

%Inequalities of lambda
A_lam = [eye(n_lambda);-eye(n_lambda)]; %size of 2*n_lamba by n_lambda
b_lam = [ones(n_lambda,1);zeros(n_lambda,1)]; % size of 2*n_lambda by 1
%Equalties of lambda
Aeq_lam = zeros(horizon,n_lambda); %size of horizon by n_lambda
beq_lam = ones(horizon,1); %size of horizon by 1
Aeq_lam(1,1:lambda_matrix(1)) = 1;
index = lambda_matrix(1);
for j=2:horizon
    Aeq_lam(j,index+1:index+lambda_matrix(j))= 1;
    index = index+lambda_matrix(j);
end

%Contact Matrix for lambdas
[dim1,dim2] = size(foot_holds_step);
foot_holds_step_reshape = reshape(foot_holds_step,2,dim1*dim2/2);
%removes infs
foot_holds_step_noinfs = foot_holds_step_reshape(:,any(~isinf(foot_holds_step_reshape),1));
%Getting C lambda
C_lambda = zeros(2*horizon,n_lambda);
for i=1:horizon
    C_lambda(2*i-1,:) = foot_holds_step_noinfs(1,:).*any(Aeq_lam(i,:),1);
    C_lambda(2*i,:) = foot_holds_step_noinfs(2,:).*any(Aeq_lam(i,:),1);
end


%Equalities of X and U
Ad = params.Ad;
Bd = params.Bd;
Aeq_xu                  = zeros(horizon*n,horizon*(n+m));
Aeq_xu(1:n,1:n)         = eye(n);
Aeq_xu(1:n,n*horizon+1:n*horizon+m) = -Bd;
for k=2:horizon
   Aeq_xu((k-1)*n+1:k*n,(k-1)*n+1:k*n)         = eye(n);
   Aeq_xu((k-1)*n+1:k*n,(k-2)*n+1:(k-1)*n)     = -Ad;
   Aeq_xu((k-1)*n+1:k*n,n*horizon+(k-1)*m+1:n*horizon+k*m) = -Bd;
end

beq_xu        = zeros(horizon*n,1);
beq_xu(1:n,1) = Ad*x0;

%Inequalities of X and U
C = params.Phi;
D = params.Psi;
E = params.eta;

A_xu = zeros(horizon*(n),horizon*(n+m));
A_xu(1:n,n*horizon+1:n*horizon+m) = D;

for k=2:horizon
    A_xu((k-1)*(n)+1:k*(n),(k-2)*(n)+1:(k-1)*(n)) = C;
    A_xu((k-1)*(n)+1:k*(n),n*horizon+(k-1)*m+1:n*horizon+k*m) = D;
end

b_xu = zeros(horizon*(n),1);
b_xu(1:n,1) = E - C*x0;

for k=2:horizon
    b_xu((k-1)*n+1:k*n)=E;
end

%Combining with lambdas into final matrices
%Equalities
Aeq = zeros(horizon*(n+m)+horizon,horizon*(n+m)+n_lambda);
Aeq(1:horizon*n,1:horizon*(n+m)) = Aeq_xu;
Aeq(horizon*n+1:horizon*(n+m),horizon*n+1:horizon*(n+m))=eye(horizon*m);
Aeq(horizon*n+1:horizon*(n+m),horizon*(n+m)+1:horizon*(n+m)+n_lambda) = -C_lambda;
Aeq(horizon*(n+m)+1:horizon*(n+m)+horizon,horizon*(n+m)+1:horizon*(n+m)+n_lambda)= Aeq_lam;

beq = zeros(horizon*(n+m)+horizon,1);
beq(1:horizon*n,1)=beq_xu;
beq(horizon*(n+m)+1:horizon*(n+m)+horizon,1)=beq_lam;


%Inequalities
A = zeros(horizon*n+2*n_lambda,horizon*(n+m)+n_lambda);
A(1:horizon*n,1:horizon*(n+m))=A_xu;
A(horizon*n+1:horizon*n+2*n_lambda,horizon*(n+m)+1:horizon*(n+m)+n_lambda)= A_lam;
b = zeros(horizon*n+2*n_lambda,1);
b(1:horizon*n,1)= b_xu;
b(horizon*n+1:horizon*n+2*n_lambda,1) = b_lam;


%Target Traj
State_trajectory = getTargetTrajectory(params);
% [len,wid] = size(params.COM_target_trajectory);
% COM_targets = params.COM_target_trajectory;
% COM_targets_resize = reshape(COM_targets,2,len*wid/2);
% [lenr,widr]= size(COM_targets_resize);
% State_trajectory = zeros(2*lenr,widr);
% State_trajectory(1,:) = COM_targets_resize(1,:);
% State_trajectory(3,:) = COM_targets_resize(2,:);



%Specific to this problem
State_trajectory_desired = State_trajectory(:,counter:counter+horizon-1);
State_trajectory_desired_reshape = reshape(State_trajectory_desired,n*horizon,1);

Decision_var_desired = zeros(horizon*(m+n)+n_lambda,1);
Decision_var_desired(1:horizon*n,1)=State_trajectory_desired_reshape;


%Cost Functions
% Z = [X, U, lambdas]
% Compute the H matrix
Qbar = zeros(n*horizon,n*horizon);
for k=1:horizon-1
    Qbar((k-1)*n+1:k*n,(k-1)*n+1:k*n) = params.Q;
end
Qbar((horizon-1)*n+1:horizon*n,(horizon-1)*n+1:horizon*n) = params.P;

Rbar = zeros(m*horizon,m*horizon);
for k=1:horizon
    Rbar((k-1)*m+1:k*m,(k-1)*m+1:k*m) = params.R;
end

H = zeros(horizon*(m+n)+n_lambda);
H(1:n*horizon,1:n*horizon) = Qbar;
H(n*horizon+1:(n+m)*horizon,n*horizon+1:(n+m)*horizon) = Rbar;

fbar = zeros(horizon*(n+m)+n_lambda);
fbar(1:horizon*n,1:horizon*n)= Qbar;
f = -fbar*Decision_var_desired;


end

