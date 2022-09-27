close all;
clear all;

load('TransQ_Raw_EMG_v1')
muscle_list = {'Carpi_Radialis', 'Bicep', 'Digitorum_Profundus', 'Deltoid', 'Tricep', 'Wrist_Extensor', 'Acromiotrapezius'};

all_stim = {};
all_rat = {};
for stim_set = 1:length(data_struct)
    stim_type_string = [data_struct(stim_set).Position,'_',data_struct(stim_set).Depth,'_',...
        data_struct(stim_set).Stim_Freq,'_',data_struct(stim_set).Stim_Waveform,'_',...
        data_struct(stim_set).Duration,'_',data_struct(stim_set).Lateral_Position];
    
    data_struct(stim_set).Stim_Type = stim_type_string;
    all_stim{end+1} = stim_type_string;
    all_rat{end+1} = data_struct(stim_set).Rat{1};
end

rat_sel = 'transq_rat_10';
muscle = 'Carpi_Radialis';
data_struct = data_struct(strcmp(all_rat, rat_sel));
all_stim = all_stim(strcmp(all_rat, rat_sel));


stim_type_list1 = {'C5_Epidural_10_kHz_Biphasic_1_ms_Midline',;
                   'C5_Epidural_10_kHz_Monophasic_1_ms_Midline',;
                   'C5_Epidural_Single_Biphasic_1_ms_Midline',;
                   'C5_Epidural_Single_Monophasic_1_ms_Midline'};
              
stim_type_list2 = {'C5_Spinous_Process_10_kHz_Biphasic_1_ms_Midline',;
                  'C5_Spinous_Process_10_kHz_Monophasic_1_ms_Midline',;
                  'C5_Spinous_Process_Single_Biphasic_1_ms_Midline',;
                  'C5_Spinous_Process_Single_Monophasic_1_ms_Midline'};

plot_title_list = {'10 kHz Biphasic',;
                   '10 kHz Monophasic',;
                   'Single Biphasic',;
                   'Single Monophasic'};

group_names = {'epidural', 'spinous_process'};
               
plot_group = {stim_type_list1, stim_type_list2};

for plot_group_idx = 1:length(plot_group)

    stim_type_list = plot_group{plot_group_idx};
    %stim_type_list = unique({data_struct.Stim_Type});
    figure('Position', [10 10 900 700])
    rat_idx = 1;
    plot_idx = 1;

    max_lines = 10;
    for stim_type = 1:length(stim_type_list)
        filtered_struct = data_struct(strcmp(all_stim, stim_type_list(stim_type)));
        subplot(2,2,plot_idx)
        hold on
        if isempty(filtered_struct(rat_idx).(muscle)) ~= 1

            z_data = filtered_struct(rat_idx).(muscle){1};
            num_stim = size(z_data,1);

            length_time = size(z_data,2); 
            real_time = repmat(linspace(0, 30, length_time), num_stim, 1);
            charge_data = repmat(filtered_struct(rat_idx).(muscle){2}',1,length_time);

            % plot3(charge_data(1:2:end,:)', real_time(1:2:end,:)', z_data(1:2:end,:)','LineWidth',2)
            plot3(charge_data(1:2:max_lines,:)', real_time(1:2:max_lines,:)', z_data(1:2:max_lines,:)','LineWidth',2)

            set(gca,'Ydir','reverse')
            view(280,20)
            title(plot_title_list{stim_type}, 'Interpreter','none')
        end

        plot_idx = plot_idx + 1;
        ylabel('Time (ms)')
        xlabel('Current (uA)');
        zlabel('EMG (V)')
        zlim([-10e-3, 12e-3])
        set(gca,'Ydir','reverse', 'FontSize', 18)
        view(300,30)

    saveas(gcf, ['raw_EMG', group_names{plot_group_idx},'_plot.svg'])
    end
end

        
        
       