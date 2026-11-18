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
