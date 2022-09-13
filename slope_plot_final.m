clear all;
close all;

load('all_param_data.mat')

muscle_list = {'Carpi_Radialis', 'Bicep', 'Deltoid', 'Tricep', 'Wrist_Extensor', 'Acromiotrapezius'};

muscle_names = {'W. Flexor','Biceps','Deltoid','Triceps','W. Extensor','Acromiotrapezius'};


%% Filter Sigmoid Structure
% sigmoid_struct = sigmoid_struct(["transq_rat_8"] ~= [sigmoid_struct.Rat]);
sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C4') == 0);
sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C6') == 0);

% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C5'));
sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Depth}, 'Epidural'));
% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Depth}, 'Spinous_Process'));

%Remove 1ms monophasic pulse
stim_filter = strcmp({sigmoid_struct.Duration}, '1_ms') + strcmp({sigmoid_struct.Stim_Waveform},'Monophasic')+...
    strcmp({sigmoid_struct.Stim_Freq}, 'Single') ~= 3;

% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Duration}, '1_ms'));
sigmoid_struct = sigmoid_struct(stim_filter);



% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Freq}, '10_kHz'));
sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Freq}, 'Single'));
sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Waveform}, 'Monophasic'));
% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Waveform}, 'Biphasic'));
sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Lateral_Position}, 'Midline'));
% sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Lateral_Position}, 'Lateral'));



filtered_struct = sigmoid_struct;

%% Organize for statistics 
% Choose parameter to plot (1 = stim threshold, 2 = asymptote,
% 3 = midpoint, 4 = slope, 5 = max_activation, 6 = max_charge)
sig_param = 4;

% stim_string_array = {};
% stim_type_general = {};
% 
% for stim_set = 1:length(sigmoid_struct)
%     stim_string = [sigmoid_struct(stim_set).Rat{1},'_',sigmoid_struct(stim_set).Stim_Freq,'_',...
%         sigmoid_struct(stim_set).Stim_Waveform,'_', sigmoid_struct(stim_set).Depth];
%     
%     stim_string_array{end+1} = stim_string;
%     
%     sigmoid_struct(stim_set).stim_idx = stim_string;
%     
%     stim_type_general{end+1} = [sigmoid_struct(stim_set).Stim_Freq,'_',...
%         sigmoid_struct(stim_set).Stim_Waveform,'_', sigmoid_struct(stim_set).Depth];
% end
% 
% stim_type_list = unique(stim_string_array);
% stim_type_general = unique(stim_type_general);

%Store single and 10k values for distribution function
%Plot by position

%Choose pos to center (C3 = 1, C5 = 2, C7 = 3)
pos_order = {'C3','C5','C7'};

muscle_data = {
    {[],[],[]}
    {[],[],[]}
    {[],[],[]}
    {[],[],[]}
    {[],[],[]}
    {[],[],[]}
    };
for pos = 1:length(pos_order)
    temp_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, pos_order{pos}));
    for muscle = 1:length(muscle_list)
        for idx = 1:length(temp_struct)
            if isempty(temp_struct(idx).(muscle_list{muscle})) ~= 1
                muscle_data{muscle}{pos}(end+1) = temp_struct(idx).(muscle_list{muscle})(sig_param);
            end
        end
    end

    
end

bar_colors = {
    [0, 0.4470, 0.7410]
    [0.4660, 0.6740, 0.1880]
    [0.35, 0.35, 0.35]

};

figure
for muscle = 1:length(muscle_list)
    subplot(2,3,muscle)
    hold on
    for pos = 1:3
        data_mean = mean(muscle_data{muscle}{pos});
        data_ste = std(muscle_data{muscle}{pos})/sqrt(length(muscle_data{muscle}{pos}));
        bar(pos,data_mean,0.5,'LineWidth',1.3, 'FaceColor', bar_colors{pos})
        errorbar(pos,data_mean,data_ste, 'k', 'LineWidth', 1.3)
        
    end
    title(muscle_names{muscle})
    ylim([0 1e-3])
    xticks([1 2 3])
    xticklabels(pos_order)
    ylabel('Sensitivity (% Activation/uA')
    ylim_max = ylim;
    xlim([0.2 3.8])
    
    ax = gca;
    ax.FontSize = 17;
    
end



