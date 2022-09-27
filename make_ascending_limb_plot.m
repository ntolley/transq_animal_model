clear all;
close all;

muscle_list = {'Carpi_Radialis', 'Bicep', 'Deltoid', 'Tricep', 'Wrist_Extensor', 'Acromiotrapezius'};

muscle_names = {'CAR','BIC','DEL','TRI','WRE','ACT'};

% muscle_names = {'BIC'};
% muscle_list = {'Bicep'};

%% Fit sigmoid to data for each muscle
d = 'TransQ_Integral_Data_v12';
load(d)

% data_struct = dataset_cap_charge(data_struct, muscle_list, 2500, 4000);
fill_between_lines = @(X,Y1,Y2,C) fill( [X fliplr(X)],  [Y1 fliplr(Y2)], C );

f = @(A, i)(A(1) ./ (1 + exp(-(i - A(2)) ./ A(3))));
z = @(B, i)(-B(3) .* log((B(1) ./i) -1) + B(2));
der_eq = @(C, i)((C(1) .* exp( (C(2) - i) ./ C(3) ))   ./   (C(3) .* (((exp( (C(2) - i) ./ C(3) )) + 1) .^ 2)   ) );

data_struct = data_struct';
sigmoid_struct = data_struct;

%% Normalize data_struct across positions, within stimulation params
all_stim = {};
rat_list = {};
for stim_set = 1:length(data_struct)
    stim_type_string = [data_struct(stim_set).Rat{1},'_',data_struct(stim_set).Depth,'_',...
        data_struct(stim_set).Stim_Freq,'_',data_struct(stim_set).Stim_Waveform,'_',...
        data_struct(stim_set).Duration,'_',data_struct(stim_set).Lateral_Position];
    
    data_struct(stim_set).Stim_Type = stim_type_string;
    
    stim_type_string = [stim_type_string,'_',data_struct(stim_set).Position,'_'];
    all_stim{end+1} = stim_type_string;
    rat_list{end+1} = data_struct(stim_set).Rat{1};
end

stim_type_list = unique({data_struct.Stim_Type});
% data_struct = normalize_EMG_SP(data_struct, 'Stim_Type', stim_type_list);
data_struct = normalize_EMG(data_struct);

data_struct = data_struct(strcmp(rat_list, 'transq_rat_8'));

%%
font_val = 16;
deriv_comp = [];
for stim_set = 1:length(data_struct)
    stim_string = [data_struct(stim_set).Rat{1},'_',data_struct(stim_set).Position,'_',data_struct(stim_set).Stim_Freq,'_',...
        data_struct(stim_set).Stim_Waveform,'_', data_struct(stim_set).Depth];
    
    %Fit sigmoids and store params
    figure('units','normalized','outerposition',[0 0 1 1])
    
    muscle_set = data_struct(stim_set).Muscle_List;
    

    for muscle = 1:length(muscle_set)
        subplot(2,3,muscle)
        hold on
        
        if isempty(data_struct(stim_set).(muscle_set{muscle})) ~= 1
            x = data_struct(stim_set).(muscle_set{muscle})(2,:);
            y = data_struct(stim_set).(muscle_set{muscle})(1,:);
            
            
            
            [mean_data, ste, c] = raw_integral_stats(data_struct(stim_set).(muscle_set{muscle}));
            
            %Plotting full curve
            plot(c,mean_data,'k--','LineWidth',2)
            
            %Cap if subsequent act drops by 10% (inhibition)
            [pks,locs] = findpeaks(mean_data);
            
            
            
            if isempty(pks) ~= 1
                for idx = 1:length(locs)
                    plateau_check = sum((mean_data(locs(idx)) - mean_data(locs(idx):end)) > 0.1);
                    if plateau_check > 0
                        break
                    end
                end
                max_idx = locs(idx);
                max_val = pks(idx);
            else
                max_idx = length(mean_data);
                max_val = mean_data(max_idx);
            end
            
           
            max_idx_charge = c(max_idx);
            x = x(x <= max_idx_charge);
            y = y(x <= max_idx_charge);
            
            [mean_data2, ste2, c2] = raw_integral_stats([y;x]);
            
            %Plotting ascending limb
            errorbar(c2,mean_data2,ste2,'b','LineWidth',2)
            
            fit_param = nlinfit(x,y,f,[1 3000 1000]);
            
            %Plot sigmoid
            plot(1:1:x(end), f(fit_param, 1:1:x(end)) ,'r', 'LineWidth', 2)
            
            asymptote = fit_param(1);   
            max_activation = max_val;
            mid_point = fit_param(2);
            
            half_max_charge = z(fit_param, max_val*0.5);
            half_max_charge = real(half_max_charge);
            slope = der_eq(fit_param, half_max_charge);
            test_deriv = diff(f(fit_param,0:1:max_idx_charge));
%             deriv_comp(end+1,:) = [slope test_deriv(floor(half_max_charge))];
            
            threshold = z(fit_param, 0.10);
            threshold = real(threshold);
            
%             
            
            %set very low thresholds to min charge delivered
            if threshold < 500
                threshold = 500;
            elseif threshold >= 8000
                threshold = NaN;
            end
            
            %Test if any values exceed threshold, if not set as NaN
            activation_test = sum(mean_data > 0.1);
            
            % Negative slope values indicate poor sigmoid fit
            if slope > 0 && activation_test > 0
                sigmoid_struct(stim_set).(muscle_set{muscle}) = [threshold asymptote mid_point slope max_activation max_idx_charge]; 
                title([muscle_names{muscle}])
            else 
                sigmoid_struct(stim_set).(muscle_set{muscle}) = NaN(1,6);
                title([muscle_names{muscle}, ' (Poor Fit)'])
            end
            
  
        
        end
        
        ylim([0 1.1]);
        
        plot([threshold threshold], [-10000 10000], 'k-.', 'LineWidth', 2)
        xlabel('Current (uA)', 'FontSize', font_val)
        ylabel('EMG Activation', 'FontSize', font_val) 
        legend({'Full Curve', 'Ascending Limb', 'Sigmoid Fit', 'Activation Thresh'},'Location','southeast', 'FontSize', font_val)
        ax = gca;
        ax.FontSize = font_val;
        
    end
    
    
  
    saveas(gcf, ['figures/ascending_limb/',stim_string,'.svg'])
    close all;
end