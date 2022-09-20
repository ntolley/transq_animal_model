clear all;
close all;

muscle_list = {'Carpi_Radialis', 'Bicep', 'Deltoid', 'Tricep', 'Wrist_Extensor', 'Acromiotrapezius'};

muscle_names = {'W. Flexor','Biceps','Deltoid','Triceps','W. Extensor','Acromiotrapezius'};

waveform_list = {'Biphasic', 'Monophasic'};

for w_idx = 1:length(waveform_list)
    load('all_param_data.mat')
    
    %% Filter Sigmoid Structure
    % sigmoid_struct = sigmoid_struct(["transq_rat_8"] ~= [sigmoid_struct.Rat]);
    sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C4') == 0);
    sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C6') == 0);

    sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Position}, 'C5'));
    % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Depth}, 'Epidural'));
    % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Depth}, 'Spinous_Process'));

    %Remove 1ms monophasic pulse
    stim_filter = strcmp({sigmoid_struct.Duration}, '1_ms') + strcmp({sigmoid_struct.Stim_Waveform},'Monophasic')+...
        strcmp({sigmoid_struct.Stim_Freq}, 'Single') ~= 3;

    % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Duration}, '1_ms'));
    sigmoid_struct = sigmoid_struct(stim_filter);

    sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Waveform}, waveform_list{w_idx}));

    % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Freq}, '10_kHz'));
    % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Freq}, 'Single'));
    % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Waveform}, 'Monophasic'));
    % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Stim_Waveform}, 'Biphasic'));
    sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Lateral_Position}, 'Midline'));
    % sigmoid_struct = sigmoid_struct(strcmp({sigmoid_struct.Lateral_Position}, 'Lateral'));

    filtered_struct = sigmoid_struct;

    %Find fields with no missing entries
    filled_muscle = {};
    for muscle = 1:length(muscle_list)
        muscle_param_matrix = [];
        empty_field = 0;
        for stim_set = 1:length(filtered_struct)
            if isempty(filtered_struct(stim_set).(muscle_list{muscle})) == 1
                empty_field = empty_field + 1;
            end
        end

        if empty_field == 0
            filled_muscle{end+1} = muscle_list{muscle};
        end
    end


    %% Organize for statistics 
    % Choose parameter to plot (1 = stim threshold, 2 = asymptote,
    % 3 = midpoint, 4 = slope, 5 = max_activation, 6 = max_charge)
    sig_param = 1;

    figure('Position', [10 10 1400 800])
    %Plot by depth
    d_vec = {[],[]};
    color_map = {[1, 0, 0],[0,0,0]};
    bar_color_map = {[1, 0, 0],[0,0,0]+0.4};

    %single pulse array
    distrib1_array = {d_vec,d_vec,d_vec,d_vec,d_vec,d_vec};
    %10 kHz arrary
    distrib2_array = {d_vec,d_vec,d_vec,d_vec,d_vec,d_vec};

    for stim_set = 1:length(sigmoid_struct)
        for muscle = 1:length(muscle_list)
            plot_data = sigmoid_struct(stim_set).(muscle_list{muscle});
            if isempty(plot_data) ~= 1
                plot_data = plot_data(sig_param);

                if strcmp(sigmoid_struct(stim_set).Stim_Freq,'Single') == 1 && strcmp(sigmoid_struct(stim_set).Depth,'Epidural') == 1
                    distrib1_array{muscle}{1}(end+1) = plot_data;
                elseif strcmp(sigmoid_struct(stim_set).Stim_Freq,'Single') == 1 && strcmp(sigmoid_struct(stim_set).Depth,'Spinous_Process') == 1
                    distrib1_array{muscle}{2}(end+1) = plot_data;           
                elseif strcmp(sigmoid_struct(stim_set).Stim_Freq,'10_kHz') == 1 && strcmp(sigmoid_struct(stim_set).Depth,'Epidural') == 1
                    distrib2_array{muscle}{1}(end+1) = plot_data;
                elseif strcmp(sigmoid_struct(stim_set).Stim_Freq,'10_kHz') == 1 && strcmp(sigmoid_struct(stim_set).Depth,'Spinous_Process') == 1
                    distrib2_array{muscle}{2}(end+1) = plot_data;
                end           
            end
        end
    end


    for muscle = 1:length(muscle_list)
        subplot(2,3,muscle)
    %     ylim manual
        hold on

    %     bar_pos = {[0.9, 1.9], [1.1, 2.1]};
        bar_pos = {[1, 1.8], [1.2, 2]};

        for idx = 1:length(d_vec)
            distrib1 = distrib1_array{muscle}{idx};
            distrib2 = distrib2_array{muscle}{idx};

            [f1,xi_1] = ksdensity(distrib1);
            mean1 = nanmean(distrib1);
            ste1 = nanstd(distrib1)/sqrt(length(distrib1));   

            [f2,xi_2] = ksdensity(distrib2);
            mean2 = nanmean(distrib2);
            ste2 = nanstd(distrib2)/sqrt(length(distrib2));

            plot(bar_pos{idx}, [mean1 mean2],'--' ,'color',bar_color_map{idx},'LineWidth',2)

            plot(rescale((f1*-1),0,0.4) + 0.4, xi_1,'--','color',color_map{idx},'LineWidth',1.3)
            a1 = bar(bar_pos{idx}(1), mean1,0.1, 'FaceColor',bar_color_map{idx},'LineWidth',1.3);
            errorbar(bar_pos{idx}(1), mean1, ste1, 'k','LineWidth',1.3)    

            plot(rescale((f2),0,0.4) + 2.2, xi_2,'--','color',color_map{idx},'LineWidth',1.3)
            a2 = bar(bar_pos{idx}(2), mean2,0.1,'FaceColor', bar_color_map{idx},'LineWidth',1.3);
            errorbar(bar_pos{idx}(2), mean2, ste2, 'k','LineWidth',1.3)



        end
        plot([0.8,0.8],[-1e4 1e4],'k','LineWidth',2)
        plot([2.2,2.2],[-1e4 1e4],'k','LineWidth',2)
    end
    for muscle = 1:length(muscle_list)
        subplot(2,3,muscle)
        hold on
        a2 = bar(-10, 10, 'FaceColor', [0 0 0]+0.4,'LineWidth',1.3);
        a1 = bar(-10, 10, 'r','LineWidth',1.3);
        title(muscle_names{muscle})
        xlim([0 3])
        ylim([0 5000])
        xticks([0.9 2.1])
        xticklabels({'Single', '10 kHz'})
        ylabel('Max Current (uA)')
        if muscle == 1
            legend([a1 a2],{'Epidural', 'Spinous Process'}, 'Location', 'northwest')
        end
    %     legend({'Epidural','Spinous Process'})
        ax = gca;
        ax.FontSize = 17;

    
    end
    
    saveas(gcf, ['activation_threshold_boxplot', waveform_list{w_idx}, '.svg'])
end


    

   

    
