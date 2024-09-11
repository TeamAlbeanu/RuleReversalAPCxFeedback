function roi_data = data_extraction_20240817(roi_means,num_roi,num_files,responses)
    
    tmp_data    = zeros(100,num_roi,size(roi_means,2));
    roi_data    = zeros(100,num_roi,size(roi_means,2));
    
    % Trial by trial loop
    for nFile = 1:num_files
    
        tmp_data(:,:,nFile)     = roi_means{nFile};

        % Assign NaNs to frames with excesive motion artifacts
        roi_data(:,:,nFile)     = tmp_data(:,:,nFile).*responses.movement_correction.thresholded(:,nFile);
        roi_data(roi_data == 0) = NaN;
    end
end    