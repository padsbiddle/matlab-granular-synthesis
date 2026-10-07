% =====================================================================
% granularSynthesisChop.m
% Loads a WAV file, applies region selection if requested,
% and chops the audio into a cell array of grains.
%
% INPUTS: Taking data from other .m scripts 
%   input_wav    - filename of the WAV file
%   grain_ms     - grain size in milliseconds
%   use_region   - 1 if region selection is active, 0 for full file
%   start_sec    - region start time in seconds
%   end_sec      - region end time in seconds
%
% OUTPUTS: passing data from other .m scripts
%   grains       - cell array of audio grains
%   fs           - sample rate
%   num_grains   - number of grains
%   grain_samples- number of samples per grain
% =====================================================================

function [grains, audio, fs, num_grains, grain_samples] = granularSynthesisChop(input_wav, grain_ms, use_region, start_sec, end_sec)

% *********************************************************************
% LOAD WAV FILE: 

% audio - pulls sample values from the WAV file (values between -1 and 1)
% fs    - Reads and pulls the sample rate e.g. 44100 samples per second
%
% audio(:,1) takes only the left channel if the file is stereo - this is
% for simplicity. the ':' means all rows, 1 takes only 1 column (left channel)
% *********************************************************************
[audio, fs] = audioread(input_wav);
audio = audio(:,1);
% take left channel only for simplicity

fprintf('--- File loaded ---\n');
fprintf('File          : %s\n', input_wav);
fprintf('Sample rate   : %d Hz\n', fs);
fprintf('Total samples : %d\n', length(audio));
fprintf('Duration      : %.2f seconds\n', length(audio) / fs);

% *********************************************************************
% REGION SELECTION
% If use_region is selected, trim audio to the selected range.
% Validate that the range is within the file duration.
% *********************************************************************
if use_region
    file_duration = length(audio) / fs;

    if start_sec < 0 || end_sec > file_duration || start_sec >= end_sec
        % start_sec < 0        - start time is before the file begins
        % end_sec > file_duration - end time is beyond the file length
        % start_sec >= end_sec - start is after or equal to end
        fprintf('Invalid region - using full file.\n');
    else
        audio = audio(round(start_sec * fs):round(end_sec * fs));
        fprintf('Region applied: %.2f to %.2f seconds\n', start_sec, end_sec);
        fprintf('Region samples: %d\n', length(audio));
    end
end

% *********************************************************************
% CALCULATE GRAIN SIZE IN SAMPLES: 
% Converts the user entered millisecond value to sample values 

% formula: samples = (milliseconds / 1000) * sample_rate
% round() to ensure a whole number value as samples cant be fraction values
% round() will round UP AND /OR DOWN 
% *********************************************************************
grain_samples = round((grain_ms / 1000) * fs);

% *********************************************************************
% CALCULTE GRAIN PARAMETERS:
% number of grains = length of audio / num samples per grain
% formula computes number of grains created for the input audio file
% floor() rounds DOWN ONLY to the nearest whole number

% remainder grains = length of audio - (num of grains * samples per grain)
% Works out any leftover samples at the end that dont fill a full grain
% printed as ignored for now
% *********************************************************************
num_grains = floor(length(audio) / grain_samples);
rem_grains = length(audio) - (num_grains * grain_samples);

fprintf('\n--- Grain info ---\n');
fprintf('Grain size    : %d ms\n', grain_ms);
fprintf('Grain samples : %d samples\n', grain_samples);
fprintf('Grains created: %d\n', num_grains);
fprintf('Tail samples  : %d (ignored)\n', rem_grains);

% *********************************************************************
% CELL ARRAY TO CONTAIN THE GRAINS:
% grains is a cell array, each grain is a chunk of audio
% samples, stored as one item in the cell array.
%
% cell(num_grains, 1) creates an empty cell array with ammount of rows defined by 
% num_grains. ', 1' means 1 column
% *********************************************************************
grains = cell(num_grains, 1);
% creates an empty cell array with num_grains rows and 1 column
% each cell will be filled with one grain by the loop below

% loop through each grain position, extract the samples and store
for i = 1:num_grains % 1 up to the length of num_grains

    % calculate the start and end sample index for this grain

    start_sample = (i - 1) * grain_samples + 1;
    % start_sample moves forward by one grain length each iteration
    % (i-1) ensures grain 1 starts at sample 1, not sample 0
    % +1 means start of grain n+1 does not overlap with the end of grain n
    % ie if end of grain 1 is 5424, grain 2 starts on 5424 + 1 = 5425

    end_sample   = start_sample + grain_samples - 1;
    % end_sample is always exactly one grain length ahead of start_sample
    % -1 prevents overlap with the start of the next grain
    % 5425 + 5424 = 10849 - 1 = 10848 

    % extract the samples and store in the cell array
    grains{i}    = audio(start_sample:end_sample);
    % takes the samples in variable audio from value start_sample to end_sample 
    % and adds to grains at cell position i

end

fprintf('Chopping complete. %d grains stored in cell array.\n\n', num_grains);

end