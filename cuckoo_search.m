function [best_cost,best_solution,convergence_curve,time_taken] = cuckoo_search(f,c,d,s,n_nests,pa,max_iter)
% Appendix A.3: Cuckoo Search with repair and penalties.
% NOTE: the report's repair may leave capacity violations; costs include penalties.
[m,n] = size(c); dim = m+m*n;
nests = rand(n_nests,dim); fitness = zeros(n_nests,1);
for i=1:n_nests
    fitness(i) = evaluate_solution(nests(i,:),f,c,d,s,m,n);
end
[best_cost,best_idx] = min(fitness);
best_solution = nests(best_idx,:);
convergence_curve = zeros(max_iter,1);
tic;
for iter=1:max_iter
    for i=1:n_nests
        new_solution = fix_bounds(levy_flight(nests(i,:),dim));
        new_fitness = evaluate_solution(new_solution,f,c,d,s,m,n);
        if new_fitness < fitness(i)
            nests(i,:) = new_solution;
            fitness(i) = new_fitness;
        end
    end
    [~,sorted_idx] = sort(fitness,'descend'); % abandon WORST nests
    num_abandon = round(pa*n_nests);
    for i=1:num_abandon
        new_nest = fix_bounds(rand(1,dim));
        nests(sorted_idx(i),:) = new_nest;
        fitness(sorted_idx(i)) = evaluate_solution(new_nest,f,c,d,s,m,n);
    end
    [current_best,best_idx] = min(fitness);
    if current_best < best_cost
        best_cost = current_best;
        best_solution = nests(best_idx,:);
    end
    convergence_curve(iter) = best_cost;
    if mod(iter,50)==0
        fprintf('Iteration %d: Best penalized cost = %.2f\n',iter,best_cost);
    end
end
time_taken = toc;
end

function step = levy_flight(solution,dim)
beta = 1.5;
sigma = (gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
u = randn(1,dim)*sigma;
v = randn(1,dim);
step = 0.01*u./(abs(v).^(1/beta));
step = solution+step.*(rand(1,dim)>0.5);
end

function sol = fix_bounds(sol)
sol = max(0,min(1,sol));
end

function cost = evaluate_solution(solution,f,c,d,s,m,n)
y = solution(1:m)';
x = reshape(solution(m+1:end),m,n); %#ok<NASGU>
y_bin = round(y);
x_repaired = zeros(m,n);
open_fac = find(y_bin==1);
if isempty(open_fac)
    open_fac = 1:m;
    % Ensure facilities assigned to customers are counted as open.
    y_bin(:) = 1;
end
for j=1:n
    [~,best_idx] = min(c(open_fac,j));
    x_repaired(open_fac(best_idx),j) = 1;
end
fixed_cost = sum(f(:).*y_bin(:));
transport_cost = sum(sum(c.*x_repaired));
penalty = 0; penalty_factor = 10000;
for i=1:m
    if y_bin(i)==1
        capacity_used = sum(d(:)'.*x_repaired(i,:));
        if capacity_used>s(i)
            penalty = penalty+(capacity_used-s(i))*penalty_factor;
        end
    end
end
cost = double(fixed_cost+transport_cost+penalty);
end
