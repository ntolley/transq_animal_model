close all;
clear all;

load('TransQ_Raw_EMG_v1')
muscle_list = {'Carpi_Radialis', 'Bicep', 'Digitorum_Profundus', 'Deltoid', 'Tricep', 'Wrist_Extensor', 'Acromiotrapezius'};


all_stim = {};
for stim_set = 1:length(data_struct)
    stim_type_string = [data_struct(stim_set).Position,'_',data_struct(stim_set).Depth,'_',...
        data_struct(stim_set).Stim_Freq,'_',data_struct(stim_set).Stim_Waveform,'_',...
        data_struct(stim_set).Duration,'_',data_struct(stim_set).Lateral_Position];
    
    data_struct(stim_set).Stim_Type = stim_type_string;
    all_stim{end+1} = stim_type_string;
end

stim_type_list = unique({data_struct.Stim_Type});

muscle = 'Bicep';
rat_idx = 1;
figure('Position', [10 10 900 700])
plot_idx = 1;

stim_type_list = {'C5_Epidural_10_kHz_Biphasic_1_ms_Midline',;
                  'C5_Epidural_10_kHz_Monophasic_1_ms_Midline',;
                  'C5_Epidural_Single_Biphasic_1_ms_Midline',;
                  'C5_Epidural_Single_Monophasic_1_ms_Midline'};

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

        plot3(charge_data(1:2:end,:)', real_time(1:2:end,:)', z_data(1:2:end,:)','LineWidth',2)

        set(gca,'Ydir','reverse')
        view(280,20)
        title(filtered_struct(rat_idx).Stim_Type,'Interpreter','none')
    end
    
    plot_idx = plot_idx + 1;
    ylabel('Time (ms)')
    xlabel('Current (uA)');
    zlabel('EMG (V)')
    set(gca,'Ydir','reverse')
    view(300,30)
    
    saveas(gcf, 'raw_EMG_plot.png')
end

        
        
       