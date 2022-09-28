clear all;
close all;

muscle_list = {'Carpi_Radialis', 'Bicep', 'Deltoid', 'Tricep', 'Wrist_Extensor', 'Acromiotrapezius'};

muscle_names = {'W. Flexor','Biceps','Deltoid','Triceps','W. Extensor','Acromiotrapezius'};


plot_depth_list = {'Epidural', 'Spinous_Process'};
plot_waveform_list = {'Biphasic', 'Monophasic'};
plot_freq_list = {'Single','10_kHz'};

for plot_depth_idx = 1:length(plot_depth_list)
    plot_depth = plot_depth_list(plot_depth_idx);
    for plot_waveform_idx = 1:length(plot_waveform_list)
        plot_waveform = plot_waveform_list(plot_waveform_idx);
        for plot_freq_idx = 1:length(plot_freq_list)
            
            load('all_param_data.mat')
            
            plot_freq = plot_freq_list(plot_freq_idx);
            %% Filter Sigmoid Structure
            % sigmoid_struct = sigmoid_struct(["transq_rat_8"] ~= [sigmoid_struct.Rat]);
            sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C4') == 0);
            sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C6') == 0);

            sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Depth}, plot_depth));

            %Remove 1ms monophasic pulse
            stim_filter = strcmp({sigmoid_struct.Duration}, '1_ms') + strcmp({sigmoid_struct.Stim_Waveform},'Monophasic')+...
                strcmp({sigmoid_struct.Stim_Freq}, 'Single') ~= 3;

            % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Duration}, '1_ms'));
            sigmoid_struct = sigmoid_struct(stim_filter);



            sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Freq}, plot_freq));
            % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Freq}, 'Single'));
            % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Waveform}, 'Monophasic'));
            sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Waveform}, plot_waveform));
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

            figure('Position', [10 10 2000 1200])
            for muscle = 1:length(muscle_list)
                subplot(2,3,muscle)
                hold on
                for pos = 1:3
                    muscle_feature = muscle_data{muscle}{pos};
                    data_mean = mean(muscle_feature, 'omitnan');
                    data_ste = std(muscle_feature, 'omitnan')/sqrt(length(muscle_feature(~isnan(muscle_feature))));
                    bar(pos,data_mean,0.5,'LineWidth',1.3, 'FaceColor', bar_colors{pos})
                    errorbar(pos,data_mean,data_ste, 'k', 'LineWidth', 2.0)

                end
                title(muscle_names{muscle})
                xticks([1 2 3])
                xticklabels(pos_order)
                ylabel('Sensitivity (% Activation/uA)')
                xlim([0.2 3.8])
                ylim([0, 1.2e-3])
                
                ax = gca;
                ax.FontSize = 17;
             
            end
            saveas(gcf, ['figures/slope_',plot_waveform_list{plot_waveform_idx},'_',plot_depth_list{plot_depth_idx},'_',plot_freq_list{plot_freq_idx},'.svg'])
        end
    end
end



