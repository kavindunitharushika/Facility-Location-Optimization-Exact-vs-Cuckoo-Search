%% CFLP: Exact Algorithm vs Cuckoo Search
% Combined from the original MATLAB files without changing their calculations.
% Run this script in MATLAB R2016b or later (supports local functions in scripts).
% Requires Optimization Toolbox for intlinprog.
% The original experiment may take several hours.
% Results are not independently validated.

%% Main comparison experiment
% Appendix A.4: master experiment script (may take several hours).
clear; clc; close all;
problem_sizes = [5,20;10,50;20,100;30,200;50,500;100,1000];
cs_results = struct([]);
for idx=1:size(problem_sizes,1)
    m = problem_sizes(idx,1); n = problem_sizes(idx,2);
    fprintf('\n========== Testing: m=%d, n=%d ==========\n',m,n);
    [f,c,d,s] = generate_problem(m,n,42);
    fprintf('Running Exact Algorithm...\n');
    [exact_cost,~,~,exact_time] = exact_solver(f,c,d,s);
    fprintf('Running Cuckoo Search (3 runs)...\n');
    cs_costs = zeros(3,1); cs_times = zeros(3,1);
    cs_convergence = cell(3,1);
    for run=1:3
        [cs_costs(run),~,cs_convergence{run},cs_times(run)] = cuckoo_search(f,c,d,s,100,0.25,3000);
        fprintf('Run %d: Penalized cost=%.2f, Time=%.2fs\n',run,cs_costs(run),cs_times(run));
    end
    cs_results(idx).m = m;
    cs_results(idx).n = n;
    cs_results(idx).mean_cost = mean(cs_costs);
    cs_results(idx).std_cost = std(cs_costs);
    cs_results(idx).best_cost = min(cs_costs);
    cs_results(idx).worst_cost = max(cs_costs);
    cs_results(idx).mean_time = mean(cs_times);
    cs_results(idx).convergence = cs_convergence;
    cs_results(idx).exact_cost = exact_cost;
    cs_results(idx).exact_time = exact_time;
    if isfinite(exact_cost) && exact_cost~=0
        cs_results(idx).gap = abs(cs_results(idx).best_cost-exact_cost)/exact_cost*100;
    else
        cs_results(idx).gap = NaN;
    end
end
save('comparison_results.mat','cs_results');
plot_convergence(cs_results,problem_sizes);
plot_scalability(cs_results,problem_sizes);
generate_report_table(cs_results,problem_sizes);


%% Local function from generate_problem.m
function [f,c,d,s] = generate_problem(m,n,seed)
% Appendix A.1: synthetic problem generator
rng(seed);
f = randi([100,500],m,1);
d = randi([10,50],n,1);
total_demand = sum(d);
avg_capacity = total_demand*1.5/m;
s = randi([round(avg_capacity*0.8),round(avg_capacity*1.2)],m,1);
facility_locs = rand(m,2)*100;
customer_locs = rand(n,2)*100;
c = zeros(m,n);
for i=1:m
    for j=1:n
        c(i,j) = sqrt(sum((facility_locs(i,:)-customer_locs(j,:)).^2));
    end
end
end


%% Local function from exact_solver.m
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


%% Local function from cuckoo_search.m
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


%% Local function from generate_report_table.m
function generate_report_table(cs_results,problem_sizes)
% Appendix A.5: comparison report table.
fprintf('\n========== COMPARISON REPORT ==========\n');
fprintf('%-8s %-8s %-15s %-15s %-15s %-15s %-12s\n','m','n','Exact Cost','Exact Time(s)','CS Best Cost','CS Time(s)','Gap(%%)');
fprintf('%s\n',repmat('-',1,100));
for idx=1:size(problem_sizes,1)
    r = cs_results(idx);
    fprintf('%-8d %-8d %-15.2f %-15.2f %-15.2f %-15.2f %-12.2f\n',r.m,r.n,r.exact_cost,r.exact_time,r.best_cost,r.mean_time,r.gap);
end
large_idx = find([cs_results.m]>=50);
if ~isempty(large_idx)
    avg_exact_time = mean([cs_results(large_idx).exact_time]);
    avg_cs_time = mean([cs_results(large_idx).mean_time]);
    fprintf('\nLarge instances: Exact mean time %.2fs; CS mean time %.2fs; time ratio %.2fx\n',avg_exact_time,avg_cs_time,avg_exact_time/avg_cs_time);
end
end


%% Local function from plot_convergence.m
function plot_convergence(cs_results,problem_sizes)
% Appendix A.6
figure('Position',[100,100,1200,800]);
for idx=1:size(problem_sizes,1)
    subplot(2,3,idx);
    for run=1:numel(cs_results(idx).convergence)
        semilogy(cs_results(idx).convergence{run},'LineWidth',1.5); hold on;
    end
    xlabel('Iteration'); ylabel('Best penalized cost (log scale)');
    title(sprintf('m=%d, n=%d; gap=%.2f%%',cs_results(idx).m,cs_results(idx).n,cs_results(idx).gap));
    grid on; legend('Run 1','Run 2','Run 3','Location','best');
end
sgtitle('Cuckoo Search Convergence Curves');
saveas(gcf,'convergence_curves.png');
end


%% Local function from plot_scalability.m
function plot_scalability(cs_results,problem_sizes)
% Appendix A.7
figure('Position',[100,100,1400,500]);
sizes = 1:size(problem_sizes,1);
subplot(1,3,1);
semilogy(sizes,[cs_results.exact_time],'r-o','LineWidth',2,'MarkerSize',8); hold on;
semilogy(sizes,[cs_results.mean_time],'b-s','LineWidth',2,'MarkerSize',8);
xlabel('Problem size index'); ylabel('Time (seconds, log scale)');
title('Scalability: Computation Time'); legend('Exact Algorithm','Cuckoo Search','Location','northwest'); grid on;
subplot(1,3,2);
bar(sizes,[cs_results.gap],'FaceColor',[0.7,0.7,0.9]);
xlabel('Problem size index'); ylabel('CS reported gap (%)'); title('Cuckoo Search vs Exact'); grid on;
subplot(1,3,3);
plot(sizes,[cs_results.exact_cost],'r-o','LineWidth',2,'MarkerSize',8); hold on;
plot(sizes,[cs_results.best_cost],'b-s','LineWidth',2,'MarkerSize',8);
xlabel('Problem size index'); ylabel('Total cost / penalized objective');
title('Cost Comparison'); legend('Exact','CS Best','Location','northwest'); grid on;
sgtitle('Scalability Analysis: Exact vs Cuckoo Search');
saveas(gcf,'scalability_analysis.png');
end
