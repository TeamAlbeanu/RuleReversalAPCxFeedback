function responses = movement_correction_20240817(data_reg,num_files,ROI,num_roi,responses)

    % Trial by trial loop
    for nFile = 1:num_files
    
        filename    = data_reg(nFile).name;                                    % Get name trial  
        tiftag      = imfinfo(filename);                                       % Information trial t-stack
        num_images  = length(tiftag);                                          % Number of frames
    
        % Initialize the scan data image           
        scanDataImage = zeros(tiftag(1).Height,tiftag(1).Width,num_images,'uint16');
        
        % Retrieve grayscale value from each pixel of the trial matrix
        for nImage = 1:num_images
    
            scanDataImage(:,:,nImage) = imread(filename,nImage);               
        end
        
        % Average value of all pixels across frames
        image_mean  = mean(scanDataImage,3);                                   
        
        % Calculate the reference average vectors for each ROI        
    
        % norm_ref = zeros(num_roi);
    
        for nRoi = 1:num_roi
            
            % Get ROI coordinates
            x1  = ROI.roicoordinate(nRoi,1);
            y1  = ROI.roicoordinate(nRoi,2);
            x2  = ROI.roicoordinate(nRoi,3);
            y2  = ROI.roicoordinate(nRoi,4);
            
            % Test values to check if ROI coordinates are in range        
            x1_test = (x1 > 0) & (x1 < (tiftag(1).Height+1));
            x2_test = (x2 > 0) & (x2 < (tiftag(1).Height+1));
            y1_test = (y1 > 0) & (y1 < (tiftag(1).Width +1));
            y2_test = (y2 > 0) & (y2 < (tiftag(1).Width +1));
            
            % Identify ROIs out of range
            if x1_test && x2_test && y1_test && y2_test
    
                as_matrix           = image_mean(x1:x2,y1:y2);                 % mask single ROI
                reference_vector    = reshape(as_matrix,(x2-x1+1)*(y2-y1+1),1);
                u                   = reference_vector-mean(reference_vector);
                a                   = u/sqrt(dot(u,u));
                norm_ref{nRoi}      = a;
            else
    
                norm_ref{nRoi} = NaN;
            end
        end
    
        % Extract reference average fluorescence for each ROI and eliminate
        % ROIs out of range
    
        dot_product_matrix = zeros(num_images,num_roi);
    
        for nImage = 1:num_images
    
            f = double((scanDataImage(:,:,nImage)));
    
            for nRoi = 1:num_roi
    
                if ~isnan(norm_ref{nRoi})
                    
                    % Get ROI coordinates
                    x1  = ROI.roicoordinate(nRoi,1);
                    y1  = ROI.roicoordinate(nRoi,2);
                    x2  = ROI.roicoordinate(nRoi,3);
                    y2  = ROI.roicoordinate(nRoi,4);
    
                    as_matrix           = f(x1:x2,y1:y2);                      % mask single ROI mask.
                    reference_vector    = reshape(as_matrix,(x2-x1+1)*(y2-y1+1),1);
                    u                   = reference_vector - mean(reference_vector);
                    a                   = u/sqrt(dot(u,u));
                    product             = (norm_ref{nRoi})'*a;
    
                    dot_product_matrix(nImage,nRoi) = product;
                else
                    dot_product_matrix(nImage,nRoi) = NaN;
                end
            end
        end
        
        % Get reference matrix z-score
        responses.movement_correction.traces(:,:,nFile)     = dot_product_matrix;
        responses.movement_correction.medians(:,nFile)      = median(responses.movement_correction.traces(:,:,nFile),2,'omitnan');
        responses.movement_correction.zscore (:,nFile)      = zscore(responses.movement_correction.medians(:,nFile));
    end
    
    % Identify frames with movement aboce threshold
    responses.movement_correction.threshold = -1.5;
    
    movement_threshold = responses.movement_correction.zscore < responses.movement_correction.threshold;
    responses.movement_correction.thresholded = double(movement_threshold);
    responses.movement_correction.thresholded(responses.movement_correction.thresholded == 1) = NaN;
    responses.movement_correction.thresholded(responses.movement_correction.thresholded == 0) = 1;
end