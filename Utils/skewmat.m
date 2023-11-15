function [mat] = skewmat(x)
    if isa(x,'sym')
        mat = sym(zeros(3,3*size(x,2)));
    else
        mat = zeros(3,3*size(x,2));
    end
    for n = 1:size(x,2)
        mat(:,(n-1)*3+1:n*3) = skewsym(x(:,n));
    end
end

