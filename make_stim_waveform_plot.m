close all;
clear all;

x = 1:1000;
z = ones(1,250);
y = [z*0,z*-1,z*1,z*0];

spacer = [zeros(1,25),ones(1,25)];
spacer_bi = [ones(1,25)*-1,ones(1,25)];
filter = repmat(spacer,1,10);

old_10k = [zeros(1,250), repmat(spacer_bi,1,10),zeros(1,250)];

new_10k = y;
new_10k(251:750) = new_10k(251:750) .* filter;

%Set evenly spaced segments to zero with filter to make 10k
mono_single_half = [zeros(1,250),ones(1,250)*-1, zeros(1,500)];
mono_single = [zeros(1,250),ones(1,500)*-1, zeros(1,250)];
mono_10k = mono_single;
mono_10k(251:750) = mono_single(251:750) .* filter;

figure
hold on

%Single Biphasic
plot(x, y + 1, 'LineWidth', 2)
%10k Biphasic
plot(x+1250 , old_10k + 1, 'LineWidth',2)

%Single Monophasic
plot(x, mono_single_half -1.2 , 'LineWidth', 2)
%10k Monophasic 
plot(x+1250, mono_10k -1.2 , 'LineWidth', 2)

%Line to indicate time
plot(251:750, ones(1,500)*2.3,'k', 'LineWidth' , 1.5)
text(425,2.5, '1 ms')

%Labels
text(75, 1.5, 'A','FontSize',14)
text(1325, 1.5, 'B','FontSize',14)
text(75, -0.7, 'C','FontSize',14)
text(1325, -0.7, 'D','FontSize',14)



xlim([-250, 2500])
ylim([-3 3])

axis off

saveas(gcf, 'stim_waveform_plot.svg')