function [aligned_raw,aligned_det,aligned_zscore] = align_20240817(stim_delivery,responses)
    
    all_raw     = responses.raw;
    all_det     = responses.detrended;
    all_zscore  = responses.zscore;
    
    % Get maximum difference of frames between trials
    stim_delivery_max = max(stim_delivery);
    stim_delivery_min = min(stim_delivery);
    stim_delivery_dif = stim_delivery_max-stim_delivery_min;
    
    % Define maximum frames for matrix after alignment
    frame_adjustment  = size(all_zscore,1)+stim_delivery_dif;
    
    % Pre-define variables for loop
    aligned_raw     = NaN(frame_adjustment,size(all_raw   ,2),size(all_raw   ,3));
    aligned_det     = NaN(frame_adjustment,size(all_det   ,2),size(all_det   ,3));
    aligned_zscore  = NaN(frame_adjustment,size(all_zscore,2),size(all_zscore,3));
    
    % Align frames to cue delivery for each trial
    for nTrial = 1:size(all_det,3)
    
        dev     = stim_delivery(nTrial);
        start   = 56 - dev;
        end_i   = start + 99;
        
        aligned_raw(start:end_i,:,nTrial)    =   all_raw(:,:,nTrial);
        aligned_det(start:end_i,:,nTrial)    =   all_det(:,:,nTrial);    
        aligned_zscore(start:end_i,:,nTrial) =   all_zscore(:,:,nTrial);
    end
end  