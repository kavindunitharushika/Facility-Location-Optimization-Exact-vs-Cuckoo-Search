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
