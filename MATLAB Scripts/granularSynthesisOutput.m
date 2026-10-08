% =====================================================================
% granularSynthesisOutput.m
% Concatenates original and all transformation outputs with silence
% gaps, writes to a single WAV file, and plots all results in one
% figure with one subplot per section.
%
% INPUTS:
%   grains_windowed - cell array of windowed grains (original)
%   audio           - raw original audio vector (no window applied)
%   outputs         - cell array of transformation output vectors
%   labels          - cell array of labels for each transformation
%   fs              - sample rate
%   pause_sec       - silence gap between sections in seconds
%   output_wav      - output filename
%   num_grains      - number of grains
%   grain_ms        - grain size in milliseconds
%   window_type  - 1=none, 2=hann, 3=hamming, 4=tukey
% =====================================================================

function granularSynthesisOutput(grains_windowed, audio, outputs, labels, fs, pause_sec, output_wav, num_grains, grain_ms, window_type)

% *********************************************************************
% WINDOW NAME
% Used in plot titles so each subplot is self documenting
% *********************************************************************
window_names = {'None', 'Hann', 'Hamming', 'Tukey'};
window_label = window_names{window_type};

% *********************************************************************
% REASSEMBLE SECTIONS
% output_original_raw      - audio trimmed to same length as grains
%                            no windowing applied
% output_original_windowed - grains reassembled after windowing
% *********************************************************************
output_original_windowed = cell2mat(grains_windowed);
% cell2mat stacks all windowed grains end to end
 
output_original_raw = audio(1:length(output_original_windowed));
% trim raw audio to same length as windowed version
% tail samples were dropped during chopping so lengths must match
% *********************************************************************
% SILENCE GAP
% zeros() creates a vector of silence between sections
% round() ensures a whole number of samples
% *********************************************************************
silence = zeros(round(pause_sec * fs), 1);

% *********************************************************************
% CONCATENATE ALL SECTIONS
% Order: raw original, silence, windowed original, silence,
% then each transformation output with silence gaps between
% *********************************************************************
combined = [output_original_raw; silence; output_original_windowed];
% start with raw then windowed original

for i = 1:length(outputs)
    combined = [combined; silence; outputs{i}];
    % append silence gap then transformation output
    % each iteration adds the next selected transformation
    % semicolon inside brackets stacks vectors vertically
end

% *********************************************************************
% WRITE OUTPUT WAV FILE
% *********************************************************************
audiowrite(output_wav, combined, fs);
fprintf('Output saved: %s\n', output_wav);
fprintf('Total duration: %.2f seconds\n\n', length(combined) / fs);
 

% *********************************************************************
% PLOT
% One subplot per section stacked vertically in one figure.
% Total subplots = 2 (raw + windowed original) + transformations
% *********************************************************************
% build the full list of sections and labels

num_plots = 2 + length(outputs);
% total number of subplots needed

% build the full list of sections and labels
all_sections = [{output_original_raw}, {output_original_windowed}, outputs];
% {} wraps each vector as a cell so they can join the outputs cell array

all_labels = [{'Original (no window)'}, {sprintf('Original (%s window)', window_label)}, labels];
% labels for raw original, windowed original, then each transformation

% define colours for each subplot
% one colour per section, cycles if more sections than colours
colours = [
        % each row is an RGB value between 0 and 1
        % format: [red, green, blue]
        0.0   0.0   0.0;    % black      - raw original
        0.2   0.4   0.8;    % blue       - windowed original
        0.188 0.522 0.200;  % dark green - transformation 1
        0.851 0.361 0.239;  % terracotta - transformation 2
        0.6   0.2   0.6;    % purple     - transformation 3
        0.8   0.7   0.0;    % gold       - transformation 4
        0.2   0.7   0.7;    % teal       - transformation 5
        0.7   0.2   0.2;    % dark red   - transformation 6
    ];

% num_plots is calculated dynamically based on how many
% transformations the user selected - the figure automatically
% adjusts to show the correct number of subplots without
% any manual changes to the code
figure(1);

for i = 1:num_plots
    t = (0:length(all_sections{i})-1) / fs;
    % time axis in seconds for this section
 
    colour_index = mod(i-1, size(colours,1)) + 1;
    % cycles through colour list if more plots than colours defined
 
    subplot(num_plots, 1, i);
    % num_plots rows, 1 column, position i
    % creates one tall figure with all waveforms stacked vertically
    plot(t, all_sections{i}, 'Color', colours(colour_index, :));
    grid on;
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(sprintf('%s  |  %d grains  |  %d ms', ...
        all_labels{i}, num_grains, grain_ms));
end

drawnow;

end