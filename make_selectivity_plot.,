close all;
clear all;

close all;
clear all;

load('all_param_data.mat')

muscle_list = {'Carpi_Radialis', 'Bicep', 'Deltoid', 'Tricep', 'Wrist_Extensor', 'Acromiotrapezius'};

muscle_names = {'W. Flexor','Biceps','Deltoid','Triceps','W. Extensor','A. Trapezius'};


%% Filter Sigmoid Structure
% sigmoid_struct = sigmoid_struct(["transq_rat_8"] ~= [sigmoid_struct.Rat]);
sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C4') == 0);
sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C6') == 0);

% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C5'));
% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Depth}, 'Epidural'));
% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Depth}, 'Spinous_Process'));

%Remove 1ms monophasic pulse
stim_filter = strcmp({sigmoid_struct.Duration}, '1_ms') + strcmp({sigmoid_struct.Stim_Waveform},'Monophasic')+...
    strcmp({sigmoid_struct.Stim_Freq}, 'Single') ~= 3;

% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Duration}, '1_ms'));
sigmoid_struct = sigmoid_struct(stim_filter);

% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Freq}, '10_kHz'));
% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Freq}, 'Single'));
% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Waveform}, 'Monophasic'));
% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Waveform}, 'Biphasic'));
sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Lateral_Position}, 'Midline'));
% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Lateral_Position}, 'Lateral'));


%% Organize for statistics 
% Choose parameter to plot (1 = stim threshold, 2 = asymptote,
% 3 = midpoint, 4 = slope, 5 = max_activation, 6 = max_charge)
sig_param = 1;

stim_string_array = {};
stim_string_general = {};
for stim_set = 1:length(sigmoid_struct)
    stim_string = [sigmoid_struct(stim_set).Rat{1},'_',sigmoid_struct(stim_set).Stim_Freq,'_',...
        sigmoid_struct(stim_set).Stim_Waveform,'_', sigmoid_struct(stim_set).Depth];
    
    stim_string_array{end+1} = stim_string;
    
    stim_string2 = [sigmoid_struct(stim_set).Stim_Freq,'_',...
        sigmoid_struct(stim_set).Stim_Waveform,'_', sigmoid_struct(stim_set).Depth];
    stim_string_general{end+1} = stim_string2;
    
    sigmoid_struct(stim_set).stim_idx = stim_string2;
    
    %Set poor fits to threshold of 8000, store inv(threshold)
    for muscle = 1:length(muscle_list)
       if any(isnan(sigmoid_struct(stim_set).(muscle_list{muscle}))) == 1
           sigmoid_struct(stim_set).(muscle_list{muscle}) = inv(8000);
       elseif isempty(sigmoid_struct(stim_set).(muscle_list{muscle})) ~= 1
           muscle_data = sigmoid_struct(stim_set).(muscle_list{muscle});
           sigmoid_struct(stim_set).(muscle_list{muscle}) = inv(muscle_data(1));
           
       end
        
    end
    
    %Compute BIC/TRI/DEL Selectivity
    if (isempty(sigmoid_struct(stim_set).Tricep) + isempty(sigmoid_struct(stim_set).Bicep) + isempty(sigmoid_struct(stim_set).Deltoid)+ isempty(sigmoid_struct(stim_set).Carpi_Radialis)) == 0
        BIC_ex = sigmoid_struct(stim_set).Bicep;
        TRI_ex = sigmoid_struct(stim_set).Tricep;
        DEL_ex = sigmoid_struct(stim_set).Deltoid;
        CAR_ex = sigmoid_struct(stim_set).Carpi_Radialis;
        
        sigmoid_struct(stim_set).BIC_sel = BIC_ex/(BIC_ex+TRI_ex+DEL_ex+CAR_ex);
        sigmoid_struct(stim_set).TRI_sel = TRI_ex/(BIC_ex+TRI_ex+DEL_ex+CAR_ex);
        sigmoid_struct(stim_set).DEL_sel = DEL_ex/(BIC_ex+TRI_ex+DEL_ex+CAR_ex);
        sigmoid_struct(stim_set).CAR_sel = CAR_ex/(BIC_ex+TRI_ex+DEL_ex+CAR_ex);
        
    end
    
    
end



stim_type_list = unique(stim_string_array);
stim_type_general = unique(stim_string_general);

%% Compute segmental selectivity
% rat_list = [8,9,10,11,12,14,15,16,17];
rat_list = [10,11,15,17];


% field_name_list = {'10k Bi Epi','10k Bi Sp','10k Mono Epi','10k Mono Sp',...
%     'Single Bi Epi','Single Bi Sp','Single Mono Epi','Single Mono Sp'};
field_name_list = {'10 kHz','10 kHz','110 kHz','10 kHz',...
    'Single Pulse','Single Pulse','Single Pulse','Single Pulse'};

%{stim_type 8 cells}=>{position 3 cells}=>{rat x muscle (DEL, BIC, TRI)}
arm_sel_data = {{[],[],[],[]},{[],[],[],[]},{[],[],[],[]},{[],[],[],[]},{[],[],[],[]},{[],[],[],[]},{[],[],[],[]},{[],[],[],[]}};

wrist_sel_struct = struct();
for rat = 1:length(rat_list)
    for stim_type = 1:length(stim_type_general)
        rat_filter = strcmp(['transq_rat_',num2str(rat_list(rat))],[sigmoid_struct.Rat]);
        stim_filter = strcmp(stim_type_general{stim_type},{sigmoid_struct.stim_idx});
               
        C3_filter = (strcmp('C3',{sigmoid_struct.Position})+rat_filter+stim_filter) == 3;
        C5_filter = (strcmp('C5',{sigmoid_struct.Position})+rat_filter+stim_filter) == 3;
        C7_filter = (strcmp('C7',{sigmoid_struct.Position})+rat_filter+stim_filter) == 3;
        
        filter_array = {C3_filter,C5_filter,C7_filter};
        
        if any(C3_filter) && any(C5_filter)&& any(C7_filter)
%             BIC_val = sigmoid_struct(C3_filter).BIC_sel;      
%             TRI_val = sigmoid_struct(C7_filter).TRI_sel;      
%             DEL_val = sigmoid_struct(C7_filter).DEL_sel;
            
           	for f = 1:length(filter_array) 
                arm_sel_data{stim_type}{f}(rat,1) = sigmoid_struct(filter_array{f}).BIC_sel;
                arm_sel_data{stim_type}{f}(rat,2) = sigmoid_struct(filter_array{f}).DEL_sel;
                arm_sel_data{stim_type}{f}(rat,3) = sigmoid_struct(filter_array{f}).TRI_sel;
                arm_sel_data{stim_type}{f}(rat,4) = sigmoid_struct(filter_array{f}).CAR_sel;
                
            end

        end
        
        
    end
    
end

%% Plot selectivity heatmaps
% stim_idx_list = [1 5]; %Epidural Bi
% stim_idx_list = [3 7]; %Epidural Mono
% stim_idx_list = [2 6]; %Sp Bi
% stim_idx_list = [4 8]; %Sp Mono

stim_plot_list = {[1 5], [2 6]};
stim_title_list = {'epidural_biphasic', 'spinous_process_biphasic'};

for plot_idx = 1:length(stim_plot_list)
    figure('Position', [10 10 900 700])
    count = 1;
    
    stim_idx_list = stim_plot_list{plot_idx};
    for stim_type = stim_idx_list
        stim_data = arm_sel_data{stim_type};

        subaxis(2,2,count, 'Spacing', 0.15, 'Padding', 0, 'Margin', 0.1);
    %     hold on

        data_matrix = [];
        ste_matrix = [];

        for pos = 1:3
            pos_data = stim_data{pos};
            %Eliminate missing rows
            pos_data = pos_data(sum(pos_data,2) > 0,:);
            avg_data = mean(pos_data,1);
            ste_data = std(pos_data,1)/sqrt(size(pos_data,1));

            data_matrix(pos,:) = avg_data;
            ste_matrix(pos,:) = ste_data;


        end

    %     xticklabels({'DEL','BIC','TRI', 'CAR'})
    %     xticks([1 2 3 4])
    %     yticklabels({'C7','C5','C3'})
    %     yticks([1 2 3])


    %     imagesc(flipud(data_matrix), [0.25 0.5])
    %     imagesc(flipud(ste_matrix), [0 0.05])
        h = heatmap({'BIC','DEL','TRI', 'FCR'},{'C3','C5','C7'},data_matrix,'CellLabelColor','none');
        h.Title = field_name_list{stim_type};
        caxis(h, [0.15 0.35])


        colorbar
        ax = gca;
        ax.FontSize = 14;
        count = count+1;
    end

    %% Line Plots
    % ***DOUBLE CHECK THIS LABELING
    muscle_title = {'Biceps','DEL','Triceps','FCR'};

    % stim_idx_list = [2 4 6 8]; %Spinous Process set
    line_x_data = {[0.8 1.8 2.8],[],[],[] ,[1.2 2.2 3.2]};

    for muscle = [1 3]
        subaxis(2,2,count, 'Spacing', 0.13, 'Padding', 0, 'Margin', 0.1);
        hold on
        for stim_type = 1:length(stim_idx_list)

            stim_data = arm_sel_data{stim_idx_list(stim_type)};

            data_matrix = [];
            ste_matrix = [];

            for pos = 1:3
                pos_data = stim_data{pos};
                %Eliminate missing rows
                pos_data = pos_data(sum(pos_data,2) > 0,:);
                avg_data = mean(pos_data,1);
                ste_data = std(pos_data,1)/sqrt(size(pos_data,1));

                data_matrix(pos,:) = avg_data;
                ste_matrix(pos,:) = ste_data;      

            end

            errorbar(line_x_data{stim_type}, data_matrix(:,muscle), ste_matrix(:,muscle), 'LineWidth', 2)

        end
        plot([1.5 1.5], [-10 10], 'k--', 'LineWidth', 2)
        plot([2.5 2.5], [-10 10], 'k--', 'LineWidth', 2)


        xticks([1 2 3])
        xticklabels({'C3', 'C5', 'C7'})
        title(muscle_title{muscle})
        if muscle == 2
            legend(field_name_list{stim_idx_list})
        end
        xlim([0.5 3.5])
        ylim([0.1 0.4])
        ylabel('Selectivity Index')
        ax = gca;
        ax.FontSize = 14;

        count = count+1;
    end
    
    saveas(gcf, ['selectivity', stim_title_list{plot_idx}, '.png'])
end

