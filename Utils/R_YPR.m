function R = R_YPR(eul)
%R_YPR
%    R = R_YPR(IN1)

r = eul(1);
p = eul(2);
y = eul(3);
t2 = cos(y);
t3 = sin(r);
t4 = sin(y);
t5 = cos(r);
t6 = sin(p);
t7 = cos(p);
R = reshape([t2.*t7,t4.*t7,-t6,-t4.*t5+t2.*t3.*t6,t2.*t5+t3.*t4.*t6,t3.*t7,t3.*t4+t2.*t5.*t6,-t2.*t3+t4.*t5.*t6,t5.*t7],[3,3]);
