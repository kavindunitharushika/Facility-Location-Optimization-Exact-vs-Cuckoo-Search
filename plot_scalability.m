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
