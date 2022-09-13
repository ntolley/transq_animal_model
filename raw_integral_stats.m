function [mean_integral, STE_integral, charge_list] = raw_integral_stats(raw_data)
    raw_integral = raw_data(1,:);
    raw_charges = raw_data(2,:);
    charge_list = unique(raw_charges);
    charge_list = sort(charge_list,'ascend');
    
    mean_integral = [];
    STE_integral = [];
    for Q = 1:length(charge_list)
        charge_filter = raw_charges == charge_list(Q);
        num_pulses = sum(charge_filter);
        mean_integral(end+1) = mean(raw_integral(charge_filter));
        STE_integral(end+1) = std(raw_integral(charge_filter)) / sqrt(num_pulses);
        
    end
    

end