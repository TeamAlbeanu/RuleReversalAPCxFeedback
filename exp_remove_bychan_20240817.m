function [rm, gof] = exp_remove_bychan_20240817(all_ROIrej, earliest_stim)
    
    rm = all_ROIrej;
    
    % max norm
    abs_max = max(max(max(rm)));
    rm      = rm / abs_max;
    
    % compute average ROI trace
    avg_activation = mean(rm, 3, 'omitnan');
    
    % select baseline
    avg_base = avg_activation(1 : earliest_stim, :);
    ind      = (1 : earliest_stim)';
    
    % Set up fittype and options.
    
    neg_exp = fittype( 'a*exp(-b*x)+c-d*log(x)', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.DiffMaxChange = 0.01;
    opts.Display = 'Off';
    opts.Lower = [0 0 0 0];
    opts.MaxFunEvals = 6000;
    opts.MaxIter = 40000;
    opts.StartPoint = [0 1 1 1];
    all_gof         = 0;
    
    for roi = 1 : size(rm, 2)
        
        current = avg_base(:, roi);
        
        % compute fit
        exp_fit        = fit(ind, current, neg_exp, opts);
        
        % remove fitted curve from each trial/ROI
        to_remove = (1:100)';
        to_remove = exp_fit(to_remove);
        gof       = corrcoef(to_remove, avg_activation(:, roi));
        gof       = gof(1,2);
        all_gof = all_gof + gof;
        
        for trial = 1 : size(rm, 3)
            current = rm(:, roi, trial);
            rm(:,roi,trial) = current - to_remove;
        end
    end
    
    gof = (all_gof / roi) ^ 2;
    rm = rm * abs_max;
end 