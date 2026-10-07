% =====================================================================
% granularSynthesisMain.m
% Entry point for the granular synthesis program.
% Collects all user inputs and calls each module in sequence.
% =====================================================================

clear; clc;

% =====================================================================
% USER INPUTS
% =====================================================================

% *********************************************************************
% INPUT 1: Audio filename
% INPUT 1: User enters the name of the WAV file to be processed. 
% Input() accepting user input in the command line 's' formats to treat
% input as a string
% *********************************************************************
input_wav = input('Enter audio filename (e.g. input.wav): ', 's');

% *********************************************************************
% INPUT 2: Grain size in milliseconds
% INPUT 2: Use enters grain size in milliseconds
% Input() does not need the 's' format as a number is expected
% The user types the desired grain size and presses Enter.
% *********************************************************************
grain_ms = input('Enter grain size in milliseconds (e.g. 100): ');

% *********************************************************************
% INPUT 3: Region selector
% Allows the user to select a specific section of the audio file
% to apply transformations to rather than the full file
% This mirrors the functionality of Ableton's Granulator III
% *********************************************************************
use_region = strcmpi(input('\nSelect a region of the audio? (y/n): ', 's'), 'y');

start_sec = 0; % setting default values 
end_sec   = 0;

if use_region
    start_sec = input('  Enter start time in seconds: ');
    end_sec   = input('  Enter end time in seconds: ');
end

% *********************************************************************
% INPUT 4a: Windowing type
% A list of available windowing formats is displayed
% User picks from this numbered list.

% fprintf allows you to mix text and
% numbers, similar to python's f string 

% /n is newline same as python 
% *********************************************************************
fprintf('\nWindow types:\n');
fprintf('  1 = None (rectangular)\n');
fprintf('  2 = Hann\n');
fprintf('  3 = Hamming\n');
fprintf('  4 = Tukey\n');

window_type = input('Select window type (1-4): ');

% *********************************************************************
% INPUT 4b: Tukey alpha - only appears if Tukey window is selected
% Skipped if Tukey window was not selected
% The if statement checks the value of window_type.

% Tukey alpha determines the slope of the start and end fade
% 0 = no fade (same as rectangular window)
% 0.5 = 25% fade in 50% flat 25% fade out
% 1 = fade in to centre and immediately fade out (same as Hann window)
% *********************************************************************
tukey_alpha = 0.5;          % sets a default value for Tukey, default value needs to 
                            % be present for program to run 

if window_type == 4
    tukey_alpha = input('Enter Tukey alpha (0=rectangular, 1=hann, try 0.5): ');
end

% *********************************************************************
% INPUT 5: User enters the pause in seconds between each transformation
% result that is processed and and added to the final output WAV.
% *********************************************************************
pause_sec = input('\nEnter silence gap between sections in seconds (e.g. 1.5): ');

% *********************************************************************
% INPUT 6: User selects which transformations to run by entering y/n
% strcmpi() compares 'y' that has been added to the function [strcmpi('y')]
% if the user enters y it matches strcmpi and the value 1 is stored in run_reverse etc. 
% strcmpi() returns 0 if they dont match.
% *********************************************************************
fprintf('\n--- Select transformations (y/n) ---\n');

run_reverse  = strcmpi(input('Reverse each grain?         ', 's'), 'y');
run_shuffle  = strcmpi(input('Shuffle grain order?        ', 's'), 'y');

run_repeat   = strcmpi(input('Repeat each grain N times?  ', 's'), 'y');
% *********************************************************************
% INPUT 7: If repeat grain is selected, allows user input for the number of
% repeats 
% *********************************************************************
repeat_n = 1; % if y is entered, run repeat has value 1
if run_repeat
    while repeat_n < 2 || repeat_n > 100 % while loop starts on 0 so 1st condition is true (n<2)
        repeat_n = input('  How many times? (2-100): '); % if correct value entered, loop breaks 
        if repeat_n < 2 || repeat_n > 100 % if incorrect value entered, loop starts again 
            fprintf('  Invalid. Enter a number between 2 and 100.\n');
        end
    end
end

run_skip   = strcmpi(input('Skip every Nth grain?       ', 's'), 'y');
% *********************************************************************
% INPUT 8: Skip grain, allows skip value only if skip was selected
% *********************************************************************
skip_n    = 2; % default value if user selects n
skip_mode = 0;
if run_skip
    skip_n = 0; % reset to 0 if user selects y - allows the while loop to run 
    while skip_n < 2
        skip_n = input('  Skip every Nth grain (minimum 2): ');
        if skip_n < 2
            fprintf('  Invalid. N must be 2 or greater.\n');
        end
    end
    skip_mode = strcmpi(input('  Replace with silence or remove? (s/r): ', 's'), 'r');
end

run_sort_amp = strcmpi(input('Sort grains by amplitude?   ', 's'), 'y');

% *********************************************************************
% INPUT 9: User prompted to enter output filename
% *********************************************************************
output_wav = input('\nEnter output filename (e.g. output.wav): ', 's');

% =====================================================================
%  CONFIRM - print all values back to the user
%  fprintf() prints formatted text to the console.
%  \n is a newline. %s = string, %d = integer, %.2f = float
%  to 2 decimal places.
% =====================================================================
fprintf('\n========== SETTINGS CONFIRMED ==========\n');
fprintf('Audio file    : %s\n', input_wav); % the '%s' is replaced with the variable value if it is a string 
fprintf('Grain size    : %d ms\n', grain_ms); % the '%' is replaced with the variable value if it is an integer


if use_region
    fprintf('Region        : %.2f to %.2f seconds\n', start_sec, end_sec);
else
    fprintf('Region        : full file\n');
end

% Print the window name rather than just the number - the names are stored
% window_names is an array and window_names{window_type} uses the number
% stored in window_types to search the window_names array
window_names = {'None (rectangular)', 'Hann', 'Hamming', 'Tukey'};
fprintf('Window type   : %s\n', window_names{window_type});
if window_type == 4
    fprintf('Tukey alpha   : %.2f\n', tukey_alpha); % the '%f' is replaced with the variable value if it is a float
                                                    % the .2 restricts the float to 2 decimal places. 
end

fprintf('Silence gap   : %.1f seconds\n', pause_sec);
fprintf('\nTransformations:\n');
fprintf('  Reverse     : %s\n', yn(run_reverse)); % yn calls the YES/NO FUNCTION 
fprintf('  Shuffle     : %s\n', yn(run_shuffle)); % if run_reverse = 1 yn will equal yes
fprintf('  Repeat      : %s', yn(run_repeat));
    if run_repeat, fprintf('  (N = %d)', repeat_n); % if the value in run_repeat is 1, then repeat_n is printed on the same line
    end
    fprintf('\n'); % moves to the next line whether or not the if statement is triggered 

fprintf('  Skip        : %s', yn(run_skip));
    if run_skip, fprintf('  (every %d, mode = %s)', skip_n, skip_mode_str(skip_mode)); end
    fprintf('\n');
fprintf('  Sort amp    : %s\n', yn(run_sort_amp));
fprintf('Output file   : %s\n', output_wav);
fprintf('=========================================\n\n');

% *********************************************************************
% CALL MODULES: Calls other .m scripts
% *********************************************************************

% 1. chop grains - calls granularSynthesisChop.m
% returns grains cell array, raw audio, sample rate, num grains, grain size in samples
[grains, audio, fs, num_grains, grain_samples] = granularSynthesisChop(input_wav, grain_ms, use_region, start_sec, end_sec);

% 2. apply window - calls granularSynthesisWindowing.m
% takes raw grains, returns windowed grains
grains_windowed = granularSynthesisWindowing(grains, grain_samples, window_type, tukey_alpha);

% 3. run transformations - calls granularSynthesisTransformations.m
% takes windowed grains, returns output vectors and labels for each selected transformation
[outputs, labels] = granularSynthesisTransformations(grains_windowed, num_grains, grain_samples, ...
    run_reverse, ...
    run_shuffle, ...
    run_repeat,  repeat_n, ...
    run_skip,    skip_n, skip_mode, ...
    run_sort_amp);

% 4. reconstruction proof - disabled in main program
% run granularSynthesisReconstruction.m separately to verify reversibility 

% 5. build output WAV and plot - calls granularSynthesisOutput.m
granularSynthesisOutput(grains_windowed, audio, outputs, labels, fs, pause_sec, output_wav, num_grains, grain_ms, window_type);

% *********************************************************************
% YES/NO FUNCTION: converts 1/0 to 'yes'/'no' for display
% *********************************************************************
function str = yn(val)
    if val
        str = 'yes';
    else
        str = 'no';
    end
end

% *********************************************************************
% SKIP MODE FUNCTION: converts 1/0 to 'remove'/'silence' for display
% *********************************************************************
function str = skip_mode_str(val)
    if val
        str = 'remove';
    else
        str = 'silence';
    end
end