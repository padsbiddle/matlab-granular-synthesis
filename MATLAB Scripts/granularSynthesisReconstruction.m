% =====================================================================
% GRANULAR SYNTHESIS - Stage 3: Reconstruct and Verify
% Reassembles the grains in original order and writes the output WAV
% Compares the reconstructed audio to the original to prove the
% chopping and reassembly process is lossless
% =====================================================================

clear; clc;

% *********************************************************************
% INPUT 1: Audio filename
% *********************************************************************
input_wav = input('Enter audio filename (e.g. input.wav): ', 's');

% *********************************************************************
% INPUT 2: Grain size in milliseconds
% *********************************************************************
grain_ms = input('Enter grain size in milliseconds (e.g. 100): ');

% *********************************************************************
% INPUT 3: Output filename
% *********************************************************************
output_wav = input('Enter output filename (e.g. output.wav): ', 's');

% *********************************************************************
% LOAD WAV FILE
% *********************************************************************
[audio, fs] = audioread(input_wav);
audio = audio(:,1);

fprintf('\n--- File loaded ---\n');
fprintf('File          : %s\n', input_wav);
fprintf('Sample rate   : %d Hz\n', fs);
fprintf('Total samples : %d\n', length(audio));
fprintf('Duration      : %.2f seconds\n', length(audio) / fs);

% *********************************************************************
% CALCULATE GRAIN SIZE IN SAMPLES
% *********************************************************************
grain_samples = round((grain_ms / 1000) * fs);

% *********************************************************************
% CALCULATE GRAIN PARAMETERS
% *********************************************************************
num_grains = floor(length(audio) / grain_samples);
rem_grains = length(audio) - (num_grains * grain_samples);

fprintf('\n--- Grain info ---\n');
fprintf('Grain size    : %d ms\n', grain_ms);
fprintf('Grain samples : %d samples\n', grain_samples);
fprintf('Grains created: %d\n', num_grains);
fprintf('Tail samples  : %d (ignored)\n', rem_grains);

% *********************************************************************
% CHOP INTO GRAINS
% *********************************************************************
grains = cell(num_grains, 1);

for i = 1:num_grains
    start_sample = (i - 1) * grain_samples + 1;
    end_sample   = start_sample + grain_samples - 1;
    grains{i}    = audio(start_sample:end_sample);
end

fprintf('\nChopping complete. %d grains stored in cell array.\n', num_grains);

% *********************************************************************
% RECONSTRUCTION OF ORIGINAL WAV FILE:
% cell2mat() converts the cell array back into a single vector
% by stacking each grain end to end in order.
% This is the reverse of the chopping process.
% The result should be identical to the original audio
% (minus the tail samples which were ignored during chopping)
% *********************************************************************
reconstructed = cell2mat(grains);

fprintf('\n--- Reconstruction ---\n');
fprintf('Reconstructed samples: %d\n', length(reconstructed));

% *********************************************************************
% VERIFY:
% Compare the reconstructed audio to the original sample by sample.
% We only compare up to the length of the reconstructed audio
% because the tail samples were dropped during chopping.
%
% max() finds the largest value in a vector
% abs() takes the absolute value (removes negative sign)
% so max(abs(...)) finds the largest difference between any two samples
%
% If the process is truly lossless this value should be 0
% or very close to 0 (floating point rounding may cause tiny differences)
% *********************************************************************
original_trimmed = audio(1:length(reconstructed));
% trim the original to the same length as reconstructed
% so we are comparing the same number of samples

max_difference = max(abs(original_trimmed - reconstructed));
% subtract reconstructed from original sample by sample
% take absolute value so negative differences dont cancel positive ones
% find the largest difference

fprintf('\n--- Verification ---\n');
fprintf('Max sample difference: %e\n', max_difference);
% %e prints the value in scientific notation e.g. 0.00 or 2.33e-10

if max_difference == 0
    fprintf('PERFECT RECONSTRUCTION - output is identical to input.\n');
elseif max_difference < 1e-10
    fprintf('NEAR PERFECT - difference is floating point rounding only.\n');
else
    fprintf('WARNING - significant difference detected.\n');
end

% *********************************************************************
% WRITE OUTPUT WAV FILE
% audiowrite() saves the reconstructed audio as a WAV file
% arguments: filename, audio data, sample rate
% *********************************************************************
audiowrite(output_wav, reconstructed, fs);
fprintf('\nOutput saved: %s\n', output_wav);

% *********************************************************************
% PLOT:
% Three subplots stacked vertically:
%   1. Original waveform
%   2. Reconstructed waveform
%   3. Difference between the two (should be flat at zero)
% *********************************************************************
t_orig  = (0:length(audio)-1) / fs; % time vector for original
t_recon = (0:length(reconstructed)-1) / fs; % time vector for reconstructed
t_diff  = (0:length(original_trimmed)-1) / fs; % time vector for trimmed

figure(1);

    subplot(3,1,1);
    plot(t_orig, audio, 'Color', [0 0 0]);
    grid on;
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(sprintf('Original  |  %d samples', length(audio)));

    subplot(3,1,2);
    plot(t_recon, reconstructed, 'Color', [0.188 0.522 0.200]);
    grid on;
    xlabel('Time (seconds)');
    ylabel('Amplitude');
    title(sprintf('Reconstructed  |  %d samples', length(reconstructed)));

    subplot(3,1,3);
    plot(t_diff, original_trimmed - reconstructed, 'Color', [0.8 0.2 0.2]);
    grid on;
    xlabel('Time (seconds)');
    ylabel('Difference');
    title(sprintf('Difference  |  Max difference: %e', max_difference));

