clear all;
close all;

muscle_string = {'Biceps','Triceps'};

d = 'TransQ_Integral_Data_v12';
load(d)



% data_struct = dataset_cap_charge(data_struct, muscle_list, 2000, 4000);
% channel_layout = {[1 2], [3 4], [5 6], [9 10], [11 12]};
% channel_layout = {[1 2], [3 4], [5 6]};
channel_layout = {[1 2], [3 4]};

n_lines = 6;
color1 = [0, 0.4470, 0.7410];
color2 = [0.6350, 0.0780, 0.1840];

% color1 = [0 0 1];
% color2 = [0 0.5 0];
colors_p = [linspace(color1(1),color2(1),n_lines)', linspace(color1(2),color2(2),n_lines)', linspace(color1(3),color2(3),n_lines)'];
% colormap(colors_p)

num_pos = 1:6;
stim_type_list = {'10k_bi','n_bi'};
stim_type_labels = {'10 kHz', 'Single Pulse'};
% 
% stim_type_list = {'10k_mono','n_mono'};
% stim_type_labels = {'10 kHz', 'Single Pulse'};

max_charge_list = [8000 5000];
count = 1;
figure
hold on
for stim = 1:length(stim_type_list)
    stim_type = stim_type_list{stim};
    max_charge = max_charge_list(stim);
    axis_max = 8000;
    position_legend = {'C3','C4','C5','C6','C7','C8'};

    delay_time = 2.9;

    %Store mean and standard error of integrals
    pos_integrals = cell(1,length(num_pos));
    pos_sterror = cell(1,length(num_pos));
    for position = num_pos
        mean_integral_array = [];
        sterror_integral_array = [];
        for c = 500:500:max_charge
            file_string = ['p',num2str(position), '_',num2str(c),'_',stim_type ];
            [mean_integral, sterror_integral] = integrate_emg(file_string, delay_time, channel_layout);

            mean_integral_array = [mean_integral_array, mean_integral];
            sterror_integral_array = [sterror_integral_array, sterror_integral];
        end

        pos_integrals{position} = mean_integral_array;
        pos_sterror{position} = sterror_integral_array;
    end

    muscle_max = [0 0];
    % Get max val for each muscle
    for muscle = 1:length(channel_layout)
        for position = num_pos
            max_val = max(pos_integrals{position}(muscle, :));
            if max_val > muscle_max(muscle)
                muscle_max(muscle) = max_val;
            end
        end

    end

    %plot each muscle with variable positions 
    for muscle = 1:length(channel_layout)
        subplot(2,2,count)
        hold on
        count = count+1;
        for position = num_pos
            mean_data = pos_integrals{position}(muscle, :)/muscle_max(muscle);
            error_data = pos_sterror{position}(muscle, :)/muscle_max(muscle);

    %         plot(mean_data, 'linewidth', 1)
            errorbar(mean_data, error_data,'linewidth', 1.5, 'color', colors_p(position,:))
     
        end
        title([muscle_string{muscle},' ',stim_type_labels{stim}],'FontSize', 15)
        xlabel('Current (uA)','FontSize', 15)
    %     xticks(1:2:(max_charge/500))
    %     xticklabels(500:1000:max_charge)

        xticks(1:2:(axis_max/500))
        xticklabels(500:1000:axis_max)

        ylabel('EMG Activation','FontSize', 15)
        if count == 2
            legend(position_legend, 'Location', 'northwest','FontSize', 10)
        end
        xlim([0 16])
    %     ylim([0 1])
    end
end