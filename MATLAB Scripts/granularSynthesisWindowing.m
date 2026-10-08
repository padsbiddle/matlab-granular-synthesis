% =====================================================================
% granularSynthesisWindowing.m
% Applies a window function to each grain in the cell array.
% Windowing fades each grain in and out smoothly to remove
% clicks and discontinuities at grain boundaries.
%
% INPUTS:
%   grains       - cell array of audio grains
%   grain_samples- number of samples per grain
%   window_type  - 1=none, 2=hann, 3=hamming, 4=tukey
%   tukey_alpha  - alpha value for Tukey window (only used if type=4)
%
% OUTPUTS:
%   grains_windowed - cell array of windowed grains
% =====================================================================

function grains_windowed = granularSynthesisWindowing(grains, grain_samples, window_type, tukey_alpha)

num_grains = length(grains);
% length() returns the number of cells in the grains cell array
% same as the number of grains created in granularSynthesisChop.m


% *********************************************************************
% GENERATE WINDOW CURVE
% Each window type produces a different shaped curve.
% The curve is the same length as the grain so every sample
% has a corresponding window value to multiply by.
% *********************************************************************
switch window_type
    % switch and case are an alternative to a chain of if/else statments -
    % easier to read 
    % using built in MATLAB operations to generate windows ( hann(),
    % hamming(), tukeywin(), [ones() - multiplies each sample by 1, same as a rectangular window (no window) ])
    case 1
        % no window - multiply by 1 (no change)
        w = ones(grain_samples, 1);
        fprintf('Window: None (rectangular)\n');

    case 2
        % A Hann window is a curve that starts at 0, rises to 1 in the middle
        % and falls back to 0 at the end. Multiplying a grain by this curve
        % fades the grain in and out smoothly.
        %
        % hann(N) generates a Hann window of length N
        % The window is the same length as the grain so every sample
        % in the grain has a corresponding window value to multiply by
        %
        % Without windowing, grains can start and end abruptly causing
        % clicks and discontinuities in the output audio.
        % Windowing removes these clicks by smoothing the edges of each grain.
        w = hann(grain_samples);
        fprintf('Window: Hann\n');

    case 3
        % Hamming window - similar to Hann but does not reach 0
        % at the edges, slightly better frequency resolution
        w = hamming(grain_samples);
        fprintf('Window: Hamming\n');

    case 4
        % Tukey window - flat in the middle with cosine tapers
        % at each end. Alpha controls how much is tapered vs flat.
        % alpha = 0 → rectangular, alpha = 1 → Hann
        w = tukeywin(grain_samples, tukey_alpha);
        fprintf('Window: Tukey (alpha = %.2f)\n', tukey_alpha);

    otherwise % same as else
        w = ones(grain_samples, 1);
        fprintf('Unknown window type - using rectangular.\n');
end

% *********************************************************************
% APPLY WINDOW TO EACH GRAIN
% .* multiplies each sample in the grain by the corresponding
% value in the window curve - element wise multiplication
% *********************************************************************
grains_windowed = cell(num_grains, 1);
% new empty cell array to store the windowed grains
% original grains cell array is left unchanged
% keeping the originals means they can be passed to reconstruction proof separately

for i = 1:num_grains
    grains_windowed{i} = grains{i} .* w;
    % each sample scaled by its corresponding window value
    % edge samples multiplied by values near 0 = fade in/out
    % centre samples multiplied by values near 1 = full volume
end

fprintf('Window applied to %d grains.\n\n', num_grains);

end