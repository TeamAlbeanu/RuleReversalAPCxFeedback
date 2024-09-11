function all_zscore = zscore_20240817(stim_delivery,all_det)

    num_Frames = size(all_det,1);
    num_Roi    = size(all_det,2);
    num_Trials = size(all_det,3);
    
    all_zscore = NaN(num_Frames,num_Roi,num_Trials);
    
    for nTrial = 1:num_Trials
    
        for nRoi = 1:num_Roi
    
            current     = all_det(:,nRoi,nTrial);
            baseline    = current(stim_delivery(nTrial)-25:stim_delivery(nTrial));
    
            %% z-score
    
            mu1                         = mean(baseline,'omitnan');
            sd                          = std(baseline,0,'omitnan');
            all_zscore(:, nRoi, nTrial) = (current-mu1)/sd;
    
        end
    end
end