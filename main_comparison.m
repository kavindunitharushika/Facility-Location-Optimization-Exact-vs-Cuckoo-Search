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
