function [total_cost,y,x,solve_time] = exact_solver(f,c,d,s)
% Appendix A.2; corrected indexing to match MATLAB column-major reshape.
[m,n] = size(c);
num_vars = m+m*n;
f_obj = [f(:);c(:)];
A_ineq = sparse(m,num_vars);
for i=1:m
    for j=1:n
        A_ineq(i,m+(j-1)*m+i) = d(j);
    end
    A_ineq(i,i) = -s(i);
end
b_ineq = zeros(m,1);
A_eq = sparse(n,num_vars);
for j=1:n
    for i=1:m
        A_eq(j,m+(j-1)*m+i) = 1;
    end
end
b_eq = ones(n,1);
lb = zeros(num_vars,1); ub = ones(num_vars,1);
intcon = 1:num_vars;
options = optimoptions('intlinprog','Display','off','MaxTime',300);
tic;
[solution,total_cost,exitflag] = intlinprog(f_obj,intcon,A_ineq,b_ineq,A_eq,b_eq,lb,ub,options);
solve_time = toc;
% A time-limited feasible solution is not necessarily proven optimal.
if isempty(solution)
    total_cost = Inf; y = zeros(m,1); x = zeros(m,n);
    fprintf('Exact solver returned no feasible solution.\n');
else
    if exitflag ~= 1
        fprintf('Exact solver returned an incumbent without proven optimality (exitflag=%d).\n',exitflag);
    end
    y = solution(1:m);
    x = reshape(solution(m+1:end),m,n);
end
end
