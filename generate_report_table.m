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
