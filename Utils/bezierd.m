function value = bezierd( alpha, s )
%#codegen
[n, m] = size(alpha);
value=zeros(n,1);
M = m-1;
if M==3
    k=[3 6 3];
elseif M==4
    k=[4 12 12 4];
elseif M==5
    k=[5 20 30 20 5];
elseif M==6
    k=[6 30 60 60 30 6];
elseif M==7
    k = [ 7    42   105   140   105    42     7];
elseif M==8
    k = [ 8    56   168   280   280   168    56     8];
elseif M==9
    k = [9    72   252   504   630   504   252    72     9];
elseif M==20
    k = [ 20         380        3420       19380       77520      232560      542640     1007760     1511640,...
     1847560     1847560     1511640     1007760      542640      232560       77520       19380        3420,...
         380          20];
else
    k=M*binom(M-1);
end
%%
x = ones(1, M);
y = ones(1, M);
for i=1:M-1
    x(i+1)=s*x(i);
    y(i+1)=(1-s)*y(i);
end
for i=1:n
   value(i) = 0;
   for j=1:M
      value(i) = value(i) + (alpha(i,j+1)-alpha(i,j))*k(j)*x(j)*y(M+1-j);
   end
end


  