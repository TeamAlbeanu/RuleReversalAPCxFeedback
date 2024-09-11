function [image_masked] = trial_registration_20240816(image_ref,image_raw,reg_range)

    
    % Matrix size
    size_frames     = size(image_raw,3);                                   % Get number of frames
    size_x          = size(image_raw,1);                                   % Get x-axis pixel size
    size_y          = size(image_raw,2);                                   % Get y-axis pixel size  
    
    % Create empty matrices to be filled in the frame loop
    xy_coordinate   = zeros(size_frames,4);                                % matrix for x and y shift values
    image_masked    = zeros(size_x,size_y,size_frames);                    % reference image matrix           
    image_new       = zeros(size_x,size_y,size_frames);                    % registered image matrix

    for nFrames = 1:size_frames

        image_frame                 = image_raw(:,:,nFrames);              % Load frame   

        % Run registration between reference image and current frame
        [output,Greg]               = dftregistration(fft2(image_ref),fft2(image_frame),reg_range);

        image_new(:,:,nFrames)      = abs(ifft2(Greg));                    % Reverse fourier transformation to get registered image

        xy_coordinate(nFrames,:)    = output;                              % Fill with correction coordinates for each frame 

        % Create mask to fill registered edges
        mask                        = ones(size(image_frame,1), ...        % create mask matrix
                                           size(image_frame,2)); 
        xshift                      = abs(floor(output(3)));               % X axis shift value
        yshift                      = abs(floor(output(4)));               % Y axis shift value
        
        if  xshift > 0 && output(3) > 0

            mask(1:xshift,:)    = 0;
        elseif xshift > 0 && output(3) < 0

            mask(size(image_frame,1)-xshift+1: size(image_frame,1),:)   = 0;
        end

        if  yshift > 0 && output(4) > 0

            mask(:,1:yshift)    = 0;
        elseif yshift >0 && output(4) < 0

            mask(:,size(image_frame,2)-yshift+1: size(image_frame,2))   = 0;
        end
        
        % Mask edges of registered matrix
        image_masked(:,:,nFrames)    = mask.*image_new(:,:,nFrames);
    end
end