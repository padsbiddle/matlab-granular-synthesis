% =====================================================================
% granularSynthesisTransformations.m
% Applies all selected transformations to the windowed grains.
% Each transformation produces an output vector which is collected
% into the outputs cell array along with a label for plotting.
%
% INPUTS: from other .m scripts
%   grains       - cell array of windowed grains
%   num_grains   - number of grains
%   grain_samples- samples per grain
%   fs           - sample rate
%   run_reverse  - 1 if reverse is selected
%   run_shuffle  - 1 if shuffle is selected
%   run_repeat   - 1 if repeat is selected
%   repeat_n     - number of repeats per grain
%   run_skip     - 1 if skip is selected
%   skip_n       - skip every Nth grain
%   skip_mode    - 0 = silence, 1 = remove
%   run_sort_amp - 1 if sort by amplitude is selected
%
% OUTPUTS: to other .m scripts
%   outputs  - cell array of output audio vectors
%   labels   - cell array of strings describing each output
% =====================================================================

function [outputs, labels] = granularSynthesisTransformations(grains, num_grains, grain_samples, ...
    run_reverse, ...
    run_shuffle, ...
    run_repeat,  repeat_n, ...
    run_skip,    skip_n, skip_mode, ...
    run_sort_amp)

    outputs = {};
    % empty cell array to collect output vectors
    % grows as each transformation is added

    labels = {};
    % empty cell array to collect labels for each output
    % used by plot_output to title each subplot

    % *********************************************************************
    % TRANSFORMATION 1: REVERSE
    % Each grain is reversed using y(n) = x(NRX - n + 1)
    % *********************************************************************
    if run_reverse
        grains_reversed = cell(num_grains, 1);

        for i = 1:num_grains
            grain = grains{i};
            NRX   = length(grain);
            reversed = zeros(NRX, 1);
            for n = 1:NRX
                reversed(n) = grain(NRX - n + 1);
                % maps last sample to first position, first to last
            end
            grains_reversed{i} = reversed;
        end

        outputs{end+1} = cell2mat(grains_reversed);
        labels{end+1}  = 'Reversed grains';
        fprintf('Reverse transformation complete.\n');
    end

    % *********************************************************************
    % TRANSFORMATION 2: SHUFFLE
    % Grains are reordered randomly using randperm()
    % shuffle_order is stored for reversibility
    % *********************************************************************
    if run_shuffle
        shuffle_order   = randperm(num_grains);
        % randperm generates a random ordering of 1 to num_grains
        % no number appears twice - every grain used exactly once
        grains_shuffled = grains(shuffle_order);
        % reindex the cell array using the random order - no loop needed

        outputs{end+1} = cell2mat(grains_shuffled);
        labels{end+1}  = 'Shuffled grains';
        fprintf('Shuffle transformation complete.\n');
    end

    % *********************************************************************
    % TRANSFORMATION 3: REPEAT
    % Each grain is copied repeat_n times consecutively
    % Output is repeat_n times longer than the original
    % *********************************************************************
    if run_repeat
        grains_repeated = cell(num_grains * repeat_n, 1);
        output_index = 1;

        for i = 1:num_grains
            for r = 1:repeat_n
                % outer loop steps through each grain
                % inner loop copies that grain repeat_n times before moving to next
                grains_repeated{output_index} = grains{i};
                output_index = output_index + 1;
                % output_index tracks position in grains_repeated
            end
        end

        outputs{end+1} = cell2mat(grains_repeated); % end+1 appends to the end of the output cell
        labels{end+1}  = sprintf('Repeated grains (N=%d)', repeat_n);
        fprintf('Repeat transformation complete.\n');
    end

    % *********************************************************************
    % TRANSFORMATION 4: SKIP
    % Every Nth grain is either replaced with silence or removed.
    % mod(i, skip_n) == 0 identifies the grains to skip.
    % skip_mode: 0 = silence, 1 = remove
    % *********************************************************************
    if run_skip
        if skip_mode == 0
            % MODE: replace with silence
            grains_skip = cell(num_grains, 1);
            skipped = 0;

            for i = 1:num_grains
                if mod(i, skip_n) == 0
                    grains_skip{i} = zeros(grain_samples, 1);
                    skipped = skipped + 1;
                else
                    grains_skip{i} = grains{i};
                end
            end

            outputs{end+1} = cell2mat(grains_skip);
            labels{end+1}  = sprintf('Skip silence (every %d)', skip_n);
            fprintf('Skip (silence) complete. %d grains silenced.\n', skipped);

        else
            % MODE: remove entirely
            kept_count   = num_grains - floor(num_grains / skip_n);
            grains_skip  = cell(kept_count, 1);
            output_index = 1;
            skipped      = 0;

            for i = 1:num_grains
                if mod(i, skip_n) == 0
                    skipped = skipped + 1;
                else
                    grains_skip{output_index} = grains{i};
                    output_index = output_index + 1;
                end
            end

            outputs{end+1} = cell2mat(grains_skip);
            labels{end+1}  = sprintf('Skip remove (every %d)', skip_n);
            fprintf('Skip (remove) complete. %d grains removed.\n', skipped);
        end
    end

    % *********************************************************************
    % TRANSFORMATION 5: SORT BY AMPLITUDE
    % RMS amplitude calculated for each grain.
    % Grains sorted from quietest to loudest and loudest to quietest.
    % sort_index stored for reversibility.
    % *********************************************************************
    if run_sort_amp
        % calculate RMS for each grain
        rms_values = zeros(num_grains, 1);
        for i = 1:num_grains
            rms_values(i) = sqrt(mean(grains{i} .^ 2));
        end

        % sort ascending - quietest to loudest
        [~, sort_index] = sort(rms_values, 'ascend');
        % ~ discards the sorted rms values - only the index is needed
        % sort_index records which grain was originally at each position
        % allowing the sort to be reversed later

        grains_quiet_loud = grains(sort_index);
        grains_loud_quiet = grains(flip(sort_index));
        % flip() reverses sort_index giving descending order for free
        % no second sort needed

        outputs{end+1} = cell2mat(grains_quiet_loud);
        labels{end+1}  = 'Sort: quiet to loud';

        outputs{end+1} = cell2mat(grains_loud_quiet);
        labels{end+1}  = 'Sort: loud to quiet';

        fprintf('Sort by amplitude complete.\n');
    end

    fprintf('\n%d transformation(s) completed.\n\n', length(outputs));

end